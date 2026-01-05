// lib/screens/explore/comment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/post/post_model.dart';
import '../../providers/explore/comment_provider.dart';
import '../../providers/explore/feed_provider.dart';
import '../../services/api/social_api.dart';
import '../../widgets/explore/comment_tile.dart';
import '../../widgets/explore/composer_bar.dart';
import '../../theme/app_theme.dart';

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

    return AppTheme.withMainBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('评论'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.mainBackgroundGradient,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: cp.isLoading(post.id) && comments.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      reverse: false,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 0,
                        color: Colors.white.withOpacity(0.06),
                      ),
                      itemBuilder: (_, i) {
                        // 外面再包一层轻微“发光”的背景，让每条评论更像一块块悬浮在黑底上
                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x22000000),
                                Color(0x330F0B24),
                              ],
                            ),
                          ),
                          child: CommentTile(comment: comments[i]),
                        );
                      },
                    ),
            ),

            // 底部输入条，做成带一点光感的底栏
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.bottomBarGradient,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xAA000000),
                    blurRadius: 16,
                    offset: Offset(0, -6),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: Color(0x33FFFFFF),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ComposerBar(
                  hintText: '写评论…',
                  onSend: (text) async {
                    final c = await context
                        .read<CommentProvider>()
                        .add(postId: post.id, content: text);
                    if (c != null) {
                      // commentCount +1
                      await SocialApi.instance.bumpCommentCount(post, delta: 1);
                      // 通知 feed 刷新这个 post 的 commentCount
                      context.read<FeedProvider>().refresh(post.category);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
