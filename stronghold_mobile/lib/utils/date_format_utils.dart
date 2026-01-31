import 'package:intl/intl.dart';

String formatDateDDMMYYYY(DateTime date) {
  return DateFormat('dd.MM.yyyy').format(date);
}
