// lib/models/post/comment_model.dart
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });
}
