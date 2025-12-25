// services/nanoService.js
import fetch from "node-fetch";
import fs from "fs";
import path from "path";
import mime from "mime";
import { URL } from "url";

const NANO_API_KEY = process.env.NANOBANANA_API_KEY;
const NANO_BASE_URL = process.env.NANOBANANA_API_URL;

function normalizeRefUrl(refUrl) {
  if (!refUrl) return refUrl;
  try {
    const u = new URL(refUrl);
    if (u.hostname === "10.0.2.2") {
      u.hostname = "127.0.0.1";
      return u.toString();
    }
  } catch {}
  return refUrl;
}

async function loadImageAsBase64(input) {
  if (!input) return null;
  const refUrl = normalizeRefUrl(String(input).trim());

  if (refUrl.startsWith("data:image/")) {
    const m = refUrl.match(
      /^data:(image\/[a-z0-9.+-]+);base64,([A-Za-z0-9+/=\r\n]+)$/i
    );
    if (!m) return null;
    return { mimeType: m[1], base64: m[2].replace(/\r?\n/g, "") };
  }

  if (refUrl.startsWith("file://")) {
    const localPath = refUrl.replace("file://", "");
    const buf = await fs.promises.readFile(localPath);
    return {
      base64: buf.toString("base64"),
      mimeType: mime.getType(localPath) || "image/png",
    };
  }

  try {
    if (fs.existsSync(refUrl)) {
      const buf = await fs.promises.readFile(refUrl);
      return {
        base64: buf.toString("base64"),
        mimeType: mime.getType(refUrl) || "image/png",
      };
    }
  } catch {}

  if (/^https?:\/\//i.test(refUrl)) {
    const r = await fetch(refUrl);
    if (!r.ok) throw new Error(`Fetch referenceImageUrl failed: ${r.status}`);
    const buf = await r.arrayBuffer();
    const contentType = r.headers.get("content-type");
    const guessed = mime.getType(new URL(refUrl).pathname);
    return {
      base64: Buffer.from(buf).toString("base64"),
      mimeType: contentType || guessed || "image/png",
    };
  }

  return null;
}

/**
 * 尝试从上游 JSON 里提取：
 * - base64
 * - 或者一个可下载的 image url/uri（后端再去下载保存）
 */
function extractImagePayload(data) {
  let mimeType = "image/png";

  const candidates = data?.candidates ?? data?.output?.candidates ?? [];
  const parts =
    candidates?.[0]?.content?.parts ??
    candidates?.[0]?.content?.Parts ??
    candidates?.[0]?.parts ??
    [];

  // 1) inlineData (camelCase)
  for (const p of parts) {
    const d = p?.inlineData?.data;
    if (d) {
      mimeType = p.inlineData.mimeType || p.inlineData.mime_type || mimeType;
      return { kind: "base64", base64: String(d).replace(/\r?\n/g, ""), mimeType };
    }
  }

  // 2) inline_data (snake_case)
  for (const p of parts) {
    const d = p?.inline_data?.data;
    if (d) {
      mimeType = p.inline_data.mime_type || p.inline_data.mimeType || mimeType;
      return { kind: "base64", base64: String(d).replace(/\r?\n/g, ""), mimeType };
    }
  }

  // 3) data URI in text
  for (const p of parts) {
    if (typeof p?.text === "string" && p.text.startsWith("data:image/")) {
      const m = p.text.match(
        /^data:(image\/[a-z0-9.+-]+);base64,([A-Za-z0-9+/=\r\n]+)$/i
      );
      if (m) return { kind: "base64", mimeType: m[1], base64: m[2].replace(/\r?\n/g, "") };
    }
  }

  // 4) fileData / file_data（很多上游用 fileUri 方式给你一个可下载资源）
  for (const p of parts) {
    const fileUri =
      p?.fileData?.fileUri ||
      p?.fileData?.file_uri ||
      p?.file_data?.fileUri ||
      p?.file_data?.file_uri ||
      null;

    const mt =
      p?.fileData?.mimeType ||
      p?.fileData?.mime_type ||
      p?.file_data?.mimeType ||
      p?.file_data?.mime_type ||
      null;

    if (fileUri) {
      mimeType = mt || mimeType;
      return { kind: "url", url: String(fileUri), mimeType };
    }
  }

  // 5) 其他常见结构（兼容一些 OpenAI/中转格式）
  const maybeUrl =
    data?.image_url?.url ||
    data?.imageUrl?.url ||
    data?.output?.[0]?.content?.[0]?.image_url?.url ||
    data?.data?.[0]?.url ||
    null;

  if (maybeUrl) return { kind: "url", url: String(maybeUrl), mimeType };

  return null;
}

