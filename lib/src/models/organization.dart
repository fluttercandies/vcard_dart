/// Represents organization-related information (ORG, TITLE, ROLE properties).
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

  /// Creates a new organization.
  const Organization({required this.name, this.units = const [], this.sortAs});

  /// Creates an organization from a list of components.
  ///
  /// First element is the name, remaining are units.
  factory Organization.fromComponents(List<String> components) {
    if (components.isEmpty) {
      return const Organization(name: '');
    }
    return Organization(
      name: components.first,
      units: components.length > 1 ? components.sublist(1) : const [],
    );
  }

  /// Whether the organization name is empty.
  bool get isEmpty => name.isEmpty;

  /// Whether the organization name is not empty.
  bool get isNotEmpty => name.isNotEmpty;

  /// Converts to a list of components for serialization.
  List<String> toComponents() {
    return [name, ...units];
  }

  /// Returns a formatted string representation.
  String toFormattedString({String separator = ', '}) {
    if (units.isEmpty) return name;
    return [name, ...units].join(separator);
  }

  /// Creates a copy with optional modifications.
  Organization copyWith({String? name, List<String>? units, String? sortAs}) {
    return Organization(
      name: name ?? this.name,
      units: units ?? this.units,
      sortAs: sortAs ?? this.sortAs,
    );
  }

  @override
  String toString() => toFormattedString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Organization) return false;
    if (name != other.name) return false;
    if (units.length != other.units.length) return false;
    for (var i = 0; i < units.length; i++) {
      if (units[i] != other.units[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(name, Object.hashAll(units));
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
