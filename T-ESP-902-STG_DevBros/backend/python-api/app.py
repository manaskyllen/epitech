#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import uuid
from pathlib import Path
from typing import Any

from flask import Flask, jsonify, request
from PIL import Image

from uv_map import colorize_template, parse_color


SHARED_DIR = Path("/app/shared")
ROOT_DIR = Path(__file__).resolve().parent
TOP_UV_REFERENCE_PATH = ROOT_DIR / "t-shirt-uv.png"
SWEATSHIRT_UV_REFERENCE_PATH = ROOT_DIR / "sweatshirt-uv.png"
BOTTOM_UV_REFERENCE_PATH = ROOT_DIR / "bottom-uv.png"
SHOES_UV_REFERENCE_PATH = ROOT_DIR / "shoes-uv.png"


def resolve_shared_path(raw_path: str) -> Path:
    path = Path(raw_path)
    if path.is_absolute():
        return path
    return SHARED_DIR / path


class TextureGenerationError(Exception):
    """Raised when UV map generation cannot complete."""


def normalize_subtype(value: str | None) -> str:
    if not value:
        return ""
    return value.strip().lower().replace("-", "").replace(" ", "")


def resolve_uv_reference(
    item_type: str,
    item_subtype: str | None,
    explicit_reference: str | None,
) -> Path:
    if explicit_reference:
        uv_reference_path = resolve_shared_path(str(explicit_reference))
    else:
        normalized_type = (item_type or "top").strip().lower()
        normalized_subtype = normalize_subtype(item_subtype)

        if normalized_subtype == "sweatshirt":
            uv_reference_path = SWEATSHIRT_UV_REFERENCE_PATH
        elif normalized_type == "top":
            uv_reference_path = TOP_UV_REFERENCE_PATH
        elif normalized_type == "bottom":
            uv_reference_path = BOTTOM_UV_REFERENCE_PATH
        elif normalized_type == "shoes":
            uv_reference_path = SHOES_UV_REFERENCE_PATH
        else:
            raise TextureGenerationError(
                f"No UV template configured for item_type '{item_type}' and item_subtype '{item_subtype}'."
            )

    if not uv_reference_path.is_file():
        raise TextureGenerationError(f"UV template not found: {uv_reference_path}")

    return uv_reference_path


def parse_payload_color(payload: dict[str, Any], photo_path: Path) -> tuple[tuple[int, int, int], str | None, str]:
    requested_color = (
        payload.get("color")
        or payload.get("front_color")
        or payload.get("front-color")
    )

    if requested_color:
        try:
            color = parse_color(str(requested_color))
        except ValueError as exc:
            raise TextureGenerationError(str(exc)) from exc
        normalized_hex = "#{:02X}{:02X}{:02X}".format(*color)
        return color, str(requested_color), normalized_hex

    if not photo_path.is_file():
        raise TextureGenerationError(f"Photo not found: {photo_path}")

    with Image.open(photo_path) as image:
        rgb_image = image.convert("RGB")
        rgb_image.thumbnail((128, 128), Image.Resampling.LANCZOS)
        palette_image = rgb_image.quantize(colors=6, method=Image.Quantize.MEDIANCUT)
        palette = palette_image.getpalette() or []
        color_counts = palette_image.getcolors() or []

    if not color_counts:
        raise TextureGenerationError("Unable to extract a dominant color from the inspiration photo.")

    dominant_index = max(color_counts, key=lambda item: item[0])[1]
    offset = dominant_index * 3
    dominant_color = tuple(int(channel) for channel in palette[offset:offset + 3])

    if len(dominant_color) != 3:
        raise TextureGenerationError("Invalid dominant color extracted from the inspiration photo.")

    normalized_hex = "#{:02X}{:02X}{:02X}".format(*dominant_color)
    return dominant_color, None, normalized_hex


