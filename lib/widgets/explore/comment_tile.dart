// lib/widgets/explore/comment_tile.dart
import 'package:flutter/material.dart';
import '../../models/post/comment_model.dart';

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(comment.userName),
      subtitle: Text(comment.content),
    );
  }
}
