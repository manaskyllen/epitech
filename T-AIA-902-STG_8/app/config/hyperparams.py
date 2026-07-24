"""
hyperparams.py – Strict validation and diagnostics for RL hyperparameters.

Each validation function raises ValueError for mathematically invalid values
and prints a [WARN] message for technically valid but potentially harmful ones.
Pedagogical comments explain the concrete impact on learning.
"""

import math


# ─────────────────────────────────────────────
#  Internal helpers
# ─────────────────────────────────────────────

def _warn(msg: str) -> None:
    print(f"  [WARN] {msg}")


def _err(param: str, value: float, msg: str) -> None:
    raise ValueError(f"Invalid hyperparameter '{param}={value}': {msg}")


# ─────────────────────────────────────────────
#  Per-parameter validators
# ─────────────────────────────────────────────

def validate_alpha(alpha: float) -> None:
    """
    alpha – learning rate: controls how much each new experience overwrites
    the existing Q-value estimate.

    Impact on learning:
      - High alpha (→ 1): the agent quickly forgets past experiences and reacts
        strongly to each new reward signal — good for deterministic environments,
        but unstable in stochastic ones (Q-values oscillate).
      - Low alpha (→ 0): the agent barely updates and converges very slowly,
        though it averages out noise well.
      - Typical sweet spot: 0.05 – 0.3 for Taxi-v3.
    """
    if alpha <= 0:
        _err(
            "alpha", alpha,
            "alpha must be strictly > 0. "
            "alpha=0 means the agent never updates its Q-table and therefore never learns."
        )
    if alpha > 1:
        _err(
            "alpha", alpha,
            "alpha must be <= 1. "
            "alpha>1 makes updates overshoot the target, causing Q-values to diverge."
        )
    if alpha > 0.5:
        _warn(
            f"alpha={alpha} is high (> 0.5). "
            "Large learning rates often cause unstable Q-table updates in stochastic "
            "environments. Values above 0.5 can prevent convergence. "
            "Consider alpha ≤ 0.3."
        )


def validate_gamma(gamma: float) -> None:
    """
    gamma – discount factor: determines how much the agent values future rewards
    relative to immediate ones.

    Impact on learning:
      - gamma = 1.0: fully far-sighted — a reward 200 steps away counts as much
        as an immediate one. Works for episodic tasks, but slows convergence.
      - gamma → 0: myopic — the agent only cares about the next step reward.
        Dangerous for tasks requiring multi-step planning (e.g. navigating to
        the passenger before picking them up).
      - Typical sweet spot: 0.95 – 0.99 for Taxi-v3.
    """
    if gamma < 0:
        _err(
            "gamma", gamma,
            "gamma must be >= 0. "
            "A negative discount factor would penalise future rewards, "
            "which has no meaningful interpretation in standard RL."
        )
    if gamma > 1:
        _err(
            "gamma", gamma,
            "gamma must be <= 1. "
            "gamma > 1 causes the sum of discounted future rewards to diverge, "
            "making the Bellman equation unsolvable."
        )
    if gamma == 1.0:
        _warn(
            "gamma=1.0 disables reward discounting entirely. "
            "The agent treats a reward 200 steps away identically to an immediate one. "
            "For episodic tasks this is mathematically fine, but convergence is often "
            "slower. Consider gamma = 0.99."
        )
    if gamma < 0.5:
        _warn(
            f"gamma={gamma} is very low. "
            "The agent will act myopically and struggle to learn multi-step strategies. "
            "In Taxi-v3, reaching the passenger requires several consecutive decisions — "
            "a discount this severe will make those long-horizon rewards nearly invisible. "
            "Consider gamma >= 0.9."
        )


