import os
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[2]
DEFAULT_ENABLED_ATTRIBUTES = (
    "item_type",
    "item_subtype",
    "gender",
    "season",
    "material",
    "color",
)
DEFAULT_ATTRIBUTE_THRESHOLDS = {
    "item_type": 0.35,
    "item_subtype": 0.25,
    "gender": 0.45,
    "season": 0.40,
    "material": 0.45,
}


def _default_yolo_validator_path() -> Path:
    candidates = (
        BASE_DIR
        / "runs"
        / "detect"
        / "runs"
        / "clothing_validator2"
        / "weights"
        / "best.pt",
        BASE_DIR
        / "runs"
        / "detect"
        / "clothing_validator2"
        / "weights"
        / "best.pt",
        BASE_DIR / "runs" / "clothing_validator2" / "weights" / "best.pt",
    )
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return candidates[0]


@dataclass(frozen=True)
class Settings:
    model_path: Path
    encoders_path: Path
    yolo_validator_model_path: Path
    log_level: str
    image_size: int
    sigmoid_threshold: float
    max_colors: int
    enabled_attributes: tuple[str, ...]
    attribute_thresholds: dict[str, float]
    attribute_margin_threshold: float
    color_fallback_to_model: bool
    cors_origins: tuple[str, ...]


def _parse_list_env(raw_value: str | None, default: tuple[str, ...]) -> tuple[str, ...]:
    if raw_value is None:
        return default
    values = tuple(part.strip() for part in raw_value.split(",") if part.strip())
    return values or default


def _parse_thresholds(raw_value: str | None) -> dict[str, float]:
    thresholds = DEFAULT_ATTRIBUTE_THRESHOLDS.copy()
    if not raw_value:
        return thresholds

    for entry in raw_value.split(","):
        if not entry.strip() or "=" not in entry:
            continue
        name, value = entry.split("=", 1)
        name = name.strip()
        value = value.strip()
        if not name or not value:
            continue
        thresholds[name] = float(value)
    return thresholds


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    model_path = Path(
        os.getenv(
            "MODEL_PATH",
            str(BASE_DIR / "artifacts" / "models" / "model_multitask.pt"),
        )
    )
    encoders_path = Path(
        os.getenv(
            "ENCODERS_PATH",
            str(BASE_DIR / "artifacts" / "encoders" / "encoders_multitask.pkl"),
        )
    )
    yolo_validator_model_path = Path(
        os.getenv(
            "YOLO_VALIDATOR_MODEL_PATH",
            str(_default_yolo_validator_path()),
        )
    )
    log_level = os.getenv("LOG_LEVEL", "INFO").upper()
    image_size = int(os.getenv("IMAGE_SIZE", "224"))
    sigmoid_threshold = float(os.getenv("SIGMOID_THRESH", "0.35"))
    max_colors = int(os.getenv("MAX_COLORS", "3"))
    enabled_attributes = _parse_list_env(
        os.getenv("ENABLED_ATTRIBUTES"),
        DEFAULT_ENABLED_ATTRIBUTES,
    )
    attribute_thresholds = _parse_thresholds(os.getenv("ATTRIBUTE_THRESHOLDS"))
    attribute_margin_threshold = float(os.getenv("ATTRIBUTE_MARGIN_THRESH", "0.05"))
    color_fallback_to_model = os.getenv("COLOR_FALLBACK_TO_MODEL", "true").lower() in {
        "1",
        "true",
        "yes",
        "on",
    }
    raw_origins = os.getenv("CORS_ALLOW_ORIGINS", "*")
    cors_origins = tuple(origin.strip() for origin in raw_origins.split(",") if origin)

    return Settings(
        model_path=model_path,
        encoders_path=encoders_path,
        yolo_validator_model_path=yolo_validator_model_path,
        log_level=log_level,
        image_size=image_size,
        sigmoid_threshold=sigmoid_threshold,
        max_colors=max_colors,
        enabled_attributes=enabled_attributes,
        attribute_thresholds=attribute_thresholds,
        attribute_margin_threshold=attribute_margin_threshold,
        color_fallback_to_model=color_fallback_to_model,
        cors_origins=cors_origins or ("*",),
    )
