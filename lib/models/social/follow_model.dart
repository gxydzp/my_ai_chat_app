// lib/models/social/follow_model.dart

class FollowModel {
  final String followerId; // 我关注的人 -> followeeId
  final String followeeId;

  final DateTime createdAt;

  const FollowModel({
    required this.followerId,
    required this.followeeId,
    required this.createdAt,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      followerId: (json['followerId'] ?? json['follower_id'] ?? '').toString(),
      followeeId: (json['followeeId'] ?? json['followee_id'] ?? '').toString(),
      createdAt:
          _parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'followerId': followerId,
        'followeeId': followeeId,
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
