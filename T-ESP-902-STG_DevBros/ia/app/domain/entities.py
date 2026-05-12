from dataclasses import dataclass
from typing import Any


def _normalize_optional(value: str | None) -> str | None:
    if value in (None, "", "None"):
        return None
    return value


@dataclass(frozen=True)
class ClothingValidation:
    clothing_detected: bool
    confidence: float
    bypassed: bool = False

    def to_payload(self) -> dict[str, Any]:
        return {
            "clothing_detected": self.clothing_detected,
            "confidence": round(self.confidence, 4),
            "bypassed": self.bypassed,
        }


@dataclass(frozen=True)
class InspectionResult:
    item_type: str | None
    item_subtype: str | None
    colors: list[str]
    size: str | None
    season: str | None
    gender: str | None
    material: str | None
    style: str | None
    confidence: float
    confidences: dict[str, float] | None = None
    margins: dict[str, float] | None = None
    suppressed_attributes: list[str] | None = None
    warnings: list[str] | None = None
    color_source: str | None = None
    debug: dict[str, Any] | None = None

    def to_payload(self) -> dict[str, Any]:
        payload = {
            "ItemType": self.item_type,
            "ItemSubtype": self.item_subtype,
            "Color": self.colors,
            "Size": _normalize_optional(self.size),
            "Season": _normalize_optional(self.season),
            "Gender": self.gender,
            "Material": _normalize_optional(self.material),
            "Style": _normalize_optional(self.style),
            "confidence": round(self.confidence, 4),
        }

        if self.confidences:
            payload["Confidences"] = {
                key: round(value, 4) for key, value in self.confidences.items()
            }
        if self.margins:
            payload["Margins"] = {
                key: round(value, 4) for key, value in self.margins.items()
            }
        if self.suppressed_attributes:
            payload["SuppressedAttributes"] = self.suppressed_attributes
        if self.warnings:
            payload["Warnings"] = self.warnings
        if self.color_source:
            payload["ColorSource"] = self.color_source
        if self.debug:
            payload["Debug"] = self.debug

        return payload


@dataclass(frozen=True)
class InspectionPipelineResult:
    success: bool
    validation: ClothingValidation
    data: InspectionResult | None = None
    error_code: str | None = None
    message: str | None = None

    def to_payload(self) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "success": self.success,
            "validation": self.validation.to_payload(),
        }

        if self.success and self.data is not None:
            payload["data"] = self.data.to_payload()
            return payload

        payload["error_code"] = self.error_code or "INVALID_CLOTHING_IMAGE"
        payload["message"] = (
            self.message
            or "Aucun vêtement exploitable n'a été détecté sur la photo."
        )
        return payload
