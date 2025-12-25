// lib/widgets/explore/post_card.dart
import 'package:flutter/material.dart';
import '../../models/post/post_model.dart';
import 'post_actions_bar.dart';
import 'post_header.dart';
import 'post_media_grid.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onOpenAuthor;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onComment,
    required this.onOpenAuthor,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(post.createdAtMs);
    final media = post.mediaUrls;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeader(
              authorName: post.authorName,
              createdAt: createdAt,
              onOpenAuthor: onOpenAuthor,
            ),
            const SizedBox(height: 8),
            if (post.content.trim().isNotEmpty)
              Text(post.content, style: const TextStyle(fontSize: 15)),
            if (media.isNotEmpty) ...[
              const SizedBox(height: 10),
              PostMediaGrid(media: media),
            ],
            const SizedBox(height: 10),
            PostActionsBar(
              liked: post.likedByMe, // 如果你也想改名，这里一起统一
              likeCount: post.likeCount,
              commentCount: post.commentCount,
              onLike: onLike,
              onComment: onComment,
            ),
          ],
        ),
      ),
    );
  }
}
