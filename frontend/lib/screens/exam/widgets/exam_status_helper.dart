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
    // CLOSED status
    if (exam.computedStatus == "closed") {
      // Nếu đã làm → show "Xem lại bài"
      if (exam.hasAttempt) {
        return "Xem lại bài";
      }
      // Nếu chưa làm → show "Chưa làm"
      return "Chưa làm";
    }

    // UNOPENED status
    if (exam.computedStatus == "unopened") {
      return "Chưa mở";
    }

    // ACTIVE status
    if (exam.computedStatus == "active") {
      // Nếu có unfinished attempt → show "Tiếp tục"
      if (exam.hasUnfinishedAttempt) {
        return "Tiếp tục";
      }
      // Nếu đã làm (submitted) → show "Xem lại bài"
      if (exam.hasAttempt) {
        return "Xem lại bài";
      }
      // Chưa làm → show "Bắt đầu làm"
      return "Bắt đầu làm";
    }

    return "Bắt đầu làm";
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

  static Color getButtonBgColor(ExamModel exam, BuildContext context) {
    switch (exam.computedStatus) {
      case "active":
        return Colors.blue;
      case "closed":
        return Theme.of(context).colorScheme.surface;
      default:
        return Colors.grey.shade400;
    }
  }

  static bool isButtonEnabled(ExamModel exam) {
    return exam.computedStatus == "active" || exam.computedStatus == "closed";
  }
}
