// lib/screens/shell/main_shell.dart
import 'package:flutter/material.dart';

import '../explore/explore_overview_screen.dart';
import '../create/create_overview_screen.dart';
import '../collection/collection_overview_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // 0 = 探索舱段（默认），1 = 创造舱段，2 = 收藏舱段
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      ExploreOverviewScreen(),
      CreateOverviewScreen(),
      CollectionOverviewScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
    );
  }
}