def validate_epsilon(epsilon: float) -> None:
    """
    epsilon – initial exploration rate: probability that the agent picks a
    random action instead of the greedy one.

    Impact on learning:
      - epsilon = 1.0 (standard): pure exploration at the start — the agent
        discovers the environment before exploiting any learned policy.
      - epsilon = 0.0: pure exploitation from step one — the agent never
        explores, so it can only reinforce whatever policy the zero-initialised
        Q-table suggests (always the same action per state).
    """
    if epsilon < 0 or epsilon > 1:
        _err(
            "epsilon", epsilon,
            "epsilon must be in [0, 1]. "
            "It represents a probability, which is mathematically bounded to [0, 1]."
        )


def validate_epsilon_min(epsilon_min: float, epsilon: float) -> None:
    """
    epsilon_min – exploration floor: the agent always keeps at least this level
    of random exploration, even after full training.

    Impact on learning:
      - epsilon_min > 0: ensures the agent keeps probing the environment forever,
        which helps in non-stationary or large state spaces (prevents greedy lock-in).
      - epsilon_min = 0: the agent will eventually act fully greedily. Fine if
        training is long enough and the state space well-covered, but the agent
        may never revisit under-explored states.
    """
    if epsilon_min < 0:
        _err(
            "epsilon_min", epsilon_min,
            "epsilon_min must be >= 0. "
            "It represents a probability, so it cannot be negative."
        )
    if epsilon_min > epsilon:
        _err(
            "epsilon_min", epsilon_min,
            f"epsilon_min must be <= epsilon (current epsilon={epsilon}). "
            "The minimum exploration floor cannot exceed the starting exploration rate — "
            "that would make decay immediately saturate at a value above epsilon."
        )
    if epsilon_min == 0:
        _warn(
            "epsilon_min=0 means the agent will eventually stop exploring entirely. "
            "This can cause it to get stuck exploiting a suboptimal policy and never "
            "discover better state-action pairs. A small value like 0.01 is safer."
        )


def validate_epsilon_decay(epsilon_decay: float) -> None:
    """
    epsilon_decay – per-episode multiplicative decay applied to epsilon.

    Impact on learning:
      - Decay close to 1 (e.g. 0.9999): very slow transition from exploration
        to exploitation — the agent stays random for many episodes.
      - Decay far from 1 (e.g. 0.9): rapid transition — the agent quickly
        becomes greedy, potentially before it has learned a good policy.
      - Typical sweet spot: 0.995 – 0.999 for 5 000–20 000 episodes.
    """
    if epsilon_decay <= 0:
        _err(
            "epsilon_decay", epsilon_decay,
            "epsilon_decay must be strictly > 0. "
            "A non-positive decay would instantly collapse epsilon to 0 or below, "
            "stopping all exploration on the very first episode."
        )
    if epsilon_decay > 1:
        _err(
            "epsilon_decay", epsilon_decay,
            "epsilon_decay must be <= 1. "
            "A value > 1 would increase epsilon each episode, making the agent "
            "explore more and more over time instead of transitioning to exploitation."
        )
    if epsilon_decay < 0.9:
        _warn(
            f"epsilon_decay={epsilon_decay} is very fast. "
            "Epsilon will collapse to epsilon_min within a handful of episodes, "
            "leaving the agent no time to explore the state space adequately. "
            "The resulting policy may be very suboptimal."
        )
    if epsilon_decay > 0.9999:
        _warn(
            f"epsilon_decay={epsilon_decay} decays extremely slowly. "
            "The agent will remain in near-random exploration for most of training "
            "and may never meaningfully exploit its learned Q-values within your "
            "episode budget."
        )


# ─────────────────────────────────────────────
#  Decay speed diagnostics
# ─────────────────────────────────────────────

