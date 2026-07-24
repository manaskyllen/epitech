"""
benchmark.py – benchmark runner for the Taxi-v3 project.

Supports quick and final profiles, with optional DQN participation.
The benchmark compares:
  - BruteForceAgent
  - QLearningAgent
  - DoubleQLearningAgent
  - DQNAgent (optional)
"""

from __future__ import annotations

import argparse
import random
from time import perf_counter

import numpy as np

from agents.qlearning.qlearning_agent import create_agent
from config.config import DEFAULT_TEST_EPISODES, DEFAULT_TRAIN_EPISODES, MAX_STEPS_PER_EPISODE
from evaluation.evaluator import Evaluator
from training.trainer import Trainer
from utils.input_validation import has_finite_metrics, has_valid_training_metrics
from utils.plotting import plot_all, plot_benchmark_bar, plot_comparison
from utils.run_manager import RunManager


PROFILE_DEFAULTS = {
    "quick": {
        "train_episodes": 1000,
        "test_episodes": 20,
        "include_dqn": False,
    },
    "final": {
        "train_episodes": DEFAULT_TRAIN_EPISODES,
        "test_episodes": DEFAULT_TEST_EPISODES,
        "include_dqn": False,
    },
}

BASELINE_AGENTS = [
    ("bruteforce", "Brute-Force"),
    ("qlearning", "Q-Learning"),
    ("double_qlearning", "Double Q-Learning"),
]


def _seed_everything(seed: int | None) -> None:
    if seed is None:
        return
    random.seed(seed)
    np.random.seed(seed)


def _collect_hyperparameters(agent) -> dict:
    keys = ("alpha", "gamma", "epsilon", "epsilon_min", "epsilon_decay")
    params = {key: getattr(agent, key) for key in keys if hasattr(agent, key)}
    if hasattr(agent, "batch_size"):
        params["batch_size"] = getattr(agent, "batch_size")
    if hasattr(agent, "buffer_size"):
        params["buffer_size"] = getattr(agent, "buffer_size")
    if hasattr(agent, "target_update_freq"):
        params["target_update_freq"] = getattr(agent, "target_update_freq")
    if hasattr(agent, "hidden_sizes"):
        params["hidden_sizes"] = list(getattr(agent, "hidden_sizes"))
    return params


def _format_cost_note(hardware: dict) -> str:
    model_size = hardware.get("model_size_bytes")
    peak_memory = hardware.get("peak_memory_mb")
    pieces = []
    if model_size is not None:
        pieces.append(f"model={model_size} B")
    if peak_memory is not None:
        pieces.append(f"peak_mem={peak_memory:.1f} MB")
    return ", ".join(pieces) if pieces else "N/A"


def _run_single_agent(agent_type: str, label: str, *, n_train: int, n_test: int,
                      max_steps: int, save_plots: bool = True) -> dict:
    agent = create_agent(agent_type, mode="time", n_episodes=n_train)

    print(f"\n{'=' * 55}")
    print(f"  Benchmarking {label}")
    print(f"  Episodes : train={n_train} test={n_test}  Max steps/ep : {max_steps}")
    print(f"{'=' * 55}")

    trainer = Trainer(agent, n_episodes=n_train, max_steps=max_steps)
    train_results = trainer.train()

    eval_start = perf_counter()
    evaluator = Evaluator(agent, n_episodes=n_test, max_steps=max_steps)
    eval_results = evaluator.evaluate()
    eval_wall = perf_counter() - eval_start

    run_manager = RunManager(mode="train_eval", agent=agent.__class__.__name__)
    run_manager.set_episodes(train=n_train, test=n_test, max_steps_per_episode=max_steps)
    run_manager.set_hyperparameters(_collect_hyperparameters(agent))
    run_manager.record_training(train_results)
    run_manager.record_evaluation(eval_results, wall_time_seconds=eval_wall)

    if not run_manager.save_model(agent) and agent.__class__.__name__ != "BruteForceAgent":
        print("  [WARN] Model save failed; manifest will still be written without model artifacts.")

    if save_plots and has_valid_training_metrics(train_results):
        plot_all(train_results, label=label, out_dir=run_manager.plots_dir)
        slug = label.lower().replace(" ", "_")
        for suffix in ("rewards", "steps", "epsilon"):
            run_manager.add_plot(f"{run_manager.plots_dir}/{slug}_{suffix}.png")

    manifest = run_manager.finalize()

    hardware = manifest["metrics"]["hardware"]
    print(
        f"  -> {label}: mean_reward={eval_results['mean_reward']:.2f}, "
        f"mean_steps={eval_results['mean_steps']:.1f}, "
        f"success_rate={eval_results['success_rate'] * 100:.1f}%, "
        f"train_time={train_results['training_time']:.2f}s, "
        f"eval_time={eval_results['mean_time']:.4f}s, "
        f"{_format_cost_note(hardware)}"
    )

    return {
        "agent_type": agent_type,
        "label": label,
        "run_id": manifest["run_id"],
        "run_dir": run_manager.run_dir,
        "manifest_path": run_manager.manifest_path,
        "train": train_results,
        "eval": eval_results,
        "evaluation_time_seconds": eval_wall,
        "hardware": hardware,
        "manifest": manifest,
    }


