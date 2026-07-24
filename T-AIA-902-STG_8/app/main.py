"""
main.py – Entry point for the T-AIA Taxi Driver project.

Modes
─────
  user      : you set every hyperparameter interactively
  time      : pre-optimised params, goal is to minimise solve time
  eval_only : load a saved model and evaluate it

Usage
─────
  python main.py
"""

import os
import sys
import json
from time import perf_counter

from config.config import (
    DEFAULT_TRAIN_EPISODES, DEFAULT_TEST_EPISODES,
    USER_PARAMS, OPTIMIZED_PARAMS, DQN_USER_PARAMS, SAVE_DIR, MAX_STEPS_PER_EPISODE, OUTPUTS_DIR,
)
from agents.qlearning.qlearning_agent import create_agent
from training.trainer     import Trainer
from evaluation.evaluator import Evaluator
from utils.plotting       import plot_all
from utils.input_validation import (
    ask_int, ask_float, ask_choice, ask_yes_no, has_valid_training_metrics, has_finite_metrics,
)
from utils.run_manager import RunManager
from utils.final_model_exporter import iter_final_model_candidates
from benchmark.benchmark import run_benchmark


def _separator(title: str = "") -> None:
    line = "─" * 55
    if title:
        print(f"\n{line}\n  {title}\n{line}")
    else:
        print(line)


# Maps agent_type key → human-readable label used for file slugs and plots
_AGENT_LABELS = {
    "qlearning":        "Q-Learning",
    "double_qlearning": "Double Q-Learning",
    "bruteforce":       "Brute-Force",
    "dqn":              "DQN",
}


def _collect_hyperparameters(agent) -> dict:
    """Extract a JSON-safe snapshot of the agent's hyperparameters."""
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


def _candidate_manifest_path(path: str) -> str | None:
    """Return the manifest path if the model lives inside outputs/<run>/model/."""
    normalized = os.path.abspath(os.path.normpath(path))
    parts = normalized.split(os.sep)
    if "outputs" not in parts:
        return None
    idx = parts.index("outputs")
    if len(parts) < idx + 3:
        return None
    return os.path.join(os.sep, *parts[1: idx + 2], "manifest.json")


def _load_manifest_metadata(manifest_path: str | None) -> dict:
    if not manifest_path or not os.path.exists(manifest_path):
        return {}
    try:
        with open(manifest_path, "r", encoding="utf-8") as fh:
            return json.load(fh)
    except Exception:
        return {}


def _saved_model_candidates(agent_type: str) -> list[dict]:
    """Return compatible saved-model candidates for the selected agent."""
    candidates: list[dict] = []

    def add_candidate(label: str, path: str) -> None:
        candidates.append({
            "label": label,
            "path": path,
            "manifest_path": _candidate_manifest_path(path),
        })

    if os.path.exists(SAVE_DIR):
        files = sorted(os.listdir(SAVE_DIR))
        if agent_type == "qlearning":
            for filename in files:
                if filename.endswith(".npy") and not filename.endswith(("_A.npy", "_B.npy")):
                    add_candidate(filename, os.path.join(SAVE_DIR, filename))
        elif agent_type == "double_qlearning":
            bases = sorted({f[:-6] for f in files if f.endswith("_A.npy")})
            for base in bases:
                a_path = os.path.join(SAVE_DIR, base + "_A.npy")
                b_path = os.path.join(SAVE_DIR, base + "_B.npy")
                if os.path.exists(a_path) and os.path.exists(b_path):
                    add_candidate(base, os.path.join(SAVE_DIR, base))
        elif agent_type == "dqn":
            for filename in files:
                if filename.endswith(".npz"):
                    add_candidate(filename, os.path.join(SAVE_DIR, filename))

    outputs_root = OUTPUTS_DIR
    if os.path.exists(outputs_root):
        if agent_type == "qlearning":
            for root, _, files in os.walk(outputs_root):
                for filename in files:
                    if filename == "qtable.npy":
                        path = os.path.join(root, filename)
                        add_candidate(os.path.relpath(path), path[:-4])
        elif agent_type == "double_qlearning":
            for root, _, files in os.walk(outputs_root):
                if "model" not in root.split(os.sep):
                    continue
                if "qtable_A.npy" in files and "qtable_B.npy" in files:
                    path = os.path.join(root, "qtable")
                    add_candidate(os.path.relpath(path), path)
        elif agent_type == "dqn":
            for root, _, files in os.walk(outputs_root):
                for filename in files:
                    if filename == "dqn_model.npz":
                        path = os.path.join(root, filename)
                        add_candidate(os.path.relpath(path), path[:-4])

    candidates.extend(iter_final_model_candidates(agent_type))
    return candidates


