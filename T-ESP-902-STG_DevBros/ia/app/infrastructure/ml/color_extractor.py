import json
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

import numpy as np
from PIL import Image
from PIL.Image import Image as PILImage


@dataclass(frozen=True)
class ColorExtractionResult:
    colors: list[str]
    dominant_rgb: list[int]
    foreground_ratio: float
    source: str


def _hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[index : index + 2], 16) for index in (0, 2, 4))


@lru_cache(maxsize=1)
def _load_palette() -> list[dict[str, object]]:
    palette_path = Path(__file__).resolve().parents[3] / "data" / "metadata" / "colors.json"
    payload = json.loads(palette_path.read_text(encoding="utf-8"))
    entries = payload.get("palette", [])
    palette: list[dict[str, object]] = []
    for entry in entries:
        name = str(entry["name"])
        family = str(entry.get("family", name))
        rgb = _hex_to_rgb(str(entry["hex"]))
        palette.append({"name": name, "family": family, "rgb": rgb})
    return palette
def extract_colors(image: PILImage, *, max_colors: int = 3) -> ColorExtractionResult:
    rgb_image = image.convert("RGB")
    thumbnail = rgb_image.resize((128, 128), Image.Resampling.BILINEAR)
    pixels = np.asarray(thumbnail, dtype=np.float32).reshape(-1, 3)

    if pixels.size == 0:
        return ColorExtractionResult(
            colors=[],
            dominant_rgb=[0, 0, 0],
            foreground_ratio=0.0,
            source="extractor",
        )

    background = pixels[0]
    distances_from_background = np.linalg.norm(pixels - background, axis=1)
    foreground_mask = distances_from_background > 30.0
    foreground_pixels = pixels[foreground_mask]

    if len(foreground_pixels) == 0:
        foreground_pixels = pixels
        foreground_ratio = 0.0
        source = "extractor_low_foreground"
    else:
        foreground_ratio = float(foreground_mask.mean())
        source = "extractor"

    mean_rgb = foreground_pixels.mean(axis=0)
    dominant_rgb = [int(round(channel)) for channel in mean_rgb.tolist()]

    palette = _load_palette()
    families_by_distance = sorted(
        (
            (float(np.linalg.norm(mean_rgb - np.asarray(entry["rgb"], dtype=np.float32))), str(entry["family"]))
            for entry in palette
        ),
        key=lambda item: item[0],
    )

    colors: list[str] = []
    for _, family in families_by_distance:
        if family not in colors:
            colors.append(family)
        if len(colors) >= max_colors:
            break

    return ColorExtractionResult(
        colors=colors,
        dominant_rgb=dominant_rgb,
        foreground_ratio=foreground_ratio,
        source=source,
    )
