// lib/models/social/nav_args.dart
import 'package:flutter/foundation.dart';

@immutable
class PostDetailArgs {
  final String postId;
  const PostDetailArgs({required this.postId});
}

@immutable
class CommentListArgs {
  final String postId;
  final String? postTitle;
  const CommentListArgs({required this.postId, this.postTitle});
}

@immutable
class UserProfileArgs {
  final String userId;
  final String? userName;
  const UserProfileArgs({required this.userId, this.userName});
}
