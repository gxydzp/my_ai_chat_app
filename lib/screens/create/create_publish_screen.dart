// lib/screens/create/create_publish_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/image_provider.dart';
import '../../theme/app_theme.dart';

class CreatePublishScreen extends StatefulWidget {
  const CreatePublishScreen({super.key});

  @override
  State<CreatePublishScreen> createState() => _CreatePublishScreenState();
}

class _CreatePublishScreenState extends State<CreatePublishScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 启动时加载风格 / 图库列表
    Future.microtask(() {
      final p = context.read<ImageGenProvider>();
      p.loadStylesIfNeeded();
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _onPickReference() async {
    final p = context.read<ImageGenProvider>();
    await p.fetchRandomReference();
  }

  Future<void> _onGenerate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final p = context.read<ImageGenProvider>();
    await p.generateImage(prompt: prompt, useReferenceIfExists: true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ImageGenProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI 生图'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        // 整页深色渐变背景
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050814),
              Color(0xFF080C1F),
              Color(0xFF10152A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部说明
                const Text(
                  '文字 → 灵感图像',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '先选一个参考图库 / 风格，再用一句话描述你想要的画面。',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),

                // -----------------------------
                // 风格 / 图库选择区域
                // -----------------------------
                if (p.isLoading && p.styles.isEmpty)
                  LinearProgressIndicator(
                    color: AppTheme.accentColor,
                    backgroundColor: Colors.white.withOpacity(0.06),
                  )
                else if (p.styles.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.14),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0x3318213A),
                          Color(0x220E1630),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: p.selectedStyleId,
                              dropdownColor: const Color(0xFF10152A),
                              hint: Text(
                                '选择参考图库 / 风格',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              items: p.styles
                                  .map(
                                    (s) => DropdownMenuItem<String>(
                                      value: s.id,
                                      child: Text(
                                        s.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  p.selectStyle(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    '暂无图库配置，可先直接使用文字生成。',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),

                const SizedBox(height: 16),

                // -----------------------------
                // prompt 输入框
                // -----------------------------
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x3318213A),
                        Color(0x220E1630),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.16),
                    ),
                  ),
                  child: TextField(
                    controller: _promptController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '输入你想生成的画面描述…',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 按钮：随机参考图 / 开始生成
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: p.isLoading ? null : _onPickReference,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.36),
                            width: 1,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text('随机参考图'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: p.isLoading ? null : _onGenerate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        child: p.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('开始生成'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 错误信息
                if (p.error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Exception: ${p.error}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                const SizedBox(height: 4),

                // -----------------------------
                // 预览区（参考图 & 生成图）
                // 用一个 Expanded 包住，内部自己滚动，避免多个 Expanded 冲突
                // -----------------------------
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildPreview(p),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ImageGenProvider p) {
    // 什么都没有时
    if (p.referenceUrl == null && p.generatedUrl == null) {
      return Center(
        key: const ValueKey('empty'),
        child: Text(
          '还没有生成内容',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      );
    }

    return ListView(
      key: const ValueKey('preview'),
      padding: const EdgeInsets.only(top: 8),
      children: [
        if (p.referenceUrl != null) ...[
          Text(
            '参考图',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildImageCard(p.referenceUrl!),
          const SizedBox(height: 16),
        ],
        if (p.generatedUrl != null) ...[
          Text(
            '生成结果',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildImageCard(p.generatedUrl!),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildImageCard(String url) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x3318213A),
            Color(0x220E1630),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          alignment: Alignment.center,
          child: Text(
            '图片加载失败',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
