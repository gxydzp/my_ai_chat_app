// lib/models/social/like_model.dart

class LikeModel {
  final String postId;
  final String userId;
  final DateTime createdAt;

  const LikeModel({
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      postId: (json['postId'] ?? json['post_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      createdAt:
          _parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
      };

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
