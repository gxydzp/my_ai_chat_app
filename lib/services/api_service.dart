// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class LoggingClient extends http.BaseClient {
  final http.Client _inner;
  LoggingClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    debugPrint('[HTTP] --> ${request.method} ${request.url}');
    request.headers.forEach((k, v) => debugPrint('[HTTP] hdr $k: $v'));

    if (request is http.Request) {
      debugPrint('[HTTP] body: ${request.body}');
    }

    try {
      final resp = await _inner.send(request);
      debugPrint('[HTTP] <-- ${resp.statusCode} ${request.url}');
      return resp;
    } catch (e) {
      debugPrint('[HTTP] xx  ERROR ${request.url}  $e');
      rethrow;
    }
  }
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();
  final http.Client _client = LoggingClient(http.Client());

  /// ✅ 聊天后端（情绪助手）
  final String chatBaseUrl = 'http://192.3.135.106:3000';

  /// ✅ 生图后端（独立工程 chat_image_backend）
  final String imageBaseUrl = 'http://192.3.135.106:3001';

  /// ✅ 社交后端（Explore + Prisma）
  final String socialBaseUrl = 'http://192.3.135.106:3002';

  /// 开发阶段：先写死一个“当前用户”，后面你可以接 StorageService / 登录
  String viewerId = 'u_test_001';
  String viewerName = 'test_user';

  Map<String, String> socialHeaders({Map<String, String>? extra}) {
    return <String, String>{
      'x-user-id': viewerId,
      'x-user-name': viewerName,
      if (extra != null) ...extra,
    };
  }

  // =========================
  // Utils
  // =========================

  /// 把后端返回的 publicUrl/url 统一转换为可直接访问的完整 URL
  String toAbsoluteImageUrl(String? urlOrPublicUrl) {
    final v = (urlOrPublicUrl ?? '').trim();
    if (v.isEmpty) return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    // 兼容 publicUrl = "/generated/xxx.png"
    if (v.startsWith('/')) return '$imageBaseUrl$v';
    return '$imageBaseUrl/$v';
  }

  List<Map<String, dynamic>> _normalizeItems(dynamic data) {
    final List items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['items'] is List) {
      items = data['items'] as List;
    } else {
      items = <dynamic>[];
    }

    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // =========================
  // Chat APIs (3000)
  // =========================

  Future<List<Map<String, dynamic>>> fetchPromptgrams() async {
    final uri = Uri.parse('$chatBaseUrl/api/promptgrams');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
          'fetchPromptgrams failed: ${resp.statusCode}\n${resp.body}');
    }

    final data = jsonDecode(resp.body);
    return _normalizeItems(data);
  }

  /// 返回：{ sessionId: "...", reply: "..." }
  Future<Map<String, dynamic>> startChat({required String promptgramId}) async {
    final uri = Uri.parse('$chatBaseUrl/api/chat/start');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'promptgramId': promptgramId}),
    );

    if (resp.statusCode != 200) {
      throw Exception('startChat failed: ${resp.statusCode}\n${resp.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  Future<String> sendChat({
    required String sessionId,
    required String message,
    List<Map<String, dynamic>>? history, // 后端支持才传
  }) async {
    final uri = Uri.parse('$chatBaseUrl/api/chat');

    final body = <String, dynamic>{
      'sessionId': sessionId,
      'message': message,
    };
    if (history != null && history.isNotEmpty) body['history'] = history;

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('sendChat failed: ${resp.statusCode}\n${resp.body}');
    }
    final data = jsonDecode(resp.body);
    return (data['reply'] ?? '').toString();
  }

  // =========================
  // Image APIs (3001)
  // =========================

  /// 返回：{ items: [ {filename, url, publicUrl}, ... ] }
  /// 我这里会额外确保每个 item 都有一个可直接访问的 url 字段
  Future<List<Map<String, dynamic>>> fetchReferenceList() async {
    final uri = Uri.parse('$imageBaseUrl/api/reference/list');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
          'fetchReferenceList failed: ${resp.statusCode}\n${resp.body}');
    }

    final data = jsonDecode(resp.body);
    final items = _normalizeItems(data);

    for (final it in items) {
      final url = (it['url'] ?? it['publicUrl'] ?? '').toString();
      it['url'] = toAbsoluteImageUrl(url);
    }
    return items;
  }

  /// 返回：{ filename, url, publicUrl }
  /// 我这里确保返回里一定有可访问的 url
  Future<Map<String, dynamic>> pickRandomReference() async {
    final uri = Uri.parse('$imageBaseUrl/api/reference/random');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
          'pickRandomReference failed: ${resp.statusCode}\n${resp.body}');
    }

    final data = Map<String, dynamic>.from(jsonDecode(resp.body));
    final url = (data['url'] ?? data['publicUrl'] ?? '').toString();
    data['url'] = toAbsoluteImageUrl(url);
    return data;
  }

  /// 返回：后端你现在 server.js 里是 res.json({ ...result, url: fullUrl })
  /// 所以这里会把 url/publicUrl 都做一次兜底，确保 imageUrl 可直接用 Image.network
  Future<Map<String, dynamic>> generateImage({
    required String prompt,
    String? referenceImageUrl,
  }) async {
    final uri = Uri.parse('$imageBaseUrl/api/image/generate');

    final body = <String, dynamic>{
      'prompt': prompt.trim(),
      // 注意：只在有值时才传，避免传 null
      if (referenceImageUrl != null && referenceImageUrl.trim().isNotEmpty)
        'referenceImageUrl': referenceImageUrl.trim(),
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('generateImage failed: ${resp.statusCode}\n${resp.body}');
    }

    final data = Map<String, dynamic>.from(jsonDecode(resp.body));

    // 兜底：如果后端只给 publicUrl，就拼成完整 url
    final url = (data['url'] ?? data['publicUrl'] ?? '').toString();
    data['url'] = toAbsoluteImageUrl(url);

    return data;
  }

