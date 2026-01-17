import 'dart:convert';
import 'dart:typed_data';

/// Represents binary data such as photos, logos, sounds, or keys.
///
/// Supports both inline data (base64 encoded) and external references (URI).
///
/// ## Example
///
/// ```dart
/// // Create from inline data
/// final inline = BinaryData.inline(
///   Uint8List.fromList([0xFF, 0xD8, 0xFF]),
///   mediaType: 'image/jpeg',
/// );
///
/// // Create from URI reference
/// final uri = BinaryData.uri(
///   'https://example.com/photo.jpg',
///   mediaType: 'image/jpeg',
/// );
///
/// // Create from base64 string
/// final fromBase64 = BinaryData.fromBase64(
///   'iVBORw0KGgoAAAANSUhEUg...',
///   mediaType: 'image/png',
/// );
///
/// // Create from data URI
/// final fromDataUri = BinaryData.fromDataUri(
///   'data:image/png;base64,iVBORw0KGgoAAAANSUhEUg...',
/// );
///
/// // Get data
/// final base64 = inline.base64;  // base64 encoded string
/// final dataUri = inline.dataUri;  // 'data:image/png;base64,...'
/// ```
class BinaryData {
  /// The raw binary data (if inline).
  final Uint8List? data;

  /// The external URI reference (if not inline).
  final String? uri;

  /// The media type (MIME type).
  final String? mediaType;

  /// The encoding used (for vCard 2.1/3.0).
  final String? encoding;

  /// Creates binary data with inline content.
  const BinaryData.inline(this.data, {this.mediaType})
    : uri = null,
      encoding = null;

  /// Creates binary data with a URI reference.
  const BinaryData.uri(this.uri, {this.mediaType})
    : data = null,
      encoding = null;

  /// Creates binary data from a base64 string.
  factory BinaryData.fromBase64(String base64String, {String? mediaType}) {
    return BinaryData.inline(base64Decode(base64String), mediaType: mediaType);
  }

  /// Creates binary data from a data URI.
  factory BinaryData.fromDataUri(String dataUri) {
    final match = RegExp(
      r'^data:([^;,]+)?(?:;base64)?,(.*)$',
    ).firstMatch(dataUri);
    if (match == null) {
      throw FormatException('Invalid data URI: $dataUri');
    }
    final mimeType = match.group(1);
    final data = match.group(2)!;
    return BinaryData.fromBase64(data, mediaType: mimeType);
  }

  /// Whether this is inline data.
  bool get isInline => data != null;

  /// Whether this is an external reference.
  bool get isUri => uri != null;

  /// Whether this has no data or URI.
  bool get isEmpty => data == null && uri == null;

  /// Whether this has data or URI.
  bool get isNotEmpty => !isEmpty;

  /// Returns the base64-encoded data string.
  String? get base64 {
    if (data == null) return null;
    return base64Encode(data!);
  }

  /// Returns as a data URI.
  String? get dataUri {
    if (data == null) return null;
    final mime = mediaType ?? 'application/octet-stream';
    return 'data:$mime;base64,${base64Encode(data!)}';
  }

  /// Returns the value for vCard serialization.
  ///
  /// For inline data, returns base64 or data URI depending on version.
  /// For URI, returns the URI string.
  String? getValue({bool asDataUri = false}) {
    if (isUri) return uri;
    if (isInline) {
      return asDataUri ? dataUri : base64;
    }
    return null;
  }

  /// Creates a copy with optional modifications.
  BinaryData copyWith({
    Uint8List? data,
    String? uri,
    String? mediaType,
    String? encoding,
  }) {
    if (data != null || (uri == null && this.data != null)) {
      return BinaryData.inline(
        data ?? this.data,
        mediaType: mediaType ?? this.mediaType,
      );
    }
    return BinaryData.uri(
      uri ?? this.uri,
      mediaType: mediaType ?? this.mediaType,
    );
  }

