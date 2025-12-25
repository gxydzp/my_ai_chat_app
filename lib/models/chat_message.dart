/// chat_message.dart
/// 说话方
enum ChatRole {
  user,
  assistant,
  system,
}

/// 一条聊天消息
class ChatMessage {
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 兼容你在 chat_screen 里用的 isUser
  bool get isUser => role == ChatRole.user;

  /// 兼容你在 chat_screen 里用的 text
  String get text => content;
}
