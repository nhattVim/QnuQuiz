import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/providers/theme_provider.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

void _showThemeSelector(BuildContext context, WidgetRef ref) {
  final themeMode = ref.read(themeModeProvider);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Chọn giao diện"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Theo hệ thống"),
            trailing: themeMode == ThemeMode.system
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.system;
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Chế độ sáng"),
            trailing: themeMode == ThemeMode.light
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.light;
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Chế độ tối"),
            trailing: themeMode == ThemeMode.dark
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Text(
                "Cài đặt",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.h),

              // 🔥 Menu chuyển Theme
              ListTile(
                leading: const Icon(Icons.nightlight_round),
                title: const Text("Hiển thị (theme)"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeSelector(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
