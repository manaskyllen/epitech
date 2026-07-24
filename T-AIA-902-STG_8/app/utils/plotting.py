"""
plotting.py – Visualisation utilities for the T-AIA benchmark report.

All functions accept the dicts returned by Trainer.train() and Evaluator.evaluate().
"""

import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker


# ── Smoothing helper ──────────────────────────────────────────────────────────

def _series(values: list, window: int = 50) -> tuple[np.ndarray, np.ndarray, int]:
    """
    Prepare a raw series and a smoothed series.

    The smoothing window is clamped to the available data length so that
    short runs still produce valid plots.
    """
    arr = np.array(values, dtype=float).ravel()
    if arr.size == 0:
        return arr, arr, 0

    window = int(window) if window is not None else 1
    if window < 1:
        window = 1

    used_window = min(window, arr.size)
    if used_window == 1:
        return arr, arr, used_window

    kernel = np.ones(used_window, dtype=float) / used_window
    smoothed = np.convolve(arr, kernel, mode="valid")
    return arr, smoothed, used_window


def _empty_figure(title: str, message: str, save_path: str = None) -> None:
    fig, ax = plt.subplots(figsize=(8, 3))
    ax.axis("off")
    ax.set_title(title)
    ax.text(0.5, 0.5, message, ha="center", va="center", fontsize=11)
    plt.tight_layout()
    _save_or_show(fig, save_path)


# ── Individual plots ──────────────────────────────────────────────────────────

def plot_rewards(train_results: dict, label: str = "Agent", window: int = 50,
                 save_path: str = None) -> None:
    """Plot smoothed reward curve over training episodes."""
    rewards = train_results.get("rewards", [])
    raw, smoothed, used_window = _series(rewards, window)

    if raw.size == 0:
        _empty_figure(
            f"Training Rewards – {label}",
            "No reward data available.",
            save_path,
        )
        return

    fig, ax = plt.subplots(figsize=(10, 4))
    ax.plot(raw, alpha=0.25, color="steelblue", label="Raw reward")
    if used_window > 1:
        ax.plot(range(used_window - 1, used_window - 1 + len(smoothed)), smoothed,
                color="steelblue", linewidth=2, label=f"Smoothed (w={used_window})")
    mean_reward = train_results.get("mean_reward", float(np.mean(raw)))
    ax.axhline(mean_reward, color="red", linestyle="--",
               linewidth=1, label=f"Overall mean ({mean_reward:.1f})")

    ax.set_title(f"Training Rewards – {label}")
    ax.set_xlabel("Episode")
    ax.set_ylabel("Total reward")
    ax.legend()
    ax.grid(alpha=0.3)
    plt.tight_layout()
    _save_or_show(fig, save_path)


def plot_steps(train_results: dict, label: str = "Agent", window: int = 50,
               save_path: str = None) -> None:
    """Plot smoothed steps-per-episode curve over training."""
    steps = train_results.get("steps", [])
    raw, smoothed, used_window = _series(steps, window)

    if raw.size == 0:
        _empty_figure(
            f"Steps per Episode – {label}",
            "No step data available.",
            save_path,
        )
        return

    fig, ax = plt.subplots(figsize=(10, 4))
    ax.plot(raw, alpha=0.2, color="darkorange", label="Raw steps")
    if used_window > 1:
        ax.plot(range(used_window - 1, used_window - 1 + len(smoothed)), smoothed,
                color="darkorange", linewidth=2, label=f"Smoothed (w={used_window})")

    ax.set_title(f"Steps per Episode – {label}")
    ax.set_xlabel("Episode")
    ax.set_ylabel("Steps")
    ax.legend()
    ax.grid(alpha=0.3)
    plt.tight_layout()
    _save_or_show(fig, save_path)


def plot_epsilon(train_results: dict, label: str = "Agent",
                 save_path: str = None) -> None:
    """Plot epsilon decay curve."""
    epsilons = train_results.get("epsilons", [])
    raw = np.array(epsilons, dtype=float).ravel()

    if raw.size == 0:
        _empty_figure(
            f"Epsilon Decay – {label}",
            "No epsilon data available.",
            save_path,
        )
        return

    fig, ax = plt.subplots(figsize=(10, 3))
    ax.plot(raw, color="purple", linewidth=1.5)
    ax.set_title(f"Epsilon Decay – {label}")
    ax.set_xlabel("Episode")
    ax.set_ylabel("Epsilon")
    ax.set_ylim(0, 1.05)
    ax.grid(alpha=0.3)
    plt.tight_layout()
    _save_or_show(fig, save_path)


