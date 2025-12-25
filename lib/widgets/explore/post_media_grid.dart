// lib/widgets/explore/post_media_grid.dart
import 'package:flutter/material.dart';

class PostMediaGrid extends StatelessWidget {
  final List<String> media; // ✅ 改成 List<String>

  const PostMediaGrid({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();

    // 1 张图：做大图
    if (media.length == 1) {
      return _MediaTile(url: media.first, aspectRatio: 16 / 9);
    }

    // 多张图：网格
    final crossAxisCount = 3;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: media.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (_, i) => _MediaTile(url: media[i]),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final String url;
  final double? aspectRatio;

  const _MediaTile({required this.url, this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    Widget child = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: Colors.black12,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image)),
          loadingBuilder: (context, w, progress) {
            if (progress == null) return w;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );

    if (aspectRatio != null) {
      child = AspectRatio(aspectRatio: aspectRatio!, child: child);
    }

    return child;
  }
}
