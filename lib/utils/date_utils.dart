class DateUtilsMadore {
  static String dayKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  static String todayKey() {
    return dayKey(DateTime.now());
  }
}