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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('发布图文'),
        backgroundColor: Colors.transparent,
      ),

      // 底部固定的「发布」按钮 + 渐变条
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x0014182C),
              Color(0xFF14182C),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
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
      ),

      body: Container(
        decoration: const BoxDecoration(
          // 整体黑底 + 紫蓝光感渐变
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
          top: true,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              // ====== 卡片 1：分区 + 文本 ======
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.65),
                      blurRadius: 24,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '分区',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ExploreCategory>(
                      value: _category,
                      dropdownColor: const Color(0xFF15192E),
                      iconEnabledColor: Colors.white70,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFBE94FF),
                            width: 1.2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ExploreCategory.galaxy,
                          child: Text('星海'),
                        ),
                        DropdownMenuItem(
                          value: ExploreCategory.station,
                          child: Text('空间站'),
                        ),
                        DropdownMenuItem(
                          value: ExploreCategory.planet,
                          child: Text('星球'),
                        ),
                      ],
                      onChanged: _submitting
                          ? null
                          : (v) => setState(
                              () => _category = v ?? ExploreCategory.galaxy),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '正文',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _content,
                      maxLines: 6,
                      enabled: !_submitting,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '写点什么…（支持文字 + 图片URL）',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.03),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFBE94FF),
                            width: 1.2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(
                          14,
                          12,
                          14,
                          12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ====== 卡片 2：图片 URL + AI 生图入口 ======
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 24,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _imgUrl,
                            enabled: !_submitting,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '粘贴图片 URL（http/https）',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.03),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFFBE94FF),
                                  width: 1.2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              '没有可用的 AI 生图结果，请先去 AI 生图页生成。'),
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
                                : () => Navigator.of(context)
                                    .pushNamed('/create/ai-image'),
                            child: const Text('去 AI 生图页'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ====== 已添加图片（发光小卡片） ======
              if (_images.isNotEmpty) ...[
                const Text(
                  '已添加图片：',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _images.map((u) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x33FFFFFF),
                            Color(0x11000000),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              u,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 120,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white.withOpacity(0.04),
                                ),
                                child: const Text(
                                  '图片加载失败',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.7),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.25),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: _submitting
                                    ? null
                                    : () => setState(() => _images.remove(u)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
