"""
trainer.py – Training loop for Q-Learning agents on Taxi-v3.
"""

import time
import numpy as np
from config.config import MAX_STEPS_PER_EPISODE
from env.taxi_env import TaxiEnv
from utils.input_validation import validate_positive_int


class Trainer:
    """
    Runs the training loop for any agent implementing BaseAgent.

    Parameters
    ----------
    agent       : a QLearningAgent or DoubleQLearningAgent instance
    n_episodes  : number of training episodes
    max_steps   : max steps per episode (safety cap)
    verbose     : print progress every N episodes (0 = silent)
    """

    def __init__(self, agent, n_episodes: int, max_steps: int = MAX_STEPS_PER_EPISODE, verbose: int = 500):
        validate_positive_int(n_episodes, "n_episodes")
        validate_positive_int(max_steps, "max_steps")
        self.agent      = agent
        self.n_episodes = n_episodes
        self.max_steps  = max_steps
        self.verbose    = verbose

        self.env = TaxiEnv(render_mode=None)   # no rendering during training

        # Recorded metrics (one value per episode)
        self.rewards_per_episode = []
        self.steps_per_episode   = []
        self.epsilons            = []
        self.training_time       = 0.0

    # ── Public API ────────────────────────────────────────────────────────

    def train(self) -> dict:
        """
        Run the full training loop.

        Returns
        -------
        dict with keys: rewards, steps, epsilons, mean_reward,
                        mean_steps, training_time
        """
        print(f"\n{'='*55}")
        print(f"  Training  {self.agent.__class__.__name__}")
        print(f"  Episodes : {self.n_episodes}   Max steps/ep : {self.max_steps}")
        print(f"{'='*55}")

        start = time.time()

        for episode in range(1, self.n_episodes + 1):
            ep_reward, ep_steps = self._run_episode()
            self.rewards_per_episode.append(ep_reward)
            self.steps_per_episode.append(ep_steps)
            if hasattr(self.agent, "epsilon"):
                self.epsilons.append(self.agent.epsilon)
            self.agent.decay_epsilon()

            if self.verbose and episode % self.verbose == 0:
                mean_r = np.mean(self.rewards_per_episode[-self.verbose:])
                mean_s = np.mean(self.steps_per_episode[-self.verbose:])
                epsilon_info = ""
                if hasattr(self.agent, "epsilon"):
                    epsilon_info = f"  |  ε={self.agent.epsilon:.4f}"
                print(
                    f"  Ep {episode:>6}/{self.n_episodes}  |  "
                    f"avg reward: {mean_r:>7.2f}  |  "
                    f"avg steps: {mean_s:>6.1f}"
                    f"{epsilon_info}"
                )

        self.training_time = time.time() - start
        self.env.close()

        results = self._build_results()
        self._print_summary(results)
        return results

    # ── Private helpers ───────────────────────────────────────────────────

    def _run_episode(self):
        """Run a single training episode. Returns (total_reward, steps)."""
        state, _ = self.env.reset()
        total_reward = 0.0

        for step in range(1, self.max_steps + 1):
            action                         = self.agent.select_action(state)
            next_state, reward, done, _    = self.env.step(action)
            self.agent.update(state, action, reward, next_state, done)
            state        = next_state
            total_reward += reward
            if done:
                return total_reward, step

        return total_reward, self.max_steps   # hit the step cap

    def _build_results(self) -> dict:
        return {
            "rewards"       : self.rewards_per_episode,
            "steps"         : self.steps_per_episode,
            "epsilons"      : self.epsilons,
            "mean_reward"   : float(np.mean(self.rewards_per_episode)),
            "mean_steps"    : float(np.mean(self.steps_per_episode)),
            "training_time" : self.training_time,
        }

    def _print_summary(self, results: dict) -> None:
        print(f"\n{'─'*55}")
        print(f"  Training complete in {results['training_time']:.2f}s")
        print(f"  Mean reward : {results['mean_reward']:.2f}")
        print(f"  Mean steps  : {results['mean_steps']:.1f}")
        print(f"{'─'*55}\n")
