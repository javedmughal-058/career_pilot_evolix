enum AppFontSize { small, medium, large, extraLarge }

class AppSettings {
  const AppSettings({
    this.fontSize = AppFontSize.medium,
    this.darkMode = false,
    this.onboardingSeen = false,
  });
  final AppFontSize fontSize;
  final bool darkMode, onboardingSeen;
  double get textScale => switch (fontSize) {
    AppFontSize.small => 0.90,
    AppFontSize.medium => 1.0,
    AppFontSize.large => 1.10,
    AppFontSize.extraLarge => 1.22,
  };
  AppSettings copyWith({
    AppFontSize? fontSize,
    bool? darkMode,
    bool? onboardingSeen,
  }) => AppSettings(
    fontSize: fontSize ?? this.fontSize,
    darkMode: darkMode ?? this.darkMode,
    onboardingSeen: onboardingSeen ?? this.onboardingSeen,
  );
  Map<String, dynamic> toJson() => {
    'fontSize': fontSize.name,
    'darkMode': darkMode,
    'onboardingSeen': onboardingSeen,
  };
  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
    fontSize:
        AppFontSize.values.where((e) => e.name == j['fontSize']).firstOrNull ??
        AppFontSize.medium,
    darkMode: j['darkMode'] ?? false,
    onboardingSeen: j['onboardingSeen'] ?? false,
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
