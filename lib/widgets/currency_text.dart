import 'package:intl/intl.dart';

final _rpFormat = NumberFormat('#,##0', 'id_ID');

String formatRupiah(double value, {bool showPrefix = true}) {
  final formatted = _rpFormat.format(value);
  return showPrefix ? 'Rp $formatted' : formatted;
}

String formatNumber(double value) => _rpFormat.format(value);
