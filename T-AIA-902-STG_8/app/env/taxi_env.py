"""
taxi_env.py – Thin wrapper around the Gym Taxi-v3 environment.

Provides a consistent interface used by trainer and evaluator,
and makes it easy to swap or extend the environment later.
"""

import gymnasium as gym


class TaxiEnv:
    """
    Wrapper around gymnasium's Taxi-v3.

    Usage
    -----
    env = TaxiEnv()
    state, _ = env.reset()
    next_state, reward, done, info = env.step(action)
    env.render()
    env.close()
    """

    def __init__(self, render_mode: str = None):
        """
        Parameters
        ----------
        render_mode : None        → no rendering (fast, used during training)
                      'ansi'      → text render in terminal
                      'human'     → graphical render (if supported)
        """
        self.render_mode = render_mode
        self.env = gym.make("Taxi-v3", render_mode=render_mode)
        self.n_states  = self.env.observation_space.n   # 500
        self.n_actions = self.env.action_space.n        # 6

    def reset(self):
        """Reset the environment and return (state, info)."""
        return self.env.reset()

    def step(self, action: int):
        """
        Apply an action.

        Returns
        -------
        next_state : int
        reward     : float
        done       : bool   (terminated OR truncated)
        info       : dict
        """
        next_state, reward, terminated, truncated, info = self.env.step(action)
        done = terminated or truncated
        return next_state, reward, done, info

    def render(self):
        """Render the current frame (only works if render_mode was set)."""
        self.env.render()

    def close(self):
        """Clean up resources."""
        self.env.close()

    def sample_action(self) -> int:
        """Return a random valid action."""
        return self.env.action_space.sample()

    def __repr__(self) -> str:
        return f"TaxiEnv(n_states={self.n_states}, n_actions={self.n_actions}, render_mode={self.render_mode!r})"
