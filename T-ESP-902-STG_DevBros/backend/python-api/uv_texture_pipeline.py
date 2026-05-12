from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Literal

import numpy as np
from PIL import Image, ImageFilter


BlendMode = Literal["normal", "multiply", "overlay", "soft_light"]
GradientDirection = Literal["vertical", "horizontal", "diagonal", "reverse_diagonal", "radial"]

VALID_BLEND_MODES: tuple[BlendMode, ...] = ("normal", "multiply", "overlay", "soft_light")
VALID_DIRECTIONS: tuple[GradientDirection, ...] = (
    "vertical",
    "horizontal",
    "diagonal",
    "reverse_diagonal",
    "radial",
)

ROOT_DIR = Path(__file__).resolve().parent
TOP_UV_REFERENCE_PATH = ROOT_DIR / "t-shirt-uv.png"
SWEATSHIRT_UV_REFERENCE_PATH = ROOT_DIR / "sweatshirt-uv.png"
BOTTOM_UV_REFERENCE_PATH = ROOT_DIR / "bottom-uv.png"
SHOES_UV_REFERENCE_PATH = ROOT_DIR / "shoes-uv.png"

TOP_ZONES: dict[str, tuple[float, float, float, float]] = {
    "front": (0.05, 0.36, 0.45, 0.95),
    "back": (0.55, 0.36, 0.95, 0.95),
    "front_logo": (0.27, 0.62, 0.36, 0.76),
    "front_collar": (0.17, 0.27, 0.39, 0.33),
    "back_collar": (0.61, 0.27, 0.83, 0.33),
    "left_sleeve": (0.05, 0.02, 0.45, 0.28),
    "right_sleeve": (0.55, 0.02, 0.95, 0.28),
}

SWEATSHIRT_ZONES: dict[str, tuple[float, float, float, float]] = {
    "front": (0.000, 0.025, 0.515, 0.455),
    "back": (0.012, 0.455, 0.448, 0.970),
    "front_logo": (0.200, 0.200, 0.315, 0.350),
    "left_sleeve": (0.470, 0.240, 0.760, 0.705),
    "right_sleeve": (0.535, 0.665, 0.995, 0.985),
    "waistband": (0.335, 0.000, 0.690, 0.020),
    "cuff": (0.952, 0.000, 0.998, 0.705),
}

BOTTOM_ZONES: dict[str, tuple[float, float, float, float]] = {
    "front_left_leg": (0.032, 0.021, 0.296, 0.762),
    "front_right_leg": (0.297, 0.021, 0.494, 0.762),
    "back_left_leg": (0.516, 0.021, 0.696, 0.762),
    "back_right_leg": (0.711, 0.021, 0.979, 0.762),
    "waistband_front": (0.067, 0.784, 0.494, 0.907),
    "waistband_back": (0.516, 0.784, 0.958, 0.907),
}

SHOES_ZONES: dict[str, tuple[float, float, float, float]] = {
    "laces_top": (0.000, 0.935, 0.718, 0.999),
    "laces_bottom": (0.000, 0.855, 0.690, 0.930),
    "sole_main": (0.000, 0.615, 0.694, 0.836),
    "sole_toe": (0.000, 0.465, 0.519, 0.610),
    "tongue_left": (0.543, 0.393, 0.671, 0.713),
    "tongue_right": (0.677, 0.421, 0.791, 0.708),
    "heel_patch": (0.688, 0.824, 0.999, 0.973),
    "sidewall_upper": (0.000, 0.202, 0.967, 0.392),
    "sidewall_lower": (0.000, 0.000, 0.995, 0.192),
    "lace_column": (0.873, 0.431, 0.996, 0.804),
}


class TextureGenerationError(Exception):
    """Raised when procedural texture generation cannot complete."""


@dataclass(slots=True)
class TextureGenerationConfig:
    photo_path: Path
    output_path: Path
    item_type: str = "top"
    item_subtype: str | None = None
    base_path: Path | None = None
    logo_path: Path | None = None
    palette_preview_path: Path | None = None
    uv_reference_path: Path | None = None
    size: int = 1024
    palette_size: int = 5
    blend_mode: BlendMode = "soft_light"
    detail_strength: float = 0.9
    zone_opacity: float = 0.9
    logo_scale: float = 0.82
    seed: int | None = None
    front_color: str | None = None
    back_color: str | None = None
    left_sleeve_color: str | None = None
    right_sleeve_color: str | None = None
    collar_color: str | None = None


@dataclass(slots=True)
class DetailMaps:
    luminance: np.ndarray
    macro: np.ndarray
    micro: np.ndarray


