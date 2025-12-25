// lib/screens/create/create_publish_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/image_provider.dart';

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
      appBar: AppBar(title: const Text("AI 生图")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -----------------------------
            // 新增：风格 / 图库选择下拉框
            // -----------------------------
            if (p.styles.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: DropdownButton<String>(
                  value: p.selectedStyleId,
                  hint: const Text('选择参考图库 / 风格'),
                  items: p.styles
                      .map(
                        (s) => DropdownMenuItem<String>(
                          value: s.id,
                          child: Text(s.label),
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
              const SizedBox(height: 12),
            ] else if (p.isLoading) ...[
              const SizedBox(
                height: 40,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],

            // -----------------------------
            // 原来的 prompt 输入框
            // -----------------------------
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "输入你想生成的画面描述…",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // 按钮：随机参考图 / 开始生成
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: p.isLoading ? null : _onPickReference,
                    child: const Text("随机参考图"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: p.isLoading ? null : _onGenerate,
                    child: p.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("开始生成"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (p.error != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Exception: ${p.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (p.referenceUrl != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text("参考图：${p.referenceUrl}"),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Image.network(p.referenceUrl!, fit: BoxFit.contain),
              ),
              const SizedBox(height: 8),
            ],

            if (p.generatedUrl != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text("生成结果：${p.generatedUrl}"),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Image.network(p.generatedUrl!, fit: BoxFit.contain),
              ),
            ],

            if (p.referenceUrl == null && p.generatedUrl == null)
              const Expanded(
                child: Center(child: Text("还没有生成内容")),
              ),
          ],
        ),
      ),
    );
  }
}