def export_palette_preview(path: Path, color: tuple[int, int, int]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.new("RGB", (512, 128), color).save(path, format="PNG")


def build_generation_context(payload: dict[str, Any]) -> dict[str, Any]:
    photo_value = payload.get("photo") or payload.get("photo_path") or payload.get("filename")
    out_value = payload.get("out") or payload.get("output") or payload.get("output_path")
    palette_preview = payload.get("palette_preview") or payload.get("palettePreview")
    item_type = payload.get("item_type") or payload.get("itemType") or "top"
    item_subtype = payload.get("item_subtype") or payload.get("itemSubtype")
    uv_reference = payload.get("uv_reference") or payload.get("uvReference") or payload.get("uv_reference_path")

    if not photo_value:
        raise TextureGenerationError("photo is required")
    if not out_value:
        out_value = f"{uuid.uuid4().hex}.png"

    photo_path = resolve_shared_path(str(photo_value))
    output_path = resolve_shared_path(str(out_value))
    palette_preview_path = (
        resolve_shared_path(str(palette_preview))
        if palette_preview
        else output_path.with_name(f"{output_path.stem}_palette.png")
    )

    uv_reference_path = resolve_uv_reference(
        item_type=str(item_type),
        item_subtype=str(item_subtype) if item_subtype else None,
        explicit_reference=str(uv_reference) if uv_reference else None,
    )
    color_rgb, requested_color, applied_color_hex = parse_payload_color(payload, photo_path)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    return {
        "photo_path": photo_path,
        "output_path": output_path,
        "palette_preview_path": palette_preview_path,
        "item_type": str(item_type),
        "item_subtype": str(item_subtype) if item_subtype else None,
        "uv_reference_path": uv_reference_path,
        "requested_color": requested_color,
        "applied_color_rgb": color_rgb,
        "applied_color_hex": applied_color_hex,
    }


app = Flask(__name__)


@app.get("/health")
def health() -> tuple[str, int]:
    return "ok", 200


@app.post("/generate")
def generate_route() -> tuple[Any, int]:
    payload = request.get_json(silent=True) or {}

    try:
        generation = build_generation_context(payload)
        colorize_template(
            input_path=str(generation["uv_reference_path"]),
            output_path=str(generation["output_path"]),
            color=generation["applied_color_rgb"],
        )
        export_palette_preview(generation["palette_preview_path"], generation["applied_color_rgb"])
    except TextureGenerationError as exc:
        return jsonify({"status": "error", "error": str(exc)}), 400
    except Exception as exc:
        return jsonify({"status": "error", "error": str(exc)}), 500

    result = {
        "output": str(generation["output_path"]),
        "palette_preview": str(generation["palette_preview_path"]),
        "item_type": generation["item_type"],
        "item_subtype": generation["item_subtype"],
        "uv_reference": str(generation["uv_reference_path"]),
        "requested_color": generation["requested_color"],
        "dominant_color": generation["applied_color_hex"],
        "applied_color": generation["applied_color_hex"],
        "applied_color_rgb": list(generation["applied_color_rgb"]),
    }

    return (
        jsonify(
            {
                "status": "success",
                "filename": Path(result["output"]).name,
                "palette_preview": Path(result["palette_preview"]).name,
                "meta": result,
            }
        ),
        200,
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate a garment UV texture from a photo and a dedicated UV template."
    )
    subparsers = parser.add_subparsers(dest="command")

    generate_parser = subparsers.add_parser("generate", help="Generate a UV texture PNG from a dedicated template")
    generate_parser.add_argument("--photo", required=True, help="Path to the inspiration photo")
    generate_parser.add_argument("--item-type", default="top", help="Garment type profile, for example top or bottom")
    generate_parser.add_argument("--item-subtype", default=None, help="Optional garment subtype")
    generate_parser.add_argument("--uv-reference", default=None, help="Optional explicit UV template path")
    generate_parser.add_argument("--out", required=True, help="Path to the output PNG")
    generate_parser.add_argument("--palette-preview", default=None)
    generate_parser.add_argument("--color", default=None)
    generate_parser.add_argument("--front-color", default=None)

    serve_parser = subparsers.add_parser("serve", help="Start the HTTP API")
    serve_parser.add_argument("--host", default="0.0.0.0", help="Bind host")
    serve_parser.add_argument("--port", type=int, default=5000, help="Bind port")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "serve":
        app.run(host=args.host, port=args.port, debug=False)
        return 0

    if args.command == "generate":
        try:
            result = build_generation_context(
                {
                    "photo": args.photo,
                    "out": args.out,
                    "item_type": args.item_type,
                    "item_subtype": args.item_subtype,
                    "uv_reference": args.uv_reference,
                    "palette_preview": args.palette_preview,
                    "color": args.color,
                    "front_color": args.front_color,
                }
            )
            colorize_template(
                input_path=str(result["uv_reference_path"]),
                output_path=str(result["output_path"]),
                color=result["applied_color_rgb"],
            )
            export_palette_preview(result["palette_preview_path"], result["applied_color_rgb"])
        except TextureGenerationError as exc:
            parser.exit(status=2, message=f"error: {exc}\n")

        print(
            json.dumps(
                {
                    "output": str(result["output_path"]),
                    "palette_preview": str(result["palette_preview_path"]),
                    "item_type": result["item_type"],
                    "item_subtype": result["item_subtype"],
                    "uv_reference": str(result["uv_reference_path"]),
                    "requested_color": result["requested_color"],
                    "dominant_color": result["applied_color_hex"],
                    "applied_color": result["applied_color_hex"],
                    "applied_color_rgb": list(result["applied_color_rgb"]),
                },
                indent=2,
            )
        )
        return 0

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
