// lib/screens/collection/collection_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class CollectionOverviewScreen extends StatelessWidget {
  const CollectionOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().profile;

    // 这里先用假数据，后面可以接自己的收藏 Provider
    final demoItems = List.generate(
      8,
      (index) => '这是我记录的第 ${index + 1} 条生活碎片',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏舱段'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile/edit');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(user.name.isNotEmpty ? user.name[0] : '?'),
            ),
            title: Text(user.name),
            subtitle: const Text('这里可以放个人签名 / 简介'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed('/collection/add');
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: demoItems.isEmpty
                ? const Center(child: Text('还没有任何收藏，去探索舱段逛逛吧～'))
                : ListView.separated(
                    itemCount: demoItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (ctx, index) {
                      final text = demoItems[index];
                      return ListTile(
                        title: Text(text),
                        onTap: () {
                          // 这里以后也可以跳一个详情页
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
