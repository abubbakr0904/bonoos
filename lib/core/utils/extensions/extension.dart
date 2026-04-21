import 'package:intl/intl.dart';

extension CurrencyFormatter on num {
  String get uzsFormat {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(this)} UZS';
  }
}