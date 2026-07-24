"""
base_agent.py – Abstract base class for all agents in the T-AIA project.
"""

from abc import ABC, abstractmethod


class BaseAgent(ABC):
    """
    Abstract base class that every agent must implement.
    """

    @abstractmethod
    def select_action(self, state: int) -> int:
        """Select an action given the current state (used during training)."""
        raise NotImplementedError

    @abstractmethod
    def greedy_action(self, state: int) -> int:
        """Select the best known action (used during evaluation, no exploration)."""
        raise NotImplementedError

    @abstractmethod
    def update(self, state: int, action: int, reward: float,
               next_state: int, done: bool) -> None:
        """Update internal knowledge (Q-table, weights, etc.)."""
        raise NotImplementedError

    def decay_epsilon(self) -> None:
        """Optional: decay exploration rate after each episode."""
        pass

    def save(self, path: str) -> None:
        """Optional: persist the agent's model to disk."""
        pass

    def load(self, path: str) -> None:
        """Optional: load a saved model from disk."""
        pass
