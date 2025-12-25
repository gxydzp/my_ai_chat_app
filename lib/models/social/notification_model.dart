// lib/models/social/notification_model.dart

enum NotificationType {
  like,
  comment,
  follow,
  system,
}

NotificationType _typeFrom(dynamic v) {
  final s = (v ?? '').toString().toLowerCase();
  switch (s) {
    case 'like':
      return NotificationType.like;
    case 'comment':
      return NotificationType.comment;
    case 'follow':
      return NotificationType.follow;
    default:
      return NotificationType.system;
  }
}

/// 注意：不要叫 Notification（会和 Flutter 的 Notification 类撞名）
class AppNotificationModel {
  final String id;
  final NotificationType type;

  // 谁触发的：点赞/评论/关注的人
  final String actorId;
  final String actorName;

  // 目标：可选
  final String? postId;
  final String? commentId;

  final String? message;
  final bool isRead;

  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.actorId,
    required this.actorName,
    required this.createdAt,
    this.postId,
    this.commentId,
    this.message,
    this.isRead = false,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      type: _typeFrom(json['type']),
      actorId: (json['actorId'] ?? json['actor_id'] ?? '').toString(),
      actorName:
          (json['actorName'] ?? json['actor_name'] ?? 'Unknown').toString(),
      postId: (json['postId'] ?? json['post_id'])?.toString(),
      commentId: (json['commentId'] ?? json['comment_id'])?.toString(),
      message: (json['message'] ?? json['msg'])?.toString(),
      isRead: (json['isRead'] ?? json['is_read'] ?? false) == true,
      createdAt:
          _parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'actorId': actorId,
        'actorName': actorName,
        'postId': postId,
        'commentId': commentId,
        'message': message,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  AppNotificationModel copyWith({
    bool? isRead,
  }) {
    return AppNotificationModel(
      id: id,
      type: type,
      actorId: actorId,
      actorName: actorName,
      postId: postId,
      commentId: commentId,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
