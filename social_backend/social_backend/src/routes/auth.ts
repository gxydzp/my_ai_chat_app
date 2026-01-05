// src/routes/auth.ts
import { Router } from "express";
import type { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "change-me-in-env";
const JWT_EXPIRES_IN = "30d";

export function createAuthRouter(prisma: PrismaClient) {
  const router = Router();

  // POST /api/auth/register
  // body: { name, email, password }
  router.post("/register", async (req, res) => {
    try {
      const { name, email, password } = req.body || {};

      if (!email || !password) {
        return res
          .status(400)
          .json({ error: "email and password are required" });
      }

      const emailNorm = String(email).trim().toLowerCase();
      const displayName = (name || "").toString().trim() || "新用户";

      const existing = await prisma.user.findUnique({
        where: { email: emailNorm },
      });
      if (existing) {
        return res.status(409).json({ error: "EMAIL_TAKEN" });
      }

      const passwordHash = await bcrypt.hash(String(password), 10);

      const user = await prisma.user.create({
        data: {
          // 如果你的 schema 给 id 配了 @default(cuid())，这里不用手动传 id
          name: displayName,
          email: emailNorm,
          passwordHash,
        },
      });

      const token = jwt.sign(
        { id: user.id, name: user.name },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
      );

      res.json({
        id: user.id,
        name: user.name,
        email: user.email,
        token,
      });
    } catch (e: any) {
      console.error("[POST /api/auth/register] error", e);
      res.status(500).json({ error: e?.message || String(e) });
    }
  });

  // POST /api/auth/login
  // body: { email, password }
  router.post("/login", async (req, res) => {
    try {
      const { email, password } = req.body || {};
      if (!email || !password) {
        return res
          .status(400)
          .json({ error: "email and password are required" });
      }

      const emailNorm = String(email).trim().toLowerCase();
      const user = await prisma.user.findUnique({
        where: { email: emailNorm },
      });

      if (!user || !user.passwordHash) {
        return res.status(401).json({ error: "INVALID_CREDENTIALS" });
      }

      const ok = await bcrypt.compare(String(password), user.passwordHash);
      if (!ok) {
        return res.status(401).json({ error: "INVALID_CREDENTIALS" });
      }

      const token = jwt.sign(
        { id: user.id, name: user.name },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
      );

      res.json({
        id: user.id,
        name: user.name,
        email: user.email,
        token,
      });
    } catch (e: any) {
      console.error("[POST /api/auth/login] error", e);
      res.status(500).json({ error: e?.message || String(e) });
    }
  });

  // GET /api/auth/me
  router.get("/me", async (req, res) => {
    const authUser = (req as any).authUser;
    if (!authUser?.id) {
      return res.status(401).json({ error: "UNAUTHORIZED" });
    }

    const user = await prisma.user.findUnique({
      where: { id: authUser.id },
    });
    if (!user) {
      return res.status(404).json({ error: "NOT_FOUND" });
    }

    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
    });
  });

  return router;
}
