class HistoryItem {
  final String id;
  final String type; // 'scan', 'inventory', 'transaction'
  final String name;
  final double qty;
  final double value;
  final String group; // 'Today', 'Yesterday', etc.
  final String time;
  final int ts;

  HistoryItem({
    required this.id,
    required this.type,
    required this.name,
    required this.qty,
    required this.value,
    required this.group,
    required this.time,
    required this.ts,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'scan',
      name: json['name']?.toString() ?? '',
      qty: (json['qty'] is num) ? (json['qty'] as num).toDouble() : double.tryParse(json['qty']?.toString() ?? '0') ?? 0.0,
      value: (json['value'] is num) ? (json['value'] as num).toDouble() : double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
      group: json['group']?.toString() ?? 'Today',
      time: json['time']?.toString() ?? '',
      ts: json['ts'] is int ? json['ts'] : int.tryParse(json['ts']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'qty': qty,
      'value': value,
      'group': group,
      'time': time,
      'ts': ts,
    };
  }
}
