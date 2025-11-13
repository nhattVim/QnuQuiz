import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/screens/exam_detail_screen.dart';
import 'package:frontend/services/exam_service.dart';
import 'package:intl/intl.dart';

final DateFormat formatterDay = DateFormat('dd');
final DateFormat formatterFull = DateFormat('dd/MM/yyyy');

class MyExamPage extends StatefulWidget {
  const MyExamPage({super.key});

  @override
  State<MyExamPage> createState() => _MyExamPageState();
}

class _MyExamPageState extends State<MyExamPage> {
  final _examService = ExamService();
  final bool _sort = true;
  late Future<List<ExamModel>> _examsFuture;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: SafeArea(
        child: Column(
          children: [
            Text(
              "Tạo bộ câu hỏi",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20.sp),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Nhập bộ câu hỏi"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Xuất bộ câu hỏi"),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Text(
                  "Bộ câu hỏi của tôi",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _examsFuture = _examService.getExamsByUserId(!_sort);
                  },
                  icon: const Icon(Icons.sort),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: FutureBuilder<List<ExamModel>>(
                future: _examsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có bộ câu hỏi nào'));
                  }

                  final exams = snapshot.data!;

                  return ListView.separated(
                    itemCount: exams.length,
                    separatorBuilder: (_, _) => SizedBox(height: 20.h),
                    itemBuilder: (context, index) {
                      final exam = exams[index];

                      final Color statusColor = exam.status == "ACTIVE"
                          ? Colors.green.shade600
                          : exam.status == "CLOSED"
                          ? Colors.red
                          : Colors.grey;

                      final String statusText = exam.status == "ACTIVE"
                          ? "Đang mở"
                          : exam.status == "CLOSED"
                          ? "Đang đóng"
                          : "Bản nháp";

                      String dateRangeText = "N/A";
                      if (exam.startTime != null && exam.endTime != null) {
                        dateRangeText =
                            '${formatterDay.format(exam.startTime!)} - ${formatterFull.format(exam.endTime!)}';
                      }

                      return InkWell(
                        onTap: () async {
                          final updatedExam = await Navigator.push<ExamModel>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExamDetailScreen(exam: exam),
                            ),
                          );

                          if (updatedExam != null) {
                            setState(() {
                              exams[index] = updatedExam;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        hoverColor: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// LEFT SIDE
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exam.title,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6.h),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 12.sp),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '${exam.durationMinutes ?? 0} phút',
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 12.sp,
                                            color: statusColor,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            statusText,
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                /// RIGHT SIDE
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.more_horiz),
                                    Text(
                                      dateRangeText,
                                      style: TextStyle(fontSize: 12.sp),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _examsFuture = _examService.getExamsByUserId(_sort);
  }
}