# ── Comparison plots ──────────────────────────────────────────────────────────

def plot_comparison(results_dict: dict, metric: str = "rewards",
                    window: int = 50, save_path: str = None) -> None:
    """
    Overlay smoothed training curves for multiple agents.

    Parameters
    ----------
    results_dict : { "Agent Name": train_results_dict, ... }
    metric       : 'rewards' or 'steps'
    """
    fig, ax = plt.subplots(figsize=(12, 5))
    colors  = plt.rcParams["axes.prop_cycle"].by_key()["color"]
    plotted = False

    for i, (name, results) in enumerate(results_dict.items()):
        raw, smoothed, used_window = _series(results.get(metric, []), window)
        if raw.size == 0:
            continue
        color    = colors[i % len(colors)]
        ax.plot(raw, alpha=0.15, color=color)
        if used_window > 1:
            ax.plot(range(used_window - 1, used_window - 1 + len(smoothed)), smoothed,
                    color=color, linewidth=2, label=name)
        else:
            ax.plot(raw, color=color, linewidth=2, label=name)
        plotted = True

    if not plotted:
        _empty_figure(
            f"Comparison – {metric}",
            "No comparison data available.",
            save_path,
        )
        return

    ylabel = "Total reward" if metric == "rewards" else "Steps"
    ax.set_title(f"Comparison – {ylabel} per Episode (smoothed w={window})")
    ax.set_xlabel("Episode")
    ax.set_ylabel(ylabel)
    ax.legend()
    ax.grid(alpha=0.3)
    plt.tight_layout()
    _save_or_show(fig, save_path)


def plot_benchmark_bar(eval_results_dict: dict, metric: str = "mean_reward",
                       save_path: str = None) -> None:
    """
    Bar chart comparing evaluation metrics across agents.

    Parameters
    ----------
    eval_results_dict : { "Agent Name": eval_results_dict, ... }
    metric            : key from Evaluator.evaluate() dict
    """
    if not eval_results_dict:
        _empty_figure(
            f"Benchmark – {metric}",
            "No benchmark data available.",
            save_path,
        )
        return

    names  = list(eval_results_dict.keys())
    values = [eval_results_dict[n].get(metric) for n in names if metric in eval_results_dict[n]]
    names  = [n for n in names if metric in eval_results_dict[n]]

    if not values:
        _empty_figure(
            f"Benchmark – {metric}",
            f"No values available for metric '{metric}'.",
            save_path,
        )
        return

    fig, ax = plt.subplots(figsize=(8, 5))
    bars = ax.bar(names, values, color=["#4C72B0", "#DD8452", "#55A868", "#C44E52"])
    ax.bar_label(bars, fmt="%.2f", padding=4, fontsize=10)

    label_map = {
        "mean_reward"  : "Mean Reward",
        "mean_steps"   : "Mean Steps",
        "success_rate" : "Success Rate",
        "mean_time"    : "Mean Time (s)",
    }
    ax.set_title(f"Benchmark – {label_map.get(metric, metric)}")
    ax.set_ylabel(label_map.get(metric, metric))
    ax.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    _save_or_show(fig, save_path)


def plot_all(train_results: dict, label: str = "Agent",
             out_dir: str = "plots") -> None:
    """Convenience: save reward, steps and epsilon plots to out_dir."""
    os.makedirs(out_dir, exist_ok=True)
    slug = label.lower().replace(" ", "_")
    plot_rewards(train_results, label, save_path=os.path.join(out_dir, f"{slug}_rewards.png"))
    plot_steps  (train_results, label, save_path=os.path.join(out_dir, f"{slug}_steps.png"))
    plot_epsilon(train_results, label, save_path=os.path.join(out_dir, f"{slug}_epsilon.png"))
    print(f"[Plotting] Saved 3 plots to '{out_dir}/'")


# ── Internal helper ───────────────────────────────────────────────────────────

def _save_or_show(fig: plt.Figure, path: str = None) -> None:
    if path:
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        fig.savefig(path, dpi=150, bbox_inches="tight")
        print(f"[Plotting] Saved → {path}")
        plt.close(fig)
    else:
        plt.show()
