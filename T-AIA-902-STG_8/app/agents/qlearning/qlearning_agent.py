"""
qlearning_agent.py – Q-Learning agents for Taxi-v3 (T-AIA Epitech Project)

Includes:
  - QLearningAgent      : standard tabular Q-Learning
  - DoubleQLearningAgent: Double Q-Learning (reduces maximisation bias)
  - BruteForceAgent     : naive random baseline (~350 steps)
  - create_agent()      : factory function
"""

import numpy as np
import random

from agents.base_agent import BaseAgent
from agents.bruteforce.brute_force_agent import BruteForceAgent
from agents.dqn.dqn_agent import DQNAgent
from config.hyperparams import validate_hyperparams
from config.config import DQN_OPTIMIZED_PARAMS


# ─────────────────────────────────────────────
#  Q-Learning Agent
# ─────────────────────────────────────────────

class QLearningAgent(BaseAgent):
    """
    Tabular Q-Learning agent.

    Parameters
    ----------
    n_states       : int   – number of discrete states (500 for Taxi-v3)
    n_actions      : int   – number of discrete actions (6 for Taxi-v3)
    alpha          : float – learning rate
    gamma          : float – discount factor
    epsilon        : float – initial exploration rate
    epsilon_min    : float – minimum exploration rate
    epsilon_decay  : float – multiplicative decay applied each episode
    """

    def __init__(
        self,
        n_states: int = 500,
        n_actions: int = 6,
        alpha: float = 0.1,
        gamma: float = 0.99,
        epsilon: float = 1.0,
        epsilon_min: float = 0.01,
        epsilon_decay: float = 0.995,
    ):
        self.n_states      = n_states
        self.n_actions     = n_actions
        self.alpha         = alpha
        self.gamma         = gamma
        self.epsilon       = epsilon
        self.epsilon_min   = epsilon_min
        self.epsilon_decay = epsilon_decay

        # Q-table initialised to zeros
        self.q_table = np.zeros((n_states, n_actions))

    # ── Action selection (ε-greedy) ──────────────────────────────────────

    def select_action(self, state: int) -> int:
        """Return a random action with probability ε, greedy otherwise."""
        if random.random() < self.epsilon:
            return random.randint(0, self.n_actions - 1)
        return int(np.argmax(self.q_table[state]))

    def greedy_action(self, state: int) -> int:
        """Pure greedy selection (used during evaluation)."""
        return int(np.argmax(self.q_table[state]))

    # ── Q-table update (Bellman equation) ───────────────────────────────

    def update(self, state: int, action: int, reward: float,
               next_state: int, done: bool) -> None:
        """
        Q(s,a) ← Q(s,a) + α · [r + γ · max_a' Q(s',a') − Q(s,a)]
        """
        target = reward if done else reward + self.gamma * np.max(self.q_table[next_state])
        self.q_table[state, action] += self.alpha * (target - self.q_table[state, action])

    # ── Epsilon decay ────────────────────────────────────────────────────

    def decay_epsilon(self) -> None:
        """Apply multiplicative decay, clamped to epsilon_min."""
        self.epsilon = max(self.epsilon_min, self.epsilon * self.epsilon_decay)

    # ── Persistence ──────────────────────────────────────────────────────

    def save(self, path: str) -> None:
        np.save(path, self.q_table)
        print(f"[QLearning] Q-table saved → {path}")

    def load(self, path: str) -> None:
        if path.endswith(".npz"):
            raise ValueError("QLearningAgent expects a .npy file, not a .npz file.")
        full = path if path.endswith(".npy") else path + ".npy"
        self.q_table = np.load(full)
        print(f"[QLearning] Q-table loaded ← {path}")

    def __repr__(self) -> str:
        return (
            f"QLearningAgent(α={self.alpha}, γ={self.gamma}, "
            f"ε={self.epsilon:.4f}, states={self.n_states}, actions={self.n_actions})"
        )


# ─────────────────────────────────────────────
#  Double Q-Learning Agent
# ─────────────────────────────────────────────

