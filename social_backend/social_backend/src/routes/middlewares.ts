// src/routes/middlewares.ts
import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "change-me-in-env"; // 记得在 .env 里配一份

// 解析 JWT，把 { id, name } 放到 req.authUser 上
export function attachUserFromToken(
  req: Request,
  _res: Response,
  next: NextFunction
) {
  const authHeader = req.header("authorization");

  if (authHeader && authHeader.startsWith("Bearer ")) {
    const token = authHeader.slice("Bearer ".length).trim();
    try {
      const payload = jwt.verify(token, JWT_SECRET) as any;
      (req as any).authUser = {
        id: payload.id,
        name: payload.name,
      };
    } catch (e) {
      console.warn("[auth] invalid token:", (e as any)?.message || e);
      // token 错了就当没登录，不直接报错
    }
  }

  next();
}

// 可选：某些路由需要强制登录时用
export function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction
) {
  if (!(req as any).authUser) {
    return res.status(401).json({ error: "UNAUTHORIZED" });
  }
  next();
}
