/// Supported vCard versions.
///
/// This enum represents the different versions of the vCard specification
/// that this library supports.
///
/// ## Example
///
/// ```dart
/// // Create vCards with different versions
/// final v21 = VCard(version: VCardVersion.v21);
/// final v30 = VCard(version: VCardVersion.v30);
/// final v40 = VCard(version: VCardVersion.v40);
///
/// // Parse version string
/// final version = VCardVersion.parse('3.0');  // VCardVersion.v30
///
/// // Try parse (returns null on failure)
/// final parsed = VCardVersion.tryParse('4.0');
///
/// // Get version string
/// print(version.value);  // '3.0'
/// print(version.toString());  // '3.0'
/// ```
enum VCardVersion {
  /// vCard 2.1 - Legacy format, widely used but not an RFC standard.
  ///
  /// Key characteristics:
  /// - Uses `=` for property parameters (e.g., `TEL;TYPE=HOME:123`)
  /// - Supports QUOTED-PRINTABLE encoding
  /// - Limited character set support
  v21('2.1'),

  /// vCard 3.0 - RFC 2426 standard.
  ///
  /// Key characteristics:
  /// - Uses `:` separator consistently
  /// - Better UTF-8 support
  /// - Improved parameter syntax
  v30('3.0'),

  /// vCard 4.0 - RFC 6350 standard (current).
  ///
  /// Key characteristics:
  /// - Full UTF-8 support
  /// - New properties (ANNIVERSARY, GENDER, KIND, etc.)
  /// - Improved data types
  /// - VALUE parameter for type specification
  v40('4.0');

  /// The string representation of the version number.
  final String value;

  const VCardVersion(this.value);

  /// Parses a version string and returns the corresponding [VCardVersion].
  ///
  /// Throws [ArgumentError] if the version string is not recognized.
  static VCardVersion parse(String version) {
    final normalized = version.trim();
    for (final v in VCardVersion.values) {
      if (v.value == normalized) {
        return v;
      }
    }
    throw ArgumentError('Unknown vCard version: $version');
  }

  /// Tries to parse a version string and returns null if not recognized.
  static VCardVersion? tryParse(String version) {
    try {
      return parse(version);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => value;
}
