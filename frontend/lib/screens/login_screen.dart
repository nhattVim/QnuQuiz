import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/link_text.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _rememberMe = false;
  bool _isLoadingCredentials = true;

  static const String _keyRememberUsername = 'remember_username';
  static const String _keyRememberPassword = 'remember_password';
  static const String _keyRememberMe = 'remember_me';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    _studentIdFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
      
      if (rememberMe) {
        final savedUsername = prefs.getString(_keyRememberUsername);
        final savedPassword = prefs.getString(_keyRememberPassword);
        
        if (savedUsername != null && savedPassword != null) {
          setState(() {
            _rememberMe = true;
            _studentIdController.text = savedUsername;
            _passwordController.text = savedPassword;
            _isLoadingCredentials = false;
          });
          return;
        }
      }
      
      setState(() {
        _isLoadingCredentials = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCredentials = false;
      });
    }
  }

  Future<void> _saveCredentials() async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyRememberMe, true);
      await prefs.setString(_keyRememberUsername, _studentIdController.text.trim());
      await prefs.setString(_keyRememberPassword, _passwordController.text);
    } else {
      await _clearSavedCredentials();
    }
  }

  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyRememberUsername);
    await prefs.remove(_keyRememberPassword);
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await ref
        .read(authProvider.notifier)
        .login(_studentIdController.text.trim(), _passwordController.text);
    
    // Nếu đăng nhập thành công, lưu thông tin nếu đã check "Nhớ mật khẩu"
    if (result) {
      await _saveCredentials();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userAsyncValue = ref.watch(userProvider);
    
    // Show loading indicator while loading saved credentials
    if (_isLoadingCredentials) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Auto redirect after login
    if (authState == AuthState.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          userAsyncValue.when(
            data: (user) {
              if (user != null) {
                if (user.role == 'ADMIN') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tài khoản quản trị không thể truy cập trang này',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  ref.read(authProvider.notifier).logout();
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }
              }
            },
            loading: () {},
            error: (err, stack) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Lỗi tải thông tin người dùng. Vui lòng đăng nhập lại.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              ref.read(authProvider.notifier).logout();
            },
          );
        }
      });
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: SvgPicture.asset(
                    'assets/images/login.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 40.h),

                // Title
                Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),

                // Student ID
                TextFormField(
                  controller: _studentIdController,
                  focusNode: _studentIdFocus,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v!.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: Icon(Icons.person_outline, size: 20.sp),
                  ),
                ),
                SizedBox(height: 20.h),

                // Password
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  validator: (v) =>
                      v!.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
                  ),
                ),
                SizedBox(height: 16.h),

                // Remember Me + Forgot Password
                Row(
                  children: [
                    _buildRememberMe(),
                    const Spacer(),
                    LinkText(
                      text: 'Quên mật khẩu?',
                      onPressed: () {
                        // TODO: Navigate
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: authState == AuthState.loading
                        ? null
                        : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: authState == AuthState.loading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        setState(() => _rememberMe = !_rememberMe);
        // Nếu uncheck, xóa thông tin đã lưu
        if (!_rememberMe) {
          await _clearSavedCredentials();
        }
      },
      borderRadius: BorderRadius.circular(4.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: Checkbox(
              value: _rememberMe,
              onChanged: (v) async {
                setState(() => _rememberMe = v ?? false);
                // Nếu uncheck, xóa thông tin đã lưu
                if (!_rememberMe) {
                  await _clearSavedCredentials();
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              activeColor: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Nhớ mật khẩu',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
