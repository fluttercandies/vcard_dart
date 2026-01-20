/// Represents a postal address (ADR property).
///
/// The address consists of multiple components as defined in vCard specs.
///
/// This class supports both structured data and raw string values. When
/// the address value cannot be parsed into structured components (e.g., from
/// a non-compliant vCard or a simple address string), it will be stored as a raw value.
///
/// ## Example
///
/// ```dart
/// // Create an address
/// final work = Address(
///   street: '123 Main St',
///   city: 'San Francisco',
///   region: 'CA',
///   postalCode: '94102',
///   country: 'USA',
///   types: ['work'],
/// );
///
/// // Create with all components
/// final full = Address(
///   poBox: 'PO Box 123',
///   extended: 'Suite 100',
///   street: '456 Oak Ave',
///   city: 'Los Angeles',
///   region: 'CA',
///   postalCode: '90001',
///   country: 'USA',
///   types: ['work', 'postal'],
///   pref: 1,
/// );
///
/// // Create from components list
/// final fromList = Address.fromComponents([
///   '', '123 Main St', 'Springfield', 'IL', '62701', 'USA'
/// ]);
///
/// // Create from raw value (unstructured string)
/// final rawAddr = Address.raw('123 Main St, San Francisco, CA 94102');
/// print(rawAddr.isRaw);  // true
/// print(rawAddr.rawValue);  // '123 Main St, San Francisco, CA 94102'
///
/// // Format for display
/// final formatted = work.toFormattedString();  // Multi-line address
///
/// // Check address type
/// if (work.isWork) {
///   print('This is a work address');
/// }
/// ```
class Address {
  /// Post office box.
  final String poBox;

  /// Extended address (e.g., apartment, suite).
  final String extended;

  /// Street address.
  final String street;

  /// City/locality.
  final String city;

  /// Region/state/province.
  final String region;

  /// Postal/ZIP code.
  final String postalCode;

  /// Country name.
  final String country;

  /// Address types (e.g., "work", "home").
  final List<String> types;

  /// Preference order (1-100, lower is more preferred).
  final int? pref;

  /// Optional label for display.
  final String? label;

  /// Geographic coordinates.
  final GeoLocation? geo;

  /// Timezone.
  final String? timezone;

  /// Language tag.
  final String? language;

  /// Raw string value when the address cannot be parsed into components.
  ///
  /// This is used when the vCard contains an address that doesn't follow
  /// the standard structured format (e.g., just a plain string).
  final String? rawValue;

  /// Creates a new address.
  const Address({
    this.poBox = '',
    this.extended = '',
    this.street = '',
    this.city = '',
    this.region = '',
    this.postalCode = '',
    this.country = '',
    this.types = const [],
    this.pref,
    this.label,
    this.geo,
    this.timezone,
    this.language,
    this.rawValue,
  });

  /// Creates an address from a raw (unstructured) string.
  ///
  /// Use this when you have a plain string address that doesn't follow
  /// the structured vCard format.
  ///
  /// Example:
  /// ```dart
  /// final addr = Address.raw('123 Main St, San Francisco, CA 94102');
  /// ```
  const Address.raw(
    String value, {
    this.types = const [],
    this.pref,
    this.label,
    this.geo,
    this.timezone,
    this.language,
  })  : poBox = '',
        extended = '',
        street = '',
        city = '',
        region = '',
        postalCode = '',
        country = '',
        rawValue = value;

  /// Creates an address from a list of components.
  ///
  /// Order: poBox, extended, street, city, region, postalCode, country.
  factory Address.fromComponents(
    List<String> components, {
    List<String> types = const [],
    int? pref,
    String? label,
    GeoLocation? geo,
    String? timezone,
    String? language,
  }) {
    return Address(
      poBox: components.isNotEmpty ? components[0] : '',
      extended: components.length > 1 ? components[1] : '',
      street: components.length > 2 ? components[2] : '',
      city: components.length > 3 ? components[3] : '',
      region: components.length > 4 ? components[4] : '',
      postalCode: components.length > 5 ? components[5] : '',
      country: components.length > 6 ? components[6] : '',
      types: types,
      pref: pref,
      label: label,
      geo: geo,
      timezone: timezone,
      language: language,
    );
  }

