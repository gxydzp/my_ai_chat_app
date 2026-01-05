// lib/screens/collection/collection_add_module_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CollectionAddModuleScreen extends StatefulWidget {
  const CollectionAddModuleScreen({super.key});

  @override
  State<CollectionAddModuleScreen> createState() =>
      _CollectionAddModuleScreenState();
}

class _CollectionAddModuleScreenState extends State<CollectionAddModuleScreen> {
  final TextEditingController _textController = TextEditingController();

  void _save() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先写点什么再保存吧')),
      );
      return;
    }

    // TODO: 把内容写入 Provider / 调接口
    Navigator.of(context).pop(); // 暂时直接返回
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('添加收藏内容'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050814),
              Color(0xFF080C1F),
              Color(0xFF10152A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '这一刻，对你意味着什么？',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '写下你想记录的文字，以后可以扩展成图文、片段、链接……',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                // 发光输入卡片
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0x3318213A),
                          Color(0x220E1630),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: '例如：今天在星海舱段看到的一段话、\n一次对话、一张让你记住的画面……',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 小提示行
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppTheme.accentColor.withOpacity(0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '收藏内容会出现在收藏舱段的时间线里。',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
