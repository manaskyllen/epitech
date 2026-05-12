import io
import logging

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile
from PIL import Image, UnidentifiedImageError

from app.api.schemas import InspectionResponse
from app.application.use_cases.inspect_clothing import InspectClothingUseCase
from app.container import get_inspection_use_case

router = APIRouter()
logger = logging.getLogger(__name__)


@router.post("/inspect", response_model=InspectionResponse, response_model_exclude_unset=True)
async def inspect_vetement(
    file: UploadFile = File(...),
    size: str | None = Form(default=None),
    force_analysis: bool = Query(
        default=False,
        description="Force l'analyse et ignore la validation photo en amont.",
    ),
    debug: bool = Query(
        default=False,
        description="Retourne les details debug et active des logs d'inspection plus verbeux.",
    ),
    use_case: InspectClothingUseCase = Depends(get_inspection_use_case),
):
    try:
        raw_bytes = await file.read()
        image = Image.open(io.BytesIO(raw_bytes)).convert("RGB")
    except (UnidentifiedImageError, OSError) as exc:
        raise HTTPException(status_code=400, detail="Invalid image file.") from exc

    logger.info(
        "inspection_request",
        extra={
            "event_data": {
                "filename": file.filename,
                "content_type": file.content_type,
                "size_param": size,
                "force_analysis": force_analysis,
                "debug": debug,
                "image_width": image.width,
                "image_height": image.height,
                "bytes": len(raw_bytes),
            }
        },
    )

    result = use_case.execute(
        image=image,
        size=size,
        force_analysis=force_analysis,
        debug=debug,
    )
    payload = result.to_payload()
    logger.info(
        "inspection_response",
        extra={
            "event_data": {
                "success": payload.get("success"),
                "validation": payload.get("validation"),
                "data_keys": sorted(payload.get("data", {}).keys()) if payload.get("data") else [],
            }
        },
    )
    return payload