@dataclass(slots=True)
class ZoneStyle:
    colors: tuple[np.ndarray, np.ndarray]
    direction: GradientDirection
    opacity: float
    blend_mode: BlendMode


@dataclass(frozen=True, slots=True)
class GarmentProfile:
    item_type: str
    uv_reference_path: Path
    zones: dict[str, tuple[float, float, float, float]]
    logo_zone_name: str | None = None


def clamp(value: float, minimum: float, maximum: float) -> float:
    return max(minimum, min(maximum, value))


def mix(color_a: np.ndarray, color_b: np.ndarray, amount: float) -> np.ndarray:
    return np.clip(color_a * (1.0 - amount) + color_b * amount, 0.0, 1.0)


def lighten(color: np.ndarray, amount: float) -> np.ndarray:
    return mix(color, np.ones(3, dtype=np.float32), amount)


def darken(color: np.ndarray, amount: float) -> np.ndarray:
    return mix(color, np.zeros(3, dtype=np.float32), amount)


def parse_hex_color(value: str) -> np.ndarray:
    raw = value.strip().lstrip("#")
    if len(raw) != 6:
        raise TextureGenerationError(f"Invalid color '{value}', expected #RRGGBB")
    try:
        rgb = np.array(
            [int(raw[0:2], 16), int(raw[2:4], 16), int(raw[4:6], 16)],
            dtype=np.float32,
        )
    except ValueError as exc:
        raise TextureGenerationError(f"Invalid color '{value}', expected #RRGGBB") from exc
    return rgb / 255.0


def normalize_subtype(value: str | None) -> str:
    if not value:
        return ""
    return value.strip().lower().replace("-", "").replace(" ", "")


def resolve_garment_profile(config: TextureGenerationConfig) -> GarmentProfile:
    normalized_type = (config.item_type or "top").strip().lower()
    normalized_subtype = normalize_subtype(config.item_subtype)

    if config.uv_reference_path is not None:
        uv_reference_path = config.uv_reference_path
    elif normalized_type == "top":
        uv_reference_path = (
            SWEATSHIRT_UV_REFERENCE_PATH if normalized_subtype == "sweatshirt" else TOP_UV_REFERENCE_PATH
        )
    elif normalized_type == "bottom":
        uv_reference_path = BOTTOM_UV_REFERENCE_PATH
    elif normalized_type == "shoes":
        uv_reference_path = SHOES_UV_REFERENCE_PATH
    else:
        raise TextureGenerationError(
            f"No UV profile is configured for item_type '{config.item_type}'."
        )

    if normalized_type == "top":
        return GarmentProfile(
            item_type="top",
            uv_reference_path=uv_reference_path,
            zones=SWEATSHIRT_ZONES if normalized_subtype == "sweatshirt" else TOP_ZONES,
            logo_zone_name="front_logo",
        )

    if normalized_type == "bottom":
        return GarmentProfile(
            item_type="bottom",
            uv_reference_path=uv_reference_path,
            zones=BOTTOM_ZONES,
            logo_zone_name=None,
        )

    if normalized_type == "shoes":
        return GarmentProfile(
            item_type="shoes",
            uv_reference_path=uv_reference_path,
            zones=SHOES_ZONES,
            logo_zone_name=None,
        )

    raise TextureGenerationError(f"Unsupported item_type '{config.item_type}'.")


def validate_config(config: TextureGenerationConfig) -> TextureGenerationConfig:
    profile = resolve_garment_profile(config)
    config.item_type = profile.item_type
    config.uv_reference_path = profile.uv_reference_path

    if not config.photo_path.is_file():
        raise TextureGenerationError(f"Photo not found: {config.photo_path}")
    if config.base_path and not config.base_path.is_file():
        raise TextureGenerationError(f"Base texture not found: {config.base_path}")
    if config.logo_path and not config.logo_path.is_file():
        raise TextureGenerationError(f"Logo not found: {config.logo_path}")
    if config.uv_reference_path and not config.uv_reference_path.is_file():
        raise TextureGenerationError(
            f"UV reference not found for item_type '{config.item_type}': {config.uv_reference_path}"
        )
    if config.size <= 0:
        raise TextureGenerationError("--size must be greater than 0")
    if config.palette_size <= 0:
        raise TextureGenerationError("--palette-size must be greater than 0")
    if config.blend_mode not in VALID_BLEND_MODES:
        raise TextureGenerationError(
            f"--blend-mode must be one of: {', '.join(VALID_BLEND_MODES)}"
        )

    config.detail_strength = clamp(config.detail_strength, 0.0, 2.0)
    config.zone_opacity = clamp(config.zone_opacity, 0.0, 1.0)
    config.logo_scale = clamp(config.logo_scale, 0.1, 1.0)
    config.output_path.parent.mkdir(parents=True, exist_ok=True)

    if config.palette_preview_path is None:
        config.palette_preview_path = config.output_path.with_name(
            f"{config.output_path.stem}_palette.png"
        )
    config.palette_preview_path.parent.mkdir(parents=True, exist_ok=True)
    return config


