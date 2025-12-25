// services/promptService.js
import OpenAI from "openai";
import GraphicalStyle from "../prompts/Graphical_style.js";
import RetroFuturisticStyle from "../prompts/Retro-futuristic_style.js";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// 所有风格预设（后续要扩展风格就在这里加）
const STYLE_PRESETS = [GraphicalStyle, RetroFuturisticStyle];

export function listPromptStyles() {
  return STYLE_PRESETS.map((s) => ({
    id: s.id,
    label: s.label,
    referenceLibraryId: s.referenceLibraryId,
  }));
}

export function getStylePresetById(styleId) {
  if (!styleId) return STYLE_PRESETS[0];
  return STYLE_PRESETS.find((s) => s.id === styleId) || STYLE_PRESETS[0];
}

// 把问卷答案生成图片提示词
export async function generatePrompt(answers, styleId) {
  const stylePreset = getStylePresetById(styleId);

  // 1. 先把 JS 数组转成字符串，方便塞给模型
  const userText = JSON.stringify(answers, null, 2);

  // 2. system 提示词：说明我们希望模型输出 JSON
  const systemPrompt = `
你是一个资深视觉设计师，要把用户的问卷答案转换成适合 AI 生成图像的提示词。

当前的目标画面风格预设为：「${stylePreset.label}」。

风格说明：
${stylePreset.styleInstruction}

请你只返回严格的 JSON 对象，不要有解释说明，不要有多余文字，也不要包含 markdown 代码块。

JSON 格式必须是：

{
  "prompt": "英文提示词……",
  "style_tags": ["${stylePreset.id}"]
}

要求：
1. 首先你要解析这个问卷答案，并给出三个形象化的物品（比如植物、动物、家具、日常用品等）。
2. 然后把这三个物品的特征融合进飞船设计中，分别对应飞船的头部、机身、尾部，在提示词中清楚描述对应关系，保证整体不违和。
3. 提示词要用英文撰写，尽可能生动形象、细节丰富，包含构图、视角、颜色、材质和关键细节。
4. 在提示词结尾加上一段简短的风格描述，使生成结果符合上述「${stylePreset.label}」的特征。
5. 可以补充或覆盖 style_tags 字段，但必须保证整个 JSON 可以被 JSON.parse() 正常解析。
`.trim();

  // 3. 调 OpenAI 生成 JSON 字符串
  const response = await openai.responses.create({
    model: "gpt-5-chat-latest",
    input: [
      { role: "system", content: systemPrompt },
      {
        role: "user",
        content: `以下是用户的问卷答案（JSON）：\n${userText}`,
      },
    ],
  });

  // 4. 先拿到模型原始文本
  let raw = response.output[0].content[0].text ?? "";
  raw = raw.trim();

  console.log("=== raw model output ===");
  console.log(raw);
  console.log("=== end raw ===");

  // 5. 只截取从第一个 { 到最后一个 } 之间的内容，防止前后有废话
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start !== -1 && end !== -1 && end > start) {
    raw = raw.slice(start, end + 1);
  }

  // 6. 把 ```json ... ``` 之类的代码块标记彻底去掉
  raw = raw
    .replace(/```[a-zA-Z]*/g, "") // 去掉 ```json / ```js 等
    .replace(/```/g, "") // 去掉单独的 ```
    .trim();

  let data;
  try {
    data = JSON.parse(raw);
  } catch (e) {
    console.error("解析 JSON 失败, 原始清洗后输出：", raw);
    throw new Error("模型输出不是合法 JSON");
  }

  // 7. 简单校验 & 兜底处理
  if (!data.prompt) {
    throw new Error("模型输出缺少 prompt 字段");
  }

  let styleTagsFromModel = [];
  if (Array.isArray(data.style_tags)) {
    styleTagsFromModel = data.style_tags.filter(
      (t) => typeof t === "string" && t.trim() !== ""
    );
  }

  // 合并模型给出的标签 + 预设里的标签 + 预设 id
  const mergedStyleTags = Array.from(
    new Set([
      ...styleTagsFromModel,
      ...(stylePreset.styleTags || []),
      stylePreset.id,
    ])
  );

  // 8. 返回给后端主流程使用
  return {
    prompt: data.prompt,
    style_tags: mergedStyleTags,
    stylePreset, // ✅ 额外返回，方便 server 决定图库
  };
}