class DoubleQLearningAgent(BaseAgent):
    """
    Double Q-Learning agent.

    Maintains two independent Q-tables (A and B) to reduce maximisation bias.
    At each step one table is chosen at random to perform the update while the
    other is used to evaluate the greedy action.

    Reference: Hasselt (2010) – "Double Q-learning"
    """

    def __init__(
        self,
        n_states: int = 500,
        n_actions: int = 6,
        alpha: float = 0.1,
        gamma: float = 0.99,
        epsilon: float = 1.0,
        epsilon_min: float = 0.01,
        epsilon_decay: float = 0.995,
    ):
        self.n_states      = n_states
        self.n_actions     = n_actions
        self.alpha         = alpha
        self.gamma         = gamma
        self.epsilon       = epsilon
        self.epsilon_min   = epsilon_min
        self.epsilon_decay = epsilon_decay

        self.q_a = np.zeros((n_states, n_actions))
        self.q_b = np.zeros((n_states, n_actions))

    # ── Action selection ──────────────────────────────────────────────────

    def select_action(self, state: int) -> int:
        if random.random() < self.epsilon:
            return random.randint(0, self.n_actions - 1)
        return int(np.argmax(self.q_a[state] + self.q_b[state]))

    def greedy_action(self, state: int) -> int:
        return int(np.argmax(self.q_a[state] + self.q_b[state]))

    # ── Double Q update ───────────────────────────────────────────────────

    def update(self, state: int, action: int, reward: float,
               next_state: int, done: bool) -> None:
        """
        With probability 0.5:
          Update A: Q_A(s,a) ← Q_A(s,a) + α[r + γ Q_B(s', argmax_a Q_A(s',a)) − Q_A(s,a)]
          Update B: symmetric
        """
        if random.random() < 0.5:
            best_next = int(np.argmax(self.q_a[next_state]))
            target = reward if done else reward + self.gamma * self.q_b[next_state, best_next]
            self.q_a[state, action] += self.alpha * (target - self.q_a[state, action])
        else:
            best_next = int(np.argmax(self.q_b[next_state]))
            target = reward if done else reward + self.gamma * self.q_a[next_state, best_next]
            self.q_b[state, action] += self.alpha * (target - self.q_b[state, action])

    # ── Epsilon decay ─────────────────────────────────────────────────────

    def decay_epsilon(self) -> None:
        self.epsilon = max(self.epsilon_min, self.epsilon * self.epsilon_decay)

    # ── Persistence ───────────────────────────────────────────────────────

    def save(self, path: str) -> None:
        np.save(path + "_A", self.q_a)
        np.save(path + "_B", self.q_b)
        print(f"[DoubleQLearning] Q-tables saved → {path}_A / {path}_B")

    def load(self, path: str) -> None:
        if path.endswith(".npz"):
            raise ValueError("DoubleQLearningAgent expects two .npy files, not a .npz file.")
        base = path[:-4] if path.endswith(".npy") else path
        if base.endswith("_A"):
            base = base[:-2]
        self.q_a = np.load(base + "_A.npy")
        self.q_b = np.load(base + "_B.npy")
        print(f"[DoubleQLearning] Q-tables loaded ← {path}_A / {path}_B")

    def __repr__(self) -> str:
        return (
            f"DoubleQLearningAgent(α={self.alpha}, γ={self.gamma}, "
            f"ε={self.epsilon:.4f})"
        )


# ─────────────────────────────────────────────
#  Agent factory
# ─────────────────────────────────────────────

_TABULAR_OPTIMIZED = {
    "alpha": 0.15,
    "gamma": 0.99,
    "epsilon": 1.0,
    "epsilon_min": 0.01,
    "epsilon_decay": 0.997,
}

# DQN-specific extra params accepted by create_agent via **user_kwargs
_DQN_EXTRA_KEYS = ("batch_size", "buffer_size", "target_update_freq")

AGENT_REGISTRY = {
    "qlearning":        QLearningAgent,
    "double_qlearning": DoubleQLearningAgent,
    "bruteforce":       BruteForceAgent,
    "dqn":              DQNAgent,
}


def create_agent(
    agent_type: str = "qlearning",
    mode: str = "user",
    n_states: int = 500,
    n_actions: int = 6,
    n_episodes: int | None = None,
    **user_kwargs,
) -> BaseAgent:
    """
    Factory that instantiates the requested agent.

    Parameters
    ----------
    agent_type  : 'qlearning' | 'double_qlearning' | 'bruteforce' | 'dqn'
    mode        : 'user' → use user_kwargs / 'time' → pre-optimised params
    n_episodes  : total training episodes — enables the decay speed check
    **user_kwargs : hyperparameters; DQN also accepts batch_size,
                    buffer_size, target_update_freq
    """
    agent_type = agent_type.lower()

    if agent_type not in AGENT_REGISTRY:
        raise ValueError(
            f"Unknown agent '{agent_type}'. "
            f"Available: {list(AGENT_REGISTRY.keys())}"
        )

    if agent_type == "bruteforce":
        return BruteForceAgent(n_actions=n_actions)

    AgentClass = AGENT_REGISTRY[agent_type]

    if agent_type == "dqn":
        if mode == "time":
            params = {**DQN_OPTIMIZED_PARAMS, "n_states": n_states, "n_actions": n_actions}
            print(f"[Factory] Time-limited mode → DQN optimised params: {DQN_OPTIMIZED_PARAMS}")
        else:
            params = {
                "n_states":           n_states,
                "n_actions":          n_actions,
                "alpha":              user_kwargs.get("alpha",              0.001),
                "gamma":              user_kwargs.get("gamma",              0.99),
                "epsilon":            user_kwargs.get("epsilon",            1.0),
                "epsilon_min":        user_kwargs.get("epsilon_min",        0.01),
                "epsilon_decay":      user_kwargs.get("epsilon_decay",      0.995),
                "batch_size":         user_kwargs.get("batch_size",         64),
                "buffer_size":        user_kwargs.get("buffer_size",        10_000),
                "target_update_freq": user_kwargs.get("target_update_freq", 200),
                "hidden_sizes":       tuple(user_kwargs.get("hidden_sizes", (128, 64))),
            }
            print(f"[Factory] User mode → DQN params: {params}")
    elif mode == "time":
        params = {**_TABULAR_OPTIMIZED, "n_states": n_states, "n_actions": n_actions}
        print(f"[Factory] Time-limited mode → optimised params: {_TABULAR_OPTIMIZED}")
    else:
        params = {
            "n_states":      n_states,
            "n_actions":     n_actions,
            "alpha":         user_kwargs.get("alpha",         0.1),
            "gamma":         user_kwargs.get("gamma",         0.99),
            "epsilon":       user_kwargs.get("epsilon",       1.0),
            "epsilon_min":   user_kwargs.get("epsilon_min",   0.01),
            "epsilon_decay": user_kwargs.get("epsilon_decay", 0.995),
        }
        print(f"[Factory] User mode → params: {params}")

    rl_params = {k: params[k] for k in ("alpha", "gamma", "epsilon", "epsilon_min", "epsilon_decay")}
    validate_hyperparams(**rl_params, n_episodes=n_episodes)

    return AgentClass(**params)
