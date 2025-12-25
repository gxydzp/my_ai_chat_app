// lib/models/explore_post.dart
enum ExploreCategory { galaxy, station, planet }

extension ExploreCategoryX on ExploreCategory {
  String get label {
    switch (this) {
      case ExploreCategory.galaxy:
        return '星海';
      case ExploreCategory.station:
        return '空间站';
      case ExploreCategory.planet:
        return '星球';
    }
  }
}

class ExplorePost {
  final String id;
  final ExploreCategory category;
  final String title;
  final String preview;
  final String author;

  const ExplorePost({
    required this.id,
    required this.category,
    required this.title,
    required this.preview,
    required this.author,
  });
}
