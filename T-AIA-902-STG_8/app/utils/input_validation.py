"""
input_validation.py – Small reusable validation helpers for CLI input and
runtime guard rails.
"""

from __future__ import annotations

import math
from numbers import Real, Integral
from typing import Iterable

import numpy as np


def validate_positive_int(value, name: str) -> int:
    """Validate that value is a strictly positive integer."""
    if isinstance(value, bool) or not isinstance(value, Integral):
        raise ValueError(f"{name} must be an integer.")
    if value <= 0:
        raise ValueError(f"{name} must be strictly positive.")
    return int(value)


def validate_positive_float(value, name: str) -> float:
    """Validate that value is a strictly positive real number."""
    if isinstance(value, bool) or not isinstance(value, Real):
        raise ValueError(f"{name} must be a number.")
    value = float(value)
    if not math.isfinite(value):
        raise ValueError(f"{name} must be finite.")
    if value <= 0:
        raise ValueError(f"{name} must be strictly positive.")
    return value


def validate_range_float(value, name: str, min_value: float, max_value: float) -> float:
    """Validate that value is a finite float within [min_value, max_value]."""
    if isinstance(value, bool) or not isinstance(value, Real):
        raise ValueError(f"{name} must be a number.")
    value = float(value)
    if not math.isfinite(value):
        raise ValueError(f"{name} must be finite.")
    if value < min_value or value > max_value:
        raise ValueError(f"{name} must be between {min_value} and {max_value}.")
    return value


def ask_int(prompt: str, default: int | None = None, *, min_value: int | None = None,
            max_value: int | None = None, name: str | None = None) -> int:
    """Prompt until a valid integer is entered."""
    label = name or prompt
    while True:
        suffix = f" [default={default}]" if default is not None else ""
        raw = input(f"{prompt}{suffix}: ").strip()
        if raw == "":
            if default is None:
                print(f"  [ERROR] {label} is required.")
                continue
            value = default
        else:
            try:
                value = int(raw)
            except ValueError:
                print(f"  [ERROR] {label} must be an integer.")
                continue
        try:
            value = validate_positive_int(value, label)
        except ValueError as exc:
            print(f"  [ERROR] {exc}")
            continue
        if min_value is not None and value < min_value:
            print(f"  [ERROR] {label} must be >= {min_value}.")
            continue
        if max_value is not None and value > max_value:
            print(f"  [ERROR] {label} must be <= {max_value}.")
            continue
        return value


def ask_float(prompt: str, default: float | None = None, *, min_value: float | None = None,
              max_value: float | None = None, positive_only: bool = False,
              name: str | None = None) -> float:
    """Prompt until a valid float is entered."""
    label = name or prompt
    while True:
        suffix = f" [default={default}]" if default is not None else ""
        raw = input(f"{prompt}{suffix}: ").strip()
        if raw == "":
            if default is None:
                print(f"  [ERROR] {label} is required.")
                continue
            value = default
        else:
            try:
                value = float(raw)
            except ValueError:
                print(f"  [ERROR] {label} must be a number.")
                continue
        try:
            if positive_only:
                value = validate_positive_float(value, label)
            else:
                if isinstance(value, bool) or not isinstance(value, Real):
                    raise ValueError(f"{label} must be a number.")
                value = float(value)
                if not math.isfinite(value):
                    raise ValueError(f"{label} must be finite.")
        except ValueError as exc:
            print(f"  [ERROR] {exc}")
            continue
        if min_value is not None and value < min_value:
            print(f"  [ERROR] {label} must be >= {min_value}.")
            continue
        if max_value is not None and value > max_value:
            print(f"  [ERROR] {label} must be <= {max_value}.")
            continue
        return value


def ask_choice(prompt: str, choices: Iterable[str], default: str | None = None,
               name: str | None = None) -> str:
    """Prompt until the user enters one of the allowed choices."""
    label = name or prompt
    allowed = {str(choice) for choice in choices}
    while True:
        suffix = f" [default={default}]" if default is not None else ""
        raw = input(f"{prompt}{suffix}: ").strip()
        if raw == "":
            if default is None:
                print(f"  [ERROR] {label} is required.")
                continue
            raw = str(default)
        if raw in allowed:
            return raw
        print(f"  [ERROR] {label} must be one of: {', '.join(sorted(allowed))}.")


def ask_yes_no(prompt: str, default: bool = False) -> bool:
    """Prompt until the user answers yes or no."""
    default_label = "y" if default else "n"
    while True:
        raw = input(f"{prompt} [y/N]: ").strip().lower()
        if raw == "":
            raw = default_label
        if raw in {"y", "yes", "1", "true"}:
            return True
        if raw in {"n", "no", "0", "false"}:
            return False
        print("  [ERROR] Please answer y or n.")


def has_finite_metrics(results: dict) -> bool:
    """Return True if metrics are present, non-empty and finite."""
    if not isinstance(results, dict) or not results:
        return False

    saw_numeric = False
    for value in results.values():
        if isinstance(value, dict):
            if not has_finite_metrics(value):
                return False
            saw_numeric = True
            continue

        if isinstance(value, (list, tuple, np.ndarray)):
            arr = np.asarray(value, dtype=float).ravel()
            if arr.size == 0:
                continue
            if not np.all(np.isfinite(arr)):
                return False
            saw_numeric = True
            continue

        if isinstance(value, (bool, str)) or value is None:
            continue

        if isinstance(value, Real):
            if not math.isfinite(float(value)):
                return False
            saw_numeric = True

    return saw_numeric


def has_valid_training_metrics(results: dict) -> bool:
    """Validate the minimal training metrics needed for saving/plotting."""
    if not isinstance(results, dict) or not results:
        return False

    for key in ("rewards", "steps"):
        values = results.get(key)
        if not isinstance(values, (list, tuple, np.ndarray)):
            return False
        arr = np.asarray(values, dtype=float).ravel()
        if arr.size == 0 or not np.all(np.isfinite(arr)):
            return False

    for key in ("mean_reward", "mean_steps", "training_time"):
        value = results.get(key)
        if not isinstance(value, Real) or not math.isfinite(float(value)):
            return False

    return True
