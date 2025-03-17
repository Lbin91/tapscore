class AppVersion {
  final String latestVersion;
  final String forceUpdateVersion;
  final bool showPopup;

  AppVersion({
    required this.latestVersion,
    required this.forceUpdateVersion,
    required this.showPopup,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      latestVersion: json['latest_version'] ?? '1.0.0',
      forceUpdateVersion: json['force_update_version'] ?? '1.0.0',
      showPopup: json['show_popup'] ?? false,
    );
  }

  factory AppVersion.defaultVersion() {
    return AppVersion(
      latestVersion: '1.0.0',
      forceUpdateVersion: '1.0.0',
      showPopup: false,
    );
  }
}