def _build_agent_for_model(agent_type: str, model_meta: dict):
    """Create an agent instance with parameters compatible with a saved model."""
    if model_meta.get("final_entry"):
        manifest = model_meta["final_entry"]
        hyper = manifest.get("hyperparameters", {})
    else:
        manifest = _load_manifest_metadata(model_meta.get("manifest_path"))
        hyper = manifest.get("hyperparameters", {})

    if agent_type == "bruteforce":
        return create_agent(agent_type, mode="time")

    if agent_type == "dqn":
        params = {
            "alpha": hyper.get("alpha", DQN_USER_PARAMS["alpha"]),
            "gamma": hyper.get("gamma", DQN_USER_PARAMS["gamma"]),
            "epsilon": hyper.get("epsilon", DQN_USER_PARAMS["epsilon"]),
            "epsilon_min": hyper.get("epsilon_min", DQN_USER_PARAMS["epsilon_min"]),
            "epsilon_decay": hyper.get("epsilon_decay", DQN_USER_PARAMS["epsilon_decay"]),
            "batch_size": hyper.get("batch_size", DQN_USER_PARAMS["batch_size"]),
            "buffer_size": hyper.get("buffer_size", DQN_USER_PARAMS["buffer_size"]),
            "target_update_freq": hyper.get("target_update_freq", DQN_USER_PARAMS["target_update_freq"]),
        }
        if "hidden_sizes" in hyper:
            params["hidden_sizes"] = tuple(hyper["hidden_sizes"])
        return create_agent(agent_type, mode="user", n_episodes=None, **params)

    params = {
        "alpha": hyper.get("alpha", USER_PARAMS["alpha"]),
        "gamma": hyper.get("gamma", USER_PARAMS["gamma"]),
        "epsilon": hyper.get("epsilon", USER_PARAMS["epsilon"]),
        "epsilon_min": hyper.get("epsilon_min", USER_PARAMS["epsilon_min"]),
        "epsilon_decay": hyper.get("epsilon_decay", USER_PARAMS["epsilon_decay"]),
    }
    return create_agent(agent_type, mode="user", n_episodes=None, **params)


def _source_model_metadata(agent_type: str, model_meta: dict) -> dict:
    """Build eval_only source metadata from a chosen saved model candidate."""
    if model_meta.get("final_entry"):
        manifest = model_meta["final_entry"]
        source_path = manifest.get("final_model")
        manifest_path = model_meta.get("metadata_path")
    else:
        manifest = _load_manifest_metadata(model_meta.get("manifest_path"))
        source_path = model_meta.get("path")
        manifest_path = model_meta.get("manifest_path")

        if agent_type == "qlearning":
            source_path = source_path if source_path.endswith(".npy") else source_path + ".npy"
        elif agent_type == "double_qlearning":
            base = source_path[:-4] if source_path.endswith(".npy") else source_path
            if base.endswith("_A"):
                base = base[:-2]
            source_path = [
                base + "_A.npy",
                base + "_B.npy",
            ]
        elif agent_type == "dqn":
            source_path = source_path if source_path.endswith(".npz") else source_path + ".npz"

    return {
        "path": _json_path(source_path),
        "source_run_id": manifest.get("source_run_id") or manifest.get("run_id"),
        "loaded_from_manifest": bool(manifest),
        "manifest_path": _json_path(manifest_path) if manifest_path else None,
    }


