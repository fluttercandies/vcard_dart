/// Standard vCard parameter names.
///
/// Parameters modify the behavior or meaning of vCard properties.
///
/// ## Example
///
/// ```dart
/// // Check if a parameter is standard
/// if (ParameterName.isStandard('TYPE')) {
///   print('TYPE is a standard parameter');
/// }
///
/// // Use parameter constants
/// final typeParam = ParameterName.type;        // 'TYPE'
/// final prefParam = ParameterName.pref;        // 'PREF'
/// final langParam = ParameterName.language;    // 'LANGUAGE'
/// ```
abstract final class ParameterName {
  /// Language tag (e.g., "en-US").
  static const language = 'LANGUAGE';

  /// Value data type.
  static const value = 'VALUE';

  /// Preference order (1-100, lower is more preferred).
  static const pref = 'PREF';

  /// Alternate representation ID.
  static const altid = 'ALTID';

  /// Property ID.
  static const pid = 'PID';

  /// Type (e.g., "work", "home").
  static const type = 'TYPE';

  /// Media type (MIME type).
  static const mediatype = 'MEDIATYPE';

  /// Calendar scale.
  static const calscale = 'CALSCALE';

  /// Sort-as string.
  static const sortAs = 'SORT-AS';

  /// Geographic position (for TZ property).
  static const geoPosition = 'GEO';

  /// Timezone (for date-time values).
  static const timezone = 'TZ';

  /// Label (vCard 4.0 alternative to LABEL property).
  static const label = 'LABEL';

  // Legacy parameters (vCard 2.1/3.0)

  /// Character encoding (vCard 2.1/3.0).
  static const encoding = 'ENCODING';

  /// Character set (vCard 2.1).
  static const charset = 'CHARSET';

  /// Context (vCard 2.1, precursor to TYPE).
  static const context = 'CONTEXT';

  /// Checks if a parameter name is standard.
  static bool isStandard(String name) {
    final upper = name.toUpperCase();
    return _standardParameters.contains(upper);
  }

  static const _standardParameters = {
    language,
    value,
    pref,
    altid,
    pid,
    type,
    mediatype,
    calscale,
    sortAs,
    geoPosition,
    timezone,
    label,
    encoding,
    charset,
    context,
  };
}

/// Standard TYPE parameter values.
///
/// ## Example
///
/// ```dart
/// // Common type values
/// final homeType = TypeValue.home;    // 'home'
/// final workType = TypeValue.work;    // 'work'
/// final cellType = TypeValue.cell;    // 'cell'
/// final prefType = TypeValue.pref;    // 'pref'
///
/// // Relationship types
/// final spouse = TypeValue.spouse;    // 'spouse'
/// final child = TypeValue.child;      // 'child'
/// final emergency = TypeValue.emergency;  // 'emergency'
/// ```
abstract final class TypeValue {
  // Address/Phone types
  static const home = 'home';
  static const work = 'work';
  static const cell = 'cell';
  static const voice = 'voice';
  static const fax = 'fax';
  static const pager = 'pager';
  static const textphone = 'textphone';
  static const text = 'text';
  static const video = 'video';

  // Preferred
  static const pref = 'pref';

  // Email types
  static const internet = 'internet';

  // Relationship types (RELATED property)
  static const contact = 'contact';
  static const acquaintance = 'acquaintance';
  static const friend = 'friend';
  static const met = 'met';
  static const coWorker = 'co-worker';
  static const colleague = 'colleague';
  static const coResident = 'co-resident';
  static const neighbor = 'neighbor';
  static const child = 'child';
  static const parent = 'parent';
  static const sibling = 'sibling';
  static const spouse = 'spouse';
  static const kin = 'kin';
  static const muse = 'muse';
  static const crush = 'crush';
  static const date = 'date';
  static const sweetheart = 'sweetheart';
  static const me = 'me';
  static const agent = 'agent';
  static const emergency = 'emergency';
}

/// Standard VALUE parameter values.
///
/// ## Example
///
/// ```dart
/// // Data type values
/// final textType = ValueType.text;       // 'text'
/// final uriType = ValueType.uri;         // 'uri'
/// final dateType = ValueType.date;       // 'date'
/// final dateTimeType = ValueType.dateTime;  // 'date-time'
/// ```
abstract final class ValueType {
  static const text = 'text';
  static const uri = 'uri';
  static const date = 'date';
  static const time = 'time';
  static const dateTime = 'date-time';
  static const dateAndOrTime = 'date-and-or-time';
  static const timestamp = 'timestamp';
  static const boolean = 'boolean';
  static const integer = 'integer';
  static const float = 'float';
  static const utcOffset = 'utc-offset';
  static const languageTag = 'language-tag';
}

/// Standard ENCODING parameter values (vCard 2.1/3.0).
///
/// ## Example
///
/// ```dart
/// // Encoding values
/// final base64 = EncodingValue.base64;           // 'BASE64'
/// final b = EncodingValue.b;                     // 'b'
/// final quotedPrintable = EncodingValue.quotedPrintable;  // 'QUOTED-PRINTABLE'
/// ```
abstract final class EncodingValue {
  static const base64 = 'BASE64';
  static const b = 'b';
  static const quotedPrintable = 'QUOTED-PRINTABLE';
  static const bit8 = '8BIT';
}
