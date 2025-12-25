// lib/screens/collection/collection_add_module_screen.dart
import 'package:flutter/material.dart';

class CollectionAddModuleScreen extends StatefulWidget {
  const CollectionAddModuleScreen({super.key});

  @override
  State<CollectionAddModuleScreen> createState() =>
      _CollectionAddModuleScreenState();
}

class _CollectionAddModuleScreenState extends State<CollectionAddModuleScreen> {
  final TextEditingController _textController = TextEditingController();

  // TODO: 以后可以加图片选择等
  void _save() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // TODO: 把内容写入 Provider / 调接口
    Navigator.of(context).pop(); // 暂时直接返回
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加收藏内容'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _textController,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: '写下你想记录的文字，可以以后扩展为图文混排。',
          ),
        ),
      ),
    );
  }
}
