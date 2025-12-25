// lib/screens/promptgram_select_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/promptgram_provider.dart';

class PromptgramSelectScreen extends StatelessWidget {
  const PromptgramSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PromptgramProvider>();
    final items = p.items;
    final selectedId = p.selectedId;

    return Scaffold(
      appBar: AppBar(title: const Text('选择 AI')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final it = items[i];
          final selected = it.id == selectedId;

          return ListTile(
            title: Text(it.name),
            subtitle: Text(it.description),
            trailing: selected ? const Icon(Icons.check) : null,
            onTap: () {
              p.select(it.id);
              Navigator.pop(context); // 或者你想跳转到对话页也行
            },
          );
        },
      ),
    );
  }
}
