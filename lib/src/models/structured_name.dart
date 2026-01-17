/// Represents a structured name (N property).
///
/// The structured name consists of multiple components:
/// family name, given name, additional names, prefixes, and suffixes.
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

  /// Creates a new structured name.
  const StructuredName({
    this.family = '',
    this.given = '',
    this.additional = const [],
    this.prefixes = const [],
    this.suffixes = const [],
  });

  /// Creates a structured name from a list of components.
  ///
  /// The order is: family, given, additional, prefixes, suffixes.
  factory StructuredName.fromComponents(List<String> components) {
    return StructuredName(
      family: components.isNotEmpty ? components[0] : '',
      given: components.length > 1 ? components[1] : '',
      additional: components.length > 2
          ? _splitComponent(components[2])
          : const [],
      prefixes: components.length > 3
          ? _splitComponent(components[3])
          : const [],
      suffixes: components.length > 4
          ? _splitComponent(components[4])
          : const [],
    );
  }

  static List<String> _splitComponent(String value) {
    if (value.isEmpty) return const [];
    return value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Whether all components are empty.
  bool get isEmpty =>
      family.isEmpty &&
      given.isEmpty &&
      additional.isEmpty &&
      prefixes.isEmpty &&
      suffixes.isEmpty;

  /// Whether any component is non-empty.
  bool get isNotEmpty => !isEmpty;

  /// Returns a formatted full name string.
  String toFormattedName() {
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
  List<String> toComponents() {
    return [
      family,
      given,
      additional.join(','),
      prefixes.join(','),
      suffixes.join(','),
    ];
  }

  /// Creates a copy with optional modifications.
  StructuredName copyWith({
    String? family,
    String? given,
    List<String>? additional,
    List<String>? prefixes,
    List<String>? suffixes,
  }) {
    return StructuredName(
      family: family ?? this.family,
      given: given ?? this.given,
      additional: additional ?? this.additional,
      prefixes: prefixes ?? this.prefixes,
      suffixes: suffixes ?? this.suffixes,
    );
  }

  @override
  String toString() => toFormattedName();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StructuredName) return false;
    return family == other.family &&
        given == other.given &&
        _listEquals(additional, other.additional) &&
        _listEquals(prefixes, other.prefixes) &&
        _listEquals(suffixes, other.suffixes);
  }

  @override
  int get hashCode => Object.hash(
    family,
    given,
    Object.hashAll(additional),
    Object.hashAll(prefixes),
    Object.hashAll(suffixes),
  );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
