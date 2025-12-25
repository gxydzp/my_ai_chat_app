// lib/providers/explore/feed_provider.dart
import 'package:flutter/foundation.dart';
import '../../models/post/post_create_dto.dart';
import '../../models/post/post_model.dart';
import '../../services/api/social_api.dart';

class FeedProvider extends ChangeNotifier {
  final SocialApi _api = SocialApi.instance;

  final Map<ExploreCategory, List<PostModel>> _posts = {
    ExploreCategory.galaxy: [],
    ExploreCategory.station: [],
    ExploreCategory.planet: [],
  };

  final Map<ExploreCategory, String?> _cursor = {
    ExploreCategory.galaxy: null,
    ExploreCategory.station: null,
    ExploreCategory.planet: null,
  };

  final Map<ExploreCategory, bool> _loading = {
    ExploreCategory.galaxy: false,
    ExploreCategory.station: false,
    ExploreCategory.planet: false,
  };

  String? _error;
  String? get error => _error;

  bool isLoading(ExploreCategory c) => _loading[c] ?? false;

  List<PostModel> postsByCategory(ExploreCategory c) =>
      List.unmodifiable(_posts[c] ?? []);

  Future<void> ensureLoaded(ExploreCategory c) async {
    if ((_posts[c]?.isNotEmpty ?? false) || isLoading(c)) return;
    await refresh(c);
  }

  Future<void> refresh(ExploreCategory c) async {
    if (isLoading(c)) return;
    _loading[c] = true;
    _error = null;
    notifyListeners();

    try {
      final page = await _api.fetchFeed(category: c, cursor: null, limit: 10);
      _posts[c] = page.items;
      _cursor[c] = page.nextCursor;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading[c] = false;
      notifyListeners();
    }
  }

  Future<void> loadMore(ExploreCategory c) async {
    if (isLoading(c)) return;
    final cur = _cursor[c];
    if (cur == null) return;

    _loading[c] = true;
    _error = null;
    notifyListeners();

    try {
      final page = await _api.fetchFeed(category: c, cursor: cur, limit: 10);
      _posts[c] = [...(_posts[c] ?? []), ...page.items];
      _cursor[c] = page.nextCursor;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading[c] = false;
      notifyListeners();
    }
  }

  Future<void> createPost(PostCreateDto dto) async {
    _error = null;
    notifyListeners();

    try {
      final post = await _api.createPost(dto);
      _posts[dto.category] = [post, ...(_posts[dto.category] ?? [])];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLike(PostModel post) async {
    _error = null;
    notifyListeners();

    try {
      final updated = await _api.toggleLike(post);
      final list = _posts[post.category] ?? [];
      final idx = list.indexWhere((p) => p.id == post.id);
      if (idx >= 0) {
        list[idx] = updated;
        _posts[post.category] = List<PostModel>.from(list);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void applyUpdatedPost(PostModel updated) {
    final list = _posts[updated.category] ?? [];
    final idx = list.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      list[idx] = updated;
      _posts[updated.category] = List<PostModel>.from(list);
      notifyListeners();
    }
  }
}
