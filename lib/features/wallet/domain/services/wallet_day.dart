abstract final class WalletDay {
  static String key(DateTime instant) {
    final local = instant.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  static DateTime nextMidnight(DateTime instant) {
    final local = instant.toLocal();
    return DateTime(local.year, local.month, local.day + 1);
  }
}
