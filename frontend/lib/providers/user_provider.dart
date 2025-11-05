import 'package:flutter_riverpod/legacy.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final user = await UserService().getUser();
    state = user;
  }

  void setUser(UserModel user) async {
    await UserService().saveUser(user);
    state = user;
  }

  Future<void> clearUser() async {
    await UserService().clearUser();
    state = null;
  }
}
