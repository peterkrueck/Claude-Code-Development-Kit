#!/usr/bin/env python3
"""Analyze an image to find the bounding box of its actual content.

Usage: python analyze_bounds.py <image_path> [--threshold 30]

Outputs JSON with content bounds, image dimensions, and suggested crop regions.
Treats near-black pixels and fully transparent pixels as background.
"""

import argparse
import json
import sys

from PIL import Image
import numpy as np


def analyze(image_path: str, threshold: int = 30) -> dict:
    img = Image.open(image_path)
    arr = np.array(img)
    w, h = img.size

    # Build mask of "content" pixels
    if img.mode == "RGBA":
        # Content = visible (alpha > threshold) AND not near-black
        alpha_mask = arr[:, :, 3] > threshold
        color_mask = np.any(arr[:, :, :3] > threshold, axis=2)
        mask = alpha_mask & color_mask
    elif img.mode == "RGB":
        mask = np.any(arr > threshold, axis=2)
    elif img.mode == "L":
        mask = arr > threshold
    else:
        # Convert to RGB and retry
        img = img.convert("RGB")
        arr = np.array(img)
        mask = np.any(arr > threshold, axis=2)

    rows = np.any(mask, axis=1)
    cols = np.any(mask, axis=0)

    if not rows.any():
        print(json.dumps({"error": "No content found above threshold"}))
        sys.exit(1)

    rmin, rmax = int(np.where(rows)[0][0]), int(np.where(rows)[0][-1])
    cmin, cmax = int(np.where(cols)[0][0]), int(np.where(cols)[0][-1])

    content_w = cmax - cmin + 1
    content_h = rmax - rmin + 1
    cx = (cmin + cmax) // 2
    cy = (rmin + rmax) // 2

    # Suggested square crops at various content percentages
    max_side = min(w, h)
    suggestions = {}
    for label, pct in [("tight_head", 0.35), ("upper_body", 0.55), ("three_quarter", 0.75), ("full", 1.0)]:
        crop_h = int(content_h * pct)
        side = max(crop_h + 80, content_w + 40)  # padding
        side = min(side, max_side)  # clamp to keep it square within image

        # Vertical: anchor near the top of content with headroom
        top = max(0, rmin - 40)
        bottom = top + side
        if bottom > h:
            bottom = h
            top = max(0, bottom - side)

        # Horizontal: center on content
        left = max(0, cx - side // 2)
        right = left + side
        if right > w:
            right = w
            left = max(0, right - side)

        suggestions[label] = {
            "top": top, "bottom": bottom, "left": left, "right": right,
            "size": f"{right - left}x{bottom - top}",
            "content_pct": pct,
        }

    result = {
        "image_size": {"width": w, "height": h},
        "image_mode": img.mode,
        "content_bounds": {
            "top": rmin, "bottom": rmax, "left": cmin, "right": cmax,
            "width": content_w, "height": content_h,
        },
        "content_center": {"x": cx, "y": (rmin + rmax) // 2},
        "padding": {
            "top": rmin, "bottom": h - 1 - rmax,
            "left": cmin, "right": w - 1 - cmax,
        },
        "suggested_square_crops": suggestions,
    }

    print(json.dumps(result, indent=2))
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Analyze image content bounds")
    parser.add_argument("image_path", help="Path to the image file")
    parser.add_argument("--threshold", type=int, default=30, help="Pixel brightness threshold (0-255)")
    args = parser.parse_args()
    analyze(args.image_path, args.threshold)
