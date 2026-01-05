// src/routes/explore.ts
import { Router } from "express";
import type { PrismaClient, ExploreCategory } from "@prisma/client";

type Viewer = { id: string; name: string };

function getViewer(req: any): Viewer {
  // 1) 如果前面中间件已经解析出 authUser（JWT），优先用这个
  if (req.authUser?.id) {
    return { id: req.authUser.id, name: req.authUser.name };
  }

  // 2) 否则退回到你之前的伪登录 header
  const id = (req.header("x-user-id") || "u_me").toString();
  const name = (req.header("x-user-name") || "我").toString();
  return { id, name };
}

function parseCategory(v: any): ExploreCategory {
  const s = (v || "").toString();
  if (s === "galaxy" || s === "station" || s === "planet")
    return s as ExploreCategory;
  return "galaxy" as ExploreCategory;
}

function toMs(d: Date) {
  return d.getTime();
}

function toPostDto(p: any, viewerId: string) {
  return {
    id: p.id,
    title: p.title,
    content: p.content,
    authorId: p.authorId,
    authorName: p.author?.name ?? "Unknown",
    category: p.category, // "galaxy" | "station" | "planet"
    mediaUrls: (p.media ?? []).map((m: any) => m.url),
    likeCount: p.likeCount ?? 0,
    commentCount: p.commentCount ?? 0,
    createdAtMs: toMs(p.createdAt),
    likedByMe: ((p.likes ?? []).length ?? 0) > 0,
  };
}