def _print_summary_table(rows: list[dict]) -> None:
    if not rows:
        return

    print(f"\n{'=' * 92}")
    print("  Benchmark Summary")
    print(f"{'=' * 92}")
    header = (
        f"{'Agent':<22} {'Mean Reward':>12} {'Mean Steps':>11} {'Success %':>10} "
        f"{'Train (s)':>10} {'Eval (s)':>10} {'Model size':>13} {'Peak mem':>10}"
    )
    print(header)
    print("─" * len(header))
    for row in rows:
        hardware = row["hardware"]
        model_size = hardware.get("model_size_bytes")
        peak_memory = hardware.get("peak_memory_mb")
        model_size_txt = f"{model_size:d}" if isinstance(model_size, int) else "N/A"
        peak_memory_txt = f"{peak_memory:.1f}" if isinstance(peak_memory, (int, float)) else "N/A"
        print(
            f"{row['label']:<22} "
            f"{row['eval']['mean_reward']:>12.2f} "
            f"{row['eval']['mean_steps']:>11.1f} "
            f"{row['eval']['success_rate'] * 100:>9.1f}% "
            f"{row['train']['training_time']:>10.2f} "
            f"{row['evaluation_time_seconds']:>10.4f} "
            f"{model_size_txt:>13} "
            f"{peak_memory_txt:>10}"
        )
    print()


