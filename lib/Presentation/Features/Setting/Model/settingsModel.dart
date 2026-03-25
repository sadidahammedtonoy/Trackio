import 'package:hive/hive.dart';

part 'settingsModel.g.dart';

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  final String languageCode;
  @HiveField(1)
  final String countryCode;
  @HiveField(2)
  final DateTime updatedAt;

  AppSettings({
    required this.languageCode,
    required this.countryCode,
    required this.updatedAt,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      languageCode: 'en',
      countryCode: 'US',
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'languageCode': languageCode,
      'countryCode': countryCode,
      'updatedAt': updatedAt,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      languageCode: map['languageCode'] ?? 'en',
      countryCode: map['countryCode'] ?? 'US',
      updatedAt: (map['updatedAt'] as DateTime?) ?? DateTime.now(),
    );
  }
}
