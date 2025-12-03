import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/service_providers.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<UserModel?> {
  late final UserService _userService;

  @override
  Future<UserModel?> build() async {
    _userService = ref.read(userServiceProvider);
    return _userService.getUser();
  }

  Future<void> setUser(UserModel user) async {
    await _userService.saveUser(user);
    state = AsyncData(user);
  }

  Future<void> clearUser() async {
    await _userService.clearUser();
    state = const AsyncData(null);
  }
}
