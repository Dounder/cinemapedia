import 'package:intl/intl.dart';

class HumanFormats {
  static String number(double number, {int decimals = 0}) {
    final formatter = NumberFormat.compactCurrency(
      decimalDigits: decimals,
      symbol: '',
      locale: 'en_US',
    ).format(number);

    return formatter;
  }
}
