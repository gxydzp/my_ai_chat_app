// chat_agent_backend/prompts/promptgrams.js

import { BASE_COUNSELING_PROMPT } from "./basePrompt.js";
import { FAMILY_PROMPTGRAM } from "./family.js";
import { IMS_RELATIONSHIP_PROMPTGRAM } from "./imsRelationship.js";
import { DEFAULT_PROMPTGRAM } from "./default.js";

// 所有可选模式
export const PROMPTGRAMS = [
  FAMILY_PROMPTGRAM,
  IMS_RELATIONSHIP_PROMPTGRAM,
  DEFAULT_PROMPTGRAM,
];

// 按 id 查找
export function getPromptgramById(id) {
  return PROMPTGRAMS.find((p) => p.id === id);
}

// 直接把通用基础 prompt 也从这里 re-export，方便 server.js 一次性引入
export { BASE_COUNSELING_PROMPT };
