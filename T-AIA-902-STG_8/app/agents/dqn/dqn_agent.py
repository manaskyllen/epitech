"""
dqn_agent.py – Deep Q-Network agent for Taxi-v3 (T-AIA Epitech Project)

Architecture
────────────
  - Fully-connected neural network (NumPy only, no ML framework)
  - Adam optimizer for stable gradient descent
  - Experience replay buffer (breaks temporal correlations between samples)
  - Separate target network (frozen copy, periodically synced) to stabilise
    the Bellman target and prevent Q-value oscillations
  - Epsilon-greedy exploration with per-episode multiplicative decay

Reference: Mnih et al., "Human-level control through deep reinforcement learning"
           Nature 518, 529–533 (2015)
"""

import numpy as np
import random
from collections import deque

from agents.base_agent import BaseAgent
from utils.input_validation import validate_positive_int


# ─────────────────────────────────────────────
#  Neural network (NumPy, fully connected)
# ─────────────────────────────────────────────

class _Network:
    """
    Fully-connected feed-forward network.

    Hidden layers use ReLU activations; the output layer is linear so that
    Q-values can be arbitrarily positive or negative.

    Trained with mini-batch gradient descent and the Adam optimizer,
    which adapts the learning rate per-parameter — much more stable than
    vanilla SGD for deep RL.

    Parameters
    ----------
    layer_sizes : list of ints, e.g. [500, 128, 64, 6]
    lr          : Adam base learning rate
    """

    def __init__(self, layer_sizes: list, lr: float = 0.001):
        self.lr = lr
        L = len(layer_sizes) - 1

        # He initialisation: variance = 2/fan_in — optimal for ReLU networks
        self.W = [
            np.random.randn(layer_sizes[i], layer_sizes[i + 1]).astype(np.float32)
            * np.sqrt(2.0 / layer_sizes[i])
            for i in range(L)
        ]
        self.b = [np.zeros(layer_sizes[i + 1], dtype=np.float32) for i in range(L)]

        # Adam moment estimates (first and second)
        self.mW = [np.zeros_like(w) for w in self.W]
        self.vW = [np.zeros_like(w) for w in self.W]
        self.mb = [np.zeros_like(b) for b in self.b]
        self.vb = [np.zeros_like(b) for b in self.b]
        self.t = 0  # Adam global timestep (for bias correction)

        self._cache: dict = {}  # activations & pre-activations used by backprop

    # ── Forward pass ─────────────────────────────────────────────────────

    def forward(self, x: np.ndarray) -> np.ndarray:
        """
        Full forward pass — caches intermediates for backpropagation.

        x   : (batch, n_in)
        out : (batch, n_out)
        """
        a = [x]   # a[i] = activation before layer i (a[0] = raw input)
        z = []    # z[i] = pre-activation at layer i (before relu / linear)
        h = x
        for i, (w, b) in enumerate(zip(self.W, self.b)):
            zi = h @ w + b
            z.append(zi)
            h = np.maximum(0.0, zi) if i < len(self.W) - 1 else zi
            a.append(h)
        self._cache = {"a": a, "z": z}
        return h

    def predict(self, x: np.ndarray) -> np.ndarray:
        """
        Inference-only forward pass — no cache, used when gradients are
        not needed (e.g. action selection, target network evaluation).
        """
        h = x
        for i, (w, b) in enumerate(zip(self.W, self.b)):
            h = h @ w + b
            if i < len(self.W) - 1:
                h = np.maximum(0.0, h)
        return h

    # ── Backward pass + Adam weight update ───────────────────────────────

    def train_step(
        self,
        x: np.ndarray,
        targets: np.ndarray,
        b1: float = 0.9,
        b2: float = 0.999,
        eps: float = 1e-8,
    ) -> float:
        """
        One gradient-descent step minimising MSE(Q_online(s), targets).

        Backpropagation derivation
        ──────────────────────────
        For each layer i (iterating from last to first):

          • Last layer (linear output):
              dL/dz[i] = (2/N) * (output − target)

          • Hidden layers (ReLU):
              dL/dz[i] = dL/da[i+1] * relu'(z[i])
                       = dL/dz[i+1] @ W[i+1].T * (z[i] > 0)

          • Gradients:
              dL/dW[i] = a[i].T @ dL/dz[i]
              dL/db[i] = sum(dL/dz[i], axis=0)

        Returns the MSE loss (for optional logging).
        """
        output = self.forward(x)
        loss = float(np.mean((output - targets) ** 2))

        N = x.shape[0]
        # Gradient at output (MSE, linear layer → derivative passes through)
        grad_z = (2.0 / N) * (output - targets)

        grads_w = [np.zeros_like(w) for w in self.W]
        grads_b = [np.zeros_like(b) for b in self.b]

        for i in reversed(range(len(self.W))):
            if i < len(self.W) - 1:
                # Apply ReLU gradient: dL/da → dL/dz
                grad_z = grad_z * (self._cache["z"][i] > 0).astype(np.float32)

            grads_w[i] = self._cache["a"][i].T @ grad_z
            grads_b[i] = grad_z.sum(axis=0)

            if i > 0:
                # Propagate gradient to previous layer's activation
                grad_z = grad_z @ self.W[i].T

        # Adam update
        self.t += 1
        for i in range(len(self.W)):
            self.mW[i] = b1 * self.mW[i] + (1 - b1) * grads_w[i]
            self.vW[i] = b2 * self.vW[i] + (1 - b2) * (grads_w[i] ** 2)
            mW_hat = self.mW[i] / (1 - b1 ** self.t)
            vW_hat = self.vW[i] / (1 - b2 ** self.t)
            self.W[i] -= self.lr * mW_hat / (np.sqrt(vW_hat) + eps)

            self.mb[i] = b1 * self.mb[i] + (1 - b1) * grads_b[i]
            self.vb[i] = b2 * self.vb[i] + (1 - b2) * (grads_b[i] ** 2)
            mb_hat = self.mb[i] / (1 - b1 ** self.t)
            vb_hat = self.vb[i] / (1 - b2 ** self.t)
            self.b[i] -= self.lr * mb_hat / (np.sqrt(vb_hat) + eps)

        return loss

    # ── Target network synchronisation ───────────────────────────────────

    def copy_weights_from(self, other: "_Network") -> None:
        """Hard-copy all weights and biases from another network."""
        for i in range(len(self.W)):
            self.W[i] = other.W[i].copy()
            self.b[i] = other.b[i].copy()

    # ── Persistence ───────────────────────────────────────────────────────

    def save(self, path: str) -> None:
        arrays = {}
        for i, (w, b) in enumerate(zip(self.W, self.b)):
            arrays[f"W{i}"] = w
            arrays[f"b{i}"] = b
        np.savez(path, **arrays)

    def load(self, path: str) -> None:
        data = np.load(path)
        for i in range(len(self.W)):
            self.W[i] = data[f"W{i}"].astype(np.float32)
            self.b[i] = data[f"b{i}"].astype(np.float32)


