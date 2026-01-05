// lib/screens/create/create_overview_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CreateOverviewScreen extends StatelessWidget {
  const CreateOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('创造舱段'),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部标题 + 简短说明
                const Text(
                  '创造舱段',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '和你的 AI 一起生成问卷、图像与故事片段。',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 24),

                // 功能卡片
                _BigActionCard(
                  icon: Icons.assignment_outlined,
                  title: 'AI 访者',
                  subtitle: '用对话式问卷帮你整理内在世界',
                  onTap: () =>
                      Navigator.of(context).pushNamed('/create/ai-survey'),
                ),
                const SizedBox(height: 16),
                _BigActionCard(
                  icon: Icons.image_outlined,
                  title: 'AI 生图',
                  subtitle: '用一句话生成你的灵感飞船和场景',
                  onTap: () =>
                      Navigator.of(context).pushNamed('/create/ai-image'),
                ),

                const Spacer(),

                // 底部一点点提示文案（可选）
                Text(
                  'Tip：你在 AI 生图里生成的图，可以一键发到探索舱段。',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BigActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BigActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // 主体是深色 + 轻微渐变
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF15192B),
              Color(0xFF0D1020),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左侧：带光晕的小圆图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.accentColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.7),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // 中间：标题 + 副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
