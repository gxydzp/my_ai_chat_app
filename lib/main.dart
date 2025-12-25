// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';

// ✅ 新增：引入 ApiService（你要确保路径正确）
import 'services/api_service.dart';

// 你已有的 providers
import 'providers/chat_provider.dart';
import 'providers/image_provider.dart';
import 'providers/user_provider.dart';
import 'providers/promptgram_provider.dart';

// 新增的 explore providers（按你现有结构）
import 'providers/explore/feed_provider.dart';
import 'providers/explore/comment_provider.dart';
import 'providers/explore/profile_provider.dart';

// screens（你已有的）
import 'screens/shell/main_shell.dart';
import 'screens/explore/explore_user_module_screen.dart';
import 'screens/create/create_import_screen.dart';
import 'screens/create/create_publish_screen.dart';
import 'screens/collection/collection_add_module_screen.dart';
import 'screens/profile/profile_screen.dart';

// 新增的 screens（按你现有结构）
import 'screens/explore/post_detail_screen.dart';
import 'screens/explore/post_create_screen.dart';
import 'screens/explore/comment_list_screen.dart';
import 'screens/explore/user_profile_screen.dart';

// 新增 model
import 'models/post/post_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 启动探针：App 一启动就请求一次 3002，确认前后端网络是否通
  await _probeSocialBackend();

  runApp(const MyAIChatApp());
}

Future<void> _probeSocialBackend() async {
  try {
    debugPrint('[BOOT] probing social backend (3002) ...');

    // 这里依赖你 ApiService 里已经实现 socialPing()
    // 我之前给你的 socialPing 是用 /api/explore/feed 做 ping（不依赖 /health）
    final result = await ApiService.instance.socialPing();

    debugPrint('[BOOT] socialPing OK: $result');
  } catch (e, st) {
    debugPrint('[BOOT] socialPing FAIL: $e');
    debugPrint('$st');
  }
}

class MyAIChatApp extends StatelessWidget {
  const MyAIChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ 你已有
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ImageGenProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PromptgramProvider()),

        // ✅ 新增（微博 Feed）
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Retro Future AI Chat',
        theme: AppTheme.mainTheme,
        home: const MainShell(),
        routes: {
          '/explore/detail': (_) => const ExploreUserModuleScreen(),
          '/create/ai-survey': (_) => const CreateImportScreen(),
          '/create/ai-image': (_) => const CreatePublishScreen(),
          '/collection/add': (_) => const CollectionAddModuleScreen(),
          '/profile/edit': (_) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/explore/post':
              final post = settings.arguments as PostModel;
              return MaterialPageRoute(
                builder: (_) => PostDetailScreen(post: post),
              );

            case '/explore/post/create':
              return MaterialPageRoute(
                builder: (_) => const PostCreateScreen(),
              );

            case '/explore/post/comments':
              final args = settings.arguments as CommentListArgs;
              return MaterialPageRoute(
                builder: (_) => CommentListScreen(args: args),
              );

            case '/explore/user':
              final args = settings.arguments as UserProfileArgs;
              return MaterialPageRoute(
                builder: (_) => UserProfileScreen(args: args),
              );
          }
          return null;
        },
      ),
    );
  }
}
