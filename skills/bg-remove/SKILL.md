---
name: bg-remove
description: Remove backgrounds from images using local AI (rembg). Use when removing backgrounds from character art, mascot images, photos, or any image that needs a transparent background.
user_invocable: true
---

# Background Remove — Local AI Background Removal

Remove backgrounds from images using rembg (local, offline, no data sent externally). Outputs RGBA PNG with proper transparency.

## Input

Arguments after `/bg-remove`:
- **Source image path** (required) — path to the image
- **`--trim`** (optional) — auto-trim transparent padding after removal
- **`--output <path>`** (optional) — custom output path. Default: same directory, `<name>-transparent.png`

Examples:
- `/bg-remove assets/character/mascot.png`
- `/bg-remove image.png --trim`
- `/bg-remove image.png --output ~/Desktop/result.png`

## Setup

rembg is installed in a dedicated venv. Always activate it before use:

```bash
source ~/.claude/tools/rembg-env/bin/activate
```

If the venv doesn't exist, install it:

```bash
python3 -m venv ~/.claude/tools/rembg-env && source ~/.claude/tools/rembg-env/bin/activate && pip install "rembg[cpu,cli]"
```

Model files are cached in `~/.u2net/` (downloaded on first use per model, ~170MB for birefnet-general).

## Process

### Step 1: Verify Input

1. Check the source image exists
2. Get dimensions: `sips -g pixelWidth -g pixelHeight <path>`
3. View the image with the Read tool to understand what we're working with

### Step 2: Remove Background

Use the `birefnet-general` model — it produces the best results for character art and general images.

```bash
source ~/.claude/tools/rembg-env/bin/activate && rembg i -m birefnet-general <input> <output>
```

**Model choice:** Always use `birefnet-general`. It gives clean edges and handles both character art and photographic subjects well.

### Step 3: Verify Result

The Read tool renders transparency as black, so you MUST verify by compositing on a colored background:

```bash
source ~/.claude/tools/rembg-env/bin/activate && python3 -c "
from PIL import Image
import numpy as np

# Load result
img = Image.open('<output>').convert('RGBA')
alpha = np.array(img)[:,:,3]
total = alpha.size
transparent = np.sum(alpha == 0)
opaque = np.sum(alpha == 255)
print(f'Dimensions: {img.size}')
print(f'Transparent: {transparent/total*100:.1f}%')
print(f'Opaque: {opaque/total*100:.1f}%')
print(f'Corners alpha: TL={alpha[0,0]} TR={alpha[0,-1]} BL={alpha[-1,0]} BR={alpha[-1,-1]}')

# Composite on magenta for visual verification
bg = Image.new('RGBA', img.size, (255, 0, 255, 255))
bg.paste(img, (0, 0), img)
bg.save('<output_dir>/verify-magenta.png')
print('Verification image saved')
"
```

Then view the magenta verification image with the Read tool. The magenta should only show where background was removed.

### Step 4: Optional Trim

If `--trim` was requested, trim transparent padding:

```bash
source ~/.claude/tools/rembg-env/bin/activate && python3 -c "
from PIL import Image
import numpy as np

img = Image.open('<output>').convert('RGBA')
alpha = np.array(img)[:,:,3]

# Find bounding box of non-transparent pixels
rows = np.any(alpha > 0, axis=1)
cols = np.any(alpha > 0, axis=0)
rmin, rmax = np.where(rows)[0][[0, -1]]
cmin, cmax = np.where(cols)[0][[0, -1]]

# Add small padding (2% of dimensions)
pad_h = max(int(img.height * 0.02), 4)
pad_w = max(int(img.width * 0.02), 4)
rmin = max(0, rmin - pad_h)
rmax = min(img.height - 1, rmax + pad_h)
cmin = max(0, cmin - pad_w)
cmax = min(img.width - 1, cmax + pad_w)

cropped = img.crop((cmin, rmin, cmax + 1, rmax + 1))
cropped.save('<output>')
print(f'Trimmed: {img.size} -> {cropped.size}')
"
```

### Step 5: Report

```
Done: background removed
  Source: <input_path>
  Output: <output_path>
  Dimensions: <width>x<height>
  Transparent pixels: <percent>%
  Model: birefnet-general (local, offline)
```

## Important Rules

1. **Always use `birefnet-general`** — best general-purpose model for this task.
2. **Always activate the venv** before running rembg or Python with Pillow/numpy.
3. **Always verify with magenta composite** — don't trust the Read tool's rendering of transparency.
4. **Never send images to external services** — rembg runs 100% locally.
5. **Preserve original files** — output to a new file, never overwrite the source.
6. **Clean up verification images** — delete the magenta composite after confirming quality.
