// lib/screens/explore/explore_user_module_screen.dart
import 'package:flutter/material.dart';
import '../../models/explore_post.dart';

class ExploreUserModuleScreen extends StatelessWidget {
  const ExploreUserModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExplorePost post =
        ModalRoute.of(context)!.settings.arguments as ExplorePost;

    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '作者：${post.author}\n\n'
          '${post.preview}\n\n'
          'TODO：这里以后替换成从后端拿到的完整贴子内容。',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
