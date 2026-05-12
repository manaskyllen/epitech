from functools import lru_cache

from app.application.use_cases.inspect_clothing import InspectClothingUseCase
from app.core.settings import get_settings
from app.infrastructure.ml.inspector import MultitaskClothingInspector
from app.infrastructure.ml.yolo_validator import YoloClothingValidator


@lru_cache(maxsize=1)
def get_inspection_use_case() -> InspectClothingUseCase:
    settings = get_settings()
    inspector = MultitaskClothingInspector(settings)
    validator = YoloClothingValidator(settings)
    return InspectClothingUseCase(inspector=inspector, validator=validator)