// =========================
// Social / Explore APIs (3002)
// =========================

  Uri _socialUri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(socialBaseUrl);
    final uri = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.port,
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
    return uri;
  }

  /// 用于快速验证：App 到 3002 是否可达
  Future<Map<String, dynamic>> socialHealth() async {
    final uri = _socialUri('/health');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('socialHealth failed: ${resp.statusCode}\n${resp.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  /// GET /api/explore/feed?category=galaxy&limit=10&cursor=...
  /// 返回：{ items: [...], nextCursor: "..." }
  Future<Map<String, dynamic>> fetchExploreFeed({
    required String category, // "galaxy" | "station" | "planet"
    int limit = 10,
    String? cursor,
  }) async {
    final query = <String, dynamic>{
      'category': category,
      'limit': limit,
      if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
    };

    final uri = _socialUri('/api/explore/feed', query);

    // 关键：打印一下最终 URL，确认确实在打 3002
    // ignore: avoid_print
    print('[ApiService] GET $uri');

    final resp = await http.get(
      uri,
      headers: socialHeaders(),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'fetchExploreFeed failed: ${resp.statusCode}\n${resp.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  /// POST /api/explore/posts
  /// body: { category: "galaxy", content: "...", imageUrls: [] }
  Future<Map<String, dynamic>> createExplorePost({
    required String category,
    required String content,
    List<String> imageUrls = const [],
  }) async {
    final uri = _socialUri('/api/explore/posts');

    final body = <String, dynamic>{
      'category': category,
      'content': content,
      'imageUrls': imageUrls,
    };

    // ignore: avoid_print
    print('[ApiService] POST $uri body=$body');

    final resp = await http.post(
      uri,
      headers: socialHeaders(extra: {'Content-Type': 'application/json'}),
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'createExplorePost failed: ${resp.statusCode}\n${resp.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  /// POST /api/explore/posts/:id/like  (toggle)
  Future<Map<String, dynamic>> toggleExploreLike(String postId) async {
    final uri = _socialUri('/api/explore/posts/$postId/like');

    // ignore: avoid_print
    print('[ApiService] POST $uri');

    final resp = await http.post(
      uri,
      headers: socialHeaders(),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'toggleExploreLike failed: ${resp.statusCode}\n${resp.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  /// GET /api/explore/posts/:id/comments?limit=20&cursor=...
  /// 返回：{ items: [...], nextCursor: "..." }
  Future<Map<String, dynamic>> fetchPostComments({
    required String postId,
    int limit = 20,
    String? cursor,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
    };

    final uri = _socialUri('/api/explore/posts/$postId/comments', query);

    // ignore: avoid_print
    print('[ApiService] GET $uri');

    final resp = await http.get(
      uri,
      headers: socialHeaders(),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'fetchPostComments failed: ${resp.statusCode}\n${resp.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  /// POST /api/explore/posts/:id/comments
  /// body: { content: "..." }
  Future<Map<String, dynamic>> createPostComment({
    required String postId,
    required String content,
  }) async {
    final uri = _socialUri('/api/explore/posts/$postId/comments');

    final body = <String, dynamic>{'content': content};

    // ignore: avoid_print
    print('[ApiService] POST $uri body=$body');

    final resp = await http.post(
      uri,
      headers: socialHeaders(extra: {'Content-Type': 'application/json'}),
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'createPostComment failed: ${resp.statusCode}\n${resp.body}');
    }
    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }

  // =========================
  // Social Ping (3002)
  // =========================

  /// 最小可用探针：请求一次 explore feed，确认 App -> 3002 可达
  Future<Map<String, dynamic>> socialPing() async {
    final uri =
        Uri.parse('$socialBaseUrl/api/explore/feed?category=galaxy&limit=1');

    debugPrint('[ApiService] socialPing GET $uri');

    final resp = await http.get(uri, headers: socialHeaders());

    debugPrint('[ApiService] socialPing status=${resp.statusCode}');
    debugPrint('[ApiService] socialPing body=${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('socialPing failed: ${resp.statusCode}\n${resp.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(resp.body));
  }
}
