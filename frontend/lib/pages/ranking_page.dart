import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/services/analytics_service.dart';
import 'package:frontend/widgets/ranking/custom_sliding_control.dart';
import 'package:frontend/widgets/ranking/ranking_list_item.dart';
import 'package:frontend/widgets/ranking/ranking_top_card.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final _analyticsService = AnalyticsService();
  bool isWeeklySelected = true;
  late Future<List<RankingModel>> _rankingFuture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Text(
                "Bảng xếp hạng",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.h),

              CustomSlidingSegmentedControl(
                isLeftSelected: isWeeklySelected,
                leftText: "Tuần này",
                rightText: "Tất cả",
                onChanged: (isLeft) {
                  if (isWeeklySelected != isLeft) {
                    setState(() {
                      isWeeklySelected = isLeft;
                      _loadData();
                    });
                  }
                },
              ),

              SizedBox(height: 24.h),

              Expanded(
                child: FutureBuilder<List<RankingModel>>(
                  future: _rankingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Lỗi: ${snapshot.error}',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 64.sp,
                              color: theme.disabledColor,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Không có bảng xếp hạng',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final ranking = snapshot.data!;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ranking.length > 1
                                  ? RankingTopCard(rank: ranking[1], index: 2)
                                  : _buildEmptyTopCard(2),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: ranking.isNotEmpty
                                  ? RankingTopCard(rank: ranking[0], index: 1)
                                  : _buildEmptyTopCard(1),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: ranking.length > 2
                                  ? RankingTopCard(rank: ranking[2], index: 3)
                                  : _buildEmptyTopCard(3),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                _loadData();
                              });
                              await _rankingFuture;
                            },
                            child: ListView.separated(
                              padding: EdgeInsets.only(bottom: 20.h),
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: 16.h),
                              // itemCount: ranking.length > 3
                              //     ? ranking.length - 3
                              //     : 0,
                              // itemBuilder: (context, index) {
                              //   final dataIndex = index + 3;
                              //   return RankingListItem(
                              //     rank: ranking[dataIndex],
                              //     index: dataIndex + 1,
                              //   );
                              // },
                              itemCount: ranking.length,
                              itemBuilder: (context, index) {
                                return RankingListItem(
                                  rank: ranking[index],
                                  index: index + 1,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Widget _buildEmptyTopCard(int index) {
    return RankingTopCard(
      rank: RankingModel(
        username: "-",
        score: 0,
        fullName: "-",
        avatarUrl:
            "https://i.pinimg.com/736x/8f/1c/a2/8f1ca2029e2efceebd22fa05cca423d7.jpg",
      ),
      index: index,
    );
  }

  void _loadData() {
    _rankingFuture = isWeeklySelected
        ? _analyticsService.getRankingAllThisWeek()
        : _analyticsService.getRankingAll();
  }
}