  /// Creates an address from a value string, auto-detecting format.
  ///
  /// If the value contains semicolons, it's treated as structured data.
  /// Otherwise, it's stored as a raw value.
  ///
  /// Example:
  /// ```dart
  /// // Structured format (with semicolons)
  /// final structured = Address.fromValue(';;123 Main St;City;ST;12345;USA');
  /// print(structured.isStructured); // true
  ///
  /// // Raw format (without semicolons)
  /// final raw = Address.fromValue('123 Main St, City, ST 12345');
  /// print(raw.isRaw); // true
  /// ```
  factory Address.fromValue(
    String value, {
    List<String> types = const [],
    int? pref,
    String? label,
    GeoLocation? geo,
    String? timezone,
    String? language,
  }) {
    if (value.contains(';')) {
      // Structured format - parse components
      final components = value.split(';');
      return Address.fromComponents(
        components,
        types: types,
        pref: pref,
        label: label,
        geo: geo,
        timezone: timezone,
        language: language,
      );
    } else if (value.trim().isNotEmpty) {
      // Raw format - store as-is
      return Address.raw(
        value,
        types: types,
        pref: pref,
        label: label,
        geo: geo,
        timezone: timezone,
        language: language,
      );
    }
    return Address(
      types: types,
      pref: pref,
      label: label,
      geo: geo,
      timezone: timezone,
      language: language,
    );
  }

  /// Whether this address is stored as a raw value.
  bool get isRaw => rawValue != null;

  /// Whether this address has structured components.
  bool get isStructured => !isRaw;

  /// Whether all address components are empty (including raw value).
  bool get isEmpty =>
      (rawValue == null || rawValue!.isEmpty) &&
      poBox.isEmpty &&
      extended.isEmpty &&
      street.isEmpty &&
      city.isEmpty &&
      region.isEmpty &&
      postalCode.isEmpty &&
      country.isEmpty;

  /// Whether any address component is non-empty (including raw value).
  bool get isNotEmpty => !isEmpty;

  /// Whether this is a work address.
  bool get isWork => types.any((t) => t.toLowerCase() == 'work');

  /// Whether this is a home address.
  bool get isHome => types.any((t) => t.toLowerCase() == 'home');

  /// Whether this is the preferred address.
  bool get isPreferred =>
      (pref != null && pref! <= 1) ||
      types.any((t) => t.toLowerCase() == 'pref');

  /// Whether this is a postal address.
  bool get isPostal => types.any((t) => t.toLowerCase() == 'postal');

  /// Converts to a list of components for serialization.
  ///
  /// If this is a raw value, returns a single-element list with the raw string.
  List<String> toComponents() {
    if (rawValue != null) {
      return [rawValue!];
    }
    return [poBox, extended, street, city, region, postalCode, country];
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

  /// Returns a formatted address string.
  ///
  /// If this is a raw value, returns the raw string.
  /// Otherwise, constructs the formatted address from components.
  String toFormattedString({String separator = '\n'}) {
    if (rawValue != null) {
      return rawValue!;
    }
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (extended.isNotEmpty) parts.add(extended);
    if (poBox.isNotEmpty) parts.add('P.O. Box $poBox');

    final cityLine = <String>[];
    if (city.isNotEmpty) cityLine.add(city);
    if (region.isNotEmpty) cityLine.add(region);
    if (postalCode.isNotEmpty) cityLine.add(postalCode);
    if (cityLine.isNotEmpty) parts.add(cityLine.join(', '));

    if (country.isNotEmpty) parts.add(country);
    return parts.join(separator);
  }

  /// Creates a copy with optional modifications.
  ///
  /// Set [clearRaw] to true to remove the raw value and convert to structured format.
  ///
  /// Example:
  /// ```dart
  /// final raw = Address.raw('123 Main St');
  /// final structured = raw.copyWith(
  ///   clearRaw: true,
  ///   street: '123 Main St',
  ///   city: 'San Francisco',
  /// );
  /// print(structured.isStructured); // true
  /// ```
  Address copyWith({
    String? poBox,
    String? extended,
    String? street,
    String? city,
    String? region,
    String? postalCode,
    String? country,
    List<String>? types,
    int? pref,
    String? label,
    GeoLocation? geo,
    String? timezone,
    String? language,
    String? rawValue,
    bool clearRaw = false,
  }) {
    return Address(
      poBox: poBox ?? this.poBox,
      extended: extended ?? this.extended,
      street: street ?? this.street,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      types: types ?? this.types,
      pref: pref ?? this.pref,
      label: label ?? this.label,
      geo: geo ?? this.geo,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      rawValue: clearRaw ? null : (rawValue ?? this.rawValue),
    );
  }

  /// Converts a raw value to structured format by attempting to parse it.
  ///
  /// If this is already structured, returns this.
  /// If this is raw, attempts to parse the raw value intelligently.
  Address toStructured() {
    if (!isRaw || rawValue == null) {
      return this;
    }

    // Try to parse common address patterns
    // This is a best-effort attempt to parse unstructured addresses
    final value = rawValue!.trim();

    // Try comma-separated format: "123 Main St, City, State ZIP, Country"
    final parts = value.split(',').map((s) => s.trim()).toList();

    if (parts.length >= 4) {
      // Assume: street, city, state/zip, country
      final stateZip = parts[2].split(RegExp(r'\s+'));
      return Address(
        street: parts[0],
        city: parts[1],
        region: stateZip.isNotEmpty ? stateZip[0] : '',
        postalCode: stateZip.length > 1 ? stateZip.sublist(1).join(' ') : '',
        country: parts.length > 3 ? parts.sublist(3).join(', ') : '',
        types: types,
        pref: pref,
        label: label,
        geo: geo,
        timezone: timezone,
        language: language,
      );
    } else if (parts.length >= 2) {
      // Minimal: street, city (and maybe more)
      return Address(
        street: parts[0],
        city: parts.length > 1 ? parts[1] : '',
        region: parts.length > 2 ? parts[2] : '',
        types: types,
        pref: pref,
        label: label,
        geo: geo,
        timezone: timezone,
        language: language,
      );
    } else {
      // Single part - treat as street
      return Address(
        street: value,
        types: types,
        pref: pref,
        label: label,
        geo: geo,
        timezone: timezone,
        language: language,
      );
    }
  }

  @override
  String toString() => toFormattedString(separator: ', ');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Address) return false;
    if (rawValue != null || other.rawValue != null) {
      return rawValue == other.rawValue;
    }
    return poBox == other.poBox &&
        extended == other.extended &&
        street == other.street &&
        city == other.city &&
        region == other.region &&
        postalCode == other.postalCode &&
        country == other.country;
  }

  @override
  int get hashCode {
    if (rawValue != null) {
      return rawValue.hashCode;
    }
    return Object.hash(
        poBox, extended, street, city, region, postalCode, country);
  }
}

