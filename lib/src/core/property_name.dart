/// Standard vCard property names as defined in various RFCs.
///
/// This class contains constants for all standard vCard property names
/// to ensure type-safety and prevent typos.
///
/// ## Example
///
/// ```dart
/// // Check if a property is standard
/// if (PropertyName.isStandard('EMAIL')) {
///   print('EMAIL is a standard vCard property');
/// }
///
/// // Check if a property is extended (X-)
/// if (PropertyName.isExtended('X-CUSTOM')) {
///   print('This is an extended property');
/// }
///
/// // Use property name constants
/// final fn = PropertyName.fn;        // 'FN'
/// final tel = PropertyName.tel;      // 'TEL'
/// final email = PropertyName.email;  // 'EMAIL'
/// ```
abstract final class PropertyName {
  // Identification Properties
  /// Formatted name (required in all versions).
  static const fn = 'FN';

  /// Structured name components.
  static const n = 'N';

  /// Nickname(s).
  static const nickname = 'NICKNAME';

  /// Photograph.
  static const photo = 'PHOTO';

  /// Birthday.
  static const bday = 'BDAY';

  /// Anniversary (vCard 4.0).
  static const anniversary = 'ANNIVERSARY';

  /// Gender (vCard 4.0).
  static const gender = 'GENDER';

  // Delivery Addressing Properties
  /// Postal address.
  static const adr = 'ADR';

  /// Address label (vCard 2.1/3.0, deprecated in 4.0).
  static const label = 'LABEL';

  // Communications Properties
  /// Telephone number.
  static const tel = 'TEL';

  /// Email address.
  static const email = 'EMAIL';

  /// Instant messaging and presence protocol (vCard 4.0).
  static const impp = 'IMPP';

  /// Language (vCard 4.0).
  static const lang = 'LANG';

  // Geographical Properties
  /// Timezone.
  static const tz = 'TZ';

  /// Geographic position.
  static const geo = 'GEO';

  // Organizational Properties
  /// Job title.
  static const title = 'TITLE';

  /// Role or occupation.
  static const role = 'ROLE';

  /// Organization logo.
  static const logo = 'LOGO';

  /// Organization name and units.
  static const org = 'ORG';

  /// Group membership (vCard 4.0).
  static const member = 'MEMBER';

  /// Related person (vCard 4.0).
  static const related = 'RELATED';

  // Explanatory Properties
  /// Categories/tags.
  static const categories = 'CATEGORIES';

  /// Note/comments.
  static const note = 'NOTE';

  /// Product identifier.
  static const prodid = 'PRODID';

  /// Revision timestamp.
  static const rev = 'REV';

  /// Sound/pronunciation.
  static const sound = 'SOUND';

  /// Unique identifier.
  static const uid = 'UID';

  /// Client PID map (vCard 4.0).
  static const clientpidmap = 'CLIENTPIDMAP';

  /// URL/website.
  static const url = 'URL';

  /// vCard version (required).
  static const version = 'VERSION';

  // Security Properties
  /// Public key or certificate.
  static const key = 'KEY';

  // Calendar Properties
  /// Free/busy URL (RFC 2739).
  static const fburl = 'FBURL';

  /// Calendar URI (RFC 2739).
  static const caluri = 'CALURI';

  /// Calendar address URI (RFC 2739).
  static const caladruri = 'CALADRURI';

  // vCard 4.0 Additional Properties
  /// Kind of entity (vCard 4.0).
  static const kind = 'KIND';

  /// XML content (vCard 4.0).
  static const xml = 'XML';

  /// Source URL (vCard 4.0).
  static const source = 'SOURCE';

  // Special markers
  /// Begin marker.
  static const begin = 'BEGIN';

  /// End marker.
  static const end = 'END';

  /// vCard type identifier.
  static const vcard = 'VCARD';

  /// Checks if a property name is a standard vCard property.
  static bool isStandard(String name) {
    final upper = name.toUpperCase();
    return _standardProperties.contains(upper);
  }

  /// Checks if a property name is an extended (X-) property.
  static bool isExtended(String name) {
    return name.toUpperCase().startsWith('X-');
  }

  static const _standardProperties = {
    fn,
    n,
    nickname,
    photo,
    bday,
    anniversary,
    gender,
    adr,
    label,
    tel,
    email,
    impp,
    lang,
    tz,
    geo,
    title,
    role,
    logo,
    org,
    member,
    related,
    categories,
    note,
    prodid,
    rev,
    sound,
    uid,
    clientpidmap,
    url,
    version,
    key,
    fburl,
    caluri,
    caladruri,
    kind,
    xml,
    source,
    begin,
    end,
  };
}
