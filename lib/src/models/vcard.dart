import '../core/property.dart';
import '../core/version.dart';
import 'address.dart';
import 'binary_data.dart';
import 'contact_info.dart';
import 'organization.dart';
import 'structured_name.dart';
import 'types.dart';

/// Represents a complete vCard contact.
///
/// This class provides a high-level, type-safe API for working with vCard data.
/// It supports all standard vCard properties as defined in RFC 2426 (vCard 3.0)
/// and RFC 6350 (vCard 4.0), as well as legacy vCard 2.1 format.
///
/// ## Example
///
/// ```dart
/// // Create a vCard
/// final vcard = VCard(version: VCardVersion.v40)
///   ..formattedName = 'John Doe'
///   ..name = StructuredName(
///     family: 'Doe',
///     given: 'John',
///     additional: ['William'],
///   )
///   ..emails.add(Email.work('john@example.com'))
///   ..telephones.add(Telephone.cell('+1-555-555-5555'))
///   ..addresses.add(Address(
///     street: '123 Main St',
///     city: 'San Francisco',
///     region: 'CA',
///     postalCode: '94102',
///     country: 'USA',
///   ));
///
/// // Get primary contact info
/// final primaryEmail = vcard.primaryEmail;
/// final primaryPhone = vcard.primaryPhone;
/// final primaryAddress = vcard.primaryAddress;
///
/// // Check validity
/// if (vcard.isValid) {
///   print('vCard has required FN property');
/// }
/// ```
class VCard {
  /// The vCard version.
  VCardVersion version;

  // Identification Properties

  /// The formatted name (FN property, required).
  String formattedName;

  /// The structured name (N property).
  StructuredName? name;

  /// Nicknames (NICKNAME property).
  List<String> nicknames;

  /// Photos (PHOTO property).
  List<Photo> photos;

  /// Birthday (BDAY property).
  DateOrDateTime? birthday;

  /// Anniversary (ANNIVERSARY property, vCard 4.0).
  DateOrDateTime? anniversary;

  /// Gender (GENDER property, vCard 4.0).
  Gender? gender;

  // Delivery Addressing Properties

  /// Postal addresses (ADR property).
  List<Address> addresses;

  // Communications Properties

  /// Telephone numbers (TEL property).
  List<Telephone> telephones;

  /// Email addresses (EMAIL property).
  List<Email> emails;

  /// Instant messaging addresses (IMPP property).
  List<InstantMessaging> impps;

  /// Language preferences (LANG property, vCard 4.0).
  List<LanguagePref> languages;

  // Geographical Properties

  /// Timezone (TZ property).
  String? timezone;

  /// Geographic location (GEO property).
  GeoLocation? geo;

  // Organizational Properties

  /// Job title (TITLE property).
  String? title;

  /// Role/occupation (ROLE property).
  String? role;

  /// Organization logo (LOGO property).
  Logo? logo;

  /// Organization (ORG property).
  Organization? organization;

  /// Group members (MEMBER property, vCard 4.0).
  List<String> members;

  /// Related persons (RELATED property, vCard 4.0).
  List<Related> related;

  // Explanatory Properties

  /// Categories/tags (CATEGORIES property).
  List<String> categories;

  /// Note/comments (NOTE property).
  String? note;

  /// Product identifier (PRODID property).
  String? productId;

  /// Revision timestamp (REV property).
  DateOrDateTime? revision;

  /// Sound/pronunciation (SOUND property).
  Sound? sound;

  /// Unique identifier (UID property).
  String? uid;

  /// URLs (URL property).
  List<WebUrl> urls;

  // Security Properties

  /// Public keys/certificates (KEY property).
  List<Key> keys;

  // Calendar Properties (RFC 2739)

  /// Free/busy URLs (FBURL property).
  List<String> freeBusyUrls;

  /// Calendar URLs (CALURI property).
  List<String> calendarUrls;

  /// Calendar address URLs (CALADRURI property).
  List<String> calendarAddressUrls;

  // vCard 4.0 Properties

  /// Kind of entity (KIND property).
  VCardKind? kind;

  /// XML content (XML property).
  List<String> xml;

  /// Source URLs (SOURCE property).
  List<String> sources;

  // Extended Properties

  /// Extended (X-) properties.
  final List<VCardProperty> extendedProperties;

  /// All raw properties (for round-trip preservation).
  final List<VCardProperty> rawProperties;

  /// Creates a new vCard with default values.
  VCard({
    this.version = VCardVersion.v40,
    this.formattedName = '',
    this.name,
    List<String>? nicknames,
    List<Photo>? photos,
    this.birthday,
    this.anniversary,
    this.gender,
    List<Address>? addresses,
    List<Telephone>? telephones,
    List<Email>? emails,
    List<InstantMessaging>? impps,
    List<LanguagePref>? languages,
    this.timezone,
    this.geo,
    this.title,
    this.role,
    this.logo,
    this.organization,
    List<String>? members,
    List<Related>? related,
    List<String>? categories,
    this.note,
    this.productId,
    this.revision,
    this.sound,
    this.uid,
    List<WebUrl>? urls,
    List<Key>? keys,
    List<String>? freeBusyUrls,
    List<String>? calendarUrls,
    List<String>? calendarAddressUrls,
    this.kind,
    List<String>? xml,
    List<String>? sources,
    List<VCardProperty>? extendedProperties,
    List<VCardProperty>? rawProperties,
  }) : nicknames = nicknames ?? [],
       photos = photos ?? [],
       addresses = addresses ?? [],
       telephones = telephones ?? [],
       emails = emails ?? [],
       impps = impps ?? [],
       languages = languages ?? [],
       members = members ?? [],
       related = related ?? [],
       categories = categories ?? [],
       urls = urls ?? [],
       keys = keys ?? [],
       freeBusyUrls = freeBusyUrls ?? [],
       calendarUrls = calendarUrls ?? [],
       calendarAddressUrls = calendarAddressUrls ?? [],
       xml = xml ?? [],
       sources = sources ?? [],
       extendedProperties = extendedProperties ?? [],
       rawProperties = rawProperties ?? [];

