"""
brute_force_agent.py – Naive random baseline for Taxi-v3.

Picks a random action at every step.
Used as the lower-bound comparison point for the benchmark.
Expected ~350 steps and strongly negative rewards per episode.
"""

import random
from agents.base_agent import BaseAgent


class BruteForceAgent(BaseAgent):
    """
    Naive baseline that always picks a random action.

    Parameters
    ----------
    n_actions  : int – number of valid actions (6 for Taxi-v3)
    max_steps  : int – safety cap to avoid infinite loops
    """

    def __init__(self, n_actions: int = 6, max_steps: int = 200):
        self.n_actions = n_actions
        self.max_steps = max_steps

    # ── BaseAgent interface ───────────────────────────────────────────────

    def select_action(self, state: int) -> int:
        return random.randint(0, self.n_actions - 1)

    def greedy_action(self, state: int) -> int:
        """Brute-force has no policy — still random during evaluation."""
        return self.select_action(state)

    def update(self, *args, **kwargs) -> None:
        pass  # stateless – nothing to learn

    # ── Standalone runner (used in main.py / benchmark) ──────────────────

    def run(self, env, n_episodes: int) -> dict:
        """
        Run the brute-force agent for n_episodes and return metrics.

        Parameters
        ----------
        env        : TaxiEnv instance
        n_episodes : number of episodes to run

        Returns
        -------
        dict with keys: mean_steps, mean_reward, all_steps, all_rewards
        """
        all_steps, all_rewards = [], []

        for _ in range(n_episodes):
            state, _     = env.reset()
            done         = False
            steps        = 0
            total_reward = 0.0

            while not done and steps < self.max_steps:
                action                              = self.select_action(state)
                state, reward, terminated, truncated, _ = env.env.step(action)
                done          = terminated or truncated
                total_reward += reward
                steps        += 1

            all_steps.append(steps)
            all_rewards.append(total_reward)

        results = {
            "mean_steps"  : sum(all_steps)   / len(all_steps),
            "mean_reward" : sum(all_rewards) / len(all_rewards),
            "all_steps"   : all_steps,
            "all_rewards" : all_rewards,
        }

        self._print_results(results, n_episodes)
        return results

    # ── Private helpers ───────────────────────────────────────────────────

    def _print_results(self, r: dict, n_episodes: int) -> None:
        print(f"\n{'─'*55}")
        print(f"  BruteForce over {n_episodes} episodes")
        print(f"  Mean steps  : {r['mean_steps']:.1f}")
        print(f"  Mean reward : {r['mean_reward']:.2f}")
        print(f"{'─'*55}\n")

    def __repr__(self) -> str:
        return f"BruteForceAgent(n_actions={self.n_actions}, max_steps={self.max_steps})"