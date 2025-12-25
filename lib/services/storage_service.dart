// lib/services/storage_service.dart
class StorageService {
  StorageService._internal();
  static final StorageService instance = StorageService._internal();

  final Map<String, Object?> _memory = {};

  Future<void> write(String key, Object? value) async {
    _memory[key] = value;
  }

  Future<Object?> read(String key) async {
    return _memory[key];
  }
}

