import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vnd = NumberFormat('#,###', 'vi_VN');

  static String vnd(num value) => '${_vnd.format(value.round())}₫';
}
