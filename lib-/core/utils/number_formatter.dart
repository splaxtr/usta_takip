import 'package:intl/intl.dart';

class NumberFormatter {
  // Türk Lirası formatı: 2.500₺
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'tr_TR');
    return '${formatter.format(amount)}₺';
  }

  // Virgüllü format: 2.500,50₺
  static String formatCurrencyWithDecimals(double amount) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return '${formatter.format(amount)}₺';
  }

  // Sadece sayı: 2.500
  static String formatNumber(double amount) {
    final formatter = NumberFormat('#,##0', 'tr_TR');
    return formatter.format(amount);
  }
}
