import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';

import '../../providers/chat_provider.dart';
import '../../services/api_service.dart';

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
    final text = _controller.text;
    _controller.clear();
    await context.read<ChatProvider>().sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('AI 问卷对话')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1) 顶部：选择 AI（Promptgram）
            Row(
              children: [
                const Text('选择一个 AI',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: _loadingPromptgrams ? null : _loadPromptgrams,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_loadingPromptgrams)
              const LinearProgressIndicator()
            else if (_promptgrams.isEmpty)
              const Text('没有可用的 AI 配置，请检查后端 /api/promptgrams')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _promptgrams.map((p) {
                  final id = p['id']?.toString() ?? '';
                  final name = p['name']?.toString() ?? id;
                  return ChoiceChip(
                    label: Text(name),
                    selected: _selectedId == id,
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
                  child:
                      Text(desc, style: const TextStyle(color: Colors.black54)),
                );
              }),

            const SizedBox(height: 8),

            // 2) 启动对话按钮（让 AI 先提问）
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed:
                    chat.isLoading || _selectedId == null ? null : _start,
                child: const Text('开始'),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // 3) 消息区
            Expanded(
              child: ListView.builder(
                itemCount: chat.messages.length,
                itemBuilder: (context, i) {
                  final m = chat.messages[i];
                  final isUser = m.role == ChatRole.user;
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m.content),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 4) 输入区
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '输入你的回答...',
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
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
