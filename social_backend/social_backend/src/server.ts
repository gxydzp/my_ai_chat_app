// src/server.ts
import "dotenv/config";
import express from "express";
import cors from "cors";
import { prisma } from "./db";
import { createExploreRouter } from "./routes/explore";

const app = express();

// --- middleware ---
app.use(cors());
app.use(express.json({ limit: "2mb" }));
app.use((req, _res, next) => {
  console.log(`[REQ] ${req.method} ${req.url}`);
  console.log(`[HDR] x-user-id=${req.header("x-user-id")} x-user-name=${req.header("x-user-name")}`);
  next();
});
app.use(express.json({ limit: "2mb" }));


// --- routes ---
app.get("/", (_req, res) => {
  res.json({ ok: true, service: "social_backend" });
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, ts: Date.now() });
});

// API
app.use("/api/explore", createExploreRouter(prisma));

// --- error handler (must be last) ---
app.use((err: any, _req: any, res: any, _next: any) => {
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

