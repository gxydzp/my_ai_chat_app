// lib/models/post/post_create_dto.dart
import 'post_model.dart';

class PostCreateDto {
  final ExploreCategory category;
  final String content;
  final List<String> imageUrls;

  PostCreateDto({
    required this.category,
    required this.content,
    required this.imageUrls,
  });
}
