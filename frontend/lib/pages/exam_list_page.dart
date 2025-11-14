import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  String? selectedTopic;
  DateTime? selectedDate;
  bool showPracticeMode = false;

  final exams = [
    {"title": "Math Test", "topic": "Toán", "date": "2025-11-20"},
    {"title": "Physics Quiz", "topic": "Vật lý", "date": "2025-11-22"},
    {"title": "English Exam", "topic": "Tiếng Anh", "date": "2025-11-25"},
    {"title": "Bài kiểm tra cố định", "topic": "Chung", "date": "2025-11-30"},
  ];

  final topics = ["Toán", "Vật lý", "Tiếng Anh", "Chung"];

  List<Map<String, String>> get filteredExams {
    return exams.where((exam) {
      final examDate = DateTime.parse(exam["date"]!);

      final matchTopic =
          selectedTopic == null || exam["topic"] == selectedTopic;
      final matchDate =
          selectedDate == null ||
          (examDate.year == selectedDate!.year &&
              examDate.month == selectedDate!.month &&
              examDate.day == selectedDate!.day);

      return matchTopic && matchDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (showPracticeMode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Chọn chủ đề luyện tập"),
          backgroundColor: Colors.blue.shade600,
          elevation: 4,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(
                          vertical: 6.h, horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: selectedTopic == topic
                            ? Colors.blue.shade400
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(Icons.topic,
                            color: selectedTopic == topic
                                ? Colors.white
                                : Colors.blue.shade600),
                        title: Text(
                          topic,
                          style: TextStyle(
                            color: selectedTopic == topic
                                ? Colors.white
                                : Colors.blue.shade800,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => setState(() => selectedTopic = topic),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade300,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 20.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () => setState(() => showPracticeMode = false),
                      child: const Text("Quay lại"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 20.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: selectedTopic == null
                          ? null
                          : () {
                              // TODO: chuyển sang màn luyện tập
                            },
                      child: const Text("Bắt đầu"),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách bài kiểm tra"),
        backgroundColor: Colors.blue.shade700,
        elevation: 6,
      ),
      body: Column(
        children: [
          // Bộ lọc
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Chủ đề",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedTopic,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text("Tất cả")),
                      ...topics.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t),
                          ))
                    ],
                    onChanged: (value) {
                      setState(() => selectedTopic = value);
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(selectedDate == null
                        ? "Chọn ngày"
                        : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}"),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: filteredExams.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final exam = filteredExams[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading:
                          const Icon(Icons.assignment_rounded, color: Colors.white),
                      title: Text(
                        exam["title"]!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      subtitle: Text(
                        "Ngày: ${exam["date"]}",
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded,
                          size: 16.sp, color: Colors.white),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => showPracticeMode = true),
        label: const Text("Luyện tập"),
        icon: const Icon(Icons.flash_on_rounded),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 12,
      ),
    );
  }
}