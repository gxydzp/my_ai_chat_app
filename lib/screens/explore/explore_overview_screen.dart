// lib/screens/explore/explore_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/post/post_model.dart';
import '../../providers/explore/feed_provider.dart';
import '../../widgets/explore/post_card.dart';
import '../../theme/app_theme.dart';

// 这两个类型现在都在同目录的 screen 里定义
import 'comment_list_screen.dart';
import 'user_profile_screen.dart';

class ExploreOverviewScreen extends StatelessWidget {
  const ExploreOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      Tab(text: '星海'),
      Tab(text: '空间站'),
      Tab(text: '星球'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        // 关键：让 MainShell 的黑底渐变透出来
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('探索舰段'),
          bottom: TabBar(
            tabs: tabs,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppTheme.textMain,
            unselectedLabelColor: AppTheme.textSub,
            indicator: const _BottomGlowTabIndicator(),
          ),
        ),
        floatingActionButton: const _GlowingFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

/// Tab 下方的发光横线指示器
class _BottomGlowTabIndicator extends Decoration {
  const _BottomGlowTabIndicator();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _BottomGlowTabPainter();
  }
}

class _BottomGlowTabPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (configuration.size == null) return;

    final Rect rect = offset & configuration.size!;
    final Size size = rect.size;

    // 以 tab 宽度中心为基准，在底部画一条横线
    final double centerX = rect.center.dx;

    // 横线宽度占 tab 宽度的 60%，高度 4 像素
    final double lineWidth = size.width * 0.6;
    final double lineHeight = 4.0;

    // 稍微往上提一点，不贴着最底边
    final double bottom = rect.bottom - 3.0;

    final Rect lineRect = Rect.fromCenter(
      center: Offset(centerX, bottom),
      width: lineWidth,
      height: lineHeight,
    );

    final RRect rrect = RRect.fromRectAndRadius(
      lineRect,
      const Radius.circular(999),
    );

    // 外部光晕
    final Paint glowPaint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // 内部渐变填充
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFFFFF).withValues(alpha: 0.95),
        const Color(0xFFFFE3FF).withValues(alpha: 0.95),
      ],
    );

    final Paint fillPaint = Paint()..shader = gradient.createShader(lineRect);

    canvas.save();
    // 先画光晕，再画本体
    canvas.drawRRect(rrect.inflate(4), glowPaint);
    canvas.drawRRect(rrect, fillPaint);
    canvas.restore();
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
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: posts.length + 1,
        separatorBuilder: (_, __) =>
            Divider(height: 0, color: Colors.white.withValues(alpha: 0.05)),
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
              // 使用 comment_list_screen.dart 里的 CommentListArgs
              arguments: CommentListArgs(post: post),
            ),
            onOpenAuthor: () => Navigator.of(context).pushNamed(
              '/explore/user',
              // 这里先用占位数据，后面接后端再换成真正的作者信息
              arguments: UserProfileArgs(
                userId: post.id,
                userName: '用户',
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 带光晕的悬浮按钮
class _GlowingFab extends StatelessWidget {
  const _GlowingFab();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.8),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed('/explore/post/create'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.black87,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
