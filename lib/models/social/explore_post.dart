// lib/models/social/explore_post.dart
enum ExploreCategory { galaxy, station, planet }

extension ExploreCategoryLabel on ExploreCategory {
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
