import 'package:flutter/material.dart';
import 'package:frontend/models/exam_model.dart';

class ExamStatusUI {
  static Color getColor(ExamModel exam) {
    switch (exam.computedStatus) {
      case "active":
        return Colors.green;
      case "unopened":
        return Colors.orange;
      case "closed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getText(ExamModel exam) {
    switch (exam.computedStatus) {
      case "active":
        return "Đang mở";
      case "unopened":
        return "Chưa mở";
      case "closed":
        return "Đã đóng";
      default:
        return "";
    }
  }

  static String getButtonText(ExamModel exam) {
    switch (exam.computedStatus) {
      case "active":
        return "Bắt đầu làm";
      case "unopened":
        return "Chưa mở";
      case "closed":
        return "Xem lại bài";
      default:
        return "";
    }
  }

  static Color getButtonTextColor(ExamModel exam) {
    switch (exam.computedStatus) {
      case "active":
        return Colors.white;
      case "closed":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static Color getButtonBgColor(ExamModel exam) {
    switch (exam.computedStatus) {
      case "active":
        return Colors.blue;
      case "closed":
        return const Color(0xFFF2F3F2);
      default:
        return Colors.grey.shade400;
    }
  }

  static bool isButtonEnabled(ExamModel exam) {
    return exam.computedStatus == "active" || exam.computedStatus == "closed";
  }
}
