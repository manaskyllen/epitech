"""
config.py – Centralized hyperparameter configuration for T-AIA Taxi Driver project.
"""

import os as _os

# ─────────────────────────────────────────────
#  Environment
# ─────────────────────────────────────────────
ENV_NAME = "Taxi-v3"
N_STATES = 500
N_ACTIONS = 6

# ─────────────────────────────────────────────
#  User mode defaults  (tunable via CLI)
# ─────────────────────────────────────────────
USER_PARAMS = {
    "alpha": 0.1,           # learning rate
    "gamma": 0.99,          # discount factor
    "epsilon": 1.0,         # initial exploration rate
    "epsilon_min": 0.01,    # minimum exploration rate
    "epsilon_decay": 0.995, # multiplicative decay per episode
}

# ─────────────────────────────────────────────
#  Time-limited mode  (pre-optimised)
# ─────────────────────────────────────────────
OPTIMIZED_PARAMS = {
    "alpha": 0.15,
    "gamma": 0.99,
    "epsilon": 1.0,
    "epsilon_min": 0.01,
    "epsilon_decay": 0.997,
}

# ─────────────────────────────────────────────
#  DQN user defaults  (tunable via CLI)
# ─────────────────────────────────────────────
DQN_USER_PARAMS = {
    "alpha":              0.001,   # Adam learning rate (much smaller than tabular α)
    "gamma":              0.99,
    "epsilon":            1.0,
    "epsilon_min":        0.01,
    "epsilon_decay":      0.995,
    "batch_size":         64,      # transitions sampled per gradient step
    "buffer_size":        10_000,  # replay buffer capacity
    "target_update_freq": 200,     # gradient steps between target network syncs
}

# ─────────────────────────────────────────────
#  DQN time-limited (pre-optimised)
# ─────────────────────────────────────────────
DQN_OPTIMIZED_PARAMS = {
    "alpha":              0.001,
    "gamma":              0.99,
    "epsilon":            1.0,
    "epsilon_min":        0.01,
    "epsilon_decay":      0.997,
    "batch_size":         64,
    "buffer_size":        10_000,
    "target_update_freq": 200,
}

# ─────────────────────────────────────────────
#  Training defaults
# ─────────────────────────────────────────────
DEFAULT_TRAIN_EPISODES = 5000
DEFAULT_TEST_EPISODES  = 100
MAX_STEPS_PER_EPISODE  = 200   # safety cap to avoid infinite loops

# ─────────────────────────────────────────────
#  Rewards (Taxi-v3 native — kept here for reference & overriding)
# ─────────────────────────────────────────────
REWARD_DROP_OFF_SUCCESS = +20
REWARD_STEP             = -1
REWARD_ILLEGAL_ACTION   = -10

# ─────────────────────────────────────────────
#  Paths  (absolute, anchored to project root — works regardless of CWD)
# ─────────────────────────────────────────────
# config.py lives at  <project>/app/config/config.py
# project root is two levels up  →  <project>/saved_models/
SAVE_DIR = _os.path.normpath(
    _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", "saved_models")
)

OUTPUTS_DIR = _os.path.normpath(
    _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", "outputs")
)

FINAL_MODELS_DIR = _os.path.normpath(
    _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", "artifacts", "final_models")
)
