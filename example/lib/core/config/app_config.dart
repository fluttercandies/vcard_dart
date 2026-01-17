import 'package:vcard_dart/vcard_dart.dart';

/// Application configuration constants.
abstract final class AppConfig {
  /// Application name
  static const String appName = 'vCard Studio';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Default vCard version for new cards
  static const VCardVersion defaultVCardVersion = VCardVersion.v40;

  /// Supported export formats
  static const List<String> supportedExportFormats = [
    'vCard',
    'jCard',
    'xCard',
  ];

  /// Maximum photo size in bytes (5MB)
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024;

  /// Supported image types for photos
  static const List<String> supportedImageTypes = ['png', 'jpeg', 'jpg', 'gif'];

  /// Maximum number of recent contacts to show
  static const int maxRecentContacts = 10;

  /// Autosave delay in milliseconds
  static const int autosaveDelayMs = 2000;
}
