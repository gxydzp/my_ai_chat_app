// lib/widgets/explore/post_actions_bar.dart
import 'package:flutter/material.dart';

class PostActionsBar extends StatelessWidget {
  final bool liked;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const PostActionsBar({
    super.key,
    required this.liked,
    required this.likeCount,
    required this.commentCount,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onLike,
          icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
          label: Text('$likeCount'),
        ),
        const SizedBox(width: 6),
        TextButton.icon(
          onPressed: onComment,
          icon: const Icon(Icons.mode_comment_outlined),
          label: Text('$commentCount'),
        ),
      ],
    );
  }
}
