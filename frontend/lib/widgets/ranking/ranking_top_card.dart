import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/ranking_model.dart';

class RankingTopCard extends StatelessWidget {
  final RankingModel rank;
  final int index;

  const RankingTopCard({super.key, required this.rank, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isFirst = index == 1;
    final double avatarSize = isFirst ? 80.r : 60.r;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFirst
                      ? const Color(0xFFFFD700)
                      : theme.colorScheme.primary,
                  width: 3,
                ),
                boxShadow: [
                  if (isFirst)
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  rank.avatarUrl ?? "https://i.pravatar.cc/150",
                ),
              ),
            ),
            Positioned(
              bottom: -6.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isFirst
                      ? const Color(0xFFFFD700)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "#$index",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isFirst ? Colors.black : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          rank.fullName ?? "Unknown",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isFirst ? 16.sp : 14.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          "${rank.score ?? 0}",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
