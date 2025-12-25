// lib/screens/explore/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/post/post_model.dart';
import '../../providers/explore/feed_provider.dart';
import '../../widgets/explore/post_card.dart';
import 'comment_list_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final list = feed.postsByCategory(post.category);
    final latest = list.firstWhere((p) => p.id == post.id, orElse: () => post);

    return Scaffold(
      appBar: AppBar(title: const Text('帖子详情')),
      body: ListView(
        children: [
          PostCard(
            post: latest,
            onTap: null,
            onLike: () => context.read<FeedProvider>().toggleLike(latest),
            onComment: () => Navigator.of(context).pushNamed(
              '/explore/post/comments',
              arguments: CommentListArgs(post: latest),
            ),
            onOpenAuthor: () {},
          ),
          const Divider(height: 0),
          ListTile(
            title: const Text('查看全部评论'),
            subtitle: Text('已有 ${latest.commentCount} 条评论'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed(
              '/explore/post/comments',
              arguments: CommentListArgs(post: latest),
            ),
          ),
        ],
      ),
    );
  }
}
