import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    _studentIdFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_studentIdController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Auto redirect after login
    if (authState == AuthState.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      });
    }

    // Display error
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next == AuthState.error && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
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
                  child: Image.asset(
                    'assets/images/login.png',
                    width: 280.w,
                    height: 280.h,
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
                    color: Colors.black87,
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
                SizedBox(height: 24.h),

                // Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                    LinkText(
                      text: 'Đăng ký',
                      onPressed: () {
                        // TODO: Navigate
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    return InkWell(
      onTap: () => setState(() => _rememberMe = !_rememberMe),
      borderRadius: BorderRadius.circular(4.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: Checkbox(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              activeColor: Colors.blue,
            ),
          ),
          SizedBox(width: 8.w),
          Text('Nhớ mật khẩu', style: TextStyle(fontSize: 14.sp)),
        ],
      ),
    );
  }
}
