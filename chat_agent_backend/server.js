// chat_agent_backend/server.js
// chat_agent_backend/server.js
import "dotenv/config";
import express from "express";
import cors from "cors";
import OpenAI from "openai";
import crypto from "crypto"; // 如你之前没写，建议显式引入
import { PROMPTGRAMS, getPromptgramById, BASE_COUNSELING_PROMPT } from "./prompts/promptgrams.js";


const app = express();
app.use(cors());
app.use(express.json({ limit: "1mb" }));

app.get("/", (req, res) => {
  res.json({ ok: true, service: "chat_agent_backend" });
});

app.get("/health", (req, res) => {
  res.json({ ok: true, ts: Date.now() });
});

// ✅ 让前端能拉到可选 AI 列表
app.get("/api/promptgrams", (req, res) => {
  const items = PROMPTGRAMS.map(({ id, name, description }) => ({ id, name, description }));
  res.json({ items });
});

function briefErr(e) {
  return { name: e?.name, message: e?.message, code: e?.code, status: e?.status, type: e?.type };
}

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  baseURL: process.env.OPENAI_BASE_URL || undefined,
  timeout: 30_000,
});

// （可选）用内存保存 session 上下文；先简单做，够你跑通逻辑
const sessions = new Map(); // sessionId -> { promptgramId, messages: [{role, content}] }

app.post("/api/chat/start", async (req, res) => {
  const promptgramId = req.body?.promptgramId;
  const pg = getPromptgramById(promptgramId);

  if (!pg) return res.status(404).json({ error: "promptgram not found" });
  if (!process.env.OPENAI_API_KEY) {
    return res.status(500).json({ error: "OPENAI_API_KEY missing on server" });
  }

  const basePrompt = String(BASE_COUNSELING_PROMPT || "").trim();
  const specificPrompt = String(pg.systemPrompt || "").trim();
  const firstUserMessage = String(pg.firstUserMessage || "").trim();

  if (!basePrompt) return res.status(500).json({ error: "BASE_COUNSELING_PROMPT empty" });
  if (!specificPrompt) return res.status(500).json({ error: "systemPrompt empty in promptgram" });
  if (!firstUserMessage) return res.status(500).json({ error: "firstUserMessage empty in promptgram" });

  try {
    const sessionId = crypto.randomUUID();

    const messages = [
      { role: "system", content: basePrompt },     // 通用访谈范式 + 防跑题
      { role: "system", content: specificPrompt }, // 本问卷专用说明
      { role: "user", content: firstUserMessage }, // 首次抛给用户的问题
    ];

    const response = await openai.responses.create({
      model: process.env.OPENAI_MODEL || "gpt-5-mini",
      input: messages,
    });

    const reply = response.output_text || "";

    sessions.set(sessionId, {
      promptgramId,
      messages: [...messages, { role: "assistant", content: reply }],
    });

    res.json({ sessionId, reply });
  } catch (err) {
    console.error("OpenAI start failed:", err);
    res.status(502).json({
      error: "OpenAI request failed",
      detail: briefErr(err),
      cause: err?.cause ? briefErr(err.cause) : undefined,
    });
  }
});


app.post("/api/chat", async (req, res) => {
  const sessionId = req.body?.sessionId;
  const message = req.body?.message;

  if (!sessionId || typeof sessionId !== "string") return res.status(400).json({ error: "sessionId is required (string)" });
  if (!message || typeof message !== "string") return res.status(400).json({ error: "message is required (string)" });

  const sess = sessions.get(sessionId);
  if (!sess) return res.status(404).json({ error: "session not found, please /api/chat/start again" });

  try {
    sess.messages.push({ role: "user", content: message });

    const response = await openai.responses.create({
      model: process.env.OPENAI_MODEL || "gpt-5-mini",
      input: sess.messages,
    });

    const reply = response.output_text || "";
    sess.messages.push({ role: "assistant", content: reply });

    res.json({ reply });
  } catch (err) {
    console.error("OpenAI chat failed:", err);
    res.status(502).json({ error: "OpenAI request failed", detail: briefErr(err), cause: err?.cause ? briefErr(err.cause) : undefined });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, "0.0.0.0", () => console.log(`API listening on http://0.0.0.0:${port}`));