def _json_path(value):
    if isinstance(value, list):
        return [os.path.relpath(item, start=os.getcwd()) if os.path.isabs(item) else item for item in value]
    if isinstance(value, str) and os.path.isabs(value):
        return os.path.relpath(value, start=os.getcwd())
    return value


def _select_saved_model(agent_type: str) -> dict | None:
    """Prompt the user to choose a compatible saved model candidate."""
    saved = _saved_model_candidates(agent_type)
    if not saved:
        print("  (No compatible saved models found)")
        return None

    print("\nAvailable saved models:")
    for i, candidate in enumerate(saved, 1):
        print(f"  {i}) {candidate['label']}")

    idx = ask_int("Select model", default=1, min_value=1, max_value=len(saved), name="model selection")
    return saved[idx - 1]


def _ask_load_model(agent, agent_type: str) -> dict | None:
    """
    Interactively ask the user whether to load an existing model.
    Skips silently if no saves exist or agent has no load() method.
    """
    if not hasattr(agent, "load"):
        return None

    saved = _saved_model_candidates(agent_type)
    if not saved:
        print("  (No compatible saved models found — starting from scratch)")
        return None

    if not ask_yes_no("\nLoad an existing model?", default=False):
        return None

    print("\nAvailable saved models:")
    for i, candidate in enumerate(saved, 1):
        print(f"  {i}) {candidate['label']}")

    idx = ask_int("Select model", default=1, min_value=1, max_value=len(saved), name="model selection")
    chosen = saved[idx - 1]

    try:
        agent.load(chosen["path"])
        # Reduce epsilon when resuming so the agent exploits learned knowledge
        if hasattr(agent, "epsilon"):
            agent.epsilon = max(agent.epsilon_min, agent.epsilon * 0.1)
            print(f"  ε reset to {agent.epsilon:.4f} (exploit mode)")
        return chosen
    except Exception as e:
        print(f"  Could not load model '{chosen['label']}': {e} — starting from scratch.")
        return None


# ─────────────────────────────────────────────
#  Mode implementations
# ─────────────────────────────────────────────

def run_user_mode() -> None:
    """Interactive mode: user tunes every hyperparameter."""
    _separator("USER MODE")

    agent_choices = {
        "1": "Q-Learning",
        "2": "Double Q-Learning",
        "3": "Brute-Force (baseline)",
        "4": "Deep Q-Network (DQN)",
    }

    while True:
        print("\nAvailable agents:")
        for key, name in agent_choices.items():
            print(f"  {key}) {name}")

        choice = ask_choice("Select agent", agent_choices.keys(), default="1", name="agent selection")
        agent_map = {
            "1": "qlearning",
            "2": "double_qlearning",
            "3": "bruteforce",
            "4": "dqn",
        }
        agent_type = agent_map[choice]
        label = _AGENT_LABELS[agent_type]

        n_train = ask_int("Training episodes", DEFAULT_TRAIN_EPISODES, min_value=1, name="training episodes")
        n_test  = ask_int("Test episodes", DEFAULT_TEST_EPISODES, min_value=1, name="test episodes")

        kwargs = {}
        if agent_type != "bruteforce":
            defaults = DQN_USER_PARAMS if agent_type == "dqn" else USER_PARAMS
            print("\nHyperparameters (press Enter to keep default):")
            kwargs["alpha"]         = ask_float("  alpha         (learning rate)", defaults["alpha"], min_value=0.0, max_value=1.0, positive_only=True, name="alpha")
            kwargs["gamma"]         = ask_float("  gamma         (discount factor)", defaults["gamma"], min_value=0.0, max_value=1.0, name="gamma")
            kwargs["epsilon"]       = ask_float("  epsilon       (initial exploration)", defaults["epsilon"], min_value=0.0, max_value=1.0, name="epsilon")
            kwargs["epsilon_min"]   = ask_float("  epsilon_min   (min exploration)", defaults["epsilon_min"], min_value=0.0, max_value=1.0, name="epsilon_min")
            kwargs["epsilon_decay"] = ask_float("  epsilon_decay (decay per episode)", defaults["epsilon_decay"], min_value=0.0, max_value=1.0, name="epsilon_decay")

            if agent_type == "dqn":
                print("\nDQN-specific parameters:")
                kwargs["batch_size"]         = ask_int("  batch_size         (transitions per update)", DQN_USER_PARAMS["batch_size"], min_value=1, name="batch_size")
                kwargs["buffer_size"]        = ask_int("  buffer_size        (replay buffer capacity)", DQN_USER_PARAMS["buffer_size"], min_value=1, name="buffer_size")
                kwargs["target_update_freq"] = ask_int("  target_update_freq (steps between target sync)", DQN_USER_PARAMS["target_update_freq"], min_value=1, name="target_update_freq")

        try:
            agent = create_agent(agent_type, mode="user", n_episodes=n_train, **kwargs)
        except ValueError as exc:
            print(f"  [ERROR] {exc}")
            print("  Please enter the values again.\n")
            continue

        if agent_type != "bruteforce":
            _ask_load_model(agent, agent_type)

        _run_training_evaluation(
            agent,
            n_train,
            n_test,
            label=label,
            display_episodes=True,
            prompt_plots=True,
            persist=True,
        )
        break


