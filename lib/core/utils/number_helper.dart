import 'package:intl/intl.dart';

/// Sayı ve para formatları için yardımcı sınıf
class NumberHelper {
  NumberHelper._();

  // Varsayılan formatlar
  static final NumberFormat _defaultNumberFormat =
      NumberFormat('#,##0.00', 'tr_TR');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );
  static final NumberFormat _compactFormat =
      NumberFormat.compact(locale: 'tr_TR');
  static final NumberFormat _percentFormat =
      NumberFormat.percentPattern('tr_TR');

  /// Sayıyı para formatına çevir
  ///
  /// Örnek: formatCurrency(1234.56) -> "₺1.234,56"
  static String formatCurrency(
    num? value, {
    String symbol = '₺',
    int decimalDigits = 2,
    String locale = 'tr_TR',
  }) {
    if (value == null) return '${symbol}0,00';

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );

    return formatter.format(value);
  }

  /// Sayıyı para formatına çevir (sembollü)
  ///
  /// Örnek: formatMoney(1234.56) -> "1.234,56 ₺"
  static String formatMoney(
    num? value, {
    String symbol = '₺',
    int decimalDigits = 2,
  }) {
    if (value == null) return '0,00 $symbol';

    final formatted = _defaultNumberFormat.format(value);
    return '$formatted $symbol';
  }

  /// Para formatını sayıya çevir
  ///
  /// Örnek: parseCurrency("₺1.234,56") -> 1234.56
  static double? parseCurrency(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      // Para birimi sembolünü ve boşlukları kaldır
      String cleaned = value.replaceAll(RegExp(r'[₺\$€£\s]'), '');

      // Nokta ve virgülü düzenle (TR formatı: 1.234,56 -> 1234.56)
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');

      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Sayıyı formatla (ondalık basamaklı)
  ///
  /// Örnek: formatNumber(1234.567) -> "1.234,57"
  static String formatNumber(
    num? value, {
    int decimalDigits = 2,
    String locale = 'tr_TR',
  }) {
    if (value == null) return '0';

    final formatter = NumberFormat.decimalPattern(locale);
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;

    return formatter.format(value);
  }

  /// Sayıyı tam sayı olarak formatla
  ///
  /// Örnek: formatInteger(1234) -> "1.234"
  static String formatInteger(int? value, {String locale = 'tr_TR'}) {
    if (value == null) return '0';

    final formatter = NumberFormat.decimalPattern(locale);
    formatter.maximumFractionDigits = 0;

    return formatter.format(value);
  }

  /// Sayıyı kompakt formatta göster
  ///
  /// Örnek: formatCompact(1234567) -> "1,2 Mn"
  static String formatCompact(num? value, {String locale = 'tr_TR'}) {
    if (value == null) return '0';
    return NumberFormat.compact(locale: locale).format(value);
  }

  /// Sayıyı kısa kompakt formatta göster
  ///
  /// Örnek: formatCompactShort(1234567) -> "1,2M"
  static String formatCompactShort(num? value, {String locale = 'tr_TR'}) {
    if (value == null) return '0';

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }

  /// Yüzde formatı
  ///
  /// Örnek: formatPercent(0.1234) -> "%12,34"
  static String formatPercent(
    num? value, {
    int decimalDigits = 2,
    String locale = 'tr_TR',
  }) {
    if (value == null) return '%0';

    final formatter = NumberFormat.percentPattern(locale);
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;

    return formatter.format(value);
  }

  /// Yüzde hesapla ve formatla
  ///
  /// Örnek: calculatePercent(25, 100) -> "%25,00"
  static String calculatePercent(
    num? value,
    num? total, {
    int decimalDigits = 2,
  }) {
    if (value == null || total == null || total == 0) return '%0';

    final percent = (value / total);
    return formatPercent(percent, decimalDigits: decimalDigits);
  }

  /// Telefon numarasını formatla (Türkiye formatı)
  ///
  /// Örnek: formatPhone("5551234567") -> "(555) 123 45 67"
  static String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    // Sadece rakamları al
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 10) {
      // 5551234567 -> (555) 123 45 67
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8)}';
    } else if (cleaned.length == 11 && cleaned.startsWith('0')) {
      // 05551234567 -> (555) 123 45 67
      return formatPhone(cleaned.substring(1));
    }

    return phone;
  }

  /// TC Kimlik numarasını formatla
  ///
  /// Örnek: formatTCKN("12345678901") -> "123 456 789 01"
  static String formatTCKN(String? tckn) {
    if (tckn == null || tckn.isEmpty) return '';

    final cleaned = tckn.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    }

    return tckn;
  }

  /// Kredi kartı numarasını formatla
  ///
  /// Örnek: formatCreditCard("1234567890123456") -> "1234 5678 9012 3456"
  static String formatCreditCard(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return '';

    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 16) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8, 12)} ${cleaned.substring(12)}';
    }

    return cardNumber;
  }

  /// IBAN formatla
  ///
  /// Örnek: formatIBAN("TR330006100519786457841326") -> "TR33 0006 1005 1978 6457 8413 26"
  static String formatIBAN(String? iban) {
    if (iban == null || iban.isEmpty) return '';

    final cleaned = iban.replaceAll(RegExp(r'\s'), '').toUpperCase();

    if (cleaned.length == 26 && cleaned.startsWith('TR')) {
      final parts = <String>[];
      for (int i = 0; i < cleaned.length; i += 4) {
        final end = (i + 4 < cleaned.length) ? i + 4 : cleaned.length;
        parts.add(cleaned.substring(i, end));
      }
      return parts.join(' ');
    }

    return iban;
  }

  /// Dosya boyutunu formatla
  ///
  /// Örnek: formatFileSize(1536) -> "1.5 KB"
  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Sayıyı sıra sayısına çevir
  ///
  /// Örnek: formatOrdinal(1) -> "1."
  static String formatOrdinal(int? number) {
    if (number == null) return '';
    return '$number.';
  }

  /// Pozitif/Negatif gösterge ekle
  ///
  /// Örnek: formatWithSign(123) -> "+123", formatWithSign(-45) -> "-45"
  static String formatWithSign(num? value) {
    if (value == null) return '0';
    if (value > 0) return '+${value.abs()}';
    return value.toString();
  }

  /// Sayıyı belirtilen aralıkta sınırla
  ///
  /// Örnek: clamp(150, min: 0, max: 100) -> 100
  static num clamp(num value, {required num min, required num max}) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Sayıyı yuvarlama
  ///
  /// Örnek: roundToDecimal(3.14159, 2) -> 3.14
  static double roundToDecimal(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  /// String'i sayıya çevir (güvenli)
  ///
  /// Örnek: parseDouble("1.234,56") -> 1234.56
  static double? parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      // TR formatını standart formata çevir
      String cleaned = value.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// String'i tam sayıya çevir (güvenli)
  ///
  /// Örnek: parseInt("1.234") -> 1234
  static int? parseInt(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      String cleaned = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Ortalama hesapla
  ///
  /// Örnek: average([1, 2, 3, 4, 5]) -> 3.0
  static double? average(List<num>? values) {
    if (values == null || values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Toplam hesapla
  ///
  /// Örnek: sum([1, 2, 3, 4, 5]) -> 15
  static num sum(List<num>? values) {
    if (values == null || values.isEmpty) return 0;
    return values.reduce((a, b) => a + b);
  }
}

// Pow fonksiyonu için (dart:math kullanımı)
num pow(num x, num exponent) {
  if (exponent == 0) return 1;
  num result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}
