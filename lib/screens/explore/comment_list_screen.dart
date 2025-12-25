// lib/screens/explore/comment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/post/post_model.dart';
import '../../providers/explore/comment_provider.dart';
import '../../providers/explore/feed_provider.dart';
import '../../services/api/social_api.dart';
import '../../widgets/explore/comment_tile.dart';
import '../../widgets/explore/composer_bar.dart';

class CommentListArgs {
  final PostModel post;
  CommentListArgs({required this.post});
}

class CommentListScreen extends StatefulWidget {
  final CommentListArgs args;
  const CommentListScreen({super.key, required this.args});

  @override
  State<CommentListScreen> createState() => _CommentListScreenState();
}

class _CommentListScreenState extends State<CommentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().load(widget.args.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.args.post;
    final cp = context.watch<CommentProvider>();
    final comments = cp.commentsOf(post.id);

    return Scaffold(
      appBar: AppBar(title: const Text('评论')),
      body: Column(
        children: [
          Expanded(
            child: cp.isLoading(post.id) && comments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    reverse: false,
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (_, i) => CommentTile(comment: comments[i]),
                  ),
          ),
          ComposerBar(
            hintText: '写评论…',
            onSend: (text) async {
              final c = await context
                  .read<CommentProvider>()
                  .add(postId: post.id, content: text);
              if (c != null) {
                // commentCount +1
                await SocialApi.instance.bumpCommentCount(post, delta: 1);
                // 通知 feed 刷新这个 post 的 commentCount（从 store 里更新后，需要重新拉/或局部更新）
                // 这里用最简单方式：refresh 当前分类
                context.read<FeedProvider>().refresh(post.category);
              }
            },
          ),
        ],
      ),
    );
  }
}
