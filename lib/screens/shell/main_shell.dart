// lib/screens/shell/main_shell.dart
import 'package:flutter/material.dart';

// 引入主题，拿渐变 & 颜色
import '../../theme/app_theme.dart';

import '../explore/explore_overview_screen.dart';
import '../create/create_overview_screen.dart';
import '../collection/collection_overview_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      ExploreOverviewScreen(),
      CreateOverviewScreen(),
      CollectionOverviewScreen(),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.mainBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // 关键：让渐变从这个 Scaffold 背后透出来（包括底部导航）
        body: pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.bottomBarGradient,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: _selectedIndex,
            selectedItemColor: AppTheme.accentColor,
            unselectedItemColor: Colors.white60,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.travel_explore),
                label: '探索',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_fix_high),
                label: '创造',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.collections_bookmark),
                label: '收藏',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
