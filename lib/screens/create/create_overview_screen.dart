// lib/screens/create/create_overview_screen.dart
import 'package:flutter/material.dart';

class CreateOverviewScreen extends StatelessWidget {
  const CreateOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创造舱段')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _BigActionCard(
              icon: Icons.assignment_outlined,
              title: 'AI 访者',
              subtitle: '帮助您探索自身',
              onTap: () => Navigator.of(context).pushNamed('/create/ai-survey'),
            ),
            const SizedBox(height: 16),
            _BigActionCard(
              icon: Icons.image_outlined,
              title: 'AI 生图',
              subtitle: '用文字生成你的灵感图像',
              onTap: () => Navigator.of(context).pushNamed('/create/ai-image'),
            ),
          ],
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
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
