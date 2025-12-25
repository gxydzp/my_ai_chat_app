// services/referenceService.js
// 功能：
// 1) 挂载静态目录（/public & /reference）
// 2) 列出图库（子目录）
// 3) 从某个图库（或全部图库）随机选一张参考图片

import express from "express";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 目录常量
const PUBLIC_DIR_NAME = "public";
const REFERENCE_DIR_NAME = "reference";

// 记录项目根目录 & 参考图根目录
let projectRoot = path.resolve(path.join(__dirname, ".."));
let referenceRoot = path.join(projectRoot, PUBLIC_DIR_NAME, REFERENCE_DIR_NAME);

/** 确保目录存在（不存在就创建） */
function ensureDir(p) {
  if (!fs.existsSync(p)) {
    fs.mkdirSync(p, { recursive: true });
  }
}

/**
 * 挂载静态目录
 *
 * 在 server.js 中调用：
 *   import { mountReferenceStatic } from "./services/referenceService.js";
 *   mountReferenceStatic(app, __dirname);
 */
export function mountReferenceStatic(app, rootDir) {
  if (rootDir) {
    projectRoot = rootDir;
    referenceRoot = path.join(projectRoot, PUBLIC_DIR_NAME, REFERENCE_DIR_NAME);
  }

  const publicDir = path.join(projectRoot, PUBLIC_DIR_NAME);
  ensureDir(publicDir);
  ensureDir(referenceRoot);

  // 先挂整个 public 目录
  app.use(express.static(publicDir));
  // 再把 /reference 单独挂出来，方便直链访问
  app.use("/reference", express.static(referenceRoot));

  console.log(`[referenceService] public 静态目录：${publicDir}`);
  console.log(`[referenceService] /reference 映射目录：${referenceRoot}`);
}

/** 列出所有图库（reference 下的子目录名） */
export function listLibraries() {
  try {
    ensureDir(referenceRoot);
    const entries = fs.readdirSync(referenceRoot, { withFileTypes: true });
    return entries
      .filter((e) => e.isDirectory())
      .map((e) => ({
        id: e.name,
        label: e.name,
      }));
  } catch (err) {
    console.error("[referenceService] listLibraries failed:", err);
    return [];
  }
}

/**
 * 从指定图库 / 全部图库中随机选一张图片
 *
 * options:
 *   - libraryId: 指定图库目录名（例如 "Graphical_style"），不传则从全部图库随机
 *   - style_tags: 预留字段，目前不用
 *
 * 兼容旧用法：pickReferenceImage(style_tagsArray)
 *
 * 返回：
 *   { filename, libraryId, publicUrl } 或 null
 */
export function pickReferenceImage(options = {}) {
  let specifiedLibraryId = null;

  // 兼容旧用法：pickReferenceImage(style_tagsArray)
  if (Array.isArray(options)) {
    // 旧版调用：传的是 style_tags 数组，这里忽略，走“全部图库里随机”
  } else if (options && typeof options === "object") {
    specifiedLibraryId = options.libraryId || null;
  }

  ensureDir(referenceRoot);

  // 1. 先枚举所有子目录 = 所有图库
  let libraries = [];
  try {
    libraries = fs
      .readdirSync(referenceRoot, { withFileTypes: true })
      .filter((e) => e.isDirectory())
      .map((e) => e.name);
  } catch (err) {
    console.error("[referenceService] 读取图库目录失败：", err);
  }

  if (!libraries.length) {
    console.warn("[referenceService] reference/ 下没有任何图库子目录");
  }

  // 2. 组织候选图片列表：[{ libraryId, filename }, ...]
  const candidates = [];

  const tryCollectFromLibrary = (libId) => {
    const dir = path.join(referenceRoot, libId);
    if (!fs.existsSync(dir)) return;

    const files = fs
      .readdirSync(dir, { withFileTypes: true })
      .filter(
        (e) =>
          e.isFile() &&
          /\.(png|jpe?g|webp|gif)$/i.test(e.name)
      )
      .map((e) => e.name);

    for (const f of files) {
      candidates.push({ libraryId: libId, filename: f });
    }
  };

  if (specifiedLibraryId && libraries.includes(specifiedLibraryId)) {
    // 如果前端指定了某个库，就只从这个库里抽
    tryCollectFromLibrary(specifiedLibraryId);
  } else {
    // 否则从所有库里抽
    for (const lib of libraries) {
      tryCollectFromLibrary(lib);
    }

    // 兼容旧结构：reference 根目录下直接有图片
    try {
      const rootFiles = fs
        .readdirSync(referenceRoot, { withFileTypes: true })
        .filter(
          (e) =>
            e.isFile() &&
            /\.(png|jpe?g|webp|gif)$/i.test(e.name)
        )
        .map((e) => e.name);
      for (const f of rootFiles) {
        candidates.push({ libraryId: null, filename: f });
      }
    } catch (err) {
      console.error("[referenceService] 读取 reference 根目录失败：", err);
    }
  }

  if (!candidates.length) {
    console.warn("[referenceService] 没有可用的参考图片，返回 null");
    return null;
  }

  // 3. 随机选一张
  const pick = candidates[Math.floor(Math.random() * candidates.length)];

  const relativePath = pick.libraryId
    ? `${pick.libraryId}/${pick.filename}`
    : pick.filename;

  return {
    filename: pick.filename,
    libraryId: pick.libraryId,
    publicUrl: `/reference/${relativePath}`,
  };
}

/** 需要时：把相对路径转成绝对路径 */
export function getReferenceAbsPath(relativePath) {
  return path.join(referenceRoot, relativePath);
}
