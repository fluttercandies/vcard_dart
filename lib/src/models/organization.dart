/// Represents organization-related information (ORG, TITLE, ROLE properties).
///
/// This class supports both structured data and raw string values. When
/// the organization value cannot be parsed into structured components (e.g., from
/// a non-compliant vCard), it will be stored as a raw value.
///
/// ## Example
///
/// ```dart
/// // Create an organization
/// final org = Organization(
///   name: 'Acme Inc.',
///   units: ['Engineering', 'Mobile Team'],
///   sortAs: 'Acme',
/// );
///
/// // Create from components list
/// final fromList = Organization.fromComponents([
///   'Acme Inc.',
///   'Engineering',
///   'Mobile Team',
/// ]);
///
/// // Create from raw value (unstructured string)
/// final rawOrg = Organization.raw('Acme Inc. - Engineering Department');
/// print(rawOrg.isRaw);  // true
/// print(rawOrg.rawValue);  // 'Acme Inc. - Engineering Department'
///
/// // Get formatted string
/// final formatted = org.toFormattedString();  // 'Acme Inc., Engineering, Mobile Team'
///
/// // Get components for serialization
/// final components = org.toComponents();
///
/// // Check if empty
/// if (org.isNotEmpty) {
///   print('Organization is not empty');
/// }
/// ```
class Organization {
  /// Organization name.
  final String name;

  /// Organizational unit(s)/department(s).
  final List<String> units;

  /// Sort string for ordering.
  final String? sortAs;

  /// Raw string value when the organization cannot be parsed into components.
  ///
  /// This is used when the vCard contains an organization that doesn't follow
  /// the standard structured format (e.g., just a plain string).
  final String? rawValue;

  /// Creates a new organization.
  const Organization({
    required this.name,
    this.units = const [],
    this.sortAs,
    this.rawValue,
  });

  /// Creates an organization with only a name (no units).
  const Organization.simple(this.name)
      : units = const [],
        sortAs = null,
        rawValue = null;

  /// Creates an organization from a raw (unstructured) string.
  ///
  /// Use this when you have a plain string organization that doesn't follow
  /// the structured vCard format.
  ///
  /// Example:
  /// ```dart
  /// final org = Organization.raw('Acme Inc. - Engineering');
  /// ```
  const Organization.raw(String value, {this.sortAs})
      : name = '',
        units = const [],
        rawValue = value;

  /// Creates an organization from a list of components.
  ///
  /// First element is the name, remaining are units.
  factory Organization.fromComponents(List<String> components,
      {String? sortAs}) {
    if (components.isEmpty) {
      return Organization(name: '', sortAs: sortAs);
    }
    return Organization(
      name: components.first,
      units: components.length > 1 ? components.sublist(1) : const [],
      sortAs: sortAs,
    );
  }

  /// Creates an organization from a value string, auto-detecting format.
  ///
  /// If the value contains semicolons, it's treated as structured data.
  /// Otherwise, it's stored as a raw value.
  ///
  /// Example:
  /// ```dart
  /// // Structured format (with semicolons)
  /// final structured = Organization.fromValue('Acme Inc.;Engineering;R&D');
  /// print(structured.isStructured); // true
  ///
  /// // Raw format (without semicolons)
  /// final raw = Organization.fromValue('Acme Inc. - Engineering Department');
  /// print(raw.isRaw); // true
  /// ```
  factory Organization.fromValue(String value, {String? sortAs}) {
    if (value.contains(';')) {
      // Structured format - parse components
      final components = value.split(';');
      return Organization.fromComponents(components, sortAs: sortAs);
    } else if (value.trim().isNotEmpty) {
      // Raw format - store as-is
      return Organization.raw(value, sortAs: sortAs);
    }
    return Organization(name: '', sortAs: sortAs);
  }

  /// Whether this organization is stored as a raw value.
  bool get isRaw => rawValue != null;

  /// Whether this organization has structured components.
  bool get isStructured => !isRaw;

  /// Whether the organization name is empty (including raw value).
  bool get isEmpty => (rawValue == null || rawValue!.isEmpty) && name.isEmpty;

  /// Whether the organization name is not empty (including raw value).
  bool get isNotEmpty => !isEmpty;

