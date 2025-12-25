// lib/services/api/social_api.dart
import 'package:flutter/foundation.dart';

import '../../models/post/post_create_dto.dart';
import '../../models/post/post_model.dart';
import '../api_service.dart';

class FeedPage {
  final List<PostModel> items;
  final String? nextCursor;
  FeedPage({required this.items, required this.nextCursor});
}

/// ✅ 真实后端版：通过 ApiService 调 3002 的 Explore/Prisma 服务
class SocialApi {
  static final SocialApi instance = SocialApi._();
  SocialApi._();

  final ApiService _api = ApiService.instance;

  /// 拉取 Feed
  Future<FeedPage> fetchFeed({
    required ExploreCategory category,
    String? cursor,
    int limit = 10,
  }) async {
    final cat = category.name; // "galaxy" | "station" | "planet"

    debugPrint(
        '[SocialApi] fetchFeed -> category=$cat limit=$limit cursor=${cursor ?? "null"}');

    final data = await _api.fetchExploreFeed(
      category: cat,
      limit: limit,
      cursor: cursor,
    );

    final rawItems = (data['items'] as List?) ?? const [];
    final items = rawItems
        .map((e) => PostModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final nextCursor = data['nextCursor']?.toString();

    debugPrint(
        '[SocialApi] fetchFeed <- items=${items.length} nextCursor=${nextCursor ?? "null"}');

    return FeedPage(items: items, nextCursor: nextCursor);
  }

  /// 创建 Post
  Future<PostModel> createPost(PostCreateDto dto) async {
    final cat = dto.category.name;

    debugPrint(
        '[SocialApi] createPost -> category=$cat contentLen=${dto.content.length} imageUrls=${dto.imageUrls.length}');

    final data = await _api.createExplorePost(
      category: cat,
      content: dto.content,
      imageUrls: dto.imageUrls,
    );

    final post = PostModel.fromJson(data);

    debugPrint('[SocialApi] createPost <- postId=${post.id}');
    return post;
  }

  /// 点赞/取消点赞（toggle）
  Future<PostModel> toggleLike(PostModel post) async {
    debugPrint('[SocialApi] toggleLike -> postId=${post.id}');

    final data = await _api.toggleExploreLike(post.id);
    final updated = PostModel.fromJson(data);

    debugPrint(
        '[SocialApi] toggleLike <- likedByMe=${updated.likedByMe} likeCount=${updated.likeCount}');
    return updated;
  }

  /// （可选）如果你有评论接口，这里通常不需要本地 bump
  Future<void> bumpCommentCount(PostModel post, {int delta = 1}) async {
    // 保留空实现，避免你别处调用时报错
    debugPrint(
        '[SocialApi] bumpCommentCount noop delta=$delta postId=${post.id}');
  }
}
