import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';


class UserService {
  static const _storage = FlutterSecureStorage();
  Future<void> clearUser() async {
    await _storage.delete(key: 'user');
  }

  Future<UserModel?> getUser() async {
    final data = await _storage.read(key: 'user');
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
  }
}