def run_time_limited_mode() -> None:
    """
    Time-limited mode: pre-optimised params, race against the clock.
    Runs the benchmark suite on the main agents.
    """
    _separator("TIME-LIMITED MODE")
    print(f"\nTabular params : {OPTIMIZED_PARAMS}")

    n_train = ask_int("Training episodes", DEFAULT_TRAIN_EPISODES, min_value=1, name="training episodes")
    n_test  = ask_int("Test episodes", DEFAULT_TEST_EPISODES, min_value=1, name="test episodes")

    print("\nRunning benchmark on Brute-Force vs Q-Learning vs Double Q-Learning …\n")
    run_benchmark(profile="final", n_train=n_train, n_test=n_test, include_dqn=False)


def run_eval_only_mode() -> None:
    """Interactive mode: load an existing model and evaluate it only."""
    _separator("EVALUATION ONLY MODE")

    agent_choices = {
        "1": "Q-Learning",
        "2": "Double Q-Learning",
        "3": "Brute-Force (baseline)",
        "4": "Deep Q-Network (DQN)",
    }

    while True:
        print("\nAvailable agents:")
        for key, name in agent_choices.items():
            print(f"  {key}) {name}")

        choice = ask_choice("Select agent", agent_choices.keys(), default="1", name="agent selection")
        agent_map = {
            "1": "qlearning",
            "2": "double_qlearning",
            "3": "bruteforce",
            "4": "dqn",
        }
        agent_type = agent_map[choice]

        model_meta = None
        if agent_type != "bruteforce":
            model_meta = _select_saved_model(agent_type)
            if model_meta is None:
                print("  No model selected — please choose another agent or mode.\n")
                continue

        n_test = ask_int("Test episodes", DEFAULT_TEST_EPISODES, min_value=1, name="test episodes")

        try:
            if agent_type == "bruteforce":
                agent = create_agent(agent_type, mode="time")
                source_meta = None
            else:
                agent = _build_agent_for_model(agent_type, model_meta)
                source_meta = _source_model_metadata(agent_type, model_meta)
                agent.load(model_meta["path"])
        except Exception as exc:
            print(f"  [ERROR] Could not prepare the model: {exc}")
            continue

        run_manager = RunManager(mode="eval_only", agent=agent.__class__.__name__)
        run_manager.set_episodes(test=n_test, max_steps_per_episode=MAX_STEPS_PER_EPISODE)
        hyper_source = "manifest" if source_meta and source_meta.get("loaded_from_manifest") else ("none" if agent_type == "bruteforce" else "defaults")
        run_manager.set_hyperparameters(
            _collect_hyperparameters(agent),
            source=hyper_source,
        )
        run_manager.set_source_model(source_meta)

        eval_start = perf_counter()
        evaluator = Evaluator(agent, n_episodes=n_test, max_steps=MAX_STEPS_PER_EPISODE)
        eval_results = evaluator.evaluate()
        eval_wall = perf_counter() - eval_start

        if ask_yes_no("Display rendered episodes?", default=False):
            evaluator.display_episodes(n=2)

        if not has_finite_metrics(eval_results):
            print("  [WARN] Invalid evaluation metrics; skipping structured run save.")
            return

        run_manager.record_evaluation(eval_results, wall_time_seconds=eval_wall)
        run_manager.save_model(agent)
        run_manager.finalize()
        print(f"  Structured run saved → {run_manager.run_dir}")
        break


