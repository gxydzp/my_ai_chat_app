// lib/providers/promptgram_provider.dart
import 'package:flutter/foundation.dart';
import '../models/promptgram.dart';

class PromptgramProvider extends ChangeNotifier {
  final List<Promptgram> _items = const [
    Promptgram(
      id: 'family_therapy',
      name: '家庭议题访谈',
      description: '围绕原生家庭与亲密关系的引导式访谈',
    ),
    Promptgram(
      id: 'default',
      name: '默认',
      description: '通用聊天',
    ),
  ];

  String? _selectedId;

  List<Promptgram> get items => List.unmodifiable(_items);
  String? get selectedId => _selectedId;

  Promptgram? get selected => _selectedId == null
      ? null
      : _items.firstWhere((e) => e.id == _selectedId);

  void select(String id) {
    _selectedId = id;
    notifyListeners();
  }
}
