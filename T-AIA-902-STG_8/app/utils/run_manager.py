"""
run_manager.py – Structured run persistence for train/eval sessions.

Creates one directory per run under outputs/<run_id>/ and stores:
  - manifest.json
  - model/
  - plots/
  - console.txt
"""

from __future__ import annotations

import json
import math
import os
import time
import uuid
from datetime import datetime
from numbers import Integral, Real

import numpy as np

from config.config import ENV_NAME, OUTPUTS_DIR
from utils.input_validation import has_finite_metrics, has_valid_training_metrics

try:
    import resource
except ImportError:  # pragma: no cover - non-POSIX fallback
    resource = None


def _slugify(value: str) -> str:
    cleaned = "".join(ch.lower() if ch.isalnum() else "_" for ch in str(value))
    while "__" in cleaned:
        cleaned = cleaned.replace("__", "_")
    return cleaned.strip("_") or "run"


def _jsonable(value):
    """Convert common NumPy / pathlib / numeric values to JSON-safe types."""
    if isinstance(value, bool):
        return value
    if isinstance(value, dict):
        return {str(k): _jsonable(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [_jsonable(v) for v in value]
    if isinstance(value, np.ndarray):
        return value.tolist()
    if isinstance(value, np.generic):
        return value.item()
    if isinstance(value, Integral):
        return int(value)
    if isinstance(value, Real):
        value = float(value)
        if math.isfinite(value):
            return value
    return value


def _rss_mb() -> float | None:
    if resource is None:
        return None
    usage = resource.getrusage(resource.RUSAGE_SELF)
    rss = float(usage.ru_maxrss)
    if rss <= 0:
        return None
    # Linux reports KiB, macOS reports bytes.
    if os.name == "posix" and os.uname().sysname == "Darwin":  # pragma: no cover
        return rss / (1024.0 * 1024.0)
    return rss / 1024.0


class RunManager:
    """
    Manage a single structured run directory.

    The instance is intentionally lightweight: the main flow populates metrics
    after the training/evaluation steps are done.
    """

    def __init__(
        self,
        mode: str,
        agent: str,
        *,
        environment: str = ENV_NAME,
        output_root: str = OUTPUTS_DIR,
    ) -> None:
        self.mode = mode
        self.agent = agent
        self.environment = environment

        now = datetime.now()
        self.timestamp = now.isoformat(timespec="seconds")
        run_id = f"{now.strftime('%Y%m%d_%H%M%S')}_{_slugify(agent)}_{uuid.uuid4().hex[:6]}"
        self.run_id = run_id

        self.run_dir = os.path.join(output_root, run_id)
        self.model_dir = os.path.join(self.run_dir, "model")
        self.plots_dir = os.path.join(self.run_dir, "plots")
        self.console_path = os.path.join(self.run_dir, "console.txt")
        self.manifest_path = os.path.join(self.run_dir, "manifest.json")

        os.makedirs(self.model_dir, exist_ok=True)
        os.makedirs(self.plots_dir, exist_ok=True)

        self._agent = None
        self._model_artifact = None
        self._plot_artifacts: list[str] = []
        self._training_metrics = None
        self._evaluation_metrics = None
        self._episodes = {}
        self._hyperparameters = {}
        self._hyperparameters_source = None
        self._source_model = None
        self._console_notes: list[str] = []
        self._finalized = False

    # ── Population helpers ──────────────────────────────────────────────

    def set_agent(self, agent) -> None:
        self._agent = agent

    def set_episodes(self, *, train: int | None = None, test: int | None = None,
                     max_steps_per_episode: int | None = None) -> None:
        if train is not None:
            self._episodes["train"] = int(train)
        if test is not None:
            self._episodes["test"] = int(test)
        if max_steps_per_episode is not None:
            self._episodes["max_steps_per_episode"] = int(max_steps_per_episode)

    def set_hyperparameters(self, params: dict | None, *, source: str | None = None) -> None:
        self._hyperparameters = _jsonable(params or {})
        self._hyperparameters_source = source

    def set_source_model(self, info: dict | None) -> None:
        self._source_model = _jsonable(info) if info is not None else None

    def add_note(self, text: str) -> None:
        self._console_notes.append(str(text))

    def record_training(self, results: dict, *, wall_time_seconds: float | None = None) -> None:
        if not has_valid_training_metrics(results):
            raise ValueError("Training metrics are invalid; refusing to record run.")

        self._training_metrics = {
            "mean_reward": float(results["mean_reward"]),
            "mean_steps": float(results["mean_steps"]),
            "training_time_seconds": float(results["training_time"]),
        }
        if wall_time_seconds is not None:
            self._training_metrics["wall_time_seconds"] = float(wall_time_seconds)

    def record_evaluation(self, results: dict, *, wall_time_seconds: float | None = None) -> None:
        if not has_finite_metrics(results):
            raise ValueError("Evaluation metrics are invalid; refusing to record run.")

        self._evaluation_metrics = {
            "mean_reward": float(results["mean_reward"]),
            "mean_steps": float(results["mean_steps"]),
            "mean_time_seconds": float(results["mean_time"]),
            "success_rate": float(results["success_rate"]),
        }
        if wall_time_seconds is not None:
            self._evaluation_metrics["evaluation_time_seconds"] = float(wall_time_seconds)

    # ── Artifact helpers ────────────────────────────────────────────────

    def save_model(self, agent) -> bool:
        """
        Save the model into run_dir/model/ and register relative artifact paths.
        BruteForceAgent does not persist a model and remains model=None.
        """
        self._agent = agent
        class_name = agent.__class__.__name__

        if class_name == "BruteForceAgent":
            self._model_artifact = None
            return True

        try:
            if class_name == "QLearningAgent":
                base = os.path.join(self.model_dir, "qtable")
                agent.save(base)
                self._model_artifact = self._rel(base + ".npy")
                return True

            if class_name == "DoubleQLearningAgent":
                base = os.path.join(self.model_dir, "qtable")
                agent.save(base)
                self._model_artifact = [
                    self._rel(base + "_A.npy"),
                    self._rel(base + "_B.npy"),
                ]
                return True

            if class_name == "DQNAgent":
                base = os.path.join(self.model_dir, "dqn_model")
                agent.save(base)
                self._model_artifact = self._rel(base + ".npz")
                return True

            base = os.path.join(self.model_dir, _slugify(class_name))
            agent.save(base)
            model_files = sorted(
                f for f in os.listdir(self.model_dir)
                if f.startswith(os.path.basename(base))
            )
            self._model_artifact = [self._rel(os.path.join(self.model_dir, f)) for f in model_files]
            return True
        except OSError as exc:
            self._model_artifact = None
            self.add_note(f"Model save failed: {exc}")
            return False

    def record_summary(self, training: dict, evaluation: dict) -> None:
        """Record a benchmark-style summary payload."""
        self._training_metrics = _jsonable(training)
        self._evaluation_metrics = _jsonable(evaluation)

    def add_plot(self, path: str) -> None:
        rel = self._rel(path)
        if rel not in self._plot_artifacts:
            self._plot_artifacts.append(rel)

    # ── Final assembly ──────────────────────────────────────────────────

    def _model_file_paths(self) -> list[str]:
        if self._model_artifact is None:
            return []
        if isinstance(self._model_artifact, list):
            return [os.path.join(self.run_dir, p) for p in self._model_artifact]
        return [os.path.join(self.run_dir, self._model_artifact)]

    def _model_memory_bytes(self) -> int | None:
        agent = self._agent
        if agent is None:
            return None

        if hasattr(agent, "q_table"):
            return int(getattr(agent, "q_table").nbytes)
        if hasattr(agent, "q_a") and hasattr(agent, "q_b"):
            return int(getattr(agent, "q_a").nbytes + getattr(agent, "q_b").nbytes)
        if hasattr(agent, "_online") and hasattr(agent._online, "W") and hasattr(agent._online, "b"):
            total = 0
            for array in list(agent._online.W) + list(agent._online.b):
                total += int(array.nbytes)
            return total
        return None

    def _hardware_metrics(self) -> dict:
        model_paths = self._model_file_paths()
        model_size = 0
        existing_files = []
        for path in model_paths:
            if os.path.exists(path):
                model_size += os.path.getsize(path)
                existing_files.append(path)

        metrics = {
            "cpu_time_seconds": float(time.process_time()),
            "peak_memory_mb": _rss_mb(),
            "model_size_bytes": model_size if existing_files else None,
            "model_memory_bytes": self._model_memory_bytes(),
        }

        if hasattr(self._agent, "q_table"):
            metrics["qtable_size_bytes"] = int(self._agent.q_table.nbytes)
        elif hasattr(self._agent, "q_a") and hasattr(self._agent, "q_b"):
            metrics["qtable_size_bytes"] = int(self._agent.q_a.nbytes + self._agent.q_b.nbytes)

        return {k: v for k, v in metrics.items() if v is not None}

    def _rel(self, path: str) -> str:
        return os.path.relpath(path, self.run_dir).replace(os.sep, "/")

    def _console_text(self) -> str:
        lines = [
            f"run_id: {self.run_id}",
            f"timestamp: {self.timestamp}",
            f"mode: {self.mode}",
            f"agent: {self.agent}",
            f"environment: {self.environment}",
            "",
            "episodes:",
            json.dumps(self._episodes, indent=2, ensure_ascii=False),
            "",
            "hyperparameters:",
            json.dumps(self._hyperparameters, indent=2, ensure_ascii=False),
            "",
            f"hyperparameters_source: {self._hyperparameters_source}",
            "",
            "source_model:",
            json.dumps(self._source_model, indent=2, ensure_ascii=False),
            "",
            "metrics:",
            json.dumps({
                "training": self._training_metrics,
                "evaluation": self._evaluation_metrics,
                "hardware": self._hardware_metrics(),
            }, indent=2, ensure_ascii=False),
            "",
            "artifacts:",
            json.dumps({
                "model": self._model_artifact,
                "plots": self._plot_artifacts,
            }, indent=2, ensure_ascii=False),
        ]
        if self._console_notes:
            lines.extend(["", "notes:"] + [f"- {note}" for note in self._console_notes])
        return "\n".join(lines) + "\n"

    def finalize(self) -> dict:
        if self._finalized:
            return self.manifest

        manifest = {
            "run_id": self.run_id,
            "timestamp": self.timestamp,
            "mode": self.mode,
            "agent": self.agent,
            "environment": self.environment,
            "episodes": self._episodes,
            "hyperparameters": self._hyperparameters,
            "hyperparameters_source": self._hyperparameters_source,
            "source_model": self._source_model,
            "metrics": {
                "training": self._training_metrics,
                "evaluation": self._evaluation_metrics,
                "hardware": self._hardware_metrics(),
            },
            "artifacts": {
                "model": self._model_artifact,
                "plots": self._plot_artifacts,
                "console": "console.txt",
            },
        }

        training_required = self.mode not in {"eval_only"}
        if (not training_required or self._training_metrics is not None) and self._evaluation_metrics is not None:
            os.makedirs(self.run_dir, exist_ok=True)
            with open(self.manifest_path, "w", encoding="utf-8") as fh:
                json.dump(_jsonable(manifest), fh, indent=2, ensure_ascii=False)
            with open(self.console_path, "w", encoding="utf-8") as fh:
                fh.write(self._console_text())

            self._finalized = True
            self.manifest = manifest
            return manifest

        raise ValueError("Cannot finalize run: training/evaluation metrics are missing.")