/// Represents a geographic location (GEO property).
///
/// ## Example
///
/// ```dart
/// // Create a location
/// final location = GeoLocation(
///   latitude: 37.7749,
///   longitude: -122.4194,
/// );
///
/// // Parse from vCard 4.0 geo URI
/// final fromUri = GeoLocation.fromUri('geo:37.7749,-122.4194');
///
/// // Parse from vCard 2.1/3.0 format
/// final fromLegacy = GeoLocation.fromLegacy('37.7749;-122.4194');
///
/// // Try parsing (handles both formats)
/// final parsed = GeoLocation.tryParse('geo:37.7749,-122.4194');
///
/// // Convert to vCard format
/// final uri = location.toUri();        // 'geo:37.7749,-122.4194'
/// final legacy = location.toLegacy();  // '37.7749;-122.4194'
/// ```
class GeoLocation {
  /// Latitude in decimal degrees.
  final double latitude;

  /// Longitude in decimal degrees.
  final double longitude;

  /// Creates a new geographic location.
  const GeoLocation({required this.latitude, required this.longitude});

  /// Creates a geo location from a vCard 4.0 geo URI.
  ///
  /// Format: `geo:latitude,longitude`
  factory GeoLocation.fromUri(String uri) {
    final match = RegExp(r'^geo:(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(uri);
    if (match == null) {
      throw FormatException('Invalid geo URI: $uri');
    }
    return GeoLocation(
      latitude: double.parse(match.group(1)!),
      longitude: double.parse(match.group(2)!),
    );
  }

  /// Creates a geo location from a vCard 2.1/3.0 value.
  ///
  /// Format: `latitude;longitude`
  factory GeoLocation.fromLegacy(String value) {
    final parts = value.split(';');
    if (parts.length != 2) {
      throw FormatException('Invalid geo value: $value');
    }
    return GeoLocation(
      latitude: double.parse(parts[0]),
      longitude: double.parse(parts[1]),
    );
  }

  /// Tries to parse a geo value, supporting both formats.
  static GeoLocation? tryParse(String value) {
    try {
      if (value.startsWith('geo:')) {
        return GeoLocation.fromUri(value);
      }
      return GeoLocation.fromLegacy(value);
    } catch (_) {
      return null;
    }
  }

  /// Converts to a geo URI (vCard 4.0 format).
  String toUri() => 'geo:$latitude,$longitude';

  /// Converts to legacy format (vCard 2.1/3.0).
  String toLegacy() => '$latitude;$longitude';

  @override
  String toString() => toUri();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GeoLocation) return false;
    return latitude == other.latitude && longitude == other.longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