def load_image(path: Path, mode: str) -> Image.Image:
    try:
        with Image.open(path) as image:
            return image.convert(mode)
    except OSError as exc:
        raise TextureGenerationError(f"Unable to open image: {path}") from exc


def image_to_array(image: Image.Image) -> np.ndarray:
    return np.asarray(image, dtype=np.float32) / 255.0


def array_to_image(array: np.ndarray, mode: str) -> Image.Image:
    clipped = np.clip(array * 255.0, 0.0, 255.0).astype(np.uint8)
    return Image.fromarray(clipped, mode=mode)


def create_procedural_base(size: int, seed: int | None) -> Image.Image:
    rng = np.random.default_rng(seed)
    axis = np.linspace(0.0, 1.0, size, dtype=np.float32)
    x, y = np.meshgrid(axis, axis)

    weave_x = np.sin(x * np.pi * 90.0) * 0.018
    weave_y = np.sin(y * np.pi * 110.0) * 0.015
    diagonal = np.sin((x + y) * np.pi * 26.0) * 0.02
    noise = rng.normal(0.0, 0.018, size=(size, size)).astype(np.float32)

    luminance = np.clip(0.84 + weave_x + weave_y + diagonal + noise, 0.0, 1.0)
    rgb = np.dstack([luminance, luminance, luminance])
    alpha = np.ones((size, size, 1), dtype=np.float32)
    return array_to_image(np.dstack([rgb, alpha]), mode="RGBA")


def resize_base_texture(image: Image.Image, size: int) -> Image.Image:
    return image.resize((size, size), Image.Resampling.LANCZOS)


def prepare_palette_source(image: Image.Image) -> np.ndarray:
    copy = image.copy()
    copy.thumbnail((384, 384), Image.Resampling.LANCZOS)
    copy = copy.filter(ImageFilter.GaussianBlur(radius=0.6))
    return image_to_array(copy)


