/// Represents a structured name (N property).
///
/// The structured name consists of multiple components:
/// family name, given name, additional names, prefixes, and suffixes.
///
/// This class supports both structured data and raw string values. When
/// the name value cannot be parsed into structured components (e.g., from
/// a non-compliant vCard), it will be stored as a raw value.
///
/// ## Example
///
/// ```dart
/// // Create a structured name
/// final name = StructuredName(
///   family: 'Smith',
///   given: 'John',
///   additional: ['William'],
///   prefixes: ['Dr.'],
///   suffixes: ['Jr.', 'Ph.D.'],
/// );
///
/// // Create from components list
/// final fromList = StructuredName.fromComponents([
///   'Doe',
///   'Jane',
///   'Marie',
///   'Ms.',
///   '',
/// ]);
///
/// // Create from raw value (unstructured string)
/// final rawName = StructuredName.raw('John Doe');
/// print(rawName.isRaw);  // true
/// print(rawName.rawValue);  // 'John Doe'
///
/// // Get formatted name
/// final formatted = name.toFormattedName();  // 'Dr. John William Smith Jr. Ph.D.'
///
/// // Get components for serialization
/// final components = name.toComponents();
///
/// // Check if empty
/// if (name.isNotEmpty) {
///   print('Name is not empty');
/// }
/// ```
class StructuredName {
  /// Family name (surname, last name).
  final String family;

  /// Given name (first name).
  final String given;

  /// Additional names (middle name(s)).
  final List<String> additional;

  /// Honorific prefixes (e.g., "Dr.", "Mr.").
  final List<String> prefixes;

  /// Honorific suffixes (e.g., "Jr.", "Ph.D.").
  final List<String> suffixes;

  /// Raw string value when the name cannot be parsed into components.
  ///
  /// This is used when the vCard contains a name that doesn't follow
  /// the standard structured format (e.g., just a plain string).
  final String? rawValue;

  /// Creates a new structured name.
  const StructuredName({
    this.family = '',
    this.given = '',
    this.additional = const [],
    this.prefixes = const [],
    this.suffixes = const [],
    this.rawValue,
  });

  /// Creates a structured name from a raw (unstructured) string.
  ///
  /// Use this when you have a plain string name that doesn't follow
  /// the structured vCard format.
  ///
  /// Example:
  /// ```dart
  /// final name = StructuredName.raw('John Doe');
  /// ```
  const StructuredName.raw(String value)
      : family = '',
        given = '',
        additional = const [],
        prefixes = const [],
        suffixes = const [],
        rawValue = value;

  /// Creates a structured name from a list of components.
  ///
  /// The order is: family, given, additional, prefixes, suffixes.
  factory StructuredName.fromComponents(List<String> components) {
    return StructuredName(
      family: components.isNotEmpty ? components[0] : '',
      given: components.length > 1 ? components[1] : '',
      additional:
          components.length > 2 ? _splitComponent(components[2]) : const [],
      prefixes:
          components.length > 3 ? _splitComponent(components[3]) : const [],
      suffixes:
          components.length > 4 ? _splitComponent(components[4]) : const [],
    );
  }

  /// Creates a structured name from a value string, auto-detecting format.
  ///
  /// If the value contains semicolons, it's treated as structured data.
  /// Otherwise, it's stored as a raw value.
  ///
  /// Example:
  /// ```dart
  /// // Structured format (with semicolons)
  /// final structured = StructuredName.fromValue('Doe;John;;;');
  /// print(structured.isStructured); // true
  ///
  /// // Raw format (without semicolons)
  /// final raw = StructuredName.fromValue('John Doe');
  /// print(raw.isRaw); // true
  /// ```
  factory StructuredName.fromValue(String value) {
    if (value.contains(';')) {
      // Structured format - parse components
      final components = value.split(';');
      return StructuredName.fromComponents(components);
    } else if (value.trim().isNotEmpty) {
      // Raw format - store as-is
      return StructuredName.raw(value);
    }
    return const StructuredName();
  }

