from typing import Protocol

from PIL.Image import Image as PILImage

from app.domain.entities import ClothingValidation, InspectionResult


class ClothingValidator(Protocol):
    def validate(self, image: PILImage) -> ClothingValidation:
        ...


class ClothingInspector(Protocol):
    def inspect(
        self,
        image: PILImage,
        *,
        size: str | None = None,
        debug: bool = False,
    ) -> InspectionResult:
        ...
