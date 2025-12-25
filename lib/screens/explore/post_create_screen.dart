// lib/screens/explore/post_create_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/post/post_create_dto.dart';
import '../../models/post/post_model.dart';
import '../../providers/explore/feed_provider.dart';
import '../../providers/image_provider.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _content = TextEditingController();
  final _imgUrl = TextEditingController();

  ExploreCategory _category = ExploreCategory.galaxy;
  final List<String> _images = [];

  bool _submitting = false;

  @override
  void dispose() {
    _content.dispose();
    _imgUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final text = _content.text.trim();
    if (text.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内容或图片至少填一项')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final dto = PostCreateDto(
        category: _category,
        content: text,
        imageUrls: List<String>.from(_images),
      );

      debugPrint('[PostCreate] dto.category=${dto.category}');
      debugPrint('[PostCreate] dto.content="${dto.content}"');
      debugPrint('[PostCreate] dto.imageUrls=${dto.imageUrls}');

      await context.read<FeedProvider>().createPost(dto);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e, st) {
      debugPrint('[PostCreate] createPost ERROR: $e');
      debugPrint('$st');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发布失败：$e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgProvider = context.watch<ImageGenProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('发布图文'),
      ),

      // ✅ 方案 C：底部固定发布按钮
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('发布'),
            ),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<ExploreCategory>(
            value: _category,
            decoration: const InputDecoration(labelText: '分类'),
            items: const [
              DropdownMenuItem(
                  value: ExploreCategory.galaxy, child: Text('星海')),
              DropdownMenuItem(
                  value: ExploreCategory.station, child: Text('空间站')),
              DropdownMenuItem(
                  value: ExploreCategory.planet, child: Text('星球')),
            ],
            onChanged: _submitting
                ? null
                : (v) =>
                    setState(() => _category = v ?? ExploreCategory.galaxy),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _content,
            maxLines: 6,
            enabled: !_submitting,
            decoration: const InputDecoration(
              hintText: '写点什么…（支持文字 + 图片URL）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _imgUrl,
                  enabled: !_submitting,
                  decoration: const InputDecoration(
                    hintText: '粘贴图片 URL（http/https）',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _submitting
                    ? null
                    : () {
                        final u = _imgUrl.text.trim();
                        if (u.isEmpty) return;
                        setState(() {
                          _images.add(u);
                          _imgUrl.clear();
                        });
                      },
                child: const Text('添加'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () {
                          final u = imgProvider.generatedUrl;
                          if (u == null || u.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('没有可用的 AI 生图结果，请先去 AI 生图页生成。'),
                              ),
                            );
                            return;
                          }
                          setState(() => _images.add(u));
                        },
                  child: const Text('使用最近一次 AI 生图'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () =>
                          Navigator.of(context).pushNamed('/create/ai-image'),
                  child: const Text('去 AI 生图页'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_images.isNotEmpty) ...[
            const Text('已添加图片：'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _images.map((u) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        u,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 110,
                          height: 110,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Text('图片加载失败'),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _submitting
                            ? null
                            : () => setState(() => _images.remove(u)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