  /// Converts to a list of components for serialization.
  ///
  /// If this is a raw value, returns a single-element list with the raw string.
  List<String> toComponents() {
    if (rawValue != null) {
      return [rawValue!];
    }
    return [name, ...units];
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

  /// Returns a formatted string representation.
  ///
  /// If this is a raw value, returns the raw string.
  /// Otherwise, constructs the formatted string from components.
  String toFormattedString({String separator = ', '}) {
    if (rawValue != null) {
      return rawValue!;
    }
    if (units.isEmpty) return name;
    return [name, ...units].join(separator);
  }

  /// Creates a copy with optional modifications.
  ///
  /// Set [clearRaw] to true to remove the raw value and convert to structured format.
  ///
  /// Example:
  /// ```dart
  /// final raw = Organization.raw('Acme Inc.');
  /// final structured = raw.copyWith(
  ///   clearRaw: true,
  ///   name: 'Acme Inc.',
  /// );
  /// print(structured.isStructured); // true
  /// ```
  Organization copyWith({
    String? name,
    List<String>? units,
    String? sortAs,
    String? rawValue,
    bool clearRaw = false,
  }) {
    return Organization(
      name: name ?? this.name,
      units: units ?? this.units,
      sortAs: sortAs ?? this.sortAs,
      rawValue: clearRaw ? null : (rawValue ?? this.rawValue),
    );
  }

  /// Converts a raw value to structured format by attempting to parse it.
  ///
  /// If this is already structured, returns this.
  /// If this is raw, attempts to parse the raw value intelligently.
  Organization toStructured() {
    if (!isRaw || rawValue == null) {
      return this;
    }

    // Try to parse common organization patterns
    final value = rawValue!.trim();

    // Try common separators: " - ", " / ", "; "
    for (final separator in [' - ', ' / ', '; ']) {
      if (value.contains(separator)) {
        final parts = value.split(separator).map((s) => s.trim()).toList();
        return Organization(
          name: parts.first,
          units: parts.length > 1 ? parts.sublist(1) : const [],
          sortAs: sortAs,
        );
      }
    }

    // No separator found - treat whole string as name
    return Organization(name: value, sortAs: sortAs);
  }

  @override
  String toString() => toFormattedString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Organization) return false;
    if (rawValue != null || other.rawValue != null) {
      return rawValue == other.rawValue;
    }
    if (name != other.name) return false;
    if (units.length != other.units.length) return false;
    for (var i = 0; i < units.length; i++) {
      if (units[i] != other.units[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    if (rawValue != null) {
      return rawValue.hashCode;
    }
    return Object.hash(name, Object.hashAll(units));
  }
}

/// Represents related person information (RELATED property, vCard 4.0).
///
/// ## Example
///
/// ```dart
/// // Create a relation
/// final spouse = Related(
///   value: 'urn:uuid:03a0e51f-d1aa-4385-8a53-e29025acd8af',
///   type: 'spouse',
/// );
///
/// // Use convenience constructors
/// final child = Related.child('Jane Doe');
/// final parent = Related.parent('John Doe');
/// final sibling = Related.sibling('Jane Smith');
/// final emergency = Related.emergency('+1-555-555-5555');
///
/// // Create with text value (vCard 4.0)
/// final textRelation = Related(
///   value: 'Jane Doe',
///   type: 'spouse',
/// );
/// ```
class Related {
  /// The related person's URI or text identifier.
  final String value;

  /// Type of relationship (e.g., "spouse", "child", "parent").
  final String? type;

  /// Preference order.
  final int? pref;

  /// Media type (if URI points to vCard).
  final String? mediaType;

  /// Language tag.
  final String? language;

  /// Creates a new related person entry.
  const Related({
    required this.value,
    this.type,
    this.pref,
    this.mediaType,
    this.language,
  });

  /// Creates a spouse relation.
  factory Related.spouse(String value) {
    return Related(value: value, type: 'spouse');
  }

  /// Creates a child relation.
  factory Related.child(String value) {
    return Related(value: value, type: 'child');
  }

  /// Creates a parent relation.
  factory Related.parent(String value) {
    return Related(value: value, type: 'parent');
  }

  /// Creates a sibling relation.
  factory Related.sibling(String value) {
    return Related(value: value, type: 'sibling');
  }

  /// Creates an emergency contact relation.
  factory Related.emergency(String value) {
    return Related(value: value, type: 'emergency');
  }

  /// Creates a copy with optional modifications.
  Related copyWith({
    String? value,
    String? type,
    int? pref,
    String? mediaType,
    String? language,
  }) {
    return Related(
      value: value ?? this.value,
      type: type ?? this.type,
      pref: pref ?? this.pref,
      mediaType: mediaType ?? this.mediaType,
      language: language ?? this.language,
    );
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Related) return false;
    return value == other.value && type == other.type;
  }

  @override
  int get hashCode => Object.hash(value, type);
}
