// lib/providers/image_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 内部使用：一个风格 / 图库选项（对应后端 /api/image/styles 的一项）
class ImageStyleOption {
  final String id;
  final String label;
  final String referenceLibraryId;

  ImageStyleOption({
    required this.id,
    required this.label,
    required this.referenceLibraryId,
  });

  factory ImageStyleOption.fromJson(Map<String, dynamic> json) {
    return ImageStyleOption(
      id: json['id'] as String,
      label: (json['label'] as String?) ?? (json['id'] as String),
      referenceLibraryId:
          (json['referenceLibraryId'] as String?) ?? (json['id'] as String),
    );
  }
}

/// 注意：不要命名成 ImageProvider，会和 Flutter 自带类型重名
class ImageGenProvider extends ChangeNotifier {
  final String imageBaseUrl;
  ImageGenProvider({this.imageBaseUrl = 'http://192.3.135.106:3001'});

  bool _isLoading = false;
  String? _error;

  /// 随机参考图（绝对 URL）
  String? _referenceUrl;

  /// 生成结果图（绝对 URL）
  String? _generatedUrl;

  /// 风格 / 图库列表
  List<ImageStyleOption> _styles = [];
  String? _selectedStyleId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get referenceUrl => _referenceUrl;
  String? get generatedUrl => _generatedUrl;

  List<ImageStyleOption> get styles => _styles;
  String? get selectedStyleId => _selectedStyleId;
  ImageStyleOption? get selectedStyle {
    if (_selectedStyleId == null) return null;
    try {
      return _styles.firstWhere((s) => s.id == _selectedStyleId);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _referenceUrl = null;
    _generatedUrl = null;
    // 不清空 _styles，风格列表只需加载一次
    notifyListeners();
  }

  // -------------------------
  // Helpers
  // -------------------------

  String _toAbsoluteUrl(String url) {
    final u = url.trim();
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    if (u.startsWith('/')) return '$imageBaseUrl$u';
    return '$imageBaseUrl/$u';
  }

  /// 尽可能从后端返回里“抓到一个能用的图片 URL”
  String? _extractImageUrl(Map<String, dynamic> obj) {
    final candidates = <dynamic>[
      obj['url'],
      obj['imageUrl'], // /api/generate-image
      obj['publicUrl'],
      obj['referenceImageUrl'],
      obj['generatedUrl'],
    ];

    for (final c in candidates) {
      final s = (c ?? '').toString().trim();
      if (s.isNotEmpty) return _toAbsoluteUrl(s);
    }
    return null;
  }

  Exception _httpErr(String tag, http.Response resp) {
    return Exception('$tag failed: ${resp.statusCode}\n${resp.body}');
  }

  // -------------------------
  // 拉取风格 / 图库列表
  // GET /api/image/styles
  // -------------------------

  Future<void> loadStylesIfNeeded() async {
    if (_styles.isNotEmpty || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$imageBaseUrl/api/image/styles');
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw _httpErr('fetchImageStyles', resp);
      }

      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;

      final List<dynamic> list = data['items'] as List<dynamic>? ?? [];
      _styles = list
          .map((e) => ImageStyleOption.fromJson(e as Map<String, dynamic>))
          .toList();

      if (_styles.isNotEmpty && _selectedStyleId == null) {
        _selectedStyleId = _styles.first.id;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 选择某个风格 / 图库
  void selectStyle(String styleId) {
    _selectedStyleId = styleId;
    // 切换图库时，清空当前参考图
    _referenceUrl = null;
    notifyListeners();
  }

  // -------------------------
  // API: random reference
  // -------------------------

  /// GET /api/reference/random
  /// 根据当前选中的风格，把它绑定的 referenceLibraryId
  /// 作为 ?libraryId=xxx 传给后端
  Future<void> fetchRandomReference() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final style = selectedStyle;
      late final Uri uri;

      if (style != null && style.referenceLibraryId.isNotEmpty) {
        final lib = Uri.encodeQueryComponent(style.referenceLibraryId);
        uri = Uri.parse('$imageBaseUrl/api/reference/random?libraryId=$lib');
      } else {
        uri = Uri.parse('$imageBaseUrl/api/reference/random');
      }

      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw _httpErr('fetchRandomReference', resp);
      }

      final Map<String, dynamic> obj =
          jsonDecode(resp.body) as Map<String, dynamic>;

      final url = _extractImageUrl(obj);
      if (url == null) {
        throw Exception('reference url is empty (no url/publicUrl)');
      }

      _referenceUrl = url;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------
  // API: generate image
  // -------------------------

  /// 优先 POST /api/image/generate  (body: {prompt, referenceImageUrl?})
  /// 回退 POST /api/generate-image  (body: {answers: [...]})
  Future<void> generateImage({
    required String prompt,
    bool useReferenceIfExists = true,
  }) async {
    final p = prompt.trim();
    if (p.isEmpty || _isLoading) return;

    _isLoading = true;
    _error = null;
    _generatedUrl = null;
    notifyListeners();

    try {
      // 1) 先走 /api/image/generate
      final uri1 = Uri.parse('$imageBaseUrl/api/image/generate');

      final body1 = <String, dynamic>{'prompt': p};
      if (useReferenceIfExists &&
          _referenceUrl != null &&
          _referenceUrl!.trim().isNotEmpty) {
        body1['referenceImageUrl'] = _referenceUrl;
      }

      final resp1 = await http.post(
        uri1,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body1),
      );

      if (resp1.statusCode == 200) {
        final Map<String, dynamic> obj =
            jsonDecode(resp1.body) as Map<String, dynamic>;
        final url = _extractImageUrl(obj);
        if (url == null) {
          throw Exception(
              'generated image url is empty (no url/publicUrl/imageUrl)');
        }
        _generatedUrl = url;
        return;
      }

      // 2) 如果 404/405 说明后端没这个路由：回退到 /api/generate-image
      if (resp1.statusCode == 404 || resp1.statusCode == 405) {
        final uri2 = Uri.parse('$imageBaseUrl/api/generate-image');

        // 老逻辑要求 answers 数组，这里用 prompt 当单个答案兜底
        final body2 = <String, dynamic>{
          'answers': [p],
        };

        final resp2 = await http.post(
          uri2,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body2),
        );

        if (resp2.statusCode != 200) {
          throw _httpErr('generateImage(fallback /api/generate-image)', resp2);
        }

        final Map<String, dynamic> obj2 =
            jsonDecode(resp2.body) as Map<String, dynamic>;
        final url = _extractImageUrl(obj2);
        if (url == null) {
          throw Exception(
              'generated image url is empty (fallback response has no imageUrl/url/publicUrl)');
        }
        _generatedUrl = url;
        return;
      }

      // 3) 其它状态码：直接抛错（带 body）
      throw _httpErr('generateImage(/api/image/generate)', resp1);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
