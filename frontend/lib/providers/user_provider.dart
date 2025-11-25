import 'package:flutter_riverpod/legacy.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<UserModel?> {
  final _userService = UserService();

  UserNotifier() : super(null) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final user = await _userService.getUser();
    state = user;
  }

  void setUser(UserModel user) async {
    await _userService.saveUser(user);
    state = user;
  }

  Future<void> clearUser() async {
    await _userService.clearUser();
    state = null;
  }
}
