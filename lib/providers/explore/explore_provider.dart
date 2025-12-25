// lib/providers/explore/comment_provider.dart
import 'package:flutter/foundation.dart';
import '../../models/post/comment_model.dart';
import '../../services/api/comment_api.dart';

class CommentProvider extends ChangeNotifier {
  final CommentApi _api = CommentApi.instance;

  final Map<String, List<CommentModel>> _cache = {};
  final Map<String, bool> _loading = {};

  String? _error;
  String? get error => _error;

  bool isLoading(String postId) => _loading[postId] ?? false;

  List<CommentModel> commentsOf(String postId) =>
      List.unmodifiable(_cache[postId] ?? []);

  Future<void> load(String postId) async {
    if (isLoading(postId)) return;
    _loading[postId] = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _api.fetchComments(postId);
      _cache[postId] = items;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading[postId] = false;
      notifyListeners();
    }
  }

  Future<CommentModel?> add({
    required String postId,
    required String content,
  }) async {
    final text = content.trim();
    if (text.isEmpty) return null;

    _error = null;
    notifyListeners();

    try {
      final c = await _api.addComment(postId: postId, content: text);
      _cache.putIfAbsent(postId, () => []);
      _cache[postId] = [c, ..._cache[postId]!];
      notifyListeners();
      return c;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
