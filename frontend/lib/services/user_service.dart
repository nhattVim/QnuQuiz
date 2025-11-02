import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/user_model.dart';

const _storage = FlutterSecureStorage();

class UserService {
  Future<UserModel?> getUser() async {
    final data = await _storage.read(key: 'user');
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
  }
}