def create_foreground_mask(image: np.ndarray) -> np.ndarray:
    height, width = image.shape[:2]
    y_axis = np.linspace(0.0, 1.0, height, dtype=np.float32)
    x_axis = np.linspace(0.0, 1.0, width, dtype=np.float32)
    x, y = np.meshgrid(x_axis, y_axis)

    center_weight = np.exp(-(((x - 0.5) / 0.34) ** 2 + ((y - 0.52) / 0.42) ** 2))
    border = max(1, min(height, width) // 12)

    border_pixels = np.concatenate(
        [
            image[:border, :, :].reshape(-1, 3),
            image[-border:, :, :].reshape(-1, 3),
            image[:, :border, :].reshape(-1, 3),
            image[:, -border:, :].reshape(-1, 3),
        ],
        axis=0,
    )
    border_color = border_pixels.mean(axis=0)
    color_distance = np.linalg.norm(image - border_color[None, None, :], axis=2)
    color_distance = color_distance / (float(np.max(color_distance)) + 1e-6)

    saturation = np.max(image, axis=2) - np.min(image, axis=2)
    luminance = np.dot(image, np.array([0.299, 0.587, 0.114], dtype=np.float32))
    midtone = 1.0 - np.clip(np.abs(luminance - 0.55) * 1.7, 0.0, 1.0)

    score = (
        center_weight * 0.58
        + color_distance * 0.95
        + saturation * 0.18
        + midtone * 0.14
    )
    threshold = max(float(np.percentile(score, 58.0)), 0.38)
    binary = (score >= threshold).astype(np.float32)

    mask_image = grayscale_image(binary)
    mask_image = mask_image.filter(ImageFilter.MaxFilter(size=5))
    mask_image = mask_image.filter(ImageFilter.MinFilter(size=3))
    mask_image = mask_image.filter(ImageFilter.GaussianBlur(radius=4.0))

    soft_mask = image_to_array(mask_image)
    if soft_mask.ndim == 3:
        soft_mask = soft_mask[..., 0]

    mask = np.clip(soft_mask * 0.82 + binary * 0.18, 0.0, 1.0)
    mask *= np.clip(0.30 + center_weight * 0.85, 0.0, 1.0)

    if float(np.mean(mask > 0.2)) < 0.04:
        mask = np.clip(center_weight, 0.0, 1.0)

    return mask.astype(np.float32)


def compute_garment_weights(image: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    height, width = image.shape[:2]
    y_axis = np.linspace(0.0, 1.0, height, dtype=np.float32)
    x_axis = np.linspace(0.0, 1.0, width, dtype=np.float32)
    x, y = np.meshgrid(x_axis, y_axis)

    center_weight = np.exp(-(((x - 0.5) / 0.34) ** 2 + ((y - 0.52) / 0.42) ** 2))
    saturation = np.max(image, axis=2) - np.min(image, axis=2)
    luminance = np.dot(image, np.array([0.299, 0.587, 0.114], dtype=np.float32))
    midtone = 1.0 - np.clip(np.abs(luminance - 0.55) * 1.9, 0.0, 1.0)
    foreground_mask = create_foreground_mask(image)

    weights = (
        0.04
        + foreground_mask * 1.15
        + center_weight * 0.26
        + saturation * 0.18
        + midtone * 0.10
    )
    return weights.astype(np.float32), foreground_mask


def extract_palette(image: Image.Image, palette_size: int) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    source = prepare_palette_source(image)
    weights, foreground_mask = compute_garment_weights(source)
    levels = 12

    quantized = np.clip(np.rint(source * (levels - 1)), 0, levels - 1).astype(np.int32)
    indices = (
        quantized[..., 0] * levels * levels
        + quantized[..., 1] * levels
        + quantized[..., 2]
    ).reshape(-1)

    counts = np.bincount(indices, weights=weights.reshape(-1), minlength=levels**3)
    order = np.argsort(counts)[::-1]

    weighted_colors: list[tuple[np.ndarray, float]] = []
    for index in order:
        if counts[index] <= 0:
            break
        r = index // (levels * levels)
        g = (index // levels) % levels
        b = index % levels
        color = np.array([r, g, b], dtype=np.float32) / float(levels - 1)
        if any(np.linalg.norm(color - existing) < 0.09 for existing, _ in weighted_colors):
            continue
        weighted_colors.append((color, float(counts[index])))
        if len(weighted_colors) >= palette_size:
            break

    if not weighted_colors:
        raise TextureGenerationError("Unable to extract a clothing palette from the inspiration photo")

    palette = np.stack([color for color, _ in weighted_colors], axis=0)
    palette_weights = np.array([weight for _, weight in weighted_colors], dtype=np.float32)
    if float(np.sum(palette_weights)) <= 0.0:
        palette_weights = np.ones(len(palette), dtype=np.float32)
    palette_weights = palette_weights / float(np.sum(palette_weights))

    if len(palette) == 1:
        base = palette[0]
        palette = np.stack([darken(base, 0.18), lighten(base, 0.18)], axis=0)
        palette_weights = np.array([0.55, 0.45], dtype=np.float32)

    order_by_luma = np.argsort(np.dot(palette, np.array([0.299, 0.587, 0.114], dtype=np.float32)))
    return palette[order_by_luma], palette_weights[order_by_luma], foreground_mask


def export_palette_preview(
    palette: np.ndarray,
    weights: np.ndarray,
    path: Path,
    width: int = 1200,
    height: int = 180,
) -> None:
    preview = np.zeros((height, width, 3), dtype=np.uint8)
    cursor = 0
    normalized = weights / max(float(np.sum(weights)), 1e-6)
    for index, color in enumerate(palette):
        if index == len(palette) - 1:
            next_cursor = width
        else:
            next_cursor = cursor + max(1, int(round(normalized[index] * width)))
        preview[:, cursor:next_cursor, :] = np.clip(color * 255.0, 0.0, 255.0).astype(np.uint8)
        cursor = min(next_cursor, width)
    Image.fromarray(preview, mode="RGB").save(path, format="PNG")


def create_uv_canvas(
    uv_reference: Image.Image,
    fabric_source: Image.Image,
    size: int,
) -> np.ndarray:
    uv_resized = resize_base_texture(uv_reference, size)
    fabric_resized = resize_base_texture(fabric_source, size)

    uv_array = image_to_array(uv_resized)
    fabric_array = image_to_array(fabric_resized)

    alpha = uv_array[..., 3:4]
    uv_luma = np.dot(uv_array[..., :3], np.array([0.299, 0.587, 0.114], dtype=np.float32))
    uv_mask = alpha[..., 0] > 0.02

    if np.any(uv_mask):
        uv_mean = float(np.mean(uv_luma[uv_mask]))
        shading = np.ones_like(uv_luma, dtype=np.float32)
        shading[uv_mask] = np.clip(0.88 + (uv_luma[uv_mask] - uv_mean) * 1.35, 0.58, 1.36)
    else:
        shading = np.ones_like(uv_luma, dtype=np.float32)

    rgb = np.clip(fabric_array[..., :3] * shading[..., None], 0.0, 1.0)
    rgb *= alpha
    return np.dstack((rgb, alpha))


def uv_to_pixels(
    rect: tuple[float, float, float, float],
    width: int,
    height: int,
) -> tuple[int, int, int, int]:
    x1, y1, x2, y2 = rect
    left = int(round(x1 * width))
    right = int(round(x2 * width))
    top = int(round((1.0 - y2) * height))
    bottom = int(round((1.0 - y1) * height))
    return left, top, right, bottom


def grayscale_image(values: np.ndarray) -> Image.Image:
    array = np.clip(values * 255.0, 0.0, 255.0).astype(np.uint8)
    return Image.fromarray(array, mode="L")


def normalize_signed(values: np.ndarray) -> np.ndarray:
    standard_deviation = float(np.std(values))
    if standard_deviation < 1e-6:
        return np.zeros_like(values)
    return np.clip(values / (standard_deviation * 3.0), -1.0, 1.0)


def create_detail_map(base_region: np.ndarray) -> DetailMaps:
    luminance = np.dot(base_region[..., :3], np.array([0.299, 0.587, 0.114], dtype=np.float32))
    luminance_image = grayscale_image(luminance)
    region_size = max(base_region.shape[0], base_region.shape[1])

    macro_blur = luminance_image.filter(ImageFilter.GaussianBlur(radius=max(region_size / 28.0, 4.0)))
    micro_blur = luminance_image.filter(ImageFilter.GaussianBlur(radius=max(region_size / 140.0, 1.2)))

    macro_array = image_to_array(macro_blur)
    micro_array = image_to_array(micro_blur)
    macro = normalize_signed(macro_array - float(np.mean(macro_array)))
    micro = normalize_signed(luminance - micro_array)
    return DetailMaps(luminance=luminance, macro=macro, micro=micro)


def build_gradient_coordinates(
    width: int,
    height: int,
    direction: GradientDirection,
) -> np.ndarray:
    x_axis = np.linspace(0.0, 1.0, width, dtype=np.float32)
    y_axis = np.linspace(0.0, 1.0, height, dtype=np.float32)
    x, y = np.meshgrid(x_axis, y_axis)

    if direction == "vertical":
        return y
    if direction == "horizontal":
        return x
    if direction == "diagonal":
        return (x + y) * 0.5
    if direction == "reverse_diagonal":
        return ((1.0 - x) + y) * 0.5
    if direction == "radial":
        distance = np.sqrt((x - 0.5) ** 2 + (y - 0.5) ** 2)
        max_distance = np.sqrt(0.5**2 + 0.5**2)
        return np.clip(distance / max_distance, 0.0, 1.0)

    raise TextureGenerationError(f"Unsupported direction: {direction}")


def make_zone_gradient(
    width: int,
    height: int,
    start_color: np.ndarray,
    end_color: np.ndarray,
    direction: GradientDirection,
) -> np.ndarray:
    coordinates = build_gradient_coordinates(width, height, direction)[..., None]
    return np.clip(
        start_color[None, None, :] * (1.0 - coordinates) + end_color[None, None, :] * coordinates,
        0.0,
        1.0,
    )


def apply_blend_mode(base: np.ndarray, overlay: np.ndarray, mode: BlendMode) -> np.ndarray:
    if mode == "normal":
        return overlay
    if mode == "multiply":
        return base * overlay
    if mode == "overlay":
        return np.where(base <= 0.5, 2.0 * base * overlay, 1.0 - 2.0 * (1.0 - base) * (1.0 - overlay))
    if mode == "soft_light":
        return (1.0 - 2.0 * overlay) * (base**2) + 2.0 * overlay * base
    raise TextureGenerationError(f"Unsupported blend mode: {mode}")


def apply_zone_style(base_region: np.ndarray, style: ZoneStyle, detail_strength: float) -> np.ndarray:
    height, width = base_region.shape[:2]
    detail_map = create_detail_map(base_region)
    gradient = make_zone_gradient(width, height, style.colors[0], style.colors[1], style.direction)

    blended = apply_blend_mode(base_region[..., :3], gradient, style.blend_mode)
    colorized = (blended * 0.68) + (gradient * 0.32)
    lighting = 1.0 + (
        detail_map.macro * (0.16 * detail_strength)
        + detail_map.micro * (0.24 * detail_strength)
    )
    rgb = np.clip(
        base_region[..., :3] * (1.0 - style.opacity) + colorized * style.opacity,
        0.0,
        1.0,
    )
    rgb = np.clip(rgb * lighting[..., None], 0.0, 1.0)
    return np.dstack((rgb, base_region[..., 3]))


def fit_logo_to_zone(
    logo: Image.Image,
    zone_width: int,
    zone_height: int,
    scale: float,
) -> Image.Image:
    target_width = max(1, int(zone_width * scale))
    target_height = max(1, int(zone_height * scale))
    copy = logo.copy()
    copy.thumbnail((target_width, target_height), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (zone_width, zone_height), (0, 0, 0, 0))
    offset = ((zone_width - copy.width) // 2, (zone_height - copy.height) // 2)
    canvas.alpha_composite(copy, dest=offset)
    return canvas


def build_top_zone_styles(config: TextureGenerationConfig, palette: np.ndarray) -> dict[str, ZoneStyle]:
    dominant = palette[len(palette) // 2]
    dark = palette[0]
    light = palette[-1]
    accent = palette[-2] if len(palette) > 2 else dominant

    front_base = parse_hex_color(config.front_color) if config.front_color else dominant
    back_base = parse_hex_color(config.back_color) if config.back_color else mix(dominant, dark, 0.12)
    left_base = parse_hex_color(config.left_sleeve_color) if config.left_sleeve_color else mix(dominant, accent, 0.10)
    right_base = parse_hex_color(config.right_sleeve_color) if config.right_sleeve_color else mix(dominant, light, 0.08)
    collar_base = parse_hex_color(config.collar_color) if config.collar_color else darken(dominant, 0.30)

    return {
        "front": ZoneStyle(
            colors=(darken(front_base, 0.08), lighten(front_base, 0.12)),
            direction="vertical",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
        "back": ZoneStyle(
            colors=(darken(back_base, 0.12), lighten(back_base, 0.08)),
            direction="vertical",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
        "left_sleeve": ZoneStyle(
            colors=(darken(left_base, 0.10), lighten(left_base, 0.10)),
            direction="diagonal",
            opacity=min(1.0, config.zone_opacity + 0.03),
            blend_mode=config.blend_mode,
        ),
        "right_sleeve": ZoneStyle(
            colors=(darken(right_base, 0.10), lighten(right_base, 0.10)),
            direction="reverse_diagonal",
            opacity=min(1.0, config.zone_opacity + 0.03),
            blend_mode=config.blend_mode,
        ),
        "front_collar": ZoneStyle(
            colors=(darken(collar_base, 0.08), lighten(collar_base, 0.04)),
            direction="horizontal",
            opacity=1.0,
            blend_mode="multiply",
        ),
        "back_collar": ZoneStyle(
            colors=(darken(collar_base, 0.08), lighten(collar_base, 0.04)),
            direction="horizontal",
            opacity=1.0,
            blend_mode="multiply",
        ),
    }


def build_sweatshirt_zone_styles(config: TextureGenerationConfig, palette: np.ndarray) -> dict[str, ZoneStyle]:
    dominant = palette[len(palette) // 2]
    dark = palette[0]
    light = palette[-1]
    accent = palette[-2] if len(palette) > 2 else dominant

    front_base = parse_hex_color(config.front_color) if config.front_color else dominant
    back_base = parse_hex_color(config.back_color) if config.back_color else mix(dominant, dark, 0.08)
    left_base = parse_hex_color(config.left_sleeve_color) if config.left_sleeve_color else mix(dominant, accent, 0.08)
    right_base = parse_hex_color(config.right_sleeve_color) if config.right_sleeve_color else mix(dominant, light, 0.06)
    trim_base = parse_hex_color(config.collar_color) if config.collar_color else darken(dominant, 0.28)

    return {
        "front": ZoneStyle(
            colors=(darken(front_base, 0.08), lighten(front_base, 0.10)),
            direction="vertical",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
        "back": ZoneStyle(
            colors=(darken(back_base, 0.10), lighten(back_base, 0.08)),
            direction="vertical",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
        "left_sleeve": ZoneStyle(
            colors=(darken(left_base, 0.10), lighten(left_base, 0.08)),
            direction="diagonal",
            opacity=min(1.0, config.zone_opacity + 0.02),
            blend_mode=config.blend_mode,
        ),
        "right_sleeve": ZoneStyle(
            colors=(darken(right_base, 0.10), lighten(right_base, 0.08)),
            direction="reverse_diagonal",
            opacity=min(1.0, config.zone_opacity + 0.02),
            blend_mode=config.blend_mode,
        ),
        "waistband": ZoneStyle(
            colors=(darken(trim_base, 0.10), lighten(trim_base, 0.04)),
            direction="horizontal",
            opacity=1.0,
            blend_mode="multiply",
        ),
        "cuff": ZoneStyle(
            colors=(darken(trim_base, 0.10), lighten(trim_base, 0.04)),
            direction="vertical",
            opacity=1.0,
            blend_mode="multiply",
        ),
    }


def build_bottom_zone_styles(config: TextureGenerationConfig, palette: np.ndarray) -> dict[str, ZoneStyle]:
    dominant = palette[len(palette) // 2]
    dark = palette[0]
    light = palette[-1]
    accent = palette[-2] if len(palette) > 2 else dominant

    front_base = parse_hex_color(config.front_color) if config.front_color else dominant
    back_base = parse_hex_color(config.back_color) if config.back_color else mix(dominant, dark, 0.10)
    left_base = parse_hex_color(config.left_sleeve_color) if config.left_sleeve_color else mix(front_base, accent, 0.08)
    right_base = parse_hex_color(config.right_sleeve_color) if config.right_sleeve_color else mix(front_base, light, 0.06)
    waistband_base = parse_hex_color(config.collar_color) if config.collar_color else darken(dominant, 0.22)

    return {
        "front_left_leg": ZoneStyle(
            colors=(darken(left_base, 0.10), lighten(left_base, 0.08)),
            direction="vertical",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
        "front_right_leg": ZoneStyle(
            colors=(darken(right_base, 0.10), lighten(right_base, 0.08)),
            direction="vertical",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
        "back_left_leg": ZoneStyle(
            colors=(darken(back_base, 0.12), lighten(back_base, 0.06)),
            direction="vertical",
            opacity=min(1.0, config.zone_opacity + 0.02),
            blend_mode=config.blend_mode,
        ),
        "back_right_leg": ZoneStyle(
            colors=(darken(back_base, 0.12), lighten(back_base, 0.06)),
            direction="vertical",
            opacity=min(1.0, config.zone_opacity + 0.02),
            blend_mode=config.blend_mode,
        ),
        "waistband_front": ZoneStyle(
            colors=(darken(waistband_base, 0.10), lighten(waistband_base, 0.04)),
            direction="horizontal",
            opacity=1.0,
            blend_mode="multiply",
        ),
        "waistband_back": ZoneStyle(
            colors=(darken(waistband_base, 0.10), lighten(waistband_base, 0.04)),
            direction="horizontal",
            opacity=1.0,
            blend_mode="multiply",
        ),
    }


def build_shoes_zone_styles(config: TextureGenerationConfig, palette: np.ndarray) -> dict[str, ZoneStyle]:
    dominant = palette[len(palette) // 2]
    dark = palette[0]
    light = palette[-1]
    accent = palette[-2] if len(palette) > 2 else dominant

    upper_base = parse_hex_color(config.front_color) if config.front_color else dominant
    side_base = parse_hex_color(config.back_color) if config.back_color else mix(dominant, accent, 0.10)
    tongue_base = parse_hex_color(config.left_sleeve_color) if config.left_sleeve_color else mix(dominant, light, 0.08)
    trim_base = parse_hex_color(config.right_sleeve_color) if config.right_sleeve_color else darken(dominant, 0.18)
    sole_base = parse_hex_color(config.collar_color) if config.collar_color else lighten(dark, 0.72)
    lace_base = lighten(upper_base, 0.34)

    return {
        "laces_top": ZoneStyle(
            colors=(darken(lace_base, 0.08), lighten(lace_base, 0.06)),
            direction="horizontal",
            opacity=1.0,
            blend_mode="multiply",
        ),
        "laces_bottom": ZoneStyle(
            colors=(darken(lace_base, 0.08), lighten(lace_base, 0.06)),
            direction="horizontal",
            opacity=1.0,
            blend_mode="multiply",
        ),
        "lace_column": ZoneStyle(
            colors=(darken(lace_base, 0.10), lighten(lace_base, 0.04)),
            direction="vertical",
            opacity=1.0,
            blend_mode="multiply",
        ),
        "sole_main": ZoneStyle(
            colors=(darken(sole_base, 0.10), lighten(sole_base, 0.04)),
            direction="horizontal",
            opacity=1.0,
            blend_mode="overlay",
        ),
        "sole_toe": ZoneStyle(
            colors=(darken(sole_base, 0.08), lighten(sole_base, 0.06)),
            direction="horizontal",
            opacity=1.0,
            blend_mode="overlay",
        ),
        "tongue_left": ZoneStyle(
            colors=(darken(tongue_base, 0.08), lighten(tongue_base, 0.08)),
            direction="vertical",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
        "tongue_right": ZoneStyle(
            colors=(darken(tongue_base, 0.08), lighten(tongue_base, 0.08)),
            direction="vertical",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
        "heel_patch": ZoneStyle(
            colors=(darken(trim_base, 0.10), lighten(trim_base, 0.06)),
            direction="horizontal",
            opacity=min(1.0, config.zone_opacity + 0.04),
            blend_mode=config.blend_mode,
        ),
        "sidewall_upper": ZoneStyle(
            colors=(darken(side_base, 0.08), lighten(side_base, 0.08)),
            direction="horizontal",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
        "sidewall_lower": ZoneStyle(
            colors=(darken(upper_base, 0.12), lighten(upper_base, 0.04)),
            direction="horizontal",
            opacity=config.zone_opacity,
            blend_mode=config.blend_mode,
        ),
    }


def compose_texture(config: TextureGenerationConfig) -> dict[str, Any]:
    validated = validate_config(config)
    profile = resolve_garment_profile(validated)
    normalized_subtype = normalize_subtype(validated.item_subtype)

    photo = load_image(validated.photo_path, "RGB")
    palette, weights, foreground_mask = extract_palette(photo, validated.palette_size)
    uv_reference = load_image(profile.uv_reference_path, "RGBA")

    if validated.base_path:
        fabric_source = load_image(validated.base_path, "RGBA")
    else:
        fabric_source = create_procedural_base(validated.size, validated.seed)

    base_array = create_uv_canvas(uv_reference, fabric_source, validated.size)
    width, height = base_array.shape[1], base_array.shape[0]
    if profile.item_type == "top" and normalized_subtype == "sweatshirt":
        zone_styles = build_sweatshirt_zone_styles(validated, palette)
    elif profile.item_type == "top":
        zone_styles = build_top_zone_styles(validated, palette)
    elif profile.item_type == "bottom":
        zone_styles = build_bottom_zone_styles(validated, palette)
    elif profile.item_type == "shoes":
        zone_styles = build_shoes_zone_styles(validated, palette)
    else:
        raise TextureGenerationError(f"Unsupported item_type '{profile.item_type}'.")

    result_array = base_array.copy()

    zone_hex: dict[str, str] = {}
    for zone_name, style in zone_styles.items():
        left, top, right, bottom = uv_to_pixels(profile.zones[zone_name], width, height)
        region = result_array[top:bottom, left:right, :]
        if region.size == 0:
            continue
        result_array[top:bottom, left:right, :] = apply_zone_style(
            region,
            style=style,
            detail_strength=validated.detail_strength,
        )
        zone_hex[zone_name] = "#{:02x}{:02x}{:02x}".format(
            *(np.clip(style.colors[0] * 255.0, 0.0, 255.0).astype(np.uint8))
        )

    composed = array_to_image(result_array, mode="RGBA")

    if validated.logo_path and profile.logo_zone_name is not None:
        logo = load_image(validated.logo_path, "RGBA")
        left, top, right, bottom = uv_to_pixels(profile.zones[profile.logo_zone_name], width, height)
        composed.alpha_composite(
            fit_logo_to_zone(logo, max(1, right - left), max(1, bottom - top), validated.logo_scale),
            dest=(left, top),
        )

    composed.save(validated.output_path, format="PNG")
    export_palette_preview(palette, weights, validated.palette_preview_path)

    dominant = palette[len(palette) // 2]
    dominant_hex = "#{:02x}{:02x}{:02x}".format(
        *(np.clip(dominant * 255.0, 0.0, 255.0).astype(np.uint8))
    )
    palette_hex = [
        "#{:02x}{:02x}{:02x}".format(*(np.clip(color * 255.0, 0.0, 255.0).astype(np.uint8)))
        for color in palette
    ]

    return {
        "output": str(validated.output_path),
        "palette_preview": str(validated.palette_preview_path),
        "palette": palette_hex,
        "dominant_color": dominant_hex,
        "item_type": profile.item_type,
        "item_subtype": validated.item_subtype,
        "foreground_coverage": round(float(np.mean(foreground_mask > 0.2)), 4),
        "zone_colors": zone_hex,
        "logo_applied": validated.logo_path is not None and profile.logo_zone_name is not None,
        "uv_reference": str(profile.uv_reference_path),
        "size": width,
        "blend_mode": validated.blend_mode,
    }


def meta_to_json(meta: dict[str, Any]) -> str:
    return json.dumps(meta, indent=2)
