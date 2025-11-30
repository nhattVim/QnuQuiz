import 'package:flutter/material.dart';

class AsyncDataBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  const AsyncDataBuilder({
    super.key,
    required this.future,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lỗi tải dữ liệu',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData ||
            (snapshot.data is List && (snapshot.data as List).isEmpty)) {
          return Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return builder(snapshot.data as T);
      },
    );
  }
}
