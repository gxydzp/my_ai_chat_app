// prompts/Graphical_style.js

export const GRAPHICAL_STYLE_PRESET = {
  id: "Graphical_style",
  label: "图形化漫画飞船风格",
  // 绑定到 public/reference/Graphical_style 这个图库
  referenceLibraryId: "Graphical_style",
  styleTags: ["graphical", "vector", "comic"],
  styleInstruction: `
图像采用图形化、矢量插画风格：
- 轮廓线清晰，由几何形和大色块构成；
- 阴影简化为少量大面积明暗，而不是细腻渐变；
- 结构偏扁平、画面干净，带有明显的漫画感和 UI / icon 视觉语言。
`.trim(),
};

export default GRAPHICAL_STYLE_PRESET;