  static List<String> _splitComponent(String value) {
    if (value.isEmpty) return const [];
    return value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Whether this name is stored as a raw value.
  bool get isRaw => rawValue != null;

  /// Whether this name has structured components.
  bool get isStructured => !isRaw;

  /// Whether all components are empty (including raw value).
  bool get isEmpty =>
      (rawValue == null || rawValue!.isEmpty) &&
      family.isEmpty &&
      given.isEmpty &&
      additional.isEmpty &&
      prefixes.isEmpty &&
      suffixes.isEmpty;

  /// Whether any component is non-empty (including raw value).
  bool get isNotEmpty => !isEmpty;

  /// Returns a formatted full name string.
  ///
  /// If this is a raw value, returns the raw string.
  /// Otherwise, constructs the formatted name from components.
  String toFormattedName() {
    if (rawValue != null) {
      return rawValue!;
    }
    final parts = <String>[];
    if (prefixes.isNotEmpty) {
      parts.add(prefixes.join(' '));
    }
    if (given.isNotEmpty) {
      parts.add(given);
    }
    if (additional.isNotEmpty) {
      parts.add(additional.join(' '));
    }
    if (family.isNotEmpty) {
      parts.add(family);
    }
    if (suffixes.isNotEmpty) {
      parts.add(suffixes.join(' '));
    }
    return parts.join(' ');
  }

  /// Converts to a list of components for serialization.
  ///
  /// If this is a raw value, returns a single-element list with the raw string.
  List<String> toComponents() {
    if (rawValue != null) {
      return [rawValue!];
    }
    return [
      family,
      given,
      additional.join(','),
      prefixes.join(','),
      suffixes.join(','),
    ];
  }

  /// Returns the value for serialization.
  ///
  /// If this is a raw value, returns the raw string.
  /// Otherwise, returns the semicolon-separated components.
  String toValue() {
    if (rawValue != null) {
      return rawValue!;
    }
    return toComponents().join(';');
  }

  /// Creates a copy with optional modifications.
  ///
  /// Set [clearRaw] to true to remove the raw value and convert to structured format.
  ///
  /// Example:
  /// ```dart
  /// final raw = StructuredName.raw('John Doe');
  /// final structured = raw.copyWith(
  ///   clearRaw: true,
  ///   given: 'John',
  ///   family: 'Doe',
  /// );
  /// print(structured.isStructured); // true
  /// ```
  StructuredName copyWith({
    String? family,
    String? given,
    List<String>? additional,
    List<String>? prefixes,
    List<String>? suffixes,
    String? rawValue,
    bool clearRaw = false,
  }) {
    return StructuredName(
      family: family ?? this.family,
      given: given ?? this.given,
      additional: additional ?? this.additional,
      prefixes: prefixes ?? this.prefixes,
      suffixes: suffixes ?? this.suffixes,
      rawValue: clearRaw ? null : (rawValue ?? this.rawValue),
    );
  }

  /// Converts a raw value to structured format by attempting to parse it.
  ///
  /// If this is already structured, returns this.
  /// If this is raw, attempts to parse the raw value intelligently.
  StructuredName toStructured() {
    if (!isRaw || rawValue == null) {
      return this;
    }

    // Try to parse common name patterns
    final value = rawValue!.trim();
    final parts = value.split(RegExp(r'\s+'));

    if (parts.isEmpty) {
      return const StructuredName();
    } else if (parts.length == 1) {
      return StructuredName(given: parts[0]);
    } else if (parts.length == 2) {
      return StructuredName(given: parts[0], family: parts[1]);
    } else {
      // First is given, last is family, middle are additional
      return StructuredName(
        given: parts.first,
        family: parts.last,
        additional: parts.sublist(1, parts.length - 1),
      );
    }
  }

  @override
  String toString() => toFormattedName();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StructuredName) return false;
    if (rawValue != null || other.rawValue != null) {
      return rawValue == other.rawValue;
    }
    return family == other.family &&
        given == other.given &&
        _listEquals(additional, other.additional) &&
        _listEquals(prefixes, other.prefixes) &&
        _listEquals(suffixes, other.suffixes);
  }

  @override
  int get hashCode {
    if (rawValue != null) {
      return rawValue.hashCode;
    }
    return Object.hash(
      family,
      given,
      Object.hashAll(additional),
      Object.hashAll(prefixes),
      Object.hashAll(suffixes),
    );
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
