import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String money(num? amount) {
    if (amount == null) return '₹0';
    return _inrFormat.format(amount.round());
  }

  static String kg(num? quantity) {
    if (quantity == null) return '0 kg';
    final rounded = quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1);
    return '$rounded kg';
  }

  static String relativeTime(int? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffSeconds = ((now - timestamp) / 1000).floor();
    if (diffSeconds < 60) return 'just now';
    if (diffSeconds < 3600) return '${(diffSeconds / 60).floor()}m ago';
    if (diffSeconds < 86400) return '${(diffSeconds / 3600).floor()}h ago';
    return '${(diffSeconds / 86400).floor()}d ago';
  }

  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(2)} MB';
  }
}