async function downloadToBuffer(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(`download image failed: ${r.status}`);
  const buf = Buffer.from(await r.arrayBuffer());
  const ct = r.headers.get("content-type");
  return { buf, contentType: ct || null };
}

export async function generateImage({ prompt, referenceImageUrl, outputDir }) {
  if (!NANO_API_KEY || !NANO_BASE_URL) {
    throw new Error("缺少 NANOBANANA_API_KEY 或 NANOBANANA_API_URL 环境变量");
  }
  if (!outputDir) {
    throw new Error("generateImage 需要传入 outputDir（保存生成图片的绝对路径）");
  }

  const p = String(prompt || "").trim();
  if (!p) throw new Error("prompt 不能为空");

  // 参考图转 base64（可选）
  let refPart = null;
  if (referenceImageUrl) {
    try {
      const loaded = await loadImageAsBase64(referenceImageUrl);
      if (loaded?.base64) {
        refPart = {
          inlineData: {
            mimeType: loaded.mimeType || "image/png",
            data: loaded.base64,
          },
        };
        console.log("[nanoService] 已把参考图编码成 base64（inlineData）");
      } else {
        console.warn("[nanoService] referenceImageUrl 无法读取为 base64，忽略参考图");
      }
    } catch (e) {
      console.warn("[nanoService] 读取 referenceImageUrl 失败，将忽略参考图：", e?.message || e);
    }
  }

  const parts = [{ text: p }];
  if (refPart) parts.push(refPart);

  const payload = {
    contents: [{ role: "user", parts }],
    generationConfig: {
      responseModalities: ["TEXT", "IMAGE"],
      response_modalities: ["TEXT", "IMAGE"],
    },
  };

  const u = new URL(NANO_BASE_URL);
  if (!u.searchParams.get("key")) u.searchParams.set("key", NANO_API_KEY);

  const res = await fetch(u.toString(), {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  const rawText = await res.text();
  let data;
  try {
    data = JSON.parse(rawText);
  } catch {
    throw new Error(`上游返回非 JSON：${rawText.slice(0, 200)}`);
  }

  await fs.promises.mkdir(path.resolve("debug"), { recursive: true });
  await fs.promises.writeFile(
    path.resolve("debug/last_gemini.json"),
    JSON.stringify(data, null, 2),
    "utf-8"
  );

  if (!res.ok) {
    throw new Error(`上游报错 ${res.status}: ${rawText.slice(0, 500)}`);
  }

  const img = extractImagePayload(data);
  if (!img) {
    throw new Error("上游响应里既没有 base64，也没有可下载的图片 url/uri（请查看 ./debug/last_gemini.json）");
  }

  // 写文件
  let mimeType = img.mimeType || "image/png";
  let fileBuf = null;

  if (img.kind === "base64") {
    fileBuf = Buffer.from(img.base64, "base64");
  } else if (img.kind === "url") {
    const { buf, contentType } = await downloadToBuffer(img.url);
    fileBuf = buf;
    if (contentType && contentType.startsWith("image/")) mimeType = contentType;
  }

  const extMap = { "image/png": "png", "image/jpeg": "jpg", "image/jpg": "jpg", "image/webp": "webp", "image/gif": "gif" };
  const ext = extMap[mimeType] || "png";

  const ts = new Date().toISOString().replace(/[:.]/g, "-").replace("T", "_").slice(0, 19);
  const filename = `gen_${ts}.${ext}`;
  const filePath = path.join(outputDir, filename);

  await fs.promises.mkdir(outputDir, { recursive: true });
  await fs.promises.writeFile(filePath, fileBuf);

  return { filename, filePath, publicUrl: `/generated/${filename}`, raw: data };
}