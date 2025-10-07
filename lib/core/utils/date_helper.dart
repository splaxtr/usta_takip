import 'package:intl/intl.dart';

/// Tarih ve zaman işlemleri için yardımcı sınıf
class DateHelper {
  DateHelper._();

  // Tarih formatları
  static const String defaultDateFormat = 'dd.MM.yyyy';
  static const String defaultTimeFormat = 'HH:mm';
  static const String defaultDateTimeFormat = 'dd.MM.yyyy HH:mm';
  static const String fullDateFormat = 'dd MMMM yyyy, EEEE';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String dayMonthFormat = 'dd MMMM';
  static const String shortDateFormat = 'dd/MM/yy';
  static const String isoDateFormat = 'yyyy-MM-dd';
  static const String isoDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss';

  /// Tarih formatını string'e çevir
  ///
  /// Örnek: formatDate(DateTime.now()) -> "06.10.2025"
  static String formatDate(
    DateTime? date, {
    String format = defaultDateFormat,
    String locale = 'tr_TR',
  }) {
    if (date == null) return '';
    return DateFormat(format, locale).format(date);
  }

  /// Saat formatını string'e çevir
  ///
  /// Örnek: formatTime(DateTime.now()) -> "14:30"
  static String formatTime(
    DateTime? date, {
    String format = defaultTimeFormat,
    String locale = 'tr_TR',
  }) {
    if (date == null) return '';
    return DateFormat(format, locale).format(date);
  }

  /// Tarih ve saat formatını string'e çevir
  ///
  /// Örnek: formatDateTime(DateTime.now()) -> "06.10.2025 14:30"
  static String formatDateTime(
    DateTime? date, {
    String format = defaultDateTimeFormat,
    String locale = 'tr_TR',
  }) {
    if (date == null) return '';
    return DateFormat(format, locale).format(date);
  }

  /// String'i DateTime'a çevir
  ///
  /// Örnek: parseDate("06.10.2025", "dd.MM.yyyy")
  static DateTime? parseDate(String? dateString, String format) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Tarihi göreceli formatta göster (bugün, dün, yarın, vb.)
  ///
  /// Örnek: "Bugün", "Dün", "2 gün önce", "3 gün sonra"
  static String getRelativeDate(DateTime? date, {String locale = 'tr_TR'}) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Bugün';
    } else if (difference == 1) {
      return 'Yarın';
    } else if (difference == -1) {
      return 'Dün';
    } else if (difference > 1 && difference <= 7) {
      return '$difference gün sonra';
    } else if (difference < -1 && difference >= -7) {
      return '${difference.abs()} gün önce';
    } else {
      return formatDate(date, format: defaultDateFormat, locale: locale);
    }
  }

  /// Zamanı göreceli formatta göster
  ///
  /// Örnek: "Az önce", "5 dakika önce", "2 saat önce", "Dün"
  static String getRelativeTime(DateTime? date, {String locale = 'tr_TR'}) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      if (difference.inDays == 1) {
        return 'Dün';
      }
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    }
  }

  /// İki tarih arasındaki farkı hesapla
  ///
  /// Örnek: getDaysBetween(date1, date2) -> 5
  static int getDaysBetween(DateTime? from, DateTime? to) {
    if (from == null || to == null) return 0;

    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);

    return toDate.difference(fromDate).inDays;
  }

  /// Belirtilen tarihin başlangıcını al (00:00:00)
  ///
  /// Örnek: getStartOfDay(DateTime.now())
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Belirtilen tarihin sonunu al (23:59:59)
  ///
  /// Örnek: getEndOfDay(DateTime.now())
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Belirtilen ayın ilk gününü al
  ///
  /// Örnek: getFirstDayOfMonth(DateTime.now())
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Belirtilen ayın son gününü al
  ///
  /// Örnek: getLastDayOfMonth(DateTime.now())
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Belirtilen haftanın ilk gününü al (Pazartesi)
  ///
  /// Örnek: getFirstDayOfWeek(DateTime.now())
  static DateTime getFirstDayOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Belirtilen haftanın son gününü al (Pazar)
  ///
  /// Örnek: getLastDayOfWeek(DateTime.now())
  static DateTime getLastDayOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  /// Yaş hesapla
  ///
  /// Örnek: calculateAge(DateTime(1990, 5, 15)) -> 35
  static int calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;

    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Tarihin gelecekte olup olmadığını kontrol et
  ///
  /// Örnek: isFutureDate(DateTime.now().add(Duration(days: 1))) -> true
  static bool isFutureDate(DateTime? date) {
    if (date == null) return false;
    return date.isAfter(DateTime.now());
  }

  /// Tarihin geçmişte olup olmadığını kontrol et
  ///
  /// Örnek: isPastDate(DateTime.now().subtract(Duration(days: 1))) -> true
  static bool isPastDate(DateTime? date) {
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  /// Tarihin bugün olup olmadığını kontrol et
  ///
  /// Örnek: isToday(DateTime.now()) -> true
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Tarihin yarın olup olmadığını kontrol et
  ///
  /// Örnek: isTomorrow(DateTime.now().add(Duration(days: 1))) -> true
  static bool isTomorrow(DateTime? date) {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Tarihin dün olup olmadığını kontrol et
  ///
  /// Örnek: isYesterday(DateTime.now().subtract(Duration(days: 1))) -> true
  static bool isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Hafta sonu kontrolü (Cumartesi veya Pazar)
  ///
  /// Örnek: isWeekend(DateTime.now()) -> false
  static bool isWeekend(DateTime? date) {
    if (date == null) return false;
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// İş günü kontrolü (Hafta içi)
  ///
  /// Örnek: isWeekday(DateTime.now()) -> true
  static bool isWeekday(DateTime? date) {
    if (date == null) return false;
    return !isWeekend(date);
  }
}
