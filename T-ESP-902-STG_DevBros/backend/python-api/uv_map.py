import cv2
import numpy as np
from PIL import Image
import sys
import os


# -----------------------------
# Utils
# -----------------------------

def normalize01(arr):
    arr = arr.astype(np.float32)
    mn, mx = arr.min(), arr.max()
    if mx - mn < 1e-8:
        return np.zeros_like(arr)
    return (arr - mn) / (mx - mn)


def parse_color(color_str):
    if color_str.startswith("#"):
        raw = color_str.lstrip("#")
        if len(raw) != 6:
            raise ValueError("Hex color must use the format #RRGGBB")
        return tuple(int(raw[index:index + 2], 16) for index in (0, 2, 4))

    parts = color_str.split(",")
    return tuple(int(p.strip()) for p in parts)


# -----------------------------
# Texture textile
# -----------------------------

def make_fabric_texture(width, height, base_color=(70, 150, 255), seed=42):
    rng = np.random.default_rng(seed)

    texture = np.zeros((height, width, 3), dtype=np.float32)
    texture[:, :] = np.array(base_color, dtype=np.float32)

    noise = rng.normal(0, 10, (height, width, 1))
    texture += noise

    y = np.arange(height).reshape(-1, 1)
    x = np.arange(width).reshape(1, -1)

    weave = 5 * np.sin(y * 0.5) + 4 * np.sin(x * 0.4)
    texture += weave[:, :, None]

    texture = np.clip(texture, 0, 255).astype(np.uint8)
    return texture


def generate_wrinkles(width, height, seed=42):
    rng = np.random.default_rng(seed)

    noise = rng.normal(0, 1, (height, width))
    noise = cv2.GaussianBlur(noise, (0, 0), 15)
    noise = normalize01(noise)

    return noise


# -----------------------------
# Détection template
# -----------------------------

def detect_masks(img):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    white_mask = cv2.inRange(gray, 180, 255)

    kernel = np.ones((3, 3), np.uint8)
    white_mask = cv2.morphologyEx(white_mask, cv2.MORPH_CLOSE, kernel)

    dark_mask = cv2.inRange(gray, 0, 120)
    line_mask = cv2.bitwise_and(dark_mask, cv2.dilate(white_mask, kernel))

    return white_mask, line_mask


# -----------------------------
# Remplissage
# -----------------------------

def apply_texture(mask, texture, seed=42):
    h, w = mask.shape

    wrinkle = generate_wrinkles(w, h, seed)

    light = 0.8 + wrinkle * 0.4
    shaded = texture.astype(np.float32) * light[:, :, None]

    shaded = np.clip(shaded, 0, 255).astype(np.uint8)

    alpha = (mask / 255.0)[:, :, None]
    shaded = (shaded * alpha).astype(np.uint8)

    return shaded


# -----------------------------
# Composition RGBA
# -----------------------------

def compose_rgba(fill, fill_mask, line_mask):
    h, w = fill_mask.shape

    rgba = np.zeros((h, w, 4), dtype=np.uint8)

    rgba[:, :, :3] = fill
    rgba[:, :, 3] = fill_mask

    # ajouter lignes
    for c in range(3):
        rgba[:, :, c] = np.where(
            line_mask > 0,
            30,
            rgba[:, :, c]
        )

    rgba[:, :, 3] = np.maximum(fill_mask, line_mask)

    return rgba


# -----------------------------
# Pipeline principal
# -----------------------------

def colorize_template(input_path, output_path, color=(70, 150, 255)):
    img = cv2.imread(input_path)

    if img is None:
        raise Exception("Image introuvable")

    h, w = img.shape[:2]

    white_mask, line_mask = detect_masks(img)

    texture = make_fabric_texture(w, h, color)

    fill = apply_texture(white_mask, texture)

    rgba = compose_rgba(fill, white_mask, line_mask)

    Image.fromarray(rgba).save(output_path)


# -----------------------------
# Entry point (compatible PHP)
# -----------------------------

def main():
    if len(sys.argv) < 3:
        print("Usage: script.py input output [--color R,G,B]")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    color = (70, 150, 255)

    for i, arg in enumerate(sys.argv):
        if arg == "--color" and i + 1 < len(sys.argv):
            color = parse_color(sys.argv[i + 1])

    if not os.path.exists(input_path):
        print("Fichier input introuvable")
        sys.exit(1)

    colorize_template(input_path, output_path, color)

    print("OK")


if __name__ == "__main__":
    main()
