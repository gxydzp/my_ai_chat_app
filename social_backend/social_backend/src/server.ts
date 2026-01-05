// src/server.ts
import "dotenv/config";
import express from "express";
import cors from "cors";

import prisma from "./db";
import { createExploreRouter } from "./routes/explore";
import { createAuthRouter } from "./routes/auth";
import { attachUserFromToken } from "./routes/middlewares";

const app = express();

// ---------- middleware ----------
app.use(cors());
app.use(express.json({ limit: "2mb" }));

// 解析 Authorization 里的 JWT
app.use(attachUserFromToken);

// 简单日志
app.use((req, _res, next) => {
  console.log(`[REQ] ${req.method} ${req.url}`);
  const viewer = (req as any).authUser;
  if (viewer) {
    console.log(`    viewer=${viewer.id} ${viewer.name}`);
  } else {
    console.log(
      `    x-user-id=${req.header("x-user-id")} x-user-name=${req.header(
        "x-user-name"
      )}`
    );
  }
  next();
});

// ---------- routes ----------
app.get("/", (_req, res) => {
  res.json({ ok: true, service: "social_backend" });
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, ts: Date.now() });
});

// 登录 / 注册
app.use("/api/auth", createAuthRouter(prisma));

// 探索模块
app.use("/api/explore", createExploreRouter(prisma));

// ---------- error handler (必须放最后) ----------
app.use((err: any, _req, res, _next) => {
  console.error("[server error]", err);
  res.status(500).json({
    error: "INTERNAL_SERVER_ERROR",
    message: err?.message ?? String(err),
  });
});

const port = Number(process.env.PORT || 3002);
app.listen(port, () => {
  console.log(`[social_backend] listening on http://localhost:${port}`);
});
