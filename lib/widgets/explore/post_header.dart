// lib/widgets/explore/post_header.dart
import 'package:flutter/material.dart';

class PostHeader extends StatelessWidget {
  final String authorName;
  final DateTime createdAt;
  final VoidCallback onOpenAuthor;

  const PostHeader({
    super.key,
    required this.authorName,
    required this.createdAt,
    required this.onOpenAuthor,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        const CircleAvatar(radius: 18, child: Icon(Icons.person)),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: onOpenAuthor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(authorName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(time,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
