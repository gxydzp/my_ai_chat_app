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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('帖子详情'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        // 整体黑底 + 紫蓝渐变
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
          top: true,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              // ====== 发光卡片包一层 PostCard ======
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.75),
                      blurRadius: 26,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: PostCard(
                  post: latest,
                  onTap: null, // 详情页内不需要再点进去
                  onLike: () => context.read<FeedProvider>().toggleLike(latest),
                  onComment: () => Navigator.of(context).pushNamed(
                    '/explore/post/comments',
                    // 保持和你现在的 CommentListArgs(post: ...) 定义一致
                    arguments: CommentListArgs(post: latest),
                  ),
                  onOpenAuthor: () {
                    // TODO: 未来可以跳转作者主页
                  },
                ),
              ),

              // ====== 光感「查看全部评论」条 ======
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                  '/explore/post/comments',
                  arguments: CommentListArgs(post: latest),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0x33BE94FF),
                        Color(0x11000000),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.forum_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '查看全部评论',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '已有 ${latest.commentCount} 条',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
