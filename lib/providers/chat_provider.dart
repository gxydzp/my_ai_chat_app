// lib/providers/chat_provider.dart
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  String? _promptgramId;
  String? _sessionId;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get promptgramId => _promptgramId;
  String? get sessionId => _sessionId;

  void resetConversation() {
    _messages.clear();
    _promptgramId = null;
    _sessionId = null;
    notifyListeners();
  }

  Future<void> startConversation({required String promptgramId}) async {
    if (_isLoading) return;

    _promptgramId = promptgramId;
    _isLoading = true;
    notifyListeners();

    try {
      final data =
          await ApiService.instance.startChat(promptgramId: promptgramId);
      _sessionId = (data['sessionId'] ?? '').toString();
      final first = (data['reply'] ?? '').toString();

      if (_sessionId == null || _sessionId!.isEmpty) {
        throw Exception('server returned empty sessionId');
      }
      if (first.isNotEmpty) {
        _messages.add(ChatMessage(role: ChatRole.assistant, content: first));
      }
    } catch (e) {
      _messages.add(ChatMessage(role: ChatRole.system, content: '启动失败：$e'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    final msg = text.trim();
    if (msg.isEmpty || _isLoading) return;

    if (_sessionId == null) {
      _messages
          .add(ChatMessage(role: ChatRole.system, content: '请先选择一个 AI 并点击开始。'));
      notifyListeners();
      return;
    }

    _messages.add(ChatMessage(role: ChatRole.user, content: msg));
    _isLoading = true;
    notifyListeners();

    try {
      final reply = await ApiService.instance.sendChat(
        sessionId: _sessionId!,
        message: msg,
      );
      _messages.add(ChatMessage(role: ChatRole.assistant, content: reply));
    } catch (e) {
      _messages.add(ChatMessage(role: ChatRole.system, content: '请求失败：$e'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
