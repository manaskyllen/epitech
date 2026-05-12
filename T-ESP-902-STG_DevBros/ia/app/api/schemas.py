from pydantic import BaseModel, Field


class ClothingValidationResponse(BaseModel):
    clothing_detected: bool
    confidence: float
    bypassed: bool = False


class InspectionDataResponse(BaseModel):
    ItemType: str | None = None
    ItemSubtype: str | None = None
    Color: list[str] = Field(default_factory=list)
    Size: str | None = None
    Season: str | None = None
    Gender: str | None = None
    Material: str | None = None
    Style: str | None = None
    confidence: float
    Confidences: dict[str, float] = Field(default_factory=dict)
    Margins: dict[str, float] = Field(default_factory=dict)
    SuppressedAttributes: list[str] = Field(default_factory=list)
    Warnings: list[str] = Field(default_factory=list)
    ColorSource: str | None = None
    Debug: dict[str, object] = Field(default_factory=dict)


class InspectionResponse(BaseModel):
    success: bool
    validation: ClothingValidationResponse
    data: InspectionDataResponse | None = None
    error_code: str | None = None
    message: str | None = None
