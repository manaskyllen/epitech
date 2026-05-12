import logging

from PIL.Image import Image as PILImage

from app.domain.entities import ClothingValidation, InspectionPipelineResult
from app.domain.ports import ClothingInspector, ClothingValidator

logger = logging.getLogger(__name__)


class InspectClothingUseCase:
    def __init__(self, inspector: ClothingInspector, validator: ClothingValidator):
        self._inspector = inspector
        self._validator = validator

    def execute(
        self,
        image: PILImage,
        *,
        size: str | None = None,
        force_analysis: bool = False,
        debug: bool = False,
    ) -> InspectionPipelineResult:
        if force_analysis:
            validation = ClothingValidation(
                clothing_detected=True,
                confidence=0.0,
                bypassed=True,
            )
            logger.info(
                "inspection_validation_bypassed",
                extra={"event_data": {"bypassed": True}},
            )
        else:
            validation = self._validator.validate(image=image)

        if not validation.clothing_detected:
            logger.warning(
                "inspection_rejected",
                extra={
                    "event_data": {
                        "clothing_detected": validation.clothing_detected,
                        "confidence": round(validation.confidence, 4),
                    }
                },
            )
            return InspectionPipelineResult(
                success=False,
                validation=validation,
                error_code="INVALID_CLOTHING_IMAGE",
                message="Aucun vêtement exploitable n'a été détecté sur la photo.",
            )

        inspection_result = self._inspector.inspect(image=image, size=size, debug=debug)
        logger.info(
            "inspection_completed",
            extra={
                "event_data": {
                    "item_type": inspection_result.item_type,
                    "item_subtype": inspection_result.item_subtype,
                    "colors": inspection_result.colors,
                }
            },
        )
        return InspectionPipelineResult(
            success=True,
            validation=validation,
            data=inspection_result,
        )
