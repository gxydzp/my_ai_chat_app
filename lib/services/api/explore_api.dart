// lib/services/explore_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_service.dart';

class ExploreApi {
  ExploreApi._();
  static final ExploreApi instance = ExploreApi._();

  ApiService get _api => ApiService.instance;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(_api.socialBaseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.port,
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  // -------------------------
  // Debug / Health
  // -------------------------
  Future<Map<String, dynamic>> health() async {
    final uri = _uri('/health');
    // ignore: avoid_print
    print('[ExploreApi] GET $uri');

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception(
          'ExploreApi.health failed: ${resp.statusCode}\n${resp.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  // -------------------------
  // Feed
  // GET /api/explore/feed?category=galaxy&limit=10&cursor=...
  // return { items: [...], nextCursor: "..." | null }
  // -------------------------
  Future<Map<String, dynamic>> fetchFeed({
    required String category, // galaxy|station|planet
    int limit = 10,
    String? cursor,
  }) async {
    final q = <String, dynamic>{
      'category': category,
      'limit': limit,
      if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
    };

    final uri = _uri('/api/explore/feed', q);
    // ignore: avoid_print
    print('[ExploreApi] GET $uri');

    final resp = await http.get(
      uri,
      headers: _api.socialHeaders(),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'ExploreApi.fetchFeed failed: ${resp.statusCode}\n${resp.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  // -------------------------
  // Create Post
  // POST /api/explore/posts
  // body: { category, content, imageUrls: [] }
  // return post json (same as feed item)
  // -------------------------
  Future<Map<String, dynamic>> createPost({
    required String category,
    required String content,
    List<String> imageUrls = const [],
  }) async {
    final uri = _uri('/api/explore/posts');

    final body = <String, dynamic>{
      'category': category,
      'content': content,
      'imageUrls': imageUrls,
    };

    // ignore: avoid_print
    print('[ExploreApi] POST $uri body=$body');

    final resp = await http.post(
      uri,
      headers: _api.socialHeaders(extra: {'Content-Type': 'application/json'}),
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'ExploreApi.createPost failed: ${resp.statusCode}\n${resp.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  // -------------------------
  // Toggle Like
  // POST /api/explore/posts/:id/like
  // return updated post json
  // -------------------------
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    final uri = _uri('/api/explore/posts/$postId/like');
    // ignore: avoid_print
    print('[ExploreApi] POST $uri');

    final resp = await http.post(
      uri,
      headers: _api.socialHeaders(),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'ExploreApi.toggleLike failed: ${resp.statusCode}\n${resp.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  // -------------------------
  // Comments List
  // GET /api/explore/posts/:id/comments?limit=20&cursor=...
  // return { items: [...], nextCursor: "..." | null }
  // -------------------------
  Future<Map<String, dynamic>> fetchComments({
    required String postId,
    int limit = 20,
    String? cursor,
  }) async {
    final q = <String, dynamic>{
      'limit': limit,
      if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
    };

    final uri = _uri('/api/explore/posts/$postId/comments', q);
    // ignore: avoid_print
    print('[ExploreApi] GET $uri');

    final resp = await http.get(
      uri,
      headers: _api.socialHeaders(),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'ExploreApi.fetchComments failed: ${resp.statusCode}\n${resp.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  // -------------------------
  // Create Comment
  // POST /api/explore/posts/:id/comments
  // body: { content }
  // return comment json
  // -------------------------
  Future<Map<String, dynamic>> createComment({
    required String postId,
    required String content,
  }) async {
    final uri = _uri('/api/explore/posts/$postId/comments');

    final body = <String, dynamic>{'content': content};

    // ignore: avoid_print
    print('[ExploreApi] POST $uri body=$body');

    final resp = await http.post(
      uri,
      headers: _api.socialHeaders(extra: {'Content-Type': 'application/json'}),
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'ExploreApi.createComment failed: ${resp.statusCode}\n${resp.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }
}
