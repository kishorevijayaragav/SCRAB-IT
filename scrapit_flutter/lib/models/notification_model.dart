class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String icon;
  final bool read;
  final int ts;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.read,
    required this.ts,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'scan',
      read: json['read'] == true,
      ts: json['ts'] is int ? json['ts'] : int.tryParse(json['ts']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'icon': icon,
      'read': read,
      'ts': ts,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? icon,
    bool? read,
    int? ts,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      icon: icon ?? this.icon,
      read: read ?? this.read,
      ts: ts ?? this.ts,
    );
  }
}
