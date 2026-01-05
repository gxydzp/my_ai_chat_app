// lib/screens/create/create_import_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class CreateImportScreen extends StatefulWidget {
  const CreateImportScreen({super.key});

  @override
  State<CreateImportScreen> createState() => _CreateImportScreenState();
}

class _CreateImportScreenState extends State<CreateImportScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _loadingPromptgrams = true;
  List<Map<String, dynamic>> _promptgrams = [];
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadPromptgrams();
  }

  Future<void> _loadPromptgrams() async {
    setState(() => _loadingPromptgrams = true);
    try {
      final list = await ApiService.instance.fetchPromptgrams();
      setState(() {
        _promptgrams = list;
        _selectedId = list.isNotEmpty ? list.first['id']?.toString() : null;
      });
    } catch (e) {
      setState(() {
        _promptgrams = [];
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载 AI 列表失败：$e')),
      );
    } finally {
      setState(() => _loadingPromptgrams = false);
    }
  }

  Future<void> _start() async {
    if (_selectedId == null) return;
    final chat = context.read<ChatProvider>();
    chat.resetConversation();
    await chat.startConversation(promptgramId: _selectedId!);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await context.read<ChatProvider>().sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI 访者对话'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        // 整体深色渐变背景
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
                // 顶部标题区（可选保留/精简）
                const Text(
                  '选择一个 AI 访者',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '不同的配置会有不同的访谈风格与问题路径。',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),

                // 顶部：选择 AI（Promptgram）
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '访者列表',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadingPromptgrams ? null : _loadPromptgrams,
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white.withOpacity(
                          _loadingPromptgrams ? 0.3 : 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                if (_loadingPromptgrams)
                  LinearProgressIndicator(
                    color: AppTheme.accentColor,
                    backgroundColor: Colors.white.withOpacity(0.06),
                  )
                else if (_promptgrams.isEmpty)
                  Text(
                    '没有可用的 AI 配置，请检查后端 /api/promptgrams',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _promptgrams.map((p) {
                      final id = p['id']?.toString() ?? '';
                      final name = p['name']?.toString() ?? id;
                      final selected = _selectedId == id;
                      return ChoiceChip(
                        label: Text(
                          name,
                          style: TextStyle(
                            color: selected
                                ? Colors.black
                                : Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppTheme.accentColor,
                        backgroundColor:
                            Colors.white.withOpacity(0.06), // 未选时的深色底
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selected
                                ? Colors.transparent
                                : Colors.white.withOpacity(0.16),
                          ),
                        ),
                        onSelected: (v) {
                          setState(() => _selectedId = id);
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 8),

                // 描述
                if (!_loadingPromptgrams &&
                    _promptgrams.isNotEmpty &&
                    _selectedId != null)
                  Builder(builder: (_) {
                    final current = _promptgrams.firstWhere(
                      (e) => e['id']?.toString() == _selectedId,
                      orElse: () => const {},
                    );
                    final desc = (current['description'] ?? '').toString();
                    if (desc.isEmpty) return const SizedBox.shrink();
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        desc,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 10),

                // 启动对话按钮（让 AI 先提问）
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed:
                        chat.isLoading || _selectedId == null ? null : _start,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('开始访谈'),
                  ),
                ),

                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.12),
                ),
                const SizedBox(height: 12),

                // 消息区
                Expanded(
                  child: ListView.builder(
                    itemCount: chat.messages.length,
                    itemBuilder: (context, i) {
                      final m = chat.messages[i];
                      final isUser = m.role == ChatRole.user;

                      final bubbleColor = isUser
                          ? AppTheme.accentColor.withOpacity(0.32)
                          : Colors.white.withOpacity(0.08);
                      final borderColor = isUser
                          ? AppTheme.accentColor.withOpacity(0.7)
                          : Colors.white.withOpacity(0.18);

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: borderColor,
                              width: 1,
                            ),
                            boxShadow: isUser
                                ? [
                                    BoxShadow(
                                      color:
                                          AppTheme.accentColor.withOpacity(0.6),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            m.content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // 输入区
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '输入你的回答...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1.4,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: chat.isLoading ? null : _send,
                      icon: chat.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
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
