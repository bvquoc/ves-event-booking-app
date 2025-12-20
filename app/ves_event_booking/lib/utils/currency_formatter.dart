import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _vndFormatter =
      NumberFormat('#,###', 'vi_VN');

  static String format(double amount) {
    return '${_vndFormatter.format(amount)} VNĐ';
  }
}
