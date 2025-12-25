// lib/models/post/post_media.dart
enum PostMediaType { image }

class PostMedia {
  final PostMediaType type;
  final String url;

  const PostMedia({
    required this.type,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'url': url,
      };

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] ?? 'image').toString();
    final type = PostMediaType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => PostMediaType.image,
    );
    return PostMedia(type: type, url: (json['url'] ?? '').toString());
  }
}
