#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

from uv_texture_pipeline import (
    VALID_BLEND_MODES,
    TextureGenerationConfig,
    TextureGenerationError,
    compose_texture,
    meta_to_json,
)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate a procedural garment UV texture from a photo, optional base texture and optional logo."
    )
    parser.add_argument("--photo-path", required=True, help="Path to the inspiration photo")
    parser.add_argument("--output-path", required=True, help="Path to the final UV texture PNG")
    parser.add_argument("--item-type", default="top", help="Garment type profile, for example top or bottom")
    parser.add_argument("--item-subtype", default=None, help="Optional garment subtype")
    parser.add_argument("--base-texture-path", default=None, help="Optional base fabric texture PNG")
    parser.add_argument("--logo-path", default=None, help="Optional logo PNG with alpha")
    parser.add_argument("--uv-reference-path", default=None, help="Optional explicit UV template path")
    parser.add_argument("--palette-preview-path", default=None, help="Optional palette preview PNG")
    parser.add_argument("--size", type=int, default=1024, help="Square output size")
    parser.add_argument("--palette-size", type=int, default=5, help="Number of palette colors to extract")
    parser.add_argument("--blend-mode", choices=VALID_BLEND_MODES, default="soft_light")
    parser.add_argument("--detail-strength", type=float, default=0.9)
    parser.add_argument("--zone-opacity", type=float, default=0.9)
    parser.add_argument("--logo-scale", type=float, default=0.82)
    parser.add_argument("--seed", type=int, default=None)
    parser.add_argument("--front-color", default=None)
    parser.add_argument("--back-color", default=None)
    parser.add_argument("--left-sleeve-color", default=None)
    parser.add_argument("--right-sleeve-color", default=None)
    parser.add_argument("--collar-color", default=None)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    try:
        result = compose_texture(
            TextureGenerationConfig(
                photo_path=Path(args.photo_path),
                output_path=Path(args.output_path),
                item_type=args.item_type,
                item_subtype=args.item_subtype,
                base_path=Path(args.base_texture_path) if args.base_texture_path else None,
                logo_path=Path(args.logo_path) if args.logo_path else None,
                uv_reference_path=Path(args.uv_reference_path) if args.uv_reference_path else None,
                palette_preview_path=Path(args.palette_preview_path)
                if args.palette_preview_path
                else None,
                size=args.size,
                palette_size=args.palette_size,
                blend_mode=args.blend_mode,
                detail_strength=args.detail_strength,
                zone_opacity=args.zone_opacity,
                logo_scale=args.logo_scale,
                seed=args.seed,
                front_color=args.front_color,
                back_color=args.back_color,
                left_sleeve_color=args.left_sleeve_color,
                right_sleeve_color=args.right_sleeve_color,
                collar_color=args.collar_color,
            )
        )
    except TextureGenerationError as exc:
        parser.exit(status=2, message=f"error: {exc}\n")

    print(meta_to_json(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
