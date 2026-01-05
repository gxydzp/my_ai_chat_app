// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().profile;
    _nameController = TextEditingController(text: user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<UserProvider>().setName(_nameController.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppTheme.withMainBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('编辑个人资料'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.mainBackgroundGradient,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 顶部小标题 & 文案
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '我的身份标记',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '这个昵称会出现在你的 AI 对话与探索舱段中，'
                      '更像是为自己点亮的一个呼号。',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 带光感的卡片容器
                  Card(
                    elevation: 12,
                    shadowColor: AppTheme.primaryColor.withValues(alpha: 0.45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        // 轻微内发光 + 描边
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x22FFFFFF),
                            Color(0x22000000),
                          ],
                        ),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.5),
                          width: 0.7,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '昵称',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSub,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textMain,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: '输入你想使用的昵称',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 底部一个显眼的保存按钮（等价于右上角 ✓）
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('保存昵称'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
