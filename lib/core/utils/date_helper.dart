class DateHelper {
  // Haftanın başlangıcını (Pazartesi) döndürür
  static DateTime getWeekStart(DateTime date) {
    int weekday = date.weekday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: weekday - 1));
  }

  // Haftanın sonunu (Pazar) döndürür
  static DateTime getWeekEnd(DateTime date) {
    int weekday = date.weekday;
    return DateTime(date.year, date.month, date.day)
        .add(Duration(days: 7 - weekday));
  }

  // Hafta aralığı string'i (örn: "15-21 Ekim 2025")
  static String getWeekRangeString(DateTime weekStart) {
    DateTime weekEnd = weekStart.add(const Duration(days: 6));

    String monthName = _getMonthName(weekStart.month);

    if (weekStart.month == weekEnd.month) {
      return "${weekStart.day}-${weekEnd.day} $monthName ${weekStart.year}";
    } else {
      String endMonthName = _getMonthName(weekEnd.month);
      return "${weekStart.day} $monthName - ${weekEnd.day} $endMonthName ${weekStart.year}";
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[month - 1];
  }

  // Tarih aynı haftada mı?
  static bool isSameWeek(DateTime date1, DateTime date2) {
    DateTime week1Start = getWeekStart(date1);
    DateTime week2Start = getWeekStart(date2);
    return week1Start.isAtSameMomentAs(week2Start);
  }
}
