// server.js
import "dotenv/config";
import express from "express";
import cors from "cors";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

import {
  generatePrompt,
  listPromptStyles,
} from "./services/promptService.js";
import {
  pickReferenceImage,
  mountReferenceStatic,
  listLibraries,
} from "./services/referenceService.js";
import { generateImage } from "./services/nanoService.js";

/* -----------------------
 * 基础初始化
 * --------------------- */
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(cors());
// 防止大 JSON 报错
app.use(express.json({ limit: "2mb" }));
app.use((req, _res, next) => {
  console.log(`[REQ] ${req.method} ${req.url}`);
  next();
});

/* -----------------------
 * 静态目录
 *   - /reference：参考图（由 referenceService 挂载）
 *   - /generated：生成图（本文件挂载）
 * --------------------- */
mountReferenceStatic(app, __dirname);

const GENERATED_DIR = path.join(__dirname, "public", "generated");
if (!fs.existsSync(GENERATED_DIR)) {
  fs.mkdirSync(GENERATED_DIR, { recursive: true });
  console.log(`[server] 已创建生成图目录: ${GENERATED_DIR}`);
}
app.use("/generated", express.static(GENERATED_DIR));
console.log(`[server] 静态目录映射: /generated -> ${GENERATED_DIR}`);

/* -----------------------
 * 健康检查
 * --------------------- */
app.get("/ping", (_req, res) => res.json({ ok: true }));

/* -----------------------
 * 辅助接口：列出风格 & 图库
 * --------------------- */

// 供前端「选择风格/图库」用，每个风格已经绑定一个 referenceLibraryId
app.get("/api/image/styles", (_req, res) => {
  const items = listPromptStyles();
  res.json({ items });
});

// 如果你想单独展示图库列表，可以用这个
app.get("/api/image/reference-libraries", (_req, res) => {
  const items = listLibraries();
  res.json({ items });
});

/* -----------------------
 * 主流程：问卷 → 提示词 → 参考图 → 生图
 * --------------------- */
app.post("/api/generate-image", async (req, res) => {
  try {
    let { answers, styleId, referenceLibraryId } = req.body || {};

    // 兼容性处理：允许前端传字符串或数组
    if (!answers && typeof req.body === "string") {
      try {
        const parsed = JSON.parse(req.body);
        answers = parsed.answers;
        styleId = parsed.styleId ?? styleId;
        referenceLibraryId = parsed.referenceLibraryId ?? referenceLibraryId;
      } catch {
        // ignore
      }
    }

    if (!answers) {
      return res.status(400).json({ error: "缺少 answers 字段" });
    }
    if (!Array.isArray(answers)) {
      return res.status(400).json({ error: "answers 必须是字符串数组" });
    }

    // 1) OpenAI 生成提示词（根据 styleId 选择不同风格）
    const {
      prompt,
      style_tags = [],
      stylePreset,
    } = await generatePrompt(answers, styleId);

    // 决定这次用哪个图库：
    // - 前端如果传了 referenceLibraryId 则优先用它；
    // - 否则用风格预设里绑的 referenceLibraryId；
    const libraryIdToUse =
      referenceLibraryId || stylePreset?.referenceLibraryId || null;

    // 2) 选一张参考图（可选，按图库随机）
    const referenceImage = pickReferenceImage(
      libraryIdToUse ? { libraryId: libraryIdToUse, style_tags } : { style_tags }
    );
    const referenceImageUrl = referenceImage
      ? `${req.protocol}://${req.get("host")}${referenceImage.publicUrl}`
      : null;

    // 3) 调图生成服务（生成图落地到 /public/generated）
    const imageResult = await generateImage({
      prompt,
      referenceImageUrl,
      outputDir: GENERATED_DIR,
    });
    // 约定 imageResult:
    // { filename, filePath, publicUrl, raw }

    const imageUrl = imageResult?.publicUrl
      ? `${req.protocol}://${req.get("host")}${imageResult.publicUrl}`
      : null;

    // ?download=1 时直接返回二进制（方便脚本 -OutFile 下载）
    if (req.query.download === "1" && imageResult?.filePath) {
      return res.sendFile(imageResult.filePath);
    }

    return res.json({
      prompt,
      style_tags,
      styleId: stylePreset?.id ?? styleId ?? null,
      referenceLibraryId: libraryIdToUse,
      referenceImageUrl,
      imageUrl,
      raw: imageResult?.raw ?? null,
    });
  } catch (err) {
    console.error("generate-image error:", err);
    return res.status(500).json({
      error: "服务器错误",
      detail: String(err?.message || err),
    });
  }
});

/* -----------------------
 * 随机参考图：给 Flutter 的 “随机参考图” 按钮用
 * 可选 query: ?libraryId=Graphical_style
 * --------------------- */
app.get("/api/reference/random", (req, res) => {
  // 支持前端指定库 ?libraryId=Retro-futuristic_style
  const libraryId = req.query.libraryId || null;

  const picked = pickReferenceImage({ libraryId });
  if (!picked) {
    return res.status(404).json({ error: "no_reference_images" });
  }

  const fullUrl = `${req.protocol}://${req.get("host")}${picked.publicUrl}`;
  return res.json({
    filename: picked.filename,
    libraryId: picked.libraryId,
    publicUrl: picked.publicUrl, // 形如 /reference/Retro-futuristic_style/xxx.png
    url: fullUrl,                // 完整 http://localhost:3001/reference/...
  });
});

/* -----------------------
 * 生图：给 Flutter 的 “开始生成（自定义 prompt）” 按钮用
 * --------------------- */
app.post("/api/image/generate", async (req, res) => {
  try {
    const prompt = req.body?.prompt;
    const referenceImageUrl = req.body?.referenceImageUrl || null;

    if (!prompt || typeof prompt !== "string") {
      return res.status(400).json({ error: "prompt_is_required" });
    }

    const imageResult = await generateImage({
      prompt,
      referenceImageUrl,
      outputDir: GENERATED_DIR,
    });

    const publicUrl = imageResult?.publicUrl || null;
    const url = publicUrl
      ? `${req.protocol}://${req.get("host")}${publicUrl}`
      : null;

    return res.json({
      ok: true,
      filename: imageResult?.filename ?? null,
      publicUrl, // 例如 /generated/2025....png
      url, // 例如 http://localhost:3001/generated/xxx.png
      raw: imageResult?.raw ?? null,
    });
  } catch (err) {
    console.error("image_generate_failed:", err);
    return res.status(500).json({
      error: "image_generate_failed",
      message: String(err?.message || err),
    });
  }
});

/* -----------------------
 * 启动
 * --------------------- */
const port = process.env.PORT || 3001;
app.listen(port, () => {
  console.log(`✅ Server running at http://localhost:${port}`);
});

