import { Router } from "express";
import { z } from "zod";
import { prisma } from "../db";
import { requireUser } from "./middlewares";

export const usersRouter = Router();

usersRouter.post("/", async (req, res) => {
  const body = z.object({
    name: z.string().min(1),
    avatarUrl: z.string().url().optional(),
  }).parse(req.body);

  const user = await prisma.user.create({ data: body });
  res.json(user);
});

usersRouter.get("/me", requireUser, async (req, res) => {
  const userId = (req as any).userId as string;
  const me = await prisma.user.findUnique({ where: { id: userId } });
  if (!me) return res.status(404).json({ error: "User not found" });
  res.json(me);
});
