extension DateFormatExt on DateTime {
  String toTimeString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String toDateString() {
    final d = day.toString().padLeft(2, '0');
    final mo = month.toString().padLeft(2, '0');
    final y = year.toString();
    return "$d/$mo/$y";
  }

  String toFullString() {
    return "${toTimeString()} • ${toDateString()}";
  }
}
