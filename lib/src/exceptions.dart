/// Base exception for vCard-related errors.
///
/// ## Example
///
/// ```dart
/// try {
///   // vCard operation that might fail
/// } on VCardException catch (e) {
///   print('vCard error: ${e.message}');
///   if (e.line != null) {
///     print('at line ${e.line}');
///   }
/// }
/// ```
class VCardException implements Exception {
  /// The error message.
  final String message;

  /// The source location (line number) where the error occurred.
  final int? line;

  /// The source column where the error occurred.
  final int? column;

  /// Creates a new vCard exception.
  const VCardException(this.message, {this.line, this.column});

  @override
  String toString() {
    final location = line != null
        ? column != null
              ? ' at line $line, column $column'
              : ' at line $line'
        : '';
    return 'VCardException: $message$location';
  }
}

/// Exception thrown when parsing a vCard fails.
///
/// ## Example
///
/// ```dart
/// try {
///   final vcard = VCardParser.parse(vcardString);
/// } on VCardParseException catch (e) {
///   print('Parse error at line ${e.line}: ${e.message}');
///   if (e.source != null) {
///     print('Problematic content: ${e.source}');
///   }
/// }
/// ```
class VCardParseException extends VCardException {
  /// The source text that failed to parse (if available).
  final String? source;

  /// Creates a new parse exception.
  const VCardParseException(
    super.message, {
    super.line,
    super.column,
    this.source,
  });

  @override
  String toString() {
    final location = line != null
        ? column != null
              ? ' at line $line, column $column'
              : ' at line $line'
        : '';
    return 'VCardParseException: $message$location';
  }
}

/// Exception thrown when a required property is missing.
///
/// ## Example
///
/// ```dart
/// try {
///   final vcard = VCard(version: VCardVersion.v40);
///   vcard.validate();  // Will throw if FN is missing
/// } on MissingPropertyException catch (e) {
///   print('Missing required property: ${e.propertyName}');
/// }
/// ```
class MissingPropertyException extends VCardException {
  /// The name of the missing property.
  final String propertyName;

  /// Creates a new missing property exception.
  const MissingPropertyException(this.propertyName)
    : super('Missing required property: $propertyName');

  @override
  String toString() =>
      'MissingPropertyException: Missing required property: $propertyName';
}

/// Exception thrown when a property value is invalid.
///
/// ## Example
///
/// ```dart
/// try {
///   // Operation that validates property values
/// } on InvalidPropertyValueException catch (e) {
///   print('Invalid ${e.propertyName}: ${e.value}');
///   print('${e.message}');
/// }
/// ```
class InvalidPropertyValueException extends VCardException {
  /// The property name.
  final String propertyName;

  /// The invalid value.
  final String value;

  /// Creates a new invalid property value exception.
  const InvalidPropertyValueException(
    this.propertyName,
    this.value, [
    String? message,
  ]) : super(message ?? 'Invalid value for $propertyName: $value');

  @override
  String toString() => 'InvalidPropertyValueException: $message';
}

/// Exception thrown when encoding/decoding fails.
///
/// ## Example
///
/// ```dart
/// try {
///   final decoded = QuotedPrintable.encode(text);
/// } on EncodingException catch (e) {
///   print('Encoding error: ${e.message}');
///   if (e.encoding != null) {
///     print('Failed encoding: ${e.encoding}');
///   }
/// }
/// ```
class EncodingException extends VCardException {
  /// The encoding that failed.
  final String? encoding;

  /// Creates a new encoding exception.
  const EncodingException(super.message, {this.encoding, super.line});

  @override
  String toString() {
    final enc = encoding != null ? ' (encoding: $encoding)' : '';
    return 'EncodingException: $message$enc';
  }
}

/// Exception thrown when an unsupported vCard version is encountered.
///
/// ## Example
///
/// ```dart
/// try {
///   final version = VCardVersion.tryParse('5.0');
///   if (version == null) {
///     throw UnsupportedVersionException('5.0');
///   }
/// } on UnsupportedVersionException catch (e) {
///   print('Unsupported version: ${e.versionString}');
/// }
/// ```
class UnsupportedVersionException extends VCardException {
  /// The unsupported version string.
  final String versionString;

  /// Creates a new unsupported version exception.
  const UnsupportedVersionException(this.versionString)
    : super('Unsupported vCard version: $versionString');

  @override
  String toString() =>
      'UnsupportedVersionException: Unsupported vCard version: $versionString';
}

/// Exception thrown when generating a vCard fails.
///
/// ## Example
///
/// ```dart
/// try {
///   final vcardString = VCardGenerator.generate(vcard);
/// } on VCardGenerateException catch (e) {
///   print('Generation error: ${e.message}');
/// }
/// ```
class VCardGenerateException extends VCardException {
  /// Creates a new generate exception.
  const VCardGenerateException(super.message);

  @override
  String toString() => 'VCardGenerateException: $message';
}

/// Exception thrown for format-specific errors (jCard, xCard).
///
/// ## Example
///
/// ```dart
/// try {
///   final vcard = JCardFormatter().fromJson(json);
/// } on FormatException catch (e) {
///   print('jCard format error: ${e.message}');
///   print('Format: ${e.format}');
/// }
/// ```
class FormatException extends VCardException {
  /// The format name (e.g., "jCard", "xCard").
  final String format;

  /// Creates a new format exception.
  const FormatException.format(this.format, String message, {int? line})
    : super(message, line: line);

  @override
  String toString() => '$format FormatException: $message';
}
