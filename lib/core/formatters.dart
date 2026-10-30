import 'package:intl/intl.dart';

String money(num value, {bool decimals = false}) => NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: decimals ? 2 : 0,
).format(value);
String shortDate(DateTime date) => DateFormat('d MMM yyyy').format(date);
String monthName(int month) => DateFormat('MMMM').format(DateTime(2026, month));
