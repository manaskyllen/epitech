import logging

from PIL.Image import Image as PILImage

from app.core.settings import Settings
from app.domain.entities import ClothingValidation

logger = logging.getLogger(__name__)


class YoloClothingValidator:
    def __init__(self, settings: Settings):
        self._settings = settings
        self._model = self._load_model()

    def _load_model(self):
        model_path = self._settings.yolo_validator_model_path
        if not model_path.exists():
            raise FileNotFoundError(
                "YOLO validator weights not found at "
                f"{model_path}. Set YOLO_VALIDATOR_MODEL_PATH to a valid file."
            )

        try:
            from ultralytics import YOLO
        except ImportError as exc:
            raise RuntimeError(
                "Failed to import ultralytics dependencies. "
                f"Original error: {exc}"
            ) from exc

        return YOLO(str(model_path))

    @staticmethod
    def _max_confidence(boxes) -> float:
        if boxes is None or len(boxes) == 0 or boxes.conf is None or len(boxes.conf) == 0:
            return 0.0

        confidence = boxes.conf.max()
        return float(confidence.item() if hasattr(confidence, "item") else confidence)

    def validate(self, image: PILImage) -> ClothingValidation:
        results = self._model(image.convert("RGB"), verbose=False)
        boxes = results[0].boxes if results else None
        clothing_detected = boxes is not None and len(boxes) > 0
        confidence = self._max_confidence(boxes) if clothing_detected else 0.0

        logger.info(
            "validator_result",
            extra={
                "event_data": {
                    "detected": clothing_detected,
                    "confidence": round(confidence, 4),
                    "boxes": len(boxes) if boxes is not None else 0,
                }
            },
        )

        return ClothingValidation(
            clothing_detected=clothing_detected,
            confidence=confidence,
        )
