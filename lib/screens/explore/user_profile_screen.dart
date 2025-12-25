// lib/screens/explore/user_profile_screen.dart
import 'package:flutter/material.dart';

class UserProfileArgs {
  final String userId;
  final String userName;
  UserProfileArgs({required this.userId, required this.userName});
}

class UserProfileScreen extends StatelessWidget {
  final UserProfileArgs args;
  const UserProfileScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(args.userName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('这里是用户主页占位：${args.userId}\n后续接后端再展示用户帖子/关注等。'),
      ),
    );
  }
}