def estimate_decay_episodes(
    epsilon: float,
    epsilon_min: float,
    epsilon_decay: float,
) -> int | float:
    """
    Estimate after how many episodes epsilon will reach epsilon_min.

    Derivation: epsilon * decay^n = epsilon_min
                → n = log(epsilon_min / epsilon) / log(decay)

    Returns
    -------
    int   : number of episodes (rounded up)
    0     : epsilon is already at or below epsilon_min
    inf   : epsilon_decay == 1 (epsilon never decays)
    """
    if epsilon <= epsilon_min:
        return 0
    if epsilon_decay == 1.0 or epsilon_min == 0:
        # decay=1 → never shrinks; epsilon_min=0 → log(0) undefined, practically infinite
        return math.inf
    return math.ceil(math.log(epsilon_min / epsilon) / math.log(epsilon_decay))


def validate_decay_speed(
    epsilon: float,
    epsilon_min: float,
    epsilon_decay: float,
    n_episodes: int,
) -> None:
    """
    Warn if the exploration schedule is poorly matched to the training budget.

    Rules:
      - < 10 % of episodes to reach epsilon_min → decays too fast
      - > 90 % of episodes to reach epsilon_min → decays too slowly
    """
    if n_episodes <= 0:
        raise ValueError("n_episodes must be strictly positive.")

    n_decay = estimate_decay_episodes(epsilon, epsilon_min, epsilon_decay)

    if n_decay == 0:
        return

    if n_decay == math.inf:
        if epsilon_decay == 1.0:
            _warn(
                "epsilon_decay=1.0 means epsilon will never decrease. "
                "The agent will explore randomly throughout all training episodes."
            )
        # epsilon_min=0 also returns inf — already warned by validate_epsilon_min
        return

    ratio = n_decay / n_episodes
    pct   = ratio * 100

    if ratio < 0.10:
        _warn(
            f"Epsilon reaches epsilon_min={epsilon_min} after ~{n_decay} episodes "
            f"({pct:.1f}% of {n_episodes} total). "
            "This is very fast: the agent will stop exploring before it has seen "
            "enough of the state space. The learned policy may be heavily suboptimal. "
            "Increase epsilon_decay (e.g. 0.995 → 0.999) or reduce epsilon_min."
        )
    elif ratio > 0.90:
        _warn(
            f"Epsilon reaches epsilon_min={epsilon_min} after ~{n_decay} episodes "
            f"({pct:.1f}% of {n_episodes} total). "
            "This is very slow: the agent is still mostly random near the end of "
            "training and has little time to exploit its learned policy. "
            "Decrease epsilon_decay (e.g. 0.999 → 0.995) or add more episodes."
        )
    else:
        print(
            f"  [INFO] Epsilon will reach epsilon_min={epsilon_min} "
            f"after ~{n_decay} episodes ({pct:.1f}% of {n_episodes} total)."
        )


# ─────────────────────────────────────────────
#  Unified entry point
# ─────────────────────────────────────────────

def validate_hyperparams(
    alpha: float,
    gamma: float,
    epsilon: float,
    epsilon_min: float,
    epsilon_decay: float,
    n_episodes: int | None = None,
) -> None:
    """
    Run all hyperparameter validations in one call.

    Raises ValueError immediately on the first mathematically invalid value.
    Prints [WARN] messages for technically valid but potentially harmful choices.
    When n_episodes is provided, also checks whether the exploration schedule
    is well-matched to the training budget.

    Parameters
    ----------
    alpha         : learning rate (0, 1]
    gamma         : discount factor [0, 1]
    epsilon       : initial exploration rate [0, 1]
    epsilon_min   : minimum exploration floor [0, epsilon]
    epsilon_decay : per-episode multiplicative decay (0, 1]
    n_episodes    : total training episodes — enables decay speed check
    """
    validate_alpha(alpha)
    validate_gamma(gamma)
    validate_epsilon(epsilon)
    validate_epsilon_min(epsilon_min, epsilon)
    validate_epsilon_decay(epsilon_decay)

    if n_episodes is not None:
        if n_episodes <= 0:
            raise ValueError("n_episodes must be strictly positive.")
        validate_decay_speed(epsilon, epsilon_min, epsilon_decay, n_episodes)