def run_benchmark(
    profile: str = "final",
    *,
    n_train: int | None = None,
    n_test: int | None = None,
    max_steps: int = MAX_STEPS_PER_EPISODE,
    include_dqn: bool | None = None,
    seed: int | None = None,
) -> dict:
    """
    Run the benchmark suite and persist outputs under outputs/.

    profile:
      quick  -> short runs for smoke checks
      final  -> longer runs for the report
    """
    profile = profile.lower().strip()
    if profile not in PROFILE_DEFAULTS:
        raise ValueError("profile must be 'quick' or 'final'")

    defaults = PROFILE_DEFAULTS[profile]
    n_train = int(n_train if n_train is not None else defaults["train_episodes"])
    n_test = int(n_test if n_test is not None else defaults["test_episodes"])
    include_dqn = defaults["include_dqn"] if include_dqn is None else bool(include_dqn)

    _seed_everything(seed)

    print(f"[Benchmark] profile={profile} train={n_train} test={n_test} max_steps={max_steps} seed={seed}")
    if include_dqn:
        print("[Benchmark] DQN is enabled for this run.")

    agent_specs = list(BASELINE_AGENTS)
    if include_dqn:
        agent_specs.append(("dqn", "DQN"))

    rows: list[dict] = []
    train_curves: dict = {}
    eval_curves: dict = {}

    for agent_type, label in agent_specs:
        result = _run_single_agent(
            agent_type,
            label,
            n_train=n_train,
            n_test=n_test,
            max_steps=max_steps,
            save_plots=True,
        )
        rows.append(result)
        train_curves[label] = result["train"]
        eval_curves[label] = result["eval"]

    summary_manager = RunManager(mode="benchmark", agent="Benchmark")
    summary_manager.set_episodes(train=n_train, test=n_test, max_steps_per_episode=max_steps)
    summary_manager.set_hyperparameters(
        {
            "profile": profile,
            "include_dqn": include_dqn,
            "seed": seed,
        }
    )
    summary_manager.record_summary(
        training={
            row["label"]: {
                "mean_reward": float(row["train"]["mean_reward"]),
                "mean_steps": float(row["train"]["mean_steps"]),
                "training_time_seconds": float(row["train"]["training_time"]),
                "model_size_bytes": row["hardware"].get("model_size_bytes"),
                "peak_memory_mb": row["hardware"].get("peak_memory_mb"),
            }
            for row in rows
        },
        evaluation={
            row["label"]: {
                "mean_reward": float(row["eval"]["mean_reward"]),
                "mean_steps": float(row["eval"]["mean_steps"]),
                "mean_time_seconds": float(row["eval"]["mean_time"]),
                "success_rate": float(row["eval"]["success_rate"]),
                "evaluation_time_seconds": float(row["evaluation_time_seconds"]),
                "model_size_bytes": row["hardware"].get("model_size_bytes"),
                "peak_memory_mb": row["hardware"].get("peak_memory_mb"),
            }
            for row in rows
        },
    )

    comparison_rewards = f"{summary_manager.plots_dir}/comparison_rewards.png"
    comparison_steps = f"{summary_manager.plots_dir}/comparison_steps.png"
    benchmark_reward = f"{summary_manager.plots_dir}/benchmark_reward.png"
    benchmark_steps = f"{summary_manager.plots_dir}/benchmark_steps.png"
    benchmark_success = f"{summary_manager.plots_dir}/benchmark_success.png"
    benchmark_time = f"{summary_manager.plots_dir}/benchmark_time.png"

    plot_comparison(train_curves, metric="rewards", save_path=comparison_rewards)
    plot_comparison(train_curves, metric="steps", save_path=comparison_steps)
    plot_benchmark_bar(eval_curves, metric="mean_reward", save_path=benchmark_reward)
    plot_benchmark_bar(eval_curves, metric="mean_steps", save_path=benchmark_steps)
    plot_benchmark_bar(eval_curves, metric="success_rate", save_path=benchmark_success)
    plot_benchmark_bar(eval_curves, metric="mean_time", save_path=benchmark_time)

    for path in (
        comparison_rewards,
        comparison_steps,
        benchmark_reward,
        benchmark_steps,
        benchmark_success,
        benchmark_time,
    ):
        summary_manager.add_plot(path)

    summary_manifest = summary_manager.finalize()
    _print_summary_table(rows)

    return {
        "profile": profile,
        "episodes": {"train": n_train, "test": n_test, "max_steps_per_episode": max_steps},
        "include_dqn": include_dqn,
        "agents": rows,
        "summary": summary_manifest,
        "summary_run_dir": summary_manager.run_dir,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Run Taxi-v3 benchmarks.")
    parser.add_argument("--profile", choices=("quick", "final"), default="final")
    parser.add_argument("--train", type=int, default=None, help="override training episodes")
    parser.add_argument("--test", type=int, default=None, help="override testing episodes")
    parser.add_argument("--max-steps", type=int, default=MAX_STEPS_PER_EPISODE, help="override max steps per episode")
    parser.add_argument("--include-dqn", action="store_true", help="include DQN in the benchmark")
    parser.add_argument("--seed", type=int, default=None, help="seed for reproducible runs")
    args = parser.parse_args()

    run_benchmark(
        profile=args.profile,
        n_train=args.train,
        n_test=args.test,
        max_steps=args.max_steps,
        include_dqn=args.include_dqn,
        seed=args.seed,
    )


if __name__ == "__main__":
    main()
