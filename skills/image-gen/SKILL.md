---
name: image-gen
description: Generate character art and image variations using AI image generation (Google Gemini) with reference images for style and character consistency. Use this skill when the user asks to generate new character poses, mascot variations, art assets, illustrations, or any AI-generated images — especially when maintaining consistency with an existing character or style.
user_invocable: true
---

# AI Image Generation (Gemini)

Generate image variations using Google's Gemini image generation model with reference images for style and character consistency. The model supports up to 14 reference images per request and can maintain consistency across multiple characters.

## Prerequisites

- **GEMINI_API_KEY** environment variable must be set
  - Get a key at https://aistudio.google.com/apikey
  - The key needs billing enabled for image generation (~$0.067/image at 1K resolution)
- **Deno** runtime installed (for the generation script)

## Workflow

### Step 1 — Understand what the user wants

Clarify the subject, pose, expression, context, and where the asset will be used (app screen, social media, website, etc.). This context helps craft the right prompt and choose the right aspect ratio.

### Step 2 — Select reference images

Always use **1-2 reference images** for consistency:

1. **Primary reference (always first):** The most canonical image of the character/subject. This anchors identity — face shape, color palette, defining features.

2. **Style/pose reference (second, optional):** Pick the closest existing approved asset to the target pose. This anchors proportions and art style.

The primary reference anchors identity; the style reference anchors proportions. Both together produce the most consistent results.

### Step 3 — Craft the prompt

Write a detailed prompt that describes the exact pose, expression, and style:

1. **Character/subject description** — physical traits that define the character (so the model doesn't drift)
2. **Pose and expression** — what the character is doing
3. **Style directives** — art style, line style, shading approach
4. **Background** — color, scene, or transparent
5. **Framing** — full body, bust, three-quarter view, etc.

**Prompt template:**
```
[CHARACTER_DESCRIPTION]. [POSE_AND_EXPRESSION]. [STYLE_DIRECTIVES]. [BACKGROUND]. [VIEW/FRAMING].
```

**Tips:**
- Be specific about what each hand/arm is doing — vague descriptions lead to random poses
- Always specify the background explicitly
- Include style keywords consistently (e.g., "flat color fills", "3D render", "watercolor")

### Step 4 — Generate variations

Run the bundled generation script:

```bash
deno run --allow-env --allow-read --allow-write --allow-net \
  .claude/skills/image-gen/scripts/generate.ts \
  --prompt "your prompt here" \
  --ref path/to/primary-reference.png \
  --ref path/to/style-reference.png \
  --output-dir /tmp/image-gen \
  --variants 4 \
  --aspect "<choose based on use case>" \
  --size "2K"
```

**Parameters:**
| Flag | Default | Options |
|------|---------|---------|
| `--variants` | 4 | 1-8 (each is a separate API call) |
| `--aspect` | 1:1 | 1:1, 3:4, 4:3, 9:16, 16:9, 2:3, 3:2 |
| `--size` | 1K | 512, 1K, 2K, 4K |

**Always default to `2K` for size** — higher resolution gives better quality and can always be downscaled.

**Choose aspect ratio based on use case:**
| Use Case | Aspect Ratio |
|----------|-------------|
| Full-body character poses | `3:4` |
| App icons, avatars, social profiles | `1:1` |
| Mobile screens, in-app cards | `9:16` or `3:4` |
| Banner/header images, OG images | `16:9` or `4:3` |
| Bust/upper-body portraits | `1:1` or `4:3` |

**Cost:** ~$0.10/image at 2K = ~$0.40 for 4 variants.

### Step 5 — Pick the best variant

Use the Read tool to visually inspect all generated images. Score each on:

**Consistency (most important):**
- Does it match the reference images — face, proportions, colors, style?
- Is the art style consistent (not drifting to photorealistic, 3D, etc.)?

**Quality (tiebreaker):**
- Does the image have personality and visual appeal?
- Would this work well as a production asset?

**Pick the single best variant** and copy it to the project's assets directory with a descriptive name. Briefly explain why you picked it.

If none are good enough, explain what went wrong and offer to regenerate with prompt adjustments.

### Step 6 — Post-process

After picking the best variant:
- Copy the chosen file to the appropriate assets directory
- Clean up: delete the rejected variants and the temp output directory
- Use the **image-edit** skill if the user needs a different crop or size

## Rate Limits

If some variants fail with 429 errors: wait 60 seconds, then rerun with only the missing number of variants. Don't retry all — just fill in the gaps.

If all fail with 429: wait 60 seconds and try again. If it keeps failing, the daily quota may be exhausted — try later or enable billing for higher limits.

## Troubleshooting

- **"GEMINI_API_KEY not set"** — Get a key at https://aistudio.google.com/apikey
- **"Billing not enabled" or 403** — Enable billing in Google AI Studio for image generation
- **429 rate limit** — Wait 60 seconds and retry
- **Character looks wrong** — Be more specific about physical traits, ensure both reference images are included
- **Style drifted** — Reinforce style keywords more strongly in the prompt
- **Pose is wrong** — Be extremely specific about what each arm/hand is doing
