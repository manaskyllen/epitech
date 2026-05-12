import os
import platform
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from fastapi import APIRouter

from app.application.use_cases.inspect_clothing import InspectClothingUseCase
from app.container import get_inspection_use_case
from app.core.settings import get_settings

router = APIRouter(tags=["debug"])


def _path_metadata(path_like: str | Path) -> dict[str, Any]:
    path = Path(path_like)
    metadata: dict[str, Any] = {
        "path": str(path),
        "exists": path.exists(),
        "is_file": path.is_file(),
    }
    if not path.exists():
        return metadata

    stat = path.stat()
    metadata["size_bytes"] = stat.st_size
    metadata["modified_at"] = datetime.fromtimestamp(
        stat.st_mtime,
        tz=timezone.utc,
    ).isoformat()
    return metadata


def _settings_payload() -> dict[str, Any]:
    settings = get_settings()
    return {
        "model_path": str(settings.model_path),
        "encoders_path": str(settings.encoders_path),
        "yolo_validator_model_path": str(settings.yolo_validator_model_path),
        "log_level": settings.log_level,
        "image_size": settings.image_size,
        "sigmoid_threshold": settings.sigmoid_threshold,
        "max_colors": settings.max_colors,
        "enabled_attributes": list(settings.enabled_attributes),
        "attribute_thresholds": dict(settings.attribute_thresholds),
        "attribute_margin_threshold": settings.attribute_margin_threshold,
        "color_fallback_to_model": settings.color_fallback_to_model,
        "cors_origins": list(settings.cors_origins),
    }


def _inspector_payload(inspector: Any) -> dict[str, Any]:
    model = getattr(inspector, "_model", None)
    encoders = getattr(inspector, "_encoders", {})
    bundle_warnings = getattr(inspector, "_bundle_warnings", [])
    color_vocab = getattr(inspector, "_color_vocab", [])
    return {
        "class": inspector.__class__.__name__,
        "device": str(getattr(inspector, "_device", "unknown")),
        "model": {
            "class": model.__class__.__name__ if model is not None else None,
            "module": model.__class__.__module__ if model is not None else None,
            "backbone": (
                model.backbone.__class__.__name__
                if model is not None and hasattr(model, "backbone")
                else None
            ),
            "heads": {
                "gender": getattr(getattr(model, "head_gender", None), "out_features", None),
                "item_subtype": getattr(
                    getattr(model, "head_subtype", None),
                    "out_features",
                    None,
                ),
                "item_type": getattr(getattr(model, "head_type", None), "out_features", None),
                "season": getattr(getattr(model, "head_season", None), "out_features", None),
                "material": getattr(
                    getattr(model, "head_material", None),
                    "out_features",
                    None,
                ),
                "colors": getattr(getattr(model, "head_colors", None), "out_features", None),
            },
        },
        "bundle": {
            "encoder_class_counts": {
                name: len(getattr(encoder, "classes_", []))
                for name, encoder in encoders.items()
            },
            "color_vocab_size": len(color_vocab),
            "warnings": list(bundle_warnings),
        },
    }


def _validator_payload(validator: Any) -> dict[str, Any]:
    model = getattr(validator, "_model", None)
    inner_model = getattr(model, "model", None)
    names = getattr(inner_model, "names", None)
    return {
        "class": validator.__class__.__name__,
        "model": {
            "class": model.__class__.__name__ if model is not None else None,
            "module": model.__class__.__module__ if model is not None else None,
            "checkpoint_path": getattr(model, "ckpt_path", None),
            "names": names if isinstance(names, dict) else None,
        },
    }


def _use_case_payload(use_case: InspectClothingUseCase) -> dict[str, Any]:
    inspector = getattr(use_case, "_inspector", None)
    validator = getattr(use_case, "_validator", None)
    return {
        "class": use_case.__class__.__name__,
        "inspector": _inspector_payload(inspector) if inspector is not None else None,
        "validator": _validator_payload(validator) if validator is not None else None,
    }


@router.get("/debug/full")
def debug_full():
    settings_payload = _settings_payload()
    pipeline: dict[str, Any] | None = None
    pipeline_error: dict[str, str] | None = None

    try:
        use_case = get_inspection_use_case()
    except Exception as exc:
        pipeline_error = {
            "type": exc.__class__.__name__,
            "message": str(exc),
        }
    else:
        pipeline = _use_case_payload(use_case)

    return {
        "app": {
            "debug_route": "/debug/full",
            "cwd": os.getcwd(),
            "pid": os.getpid(),
            "python_version": platform.python_version(),
            "platform": platform.platform(),
        },
        "environment": dict(sorted(os.environ.items())),
        "settings": settings_payload,
        "artifacts": {
            "model": _path_metadata(settings_payload["model_path"]),
            "encoders": _path_metadata(settings_payload["encoders_path"]),
            "yolo_validator": _path_metadata(settings_payload["yolo_validator_model_path"]),
        },
        "pipeline": pipeline,
        "pipeline_error": pipeline_error,
    }
