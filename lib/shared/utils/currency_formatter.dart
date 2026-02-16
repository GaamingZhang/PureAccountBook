import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0.00');

  static String format(double amount) {
    return '¥${_formatter.format(amount)}';
  }

  static String formatWithoutSymbol(double amount) {
    return _formatter.format(amount);
  }
}
