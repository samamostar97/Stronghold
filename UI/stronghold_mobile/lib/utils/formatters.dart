/// Zajednicki formati prikaza - datumi i novac na jednom mjestu.
class Formatters {
  static String date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}.';
  }

  static String dateTime(DateTime value) {
    final local = value.toLocal();
    return '${date(local)} ${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  static String money(double value) => '${value.toStringAsFixed(2)} KM';

  static String orderStatus(String status) => switch (status) {
        'Processing' => 'U obradi',
        'Shipped' => 'Poslano',
        'Delivered' => 'Dostavljeno',
        'Cancelled' => 'Otkazano',
        _ => status,
      };

  static String appointmentStatus(String status) => switch (status) {
        'Pending' => 'Na čekanju',
        'Confirmed' => 'Potvrđen',
        'Completed' => 'Održan',
        'Cancelled' => 'Otkazan',
        'NoShow' => 'Nedolazak',
        _ => status,
      };
}
