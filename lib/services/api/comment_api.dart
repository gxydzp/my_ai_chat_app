// lib/services/api/comment_api.dart
import '../../models/post/comment_model.dart';

class CommentApi {
  static final CommentApi instance = CommentApi._();
  CommentApi._();

  final Map<String, List<CommentModel>> _commentsByPost = {};

  Future<List<CommentModel>> fetchComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_commentsByPost[postId] ?? []);
  }

  Future<CommentModel> addComment({
    required String postId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final now = DateTime.now();
    final c = CommentModel(
      id: 'c_${now.microsecondsSinceEpoch}',
      postId: postId,
      userId: 'u_me',
      userName: '我',
      content: content.trim(),
      createdAt: now,
    );
    _commentsByPost.putIfAbsent(postId, () => []);
    _commentsByPost[postId]!.insert(0, c);
    return c;
  }
}