  @override
  String toString() {
    if (isUri) return uri!;
    if (isInline) return '[${data!.length} bytes]';
    return '[empty]';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BinaryData) return false;
    if (uri != other.uri) return false;
    if (data?.length != other.data?.length) return false;
    if (data != null && other.data != null) {
      for (var i = 0; i < data!.length; i++) {
        if (data![i] != other.data![i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    if (uri != null) return uri.hashCode;
    if (data != null) return Object.hashAll(data!);
    return 0;
  }
}

/// Represents photo data (PHOTO property).
///
/// ## Example
///
/// ```dart
/// // Create photo from inline data
/// final photo = Photo.inline(
///   photoBytes,
///   mediaType: 'image/jpeg',
///   types: ['work'],
///   pref: 1,
/// );
///
/// // Create photo from URI
/// final fromUri = Photo.uri(
///   'https://example.com/photo.jpg',
///   mediaType: 'image/jpeg',
/// );
///
/// // Create from data URI
/// final fromDataUri = Photo.fromDataUri(
///   'data:image/jpeg;base64,...',
///   types: ['home'],
/// );
/// ```
class Photo extends BinaryData {
  /// Photo types (e.g., "work", "home") - vCard 4.0.
  final List<String> types;

  /// Preference order.
  final int? pref;

  /// Creates photo with inline data.
  const Photo.inline(
    super.data, {
    super.mediaType,
    this.types = const [],
    this.pref,
  }) : super.inline();

  /// Creates photo with URI reference.
  const Photo.uri(
    super.uri, {
    super.mediaType,
    this.types = const [],
    this.pref,
  }) : super.uri();

  /// Creates photo from base64 string.
  factory Photo.fromBase64(
    String base64String, {
    String? mediaType,
    List<String>? types,
    int? pref,
  }) {
    return Photo.inline(
      base64Decode(base64String),
      mediaType: mediaType,
      types: types ?? const [],
      pref: pref,
    );
  }

  /// Creates photo from data URI.
  factory Photo.fromDataUri(String dataUri, {List<String>? types, int? pref}) {
    final binary = BinaryData.fromDataUri(dataUri);
    return Photo.inline(
      binary.data,
      mediaType: binary.mediaType,
      types: types ?? const [],
      pref: pref,
    );
  }
}

/// Represents logo data (LOGO property).
///
/// ## Example
///
/// ```dart
/// // Create logo from inline data
/// final logo = Logo.inline(
///   logoBytes,
///   mediaType: 'image/png',
///   types: ['work'],
/// );
///
/// // Create logo from URI
/// final fromUri = Logo.uri(
///   'https://example.com/logo.png',
///   mediaType: 'image/png',
/// );
/// ```
class Logo extends BinaryData {
  /// Logo types.
  final List<String> types;

  /// Preference order.
  final int? pref;

  /// Creates logo with inline data.
  const Logo.inline(
    super.data, {
    super.mediaType,
    this.types = const [],
    this.pref,
  }) : super.inline();

  /// Creates logo with URI reference.
  const Logo.uri(super.uri, {super.mediaType, this.types = const [], this.pref})
    : super.uri();
}

/// Represents sound data (SOUND property).
///
/// ## Example
///
/// ```dart
/// // Create sound from inline data
/// final sound = Sound.inline(
///   audioBytes,
///   mediaType: 'audio/wav',
/// );
///
/// // Create sound from URI
/// final fromUri = Sound.uri(
///   'https://example.com/pronunciation.wav',
///   mediaType: 'audio/wav',
/// );
/// ```
class Sound extends BinaryData {
  /// Sound types.
  final List<String> types;

  /// Preference order.
  final int? pref;

  /// Creates sound with inline data.
  const Sound.inline(
    super.data, {
    super.mediaType,
    this.types = const [],
    this.pref,
  }) : super.inline();

  /// Creates sound with URI reference.
  const Sound.uri(
    super.uri, {
    super.mediaType,
    this.types = const [],
    this.pref,
  }) : super.uri();
}

/// Represents key/certificate data (KEY property).
///
/// ## Example
///
/// ```dart
/// // Create key from inline data
/// final key = Key.inline(
///   publicKeyBytes,
///   mediaType: 'application/pgp-keys',
/// );
///
/// // Create key from URI
/// final fromUri = Key.uri(
///   'https://example.com/public-key.asc',
///   mediaType: 'application/pgp-keys',
/// );
/// ```
class Key extends BinaryData {
  /// Key types (e.g., "work", "home").
  final List<String> types;

  /// Preference order.
  final int? pref;

  /// Creates key with inline data.
  const Key.inline(
    super.data, {
    super.mediaType,
    this.types = const [],
    this.pref,
  }) : super.inline();

  /// Creates key with URI reference.
  const Key.uri(super.uri, {super.mediaType, this.types = const [], this.pref})
    : super.uri();
}
