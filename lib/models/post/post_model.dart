// lib/models/post/post_model.dart

// ✅ 让 import post_model.dart 的地方也能用 ExploreCategory
export '../social/explore_post.dart' show ExploreCategory;

import '../social/explore_post.dart';

class PostModel {
  final String id;
  final String title;
  final String content;

  final String authorId;
  final String authorName;

  final ExploreCategory category;

  /// 你已有：图片 URL 列表
  final List<String> mediaUrls;

  final int likeCount;
  final int commentCount;

  /// 你已有：毫秒时间戳
  final int createdAtMs;

  /// ✅ 新增：是否我已点赞（UI 需要）
  final bool likedByMe;

  const PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.category,
    required this.mediaUrls,
    required this.likeCount,
    required this.commentCount,
    required this.createdAtMs,
    this.likedByMe = false,
  });

  /// ✅ 兼容 UI：PostHeader 需要 DateTime createdAt
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);

  /// ✅ 兼容 UI：PostMediaGrid 现在在用 post.media
  List<String> get media => mediaUrls;

  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    ExploreCategory? category,
    List<String>? mediaUrls,
    int? likeCount,
    int? commentCount,
    int? createdAtMs,
    bool? likedByMe,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      category: category ?? this.category,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }

  /// --- JSON ---
  /// 约定：
  /// category: "galaxy" | "station" | "planet"
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final media = (json['mediaUrls'] as List?) ??
        (json['media_urls'] as List?) ??
        (json['media'] as List?) ??
        const [];

    final catRaw = (json['category'] ?? '').toString();

    return PostModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      authorId: (json['authorId'] ?? json['author_id'] ?? '').toString(),
      authorName: (json['authorName'] ?? json['author_name'] ?? '').toString(),
      category: _categoryFromString(catRaw),
      mediaUrls: media.map((e) => e.toString()).toList(),
      likeCount: _toInt(json['likeCount'] ?? json['like_count']),
      commentCount: _toInt(json['commentCount'] ?? json['comment_count']),
      createdAtMs: _toInt(json['createdAtMs'] ?? json['created_at_ms']),
      likedByMe: _toBool(json['likedByMe'] ?? json['liked_by_me']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'category': _categoryToString(category),
      'mediaUrls': mediaUrls,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAtMs': createdAtMs,
      'likedByMe': likedByMe,
    };
  }
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse((v ?? '0').toString()) ?? 0;
}

bool _toBool(dynamic v) {
  if (v is bool) return v;
  final s = (v ?? '').toString().toLowerCase();
  return s == '1' || s == 'true' || s == 'yes';
}

ExploreCategory _categoryFromString(String v) {
  switch (v) {
    case 'galaxy':
      return ExploreCategory.galaxy;
    case 'station':
      return ExploreCategory.station;
    case 'planet':
      return ExploreCategory.planet;
    default:
      return ExploreCategory.galaxy;
  }
}

String _categoryToString(ExploreCategory v) {
  switch (v) {
    case ExploreCategory.galaxy:
      return 'galaxy';
    case ExploreCategory.station:
      return 'station';
    case ExploreCategory.planet:
      return 'planet';
  }
}
