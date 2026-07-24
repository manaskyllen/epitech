"""
evaluator.py – Evaluate a trained agent on Taxi-v3.

Computes:
  - mean reward over N test episodes
  - mean steps  over N test episodes
  - mean time   per episode
  - success rate (episodes solved without hitting step cap)

Also supports displaying random rendered episodes in the terminal.
"""

import time
import random
import numpy as np
from config.config import MAX_STEPS_PER_EPISODE
from env.taxi_env import TaxiEnv
from utils.input_validation import validate_positive_int


class Evaluator:
    """
    Parameters
    ----------
    agent       : trained agent (must implement greedy_action)
    n_episodes  : number of test episodes
    max_steps   : step cap per episode
    """

    def __init__(self, agent, n_episodes: int, max_steps: int = MAX_STEPS_PER_EPISODE):
        validate_positive_int(n_episodes, "n_episodes")
        validate_positive_int(max_steps, "max_steps")
        self.agent      = agent
        self.n_episodes = n_episodes
        self.max_steps  = max_steps

    # ── Public API ────────────────────────────────────────────────────────

    def evaluate(self) -> dict:
        """
        Run greedy evaluation over n_episodes.

        Returns
        -------
        dict with keys: mean_reward, mean_steps, mean_time,
                        success_rate, all_rewards, all_steps
        """
        env = TaxiEnv(render_mode=None)

        all_rewards, all_steps, all_times = [], [], []

        for _ in range(self.n_episodes):
            state, _ = env.reset()
            total_reward = 0.0
            t0 = time.time()

            for step in range(1, self.max_steps + 1):
                action                      = self.agent.greedy_action(state)
                next_state, reward, done, _ = env.step(action)
                state        = next_state
                total_reward += reward
                if done:
                    break

            all_rewards.append(total_reward)
            all_steps.append(step)
            all_times.append(time.time() - t0)

        env.close()

        results = {
            "mean_reward"  : float(np.mean(all_rewards)),
            "mean_steps"   : float(np.mean(all_steps)),
            "mean_time"    : float(np.mean(all_times)),
            "success_rate" : float(np.mean([s < self.max_steps for s in all_steps])),
            "all_rewards"  : all_rewards,
            "all_steps"    : all_steps,
        }
        self._print_results(results)
        return results

    def display_episodes(self, n: int = 3) -> None:
        """
        Render N random episodes in the terminal using ANSI mode.

        Parameters
        ----------
        n : number of episodes to display
        """
        env = TaxiEnv(render_mode="ansi")
        print(f"\n{'='*55}")
        print(f"  Displaying {n} random rendered episode(s)")
        print(f"{'='*55}")

        for ep in range(1, n + 1):
            state, _ = env.reset()
            total_reward = 0.0
            print(f"\n── Episode {ep} ──────────────────────────")

            for step in range(1, self.max_steps + 1):
                env.render()
                action                      = self.agent.greedy_action(state)
                next_state, reward, done, _ = env.step(action)
                state        = next_state
                total_reward += reward
                time.sleep(0.05)   # small delay so the terminal is readable
                if done:
                    print(f"  ✓ Solved in {step} steps | reward: {total_reward:.0f}")
                    break
            else:
                print(f"  ✗ Not solved in {self.max_steps} steps | reward: {total_reward:.0f}")

        env.close()

    # ── Private helpers ───────────────────────────────────────────────────

    def _print_results(self, r: dict) -> None:
        print(f"\n{'─'*55}")
        print(f"  Evaluation over {self.n_episodes} episodes")
        print(f"  Mean reward   : {r['mean_reward']:.2f}")
        print(f"  Mean steps    : {r['mean_steps']:.1f}")
        print(f"  Mean time/ep  : {r['mean_time']*1000:.2f} ms")
        print(f"  Success rate  : {r['success_rate']*100:.1f}%")
        print(f"{'─'*55}\n")
