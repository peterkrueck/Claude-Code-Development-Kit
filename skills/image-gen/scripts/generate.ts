#!/usr/bin/env -S deno run --allow-env --allow-read --allow-write --allow-net

/**
 * Generate image variations using Gemini's image generation.
 *
 * Usage:
 *   deno run --allow-env --allow-read --allow-write --allow-net generate.ts \
 *     --prompt "description of the image" \
 *     --ref path/to/reference1.png [--ref path/to/reference2.png] \
 *     --output-dir ./output \
 *     [--variants 4] \
 *     [--aspect "1:1"] \
 *     [--size "1K"]
 *
 * Requires GEMINI_API_KEY environment variable.
 */

import { GoogleGenAI } from "npm:@google/genai@^1.0.0";
import { parseArgs } from "jsr:@std/cli/parse-args";
import { encodeBase64 } from "jsr:@std/encoding/base64";
import { ensureDir } from "jsr:@std/fs/ensure-dir";
import { join } from "jsr:@std/path";
import { load } from "jsr:@std/dotenv";

// Auto-load .env from CWD (won't override existing env vars)
try {
  const env = await load();
  for (const [key, value] of Object.entries(env)) {
    if (!Deno.env.get(key)) {
      Deno.env.set(key, value);
    }
  }
} catch {
  // .env not found — that's fine, key may be in environment already
}

const args = parseArgs(Deno.args, {
  string: ["prompt", "output-dir", "aspect", "size"],
  collect: ["ref"],
  default: {
    "output-dir": "./generated",
    aspect: "1:1",
    size: "1K",
    variants: "4",
  },
});

const prompt = args.prompt;
const refPaths = args.ref as string[];
const outputDir = args["output-dir"] as string;
const aspect = args.aspect as string;
const imageSize = args.size as string;
const numVariants = parseInt(args.variants as string || "4", 10);

if (!prompt) {
  console.error("Error: --prompt is required");
  Deno.exit(1);
}

if (!refPaths || refPaths.length === 0) {
  console.error("Error: at least one --ref image is required");
  Deno.exit(1);
}

const apiKey = Deno.env.get("GEMINI_API_KEY");
if (!apiKey) {
  console.error("Error: GEMINI_API_KEY environment variable is not set");
  console.error("Get one at https://aistudio.google.com/apikey");
  Deno.exit(1);
}

// Load reference images as base64
console.log(`Loading ${refPaths.length} reference image(s)...`);
const refImages = await Promise.all(
  refPaths.map(async (path) => {
    const bytes = await Deno.readFile(path);
    const ext = path.toLowerCase().split(".").pop();
    const mimeType =
      ext === "jpg" || ext === "jpeg"
        ? "image/jpeg"
        : ext === "webp"
        ? "image/webp"
        : "image/png";
    return {
      inlineData: {
        mimeType,
        data: encodeBase64(bytes),
      },
    };
  })
);

// Build the content array: text prompt + reference images
const contents = [{ text: prompt }, ...refImages];

// Initialize Gemini client
const ai = new GoogleGenAI({ apiKey });

console.log(
  `Generating ${numVariants} variations (${aspect}, ${imageSize})...`
);
console.log(`Prompt: ${prompt.substring(0, 100)}${prompt.length > 100 ? "..." : ""}`);

// Generate variants in parallel
const results = await Promise.allSettled(
  Array.from({ length: numVariants }, (_, i) =>
    ai.models
      .generateContent({
        model: "gemini-3.1-flash-image-preview",
        contents,
        config: {
          responseModalities: ["IMAGE"],
          imageConfig: {
            aspectRatio: aspect,
            imageSize: imageSize,
          },
        },
      })
      .then((response) => ({ index: i, response }))
  )
);

// Save successful results
await ensureDir(outputDir);
const timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
let savedCount = 0;

const savedFiles: string[] = [];

for (const result of results) {
  if (result.status === "rejected") {
    console.error(`Variant failed: ${result.reason}`);
    continue;
  }

  const { index, response } = result.value;
  const parts = response.candidates?.[0]?.content?.parts;
  if (!parts) {
    console.error(`Variant ${index + 1}: no content in response`);
    continue;
  }

  for (const part of parts) {
    if (part.inlineData?.data) {
      const ext = part.inlineData.mimeType === "image/jpeg" ? "jpg" : "png";
      const filename = `variant-${index + 1}-${timestamp}.${ext}`;
      const filepath = join(outputDir, filename);

      // Decode base64 to bytes
      const binaryStr = atob(part.inlineData.data);
      const bytes = new Uint8Array(binaryStr.length);
      for (let i = 0; i < binaryStr.length; i++) {
        bytes[i] = binaryStr.charCodeAt(i);
      }

      await Deno.writeFile(filepath, bytes);
      savedFiles.push(filepath);
      savedCount++;
      console.log(`Saved: ${filepath}`);
    }
  }
}

console.log(
  `\nDone: ${savedCount}/${numVariants} variants saved to ${outputDir}`
);

// Output JSON summary for programmatic use
const summary = {
  prompt,
  references: refPaths,
  variants_requested: numVariants,
  variants_saved: savedCount,
  output_dir: outputDir,
  files: savedFiles,
  settings: { aspect, imageSize },
};
console.log("\n" + JSON.stringify(summary, null, 2));