# ─────────────────────────────────────────────
#  Replay buffer
# ─────────────────────────────────────────────

class _ReplayBuffer:
    """
    Circular buffer of (state, action, reward, next_state, done) transitions.

    Experience replay is critical to DQN: training on randomly sampled past
    transitions instead of consecutive ones breaks the temporal correlations
    that would otherwise bias the gradient and destabilise learning.
    """

    def __init__(self, capacity: int):
        self._buf = deque(maxlen=capacity)

    def push(self, state: int, action: int, reward: float,
             next_state: int, done: bool) -> None:
        self._buf.append((state, action, reward, next_state, done))

    def sample(self, batch_size: int) -> list:
        return random.sample(self._buf, batch_size)

    def __len__(self) -> int:
        return len(self._buf)


# ─────────────────────────────────────────────
#  DQN Agent
# ─────────────────────────────────────────────

class DQNAgent(BaseAgent):
    """
    Deep Q-Network agent for Taxi-v3.

    The agent maps the discrete state integer to a one-hot vector of
    length n_states (500), which is fed into a small fully-connected
    neural network that outputs one Q-value per action.

    Why one-hot encoding?
    ─────────────────────
    Taxi-v3 has 500 discrete states with no natural metric between them
    (state 42 is not "close" to state 43 in any geometric sense). A raw
    integer input would force the network to discover an arbitrary ordering.
    One-hot encoding treats each state as an independent entity and lets the
    network learn an unbiased embedding from scratch.

    Parameters
    ----------
    n_states           : number of discrete states (500 for Taxi-v3)
    n_actions          : number of discrete actions (6 for Taxi-v3)
    alpha              : Adam learning rate for the neural network
                         (typical range 1e-4 – 1e-2; much smaller than tabular α)
    gamma              : discount factor — same role as in Q-learning
    epsilon            : initial exploration rate
    epsilon_min        : minimum exploration floor
    epsilon_decay      : per-episode multiplicative decay of epsilon
    batch_size         : transitions sampled per gradient step
                         (too small → noisy gradients; too large → slow updates)
    buffer_size        : replay buffer capacity
                         (too small → correlated samples; too large → stale data)
    target_update_freq : gradient steps between hard target-network syncs
                         (too low → moving target problem;
                          too high → slow Bellman bootstrapping)
    hidden_sizes       : tuple of hidden layer widths, e.g. (128, 64)
    """

    def __init__(
        self,
        n_states: int = 500,
        n_actions: int = 6,
        alpha: float = 0.001,
        gamma: float = 0.99,
        epsilon: float = 1.0,
        epsilon_min: float = 0.01,
        epsilon_decay: float = 0.995,
        batch_size: int = 64,
        buffer_size: int = 10_000,
        target_update_freq: int = 200,
        hidden_sizes: tuple = (128, 64),
    ):
        validate_positive_int(batch_size, "batch_size")
        validate_positive_int(buffer_size, "buffer_size")
        validate_positive_int(target_update_freq, "target_update_freq")
        for idx, size in enumerate(hidden_sizes, 1):
            validate_positive_int(size, f"hidden_sizes[{idx}]")

        self.n_states          = n_states
        self.n_actions         = n_actions
        self.alpha             = alpha
        self.gamma             = gamma
        self.epsilon           = epsilon
        self.epsilon_min       = epsilon_min
        self.epsilon_decay     = epsilon_decay
        self.batch_size        = batch_size
        self.buffer_size       = buffer_size
        self.target_update_freq = target_update_freq
        self.hidden_sizes       = tuple(hidden_sizes)

        layer_sizes = [n_states, *hidden_sizes, n_actions]
        self._online = _Network(layer_sizes, lr=alpha)  # updated every learning step
        self._target = _Network(layer_sizes, lr=alpha)  # frozen copy, periodically synced
        self._target.copy_weights_from(self._online)

        self._buffer      = _ReplayBuffer(buffer_size)
        self._learn_steps = 0  # counts gradient steps (drives target sync schedule)

    # ── State encoding ────────────────────────────────────────────────────

    def _one_hot(self, state: int) -> np.ndarray:
        """Scalar state → (1, n_states) float32 one-hot vector."""
        v = np.zeros((1, self.n_states), dtype=np.float32)
        v[0, state] = 1.0
        return v

    def _batch_one_hot(self, states: np.ndarray) -> np.ndarray:
        """Array of state ints → (N, n_states) float32 one-hot matrix."""
        out = np.zeros((len(states), self.n_states), dtype=np.float32)
        out[np.arange(len(states)), states] = 1.0
        return out

    # ── Action selection (ε-greedy) ───────────────────────────────────────

    def select_action(self, state: int) -> int:
        """Random action with probability ε, greedy otherwise (training)."""
        if random.random() < self.epsilon:
            return random.randint(0, self.n_actions - 1)
        q = self._online.predict(self._one_hot(state))
        return int(np.argmax(q[0]))

    def greedy_action(self, state: int) -> int:
        """Pure greedy action — always picks argmax Q (evaluation)."""
        q = self._online.predict(self._one_hot(state))
        return int(np.argmax(q[0]))

    # ── Learning ──────────────────────────────────────────────────────────

    def update(self, state: int, action: int, reward: float,
               next_state: int, done: bool) -> None:
        """
        Store the transition in the replay buffer, then — once the buffer
        holds at least one full batch — perform one gradient-descent step.

        Called every environment step by the Trainer.
        """
        self._buffer.push(state, action, reward, next_state, done)

        if len(self._buffer) >= self.batch_size:
            self._learn()

    def _learn(self) -> None:
        """
        Sample a random mini-batch and update the online network.

        DQN Bellman target construction
        ────────────────────────────────
        For each transition (s, a, r, s', done):

          target_a = r + γ · max_a' Q_target(s', a')   if not done
          target_a = r                                   if done

        The target for all OTHER actions is kept equal to the online network's
        current prediction, so their gradient contribution is exactly zero.
        Only the taken action's Q-value is pulled towards the TD target.

        Using the TARGET network (not the online one) to compute Q(s', ·)
        is the key stability trick: it decouples the "what we predict" network
        from the "what we bootstrap from" network, preventing feedback loops.
        """
        batch = self._buffer.sample(self.batch_size)
        states, actions, rewards, next_states, dones = zip(*batch)

        states      = np.array(states,      dtype=np.int32)
        actions     = np.array(actions,     dtype=np.int32)
        rewards     = np.array(rewards,     dtype=np.float32)
        next_states = np.array(next_states, dtype=np.int32)
        dones       = np.array(dones,       dtype=np.float32)

        s  = self._batch_one_hot(states)
        s_ = self._batch_one_hot(next_states)

        # Bellman targets for taken actions
        q_next   = self._target.predict(s_)          # (batch, n_actions)
        td_target = rewards + self.gamma * np.max(q_next, axis=1) * (1.0 - dones)

        # Full target matrix: start from current predictions so non-taken
        # actions contribute zero gradient
        targets         = self._online.predict(s).copy()
        targets[np.arange(self.batch_size), actions] = td_target

        self._online.train_step(s, targets)
        self._learn_steps += 1

        # Periodically copy online weights to target network (hard update)
        if self._learn_steps % self.target_update_freq == 0:
            self._target.copy_weights_from(self._online)

    # ── Epsilon decay ─────────────────────────────────────────────────────

    def decay_epsilon(self) -> None:
        """Multiplicative decay per episode, clamped to epsilon_min."""
        self.epsilon = max(self.epsilon_min, self.epsilon * self.epsilon_decay)

    # ── Persistence ───────────────────────────────────────────────────────

    def save(self, path: str) -> None:
        """Save online network weights to <path>.npz."""
        self._online.save(path)
        print(f"[DQN] Weights saved → {path}.npz")

    def load(self, path: str) -> None:
        """Load weights from <path>.npz and sync the target network."""
        if path.endswith(".npy"):
            raise ValueError("DQNAgent expects a .npz file, not a .npy file.")
        full = path if path.endswith(".npz") else path + ".npz"
        self._online.load(full)
        self._target.copy_weights_from(self._online)
        print(f"[DQN] Weights loaded ← {full}")

    def __repr__(self) -> str:
        return (
            f"DQNAgent(α={self.alpha}, γ={self.gamma}, ε={self.epsilon:.4f}, "
            f"buffer={len(self._buffer)}/{self.buffer_size}, "
            f"steps={self._learn_steps})"
        )