  /// Whether the vCard has the required FN property.
  bool get isValid => formattedName.isNotEmpty;

  /// The primary email address.
  Email? get primaryEmail {
    if (emails.isEmpty) return null;
    return emails.firstWhere((e) => e.isPreferred, orElse: () => emails.first);
  }

  /// The primary phone number.
  Telephone? get primaryPhone {
    if (telephones.isEmpty) return null;
    return telephones.firstWhere(
      (t) => t.isPreferred,
      orElse: () => telephones.first,
    );
  }

  /// The primary address.
  Address? get primaryAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isPreferred,
      orElse: () => addresses.first,
    );
  }

  /// The primary URL.
  WebUrl? get primaryUrl {
    if (urls.isEmpty) return null;
    return urls.firstWhere((u) => u.isPreferred, orElse: () => urls.first);
  }

  /// The primary photo.
  Photo? get primaryPhoto {
    if (photos.isEmpty) return null;
    return photos.firstWhere(
      (p) => p.pref != null && p.pref! <= 1,
      orElse: () => photos.first,
    );
  }

  /// Gets an extended property by name.
  VCardProperty? getExtendedProperty(String name) {
    final upper = name.toUpperCase();
    for (final prop in extendedProperties) {
      if (prop.upperName == upper) {
        return prop;
      }
    }
    return null;
  }

  /// Gets all extended properties with the given name.
  List<VCardProperty> getExtendedProperties(String name) {
    final upper = name.toUpperCase();
    return extendedProperties.where((p) => p.upperName == upper).toList();
  }

  /// Adds an extended property.
  void addExtendedProperty(String name, String value) {
    extendedProperties.add(
      VCardProperty(
        name: name.toUpperCase().startsWith('X-') ? name : 'X-$name',
        value: value,
      ),
    );
  }

  /// Gets a raw property by name.
  VCardProperty? getRawProperty(String name) {
    final upper = name.toUpperCase();
    for (final prop in rawProperties) {
      if (prop.upperName == upper) {
        return prop;
      }
    }
    return null;
  }

  /// Gets all raw properties with the given name.
  List<VCardProperty> getRawProperties(String name) {
    final upper = name.toUpperCase();
    return rawProperties.where((p) => p.upperName == upper).toList();
  }

  /// Creates a copy of this vCard with optional modifications.
  VCard copyWith({
    VCardVersion? version,
    String? formattedName,
    StructuredName? name,
    List<String>? nicknames,
    List<Photo>? photos,
    DateOrDateTime? birthday,
    DateOrDateTime? anniversary,
    Gender? gender,
    List<Address>? addresses,
    List<Telephone>? telephones,
    List<Email>? emails,
    List<InstantMessaging>? impps,
    List<LanguagePref>? languages,
    String? timezone,
    GeoLocation? geo,
    String? title,
    String? role,
    Logo? logo,
    Organization? organization,
    List<String>? members,
    List<Related>? related,
    List<String>? categories,
    String? note,
    String? productId,
    DateOrDateTime? revision,
    Sound? sound,
    String? uid,
    List<WebUrl>? urls,
    List<Key>? keys,
    List<String>? freeBusyUrls,
    List<String>? calendarUrls,
    List<String>? calendarAddressUrls,
    VCardKind? kind,
    List<String>? xml,
    List<String>? sources,
    List<VCardProperty>? extendedProperties,
    List<VCardProperty>? rawProperties,
  }) {
    return VCard(
      version: version ?? this.version,
      formattedName: formattedName ?? this.formattedName,
      name: name ?? this.name,
      nicknames: nicknames ?? List.from(this.nicknames),
      photos: photos ?? List.from(this.photos),
      birthday: birthday ?? this.birthday,
      anniversary: anniversary ?? this.anniversary,
      gender: gender ?? this.gender,
      addresses: addresses ?? List.from(this.addresses),
      telephones: telephones ?? List.from(this.telephones),
      emails: emails ?? List.from(this.emails),
      impps: impps ?? List.from(this.impps),
      languages: languages ?? List.from(this.languages),
      timezone: timezone ?? this.timezone,
      geo: geo ?? this.geo,
      title: title ?? this.title,
      role: role ?? this.role,
      logo: logo ?? this.logo,
      organization: organization ?? this.organization,
      members: members ?? List.from(this.members),
      related: related ?? List.from(this.related),
      categories: categories ?? List.from(this.categories),
      note: note ?? this.note,
      productId: productId ?? this.productId,
      revision: revision ?? this.revision,
      sound: sound ?? this.sound,
      uid: uid ?? this.uid,
      urls: urls ?? List.from(this.urls),
      keys: keys ?? List.from(this.keys),
      freeBusyUrls: freeBusyUrls ?? List.from(this.freeBusyUrls),
      calendarUrls: calendarUrls ?? List.from(this.calendarUrls),
      calendarAddressUrls:
          calendarAddressUrls ?? List.from(this.calendarAddressUrls),
      kind: kind ?? this.kind,
      xml: xml ?? List.from(this.xml),
      sources: sources ?? List.from(this.sources),
      extendedProperties:
          extendedProperties ?? List.from(this.extendedProperties),
      rawProperties: rawProperties ?? List.from(this.rawProperties),
    );
  }

  @override
  String toString() {
    return 'VCard(fn: $formattedName, version: ${version.value})';
  }
}
