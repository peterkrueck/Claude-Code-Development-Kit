#!/usr/bin/env python3
"""Crop, resize, mirror, and rotate images.

Usage:
  # Crop only
  python crop_image.py input.png output.png --left 0 --top 0 --right 500 --bottom 500

  # Transform only (no crop)
  python crop_image.py input.png output.png --mirror horizontal --rotate 90

  # Combined: crop, then mirror, then rotate, then resize
  python crop_image.py input.png output.png --left 0 --top 0 --right 500 --bottom 500 \
    --mirror horizontal --rotate 90 --resize 512x512

Operations apply in order: crop -> mirror -> rotate -> resize.
Coordinates are in pixels. (0,0) is top-left.
"""

import argparse
import sys

from PIL import Image


def transform(
    input_path: str,
    output_path: str,
    left: int = None,
    top: int = None,
    right: int = None,
    bottom: int = None,
    mirror: str = None,
    rotate: float = None,
    resize: str = None,
):
    img = Image.open(input_path)
    steps = []

    # --- Crop ---
    crop_coords = [left, top, right, bottom]
    has_crop = any(c is not None for c in crop_coords)
    if has_crop:
        if not all(c is not None for c in crop_coords):
            print("Error: all four crop coordinates (--left, --top, --right, --bottom) must be provided together.", file=sys.stderr)
            sys.exit(1)

        if left < 0 or top < 0 or right > img.width or bottom > img.height:
            print(f"Warning: crop region ({left},{top})-({right},{bottom}) extends beyond image ({img.width}x{img.height}). Clamping.", file=sys.stderr)
            left = max(0, left)
            top = max(0, top)
            right = min(img.width, right)
            bottom = min(img.height, bottom)

        img = img.crop((left, top, right, bottom))
        steps.append(f"cropped to {img.width}x{img.height}")

    # --- Mirror ---
    if mirror:
        direction = mirror.lower()
        if direction in ("horizontal", "h"):
            img = img.transpose(Image.FLIP_LEFT_RIGHT)
            steps.append("mirrored horizontally")
        elif direction in ("vertical", "v"):
            img = img.transpose(Image.FLIP_TOP_BOTTOM)
            steps.append("mirrored vertically")
        else:
            print(f"Error: --mirror must be 'horizontal' (or 'h') or 'vertical' (or 'v'), got '{mirror}'", file=sys.stderr)
            sys.exit(1)

    # --- Rotate ---
    if rotate is not None:
        angle = rotate % 360
        if angle == 90:
            img = img.transpose(Image.ROTATE_90)
        elif angle == 180:
            img = img.transpose(Image.ROTATE_180)
        elif angle == 270:
            img = img.transpose(Image.ROTATE_270)
        else:
            img = img.rotate(rotate, expand=True, resample=Image.BICUBIC)
        steps.append(f"rotated {rotate}deg")

    # --- Resize ---
    if resize:
        w, h = map(int, resize.lower().split("x"))
        img = img.resize((w, h), Image.LANCZOS)
        steps.append(f"resized to {w}x{h}")

    if not steps:
        print("Error: no operations specified. Use --left/--top/--right/--bottom, --mirror, --rotate, or --resize.", file=sys.stderr)
        sys.exit(1)

    img.save(output_path)
    summary = " -> ".join(steps)
    print(f"{summary}")
    print(f"Saved to {output_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Crop, resize, mirror, and rotate images")
    parser.add_argument("input_path", help="Source image path")
    parser.add_argument("output_path", help="Output image path")
    parser.add_argument("--left", type=int, default=None, help="Crop left coordinate")
    parser.add_argument("--top", type=int, default=None, help="Crop top coordinate")
    parser.add_argument("--right", type=int, default=None, help="Crop right coordinate")
    parser.add_argument("--bottom", type=int, default=None, help="Crop bottom coordinate")
    parser.add_argument("--mirror", type=str, default=None, help="Mirror direction: horizontal (h) or vertical (v)")
    parser.add_argument("--rotate", type=float, default=None, help="Rotation in degrees (counter-clockwise, canvas expands)")
    parser.add_argument("--resize", type=str, default=None, help="Resize after other ops, e.g. 512x512")
    args = parser.parse_args()
    transform(
        args.input_path, args.output_path,
        args.left, args.top, args.right, args.bottom,
        args.mirror, args.rotate, args.resize,
    )
