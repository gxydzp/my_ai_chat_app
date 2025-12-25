// lib/screens/explore/explore_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/post/post_model.dart';
import '../../models/social/nav_args.dart';
import '../../providers/explore/feed_provider.dart';
import '../../widgets/explore/post_card.dart';

class ExploreOverviewScreen extends StatelessWidget {
  const ExploreOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 如果你暂时不想依赖 ExploreCategory.values，可以固定 3 个 tab
    final tabs = const [
      Tab(text: '星海'),
      Tab(text: '空间站'),
      Tab(text: '星球'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('探索舰段'),
          bottom: TabBar(tabs: tabs),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              Navigator.of(context).pushNamed('/explore/post/create'),
          child: const Icon(Icons.edit),
        ),
        body: const TabBarView(
          children: [
            _FeedTab(category: ExploreCategory.galaxy),
            _FeedTab(category: ExploreCategory.station),
            _FeedTab(category: ExploreCategory.planet),
          ],
        ),
      ),
    );
  }
}

class _FeedTab extends StatefulWidget {
  final ExploreCategory category;
  const _FeedTab({required this.category});

  @override
  State<_FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<_FeedTab> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FeedProvider>().ensureLoaded(widget.category);
    });

    _controller.addListener(() {
      if (!mounted) return;
      final pos = _controller.position;
      if (pos.pixels >= pos.maxScrollExtent - 240) {
        context.read<FeedProvider>().loadMore(widget.category);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final posts = feed.postsByCategory(widget.category);

    return RefreshIndicator(
      onRefresh: () => feed.refresh(widget.category),
      child: ListView.separated(
        controller: _controller,
        itemCount: posts.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (ctx, i) {
          if (i == posts.length) {
            final loading = feed.isLoading(widget.category);
            if (!loading) return const SizedBox(height: 80);
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final post = posts[i];

          return PostCard(
            post: post,
            onTap: () => Navigator.of(context)
                .pushNamed('/explore/post', arguments: post),
            onLike: () => context.read<FeedProvider>().toggleLike(post),
            onComment: () => Navigator.of(context).pushNamed(
              '/explore/post/comments',
              // ✅ 你的 nav_args.dart 里是 CommentListArgs(postId, postTitle?)
              arguments: CommentListArgs(
                postId: post.id,
                postTitle: post.title,
              ),
            ),
            onOpenAuthor: () => Navigator.of(context).pushNamed(
              '/explore/user',
              // ✅ 你的 nav_args.dart 里至少有 userId
              arguments: UserProfileArgs(userId: post.authorId),
            ),
          );
        },
      ),
    );
  }
}