# ─────────────────────────────────────────────
#  Shared helpers
# ─────────────────────────────────────────────

def _run_training_evaluation(
    agent,
    n_train: int,
    n_test: int,
    *,
    label: str,
    display_episodes: bool = True,
    prompt_plots: bool = True,
    persist: bool = False,
    run_mode: str = "train_eval",
) -> dict:
    """Train then evaluate an agent. Returns {'train': ..., 'eval': ...}."""
    trainer = Trainer(agent, n_episodes=n_train, max_steps=MAX_STEPS_PER_EPISODE)
    train_results = trainer.train()

    eval_start = perf_counter()
    evaluator = Evaluator(agent, n_episodes=n_test, max_steps=MAX_STEPS_PER_EPISODE)
    eval_results = evaluator.evaluate()
    eval_wall = perf_counter() - eval_start

    if display_episodes and ask_yes_no("Display rendered episodes?", default=False):
        evaluator.display_episodes(n=2)

    if persist:
        if not (has_valid_training_metrics(train_results) and has_finite_metrics(eval_results)):
            print("  [WARN] Invalid metrics detected; skipping structured run save.")
            return {"train": train_results, "eval": eval_results}

        run_manager = RunManager(mode=run_mode, agent=agent.__class__.__name__)
        run_manager.set_episodes(
            train=n_train,
            test=n_test,
            max_steps_per_episode=MAX_STEPS_PER_EPISODE,
        )
        run_manager.set_hyperparameters(_collect_hyperparameters(agent))
        run_manager.record_training(train_results)
        run_manager.record_evaluation(eval_results, wall_time_seconds=eval_wall)

        if not run_manager.save_model(agent) and agent.__class__.__name__ != "BruteForceAgent":
            print("  [WARN] Model save failed; manifest will still be written without model artifacts.")

        if prompt_plots and has_valid_training_metrics(train_results):
            if ask_yes_no("\nSave training plots?", default=False):
                plot_all(train_results, label=label, out_dir=run_manager.plots_dir)
                slug = label.lower().replace(" ", "_")
                for suffix in ("rewards", "steps", "epsilon"):
                    run_manager.add_plot(os.path.join(run_manager.plots_dir, f"{slug}_{suffix}.png"))

        run_manager.finalize()
        print(f"  Structured run saved → {run_manager.run_dir}")

    return {"train": train_results, "eval": eval_results}


def _print_summary_table(eval_results: dict) -> None:
    _separator("Results Table")
    header = f"{'Agent':<22} {'Mean Reward':>12} {'Mean Steps':>11} {'Success %':>10}"
    print(header)
    print("─" * len(header))
    for name, r in eval_results.items():
        print(
            f"{name:<22} "
            f"{r['mean_reward']:>12.2f} "
            f"{r['mean_steps']:>11.1f} "
            f"{r['success_rate']*100:>9.1f}%"
        )
    print()


# ─────────────────────────────────────────────
#  Entry point
# ─────────────────────────────────────────────

def main() -> None:
    print("\n╔══════════════════════════════════╗")
    print("║     T-AIA  –  TAXI DRIVER        ║")
    print("╚══════════════════════════════════╝")
    print("\nSelect a mode:")
    print("  1) User mode         (tune parameters manually)")
    print("  2) Time-limited mode (optimised benchmark, main agents)")
    print("  3) Evaluation only   (load a saved model and evaluate)")

    choice = ask_choice("\nMode", ["1", "2", "3"], default="1", name="mode selection")

    if choice == "1":
        run_user_mode()
    elif choice == "2":
        run_time_limited_mode()
    elif choice == "3":
        run_eval_only_mode()
    else:
        print("Invalid choice. Exiting.")
        sys.exit(1)


if __name__ == "__main__":
    main()