export function createExploreRouter(prisma: PrismaClient) {
  const router = Router();

  // GET /api/explore/feed?category=galaxy&cursor=...&limit=10
  router.get("/feed", async (req, res) => {
    try {
      const viewer = getViewer(req);
      const category = parseCategory(req.query.category);
      const limit = Math.min(Number(req.query.limit || 10), 50);

      const cursorMsRaw = req.query.cursor?.toString();
      const cursorMs = cursorMsRaw ? Number(cursorMsRaw) : null;
      const cursorDate = cursorMs ? new Date(cursorMs) : null;

      const posts = await prisma.post.findMany({
        where: {
          category,
          ...(cursorDate ? { createdAt: { lt: cursorDate } } : {}),
        },
        orderBy: { createdAt: "desc" },
        take: limit + 1,
        include: {
          author: true,
          media: { orderBy: { order: "asc" } },
          likes: { where: { userId: viewer.id }, select: { userId: true } },
        },
      });

      const hasMore = posts.length > limit;
      const slice = hasMore ? posts.slice(0, limit) : posts;

      const items = slice.map((p) => toPostDto(p, viewer.id));
      const nextCursor = hasMore
        ? String(items[items.length - 1].createdAtMs)
        : null;

      res.json({ items, nextCursor });
    } catch (e: any) {
      res.status(500).json({ error: e?.message || String(e) });
    }
  });

  // POST /api/explore/posts
  // body: { category: "galaxy", content: "...", imageUrls: ["http://..."] }
  router.post("/posts", async (req, res) => {
    try {
      console.log("[POST /api/explore/posts] headers=", {
        uid: req.header("x-user-id"),
        uname: req.header("x-user-name"),
        ct: req.header("content-type"),
      });
      console.log("[POST /api/explore/posts] body=", req.body);

      const viewer = getViewer(req);

      const category = parseCategory(req.body.category);
      const content = (req.body.content || "").toString();

      const imageUrls: string[] = Array.isArray(req.body.imageUrls)
        ? req.body.imageUrls
            .map((x: any) => String(x))
            .filter((x: string) => x.trim().length > 0)
        : [];

      const title =
        content.trim().length === 0
          ? "新动态"
          : content.trim().split("\n")[0].slice(0, 80);

      // 确保用户存在（开发阶段用 header 伪登录）
      await prisma.user.upsert({
        where: { id: viewer.id },
        update: { name: viewer.name },
        create: { id: viewer.id, name: viewer.name },
      });

      const post = await prisma.post.create({
        data: {
          title,
          content,
          category,
          authorId: viewer.id,
          media: {
            create: imageUrls.map((url, idx) => ({
              url,
              order: idx,
              type: "image",
            })),
          },
        },
        include: {
          author: true,
          media: { orderBy: { order: "asc" } },
          likes: { where: { userId: viewer.id }, select: { userId: true } },
        },
      });

      res.json(toPostDto(post, viewer.id));
    } catch (e: any) {
      res.status(500).json({ error: e?.message || String(e) });
    }
  });

  // PATCH /api/explore/posts/:id  —— 修改已有帖子（文字 / 分类 / 图片）
  router.patch("/posts/:id", async (req, res) => {
    try {
      console.log("[PATCH /api/explore/posts/:id] headers=", {
        uid: req.header("x-user-id"),
        uname: req.header("x-user-name"),
        ct: req.header("content-type"),
      });
      console.log("[PATCH /api/explore/posts/:id] body=", req.body);

      const viewer = getViewer(req);
      const postId = req.params.id;

      if (!postId) {
        return res.status(400).json({ error: "missing_post_id" });
      }

      const existing = await prisma.post.findUnique({
        where: { id: postId },
        include: {
          author: true,
          media: { orderBy: { order: "asc" } },
          likes: {
            where: { userId: viewer.id },
            select: { userId: true },
          },
        },
      });

      if (!existing) {
        return res.status(404).json({ error: "post_not_found" });
      }

      // 只有作者本人可以改
      if (existing.authorId !== viewer.id) {
        return res.status(403).json({ error: "forbidden" });
      }

      // ---- 处理 content ----
      const hasContentProp = Object.prototype.hasOwnProperty.call(
        req.body,
        "content",
      );
      const newContentRaw = hasContentProp
        ? req.body.content
        : existing.content ?? "";
      const content = (newContentRaw || "").toString();

      // ---- 处理 category（可选）----
      const hasCategoryProp = Object.prototype.hasOwnProperty.call(
        req.body,
        "category",
      );
      const category = hasCategoryProp
        ? parseCategory(req.body.category)
        : (existing.category as ExploreCategory);

      // ---- 处理 imageUrls（如果给了就重置，没有给就保留原图）----
      let imageUrls: string[] | null = null;
      if (
        Object.prototype.hasOwnProperty.call(req.body, "imageUrls")
      ) {
        if (Array.isArray(req.body.imageUrls)) {
          imageUrls = req.body.imageUrls
            .map((x: any) => String(x))
            .filter((x: string) => x.trim().length > 0);
        } else {
          imageUrls = [];
        }
      }

      // ---- 重新算标题 ----
      const title =
        content.trim().length === 0
          ? existing.title
          : content.trim().split("\n")[0].slice(0, 80);

      const data: any = {
        title,
        content,
        category,
      };

      if (imageUrls !== null) {
        data.media = {
          deleteMany: { postId },
          create: imageUrls.map((url, idx) => ({
            url,
            order: idx,
            type: "image" as const,
          })),
        };
      }

      const post = await prisma.post.update({
        where: { id: postId },
        data,
        include: {
          author: true,
          media: { orderBy: { order: "asc" } },
          likes: {
            where: { userId: viewer.id },
            select: { userId: true },
          },
        },
      });

      res.json(toPostDto(post, viewer.id));
    } catch (e: any) {
      console.error("[PATCH /api/explore/posts/:id] ERROR", e);
      res.status(500).json({ error: e?.message || String(e) });
    }
  });

  // POST /api/explore/posts/:id/like  (toggle)
  router.post("/posts/:id/like", async (req, res) => {
    console.log("[POST /api/explore/posts/:id/like] headers=", {
      uid: req.header("x-user-id"),
      uname: req.header("x-user-name"),
      ct: req.header("content-type"),
    });
    console.log("[POST /api/explore/posts/:id/like] body=", req.body);

    const postId = req.params.id;
    const viewer = getViewer(req);

    try {
      const result = await prisma.$transaction(async (tx) => {
        const existing = await tx.like.findUnique({
          where: { postId_userId: { postId, userId: viewer.id } },
        });

        // 确保用户存在
        await tx.user.upsert({
          where: { id: viewer.id },
          update: { name: viewer.name },
          create: { id: viewer.id, name: viewer.name },
        });

        if (existing) {
          await tx.like.delete({
            where: { postId_userId: { postId, userId: viewer.id } },
          });
          return tx.post.update({
            where: { id: postId },
            data: { likeCount: { decrement: 1 } },
            include: {
              author: true,
              media: { orderBy: { order: "asc" } },
              likes: {
                where: { userId: viewer.id },
                select: { userId: true },
              },
            },
          });
        } else {
          await tx.like.create({ data: { postId, userId: viewer.id } });
          return tx.post.update({
            where: { id: postId },
            data: { likeCount: { increment: 1 } },
            include: {
              author: true,
              media: { orderBy: { order: "asc" } },
              likes: {
                where: { userId: viewer.id },
                select: { userId: true },
              },
            },
          });
        }
      });

      res.json(toPostDto(result, viewer.id));
    } catch (e: any) {
      res.status(500).json({ error: e?.message || String(e) });
    }
  });

  // GET /api/explore/posts/:id/comments?cursor=...&limit=20
  router.get("/posts/:id/comments", async (req, res) => {
    try {
      const postId = req.params.id;
      const limit = Math.min(Number(req.query.limit || 20), 50);

      const cursorMsRaw = req.query.cursor?.toString();
      const cursorMs = cursorMsRaw ? Number(cursorMsRaw) : null;
      const cursorDate = cursorMs ? new Date(cursorMs) : null;

      const comments = await prisma.comment.findMany({
        where: {
          postId,
          ...(cursorDate ? { createdAt: { lt: cursorDate } } : {}),
        },
        orderBy: { createdAt: "desc" },
        take: limit + 1,
        include: { user: true },
      });

      const hasMore = comments.length > limit;
      const slice = hasMore ? comments.slice(0, limit) : comments;

      const items = slice.map((c) => ({
        id: c.id,
        postId: c.postId,
        userId: c.userId,
        userName: c.user?.name ?? "Unknown",
        content: c.content,
        createdAtMs: toMs(c.createdAt),
      }));

      const nextCursor = hasMore
        ? String(items[items.length - 1].createdAtMs)
        : null;

      res.json({ items, nextCursor });
    } catch (e: any) {
      res.status(500).json({ error: e?.message || String(e) });
    }
  });

  // POST /api/explore/posts/:id/comments
  // body: { content: "..." }
  router.post("/posts/:id/comments", async (req, res) => {
    const postId = req.params.id;
    const viewer = getViewer(req);

    try {
      const content = (req.body.content || "").toString().trim();
      if (!content)
        return res.status(400).json({ error: "content is required" });

      const created = await prisma.$transaction(async (tx) => {
        await tx.user.upsert({
          where: { id: viewer.id },
          update: { name: viewer.name },
          create: { id: viewer.id, name: viewer.name },
        });

        const comment = await tx.comment.create({
          data: { postId, userId: viewer.id, content },
          include: { user: true },
        });

        await tx.post.update({
          where: { id: postId },
          data: { commentCount: { increment: 1 } },
        });

        return comment;
      });

      res.json({
        id: created.id,
        postId: created.postId,
        userId: created.userId,
        userName: created.user?.name ?? viewer.name,
        content: created.content,
        createdAtMs: toMs(created.createdAt),
      });
    } catch (e: any) {
      res.status(500).json({ error: e?.message || String(e) });
    }
  });

  return router;
}

