import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/ranking_model.dart';
import 'package:frontend/widgets/ranking/ranking_list_item.dart';
import 'package:frontend/widgets/ranking/ranking_top_card.dart';

class RankingList extends StatefulWidget {
  final Future<List<RankingModel>> rankingFuture;
  final Function() onRefresh;

  const RankingList({
    super.key,
    required this.rankingFuture,
    required this.onRefresh,
  });

  @override
  State<RankingList> createState() => _RankingListState();
}

class _RankingListState extends State<RankingList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.expand(
      child: FutureBuilder<List<RankingModel>>(
        future: widget.rankingFuture,
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

          List<RankingModel> fullRanking = List.from(ranking);

          while (fullRanking.length < 6) {
            fullRanking.add(
              RankingModel(
                username: "-",
                score: 0,
                fullName: "-",
                avatarUrl:
                    "https://i.pinimg.com/736x/8f/1c/a2/8f1ca2029e2efceebd22fa05cca423d7.jpg",
              ),
            );
          }

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
                    widget.onRefresh();
                    await widget.rankingFuture;
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.only(bottom: 20.h),
                    separatorBuilder: (_, _) => SizedBox(height: 16.h),
                    itemCount: fullRanking.length > 3
                        ? fullRanking.length - 3
                        : 0,
                    itemBuilder: (context, index) {
                      final dataIndex = index + 3;
                      return RankingListItem(
                        rank: fullRanking[dataIndex],
                        index: dataIndex + 1,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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
}
