// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isUser;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryColor : AppTheme.softPink,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
