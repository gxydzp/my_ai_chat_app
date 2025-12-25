// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  // 初始默认用户
  UserProfile _profile = const UserProfile(
    id: 'me',
    name: '你',
  );

  // 对外只读
  UserProfile get profile => _profile;

  // 修改名字
  void setName(String name) {
    _profile = UserProfile(
      id: _profile.id,
      name: name,
    );
    notifyListeners();
  }
}


