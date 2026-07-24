"""
final_model_exporter.py – Copy selected final models into artifacts/final_models.

This module keeps the selection explicit: only a few hand-picked models are
copied from real runs under outputs/ and recorded in metadata.json.
"""

from __future__ import annotations

import json
import os
import shutil
from datetime import datetime
from pathlib import Path

from config.config import FINAL_MODELS_DIR


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _abs(path: str | os.PathLike[str]) -> Path:
    p = Path(path)
    return p if p.is_absolute() else (_repo_root() / p).resolve()


def _rel(path: Path) -> str:
    return path.resolve().relative_to(_repo_root()).as_posix()


def _load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def _dump_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as fh:
        json.dump(payload, fh, indent=2, ensure_ascii=False)
        fh.write("\n")


def _agent_slug(agent: str) -> str:
    lower = agent.lower()
    if "double" in lower:
        return "double_qlearning"
    if "dqn" in lower:
        return "dqn"
    if "bruteforce" in lower:
        return "bruteforce"
    return "qlearning"


def _copy_one(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def export_final_models(selected_runs: list[dict], destination_dir: str | os.PathLike[str] = FINAL_MODELS_DIR) -> dict:
    """
    Copy selected source models into artifacts/final_models and write metadata.

    Each item in selected_runs must contain:
      - name
      - source_run_dir
      - final_filename or final_filenames
    """
    destination = _abs(destination_dir)
    destination.mkdir(parents=True, exist_ok=True)

    selected_models: list[dict] = []

    for spec in selected_runs:
        source_run_dir = _abs(spec["source_run_dir"])
        manifest_path = source_run_dir / "manifest.json"
        manifest = _load_json(manifest_path)
        artifacts = manifest.get("artifacts", {})
        source_model = artifacts.get("model")
        if source_model is None:
            raise ValueError(f"Run {source_run_dir} does not expose a saved model.")

        entry = {
            "name": spec["name"],
            "agent": manifest.get("agent"),
            "source_run_id": manifest.get("run_id"),
            "source_manifest": _rel(manifest_path),
            "source_model": None,
            "final_model": None,
            "environment": manifest.get("environment", "Taxi-v3"),
            "episodes": manifest.get("episodes", {}),
            "hyperparameters": manifest.get("hyperparameters", {}),
            "metrics": {},
            "exported_at": datetime.now().isoformat(timespec="seconds"),
        }

        metrics = manifest.get("metrics", {})
        training = metrics.get("training") or {}
        evaluation = metrics.get("evaluation") or {}
        entry["metrics"] = {
            "mean_reward": evaluation.get("mean_reward"),
            "mean_steps": evaluation.get("mean_steps"),
            "success_rate": evaluation.get("success_rate"),
            "training_time_seconds": training.get("training_time_seconds"),
            "evaluation_time_seconds": evaluation.get("evaluation_time_seconds"),
        }

        final_filename = spec.get("final_filename")
        final_filenames = spec.get("final_filenames")

        if isinstance(source_model, list):
            if not final_filenames or len(final_filenames) != len(source_model):
                raise ValueError(f"Run {source_run_dir} requires matching final_filenames.")
            copied = []
            source_paths = []
            for rel_source, rel_final in zip(source_model, final_filenames):
                src = source_run_dir / rel_source
                dst = destination / rel_final
                _copy_one(src, dst)
                copied.append(_rel(dst))
                source_paths.append(_rel(src))
            entry["source_model"] = source_paths
            entry["final_model"] = copied
        else:
            if not final_filename:
                raise ValueError(f"Run {source_run_dir} requires final_filename.")
            src = source_run_dir / source_model
            dst = destination / final_filename
            _copy_one(src, dst)
            entry["source_model"] = _rel(src)
            entry["final_model"] = _rel(dst)

        selected_models.append(entry)

    metadata = {
        "exported_at": datetime.now().isoformat(timespec="seconds"),
        "selected_models": selected_models,
    }
    _dump_json(destination / "metadata.json", metadata)
    return metadata


def load_final_model_catalog(destination_dir: str | os.PathLike[str] = FINAL_MODELS_DIR) -> dict:
    """Load the final-model metadata catalog if it exists."""
    metadata_path = _abs(destination_dir) / "metadata.json"
    if not metadata_path.exists():
        return {}
    return _load_json(metadata_path)


def iter_final_model_candidates(agent_type: str, destination_dir: str | os.PathLike[str] = FINAL_MODELS_DIR) -> list[dict]:
    """Return model candidates from artifacts/final_models for eval-only mode."""
    catalog = load_final_model_catalog(destination_dir)
    candidates: list[dict] = []
    for entry in catalog.get("selected_models", []):
        if _agent_slug(entry.get("agent", "")) != agent_type:
            continue
        final_model = entry.get("final_model")
        if isinstance(final_model, list):
            model_path = final_model[0]
            if model_path.endswith("_A.npy"):
                model_path = model_path[:-6]
        else:
            model_path = final_model
        if not model_path:
            continue
        candidates.append({
            "label": f"{entry.get('name', entry.get('agent', 'final_model'))} [final]",
            "path": str(_abs(model_path)),
            "final_entry": entry,
            "metadata_path": str(_abs(destination_dir) / "metadata.json"),
        })
    return candidates
