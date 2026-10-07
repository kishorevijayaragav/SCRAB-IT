class NotificationSettings {
  final bool pushScan;
  final bool priceAlerts;
  final bool invReminder;

  NotificationSettings({
    this.pushScan = true,
    this.priceAlerts = true,
    this.invReminder = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationSettings();
    return NotificationSettings(
      pushScan: json['pushScan'] != false,
      priceAlerts: json['priceAlerts'] != false,
      invReminder: json['invReminder'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushScan': pushScan,
      'priceAlerts': priceAlerts,
      'invReminder': invReminder,
    };
  }

  NotificationSettings copyWith({
    bool? pushScan,
    bool? priceAlerts,
    bool? invReminder,
  }) {
    return NotificationSettings(
      pushScan: pushScan ?? this.pushScan,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      invReminder: invReminder ?? this.invReminder,
    );
  }
}

class UserPreferences {
  final String language;
  final String currency;
  final String unit;

  UserPreferences({
    this.language = 'English',
    this.currency = 'INR (₹)',
    this.unit = 'kg',
  });

  factory UserPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserPreferences();
    return UserPreferences(
      language: json['language']?.toString() ?? 'English',
      currency: json['currency']?.toString() ?? 'INR (₹)',
      unit: json['unit']?.toString() ?? 'kg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'currency': currency,
      'unit': unit,
    };
  }

  UserPreferences copyWith({
    String? language,
    String? currency,
    String? unit,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      unit: unit ?? this.unit,
    );
  }
}

class AppSettings {
  final NotificationSettings notifications;
  final UserPreferences preferences;

  AppSettings({
    NotificationSettings? notifications,
    UserPreferences? preferences,
  })  : notifications = notifications ?? NotificationSettings(),
        preferences = preferences ?? UserPreferences();

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notifications: NotificationSettings.fromJson(json['notifications'] as Map<String, dynamic>?),
      preferences: UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.toJson(),
      'preferences': preferences.toJson(),
    };
  }

  AppSettings copyWith({
    NotificationSettings? notifications,
    UserPreferences? preferences,
  }) {
    return AppSettings(
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
    );
  }
}
