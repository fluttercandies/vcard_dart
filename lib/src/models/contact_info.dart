/// Represents a telephone number (TEL property).
///
/// ## Example
///
/// ```dart
/// // Create a telephone
/// final phone = Telephone(
///   number: '+1-555-555-5555',
///   types: ['work', 'voice'],
///   pref: 1,
/// );
///
/// // Use convenience constructors
/// final cell = Telephone.cell('+1-555-555-5555');
/// final work = Telephone.work('+1-555-555-5555');
/// final home = Telephone.home('+1-555-555-5555');
/// final fax = Telephone.fax('+1-555-555-5555');
///
/// // Check phone type
/// if (cell.isCell) {
///   print('This is a cell phone');
/// }
///
/// // Get tel: URI format
/// final uri = phone.toUri();  // 'tel:+15555555555'
/// ```
class Telephone {
  /// The phone number value.
  final String number;

  /// Phone types (e.g., "work", "cell", "fax").
  final List<String> types;

  /// Preference order (1-100, lower is more preferred).
  final int? pref;

  /// Optional extension.
  final String? extension;

  /// Creates a new telephone entry.
  const Telephone({
    required this.number,
    this.types = const [],
    this.pref,
    this.extension,
  });

  /// Creates a cell/mobile phone.
  factory Telephone.cell(String number, {int? pref}) {
    return Telephone(number: number, types: const ['cell'], pref: pref);
  }

  /// Creates a work phone.
  factory Telephone.work(String number, {int? pref}) {
    return Telephone(
      number: number,
      types: const ['work', 'voice'],
      pref: pref,
    );
  }

  /// Creates a home phone.
  factory Telephone.home(String number, {int? pref}) {
    return Telephone(
      number: number,
      types: const ['home', 'voice'],
      pref: pref,
    );
  }

  /// Creates a fax number.
  factory Telephone.fax(String number, {bool work = false, int? pref}) {
    return Telephone(
      number: number,
      types: work ? const ['work', 'fax'] : const ['fax'],
      pref: pref,
    );
  }

  /// Whether this is a cell/mobile phone.
  bool get isCell => types.any((t) => t.toLowerCase() == 'cell');

  /// Whether this is a work phone.
  bool get isWork => types.any((t) => t.toLowerCase() == 'work');

  /// Whether this is a home phone.
  bool get isHome => types.any((t) => t.toLowerCase() == 'home');

  /// Whether this is a fax number.
  bool get isFax => types.any((t) => t.toLowerCase() == 'fax');

  /// Whether this is the preferred phone.
  bool get isPreferred =>
      (pref != null && pref! <= 1) ||
      types.any((t) => t.toLowerCase() == 'pref');

  /// Returns the phone number in tel: URI format.
  String toUri() {
    final sanitized = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (extension != null) {
      return 'tel:$sanitized;ext=$extension';
    }
    return 'tel:$sanitized';
  }

  /// Creates a copy with optional modifications.
  Telephone copyWith({
    String? number,
    List<String>? types,
    int? pref,
    String? extension,
  }) {
    return Telephone(
      number: number ?? this.number,
      types: types ?? this.types,
      pref: pref ?? this.pref,
      extension: extension ?? this.extension,
    );
  }

  @override
  String toString() => number;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Telephone) return false;
    return number == other.number;
  }

  @override
  int get hashCode => number.hashCode;
}

/// Represents an email address (EMAIL property).
///
/// ## Example
///
/// ```dart
/// // Create an email
/// final email = Email(
///   address: 'john@example.com',
///   types: ['work'],
///   pref: 1,
/// );
///
/// // Use convenience constructors
/// final work = Email.work('john@company.com');
/// final home = Email.home('john@example.com');
///
/// // Check email type
/// if (work.isWork) {
///   print('This is a work email');
/// }
///
/// // Get mailto: URI format
/// final uri = email.toUri();  // 'mailto:john@example.com'
/// ```
class Email {
  /// The email address value.
  final String address;

  /// Email types (e.g., "work", "home").
  final List<String> types;

  /// Preference order (1-100, lower is more preferred).
  final int? pref;

  /// Creates a new email entry.
  const Email({required this.address, this.types = const [], this.pref});

  /// Creates a work email.
  factory Email.work(String address, {int? pref}) {
    return Email(address: address, types: const ['work'], pref: pref);
  }

  /// Creates a home/personal email.
  factory Email.home(String address, {int? pref}) {
    return Email(address: address, types: const ['home'], pref: pref);
  }

  /// Whether this is a work email.
  bool get isWork => types.any((t) => t.toLowerCase() == 'work');

  /// Whether this is a home email.
  bool get isHome => types.any((t) => t.toLowerCase() == 'home');

  /// Whether this is the preferred email.
  bool get isPreferred =>
      (pref != null && pref! <= 1) ||
      types.any((t) => t.toLowerCase() == 'pref');

  /// Returns the email in mailto: URI format.
  String toUri() => 'mailto:$address';

  /// Creates a copy with optional modifications.
  Email copyWith({String? address, List<String>? types, int? pref}) {
    return Email(
      address: address ?? this.address,
      types: types ?? this.types,
      pref: pref ?? this.pref,
    );
  }

  @override
  String toString() => address;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Email) return false;
    return address.toLowerCase() == other.address.toLowerCase();
  }

  @override
  int get hashCode => address.toLowerCase().hashCode;
}

/// Represents an instant messaging address (IMPP property).
///
/// ## Example
///
/// ```dart
/// // Create an IM address
/// final im = InstantMessaging(
///   uri: 'xmpp:user@example.com',
///   types: ['work'],
/// );
///
/// // Use convenience constructors
/// final xmpp = InstantMessaging.xmpp('user@example.com');
/// final skype = InstantMessaging.skype('username');
/// final sip = InstantMessaging.sip('user@example.com');
///
/// // Get IM protocol
/// final protocol = im.scheme;  // 'xmpp'
/// final address = im.address;  // 'user@example.com'
/// ```
class InstantMessaging {
  /// The IM URI (e.g., "xmpp:user@example.com").
  final String uri;

  /// IM types (e.g., "work", "home").
  final List<String> types;

  /// Preference order (1-100, lower is more preferred).
  final int? pref;

  /// Creates a new IM entry.
  const InstantMessaging({required this.uri, this.types = const [], this.pref});

  /// Creates an XMPP/Jabber IM address.
  factory InstantMessaging.xmpp(
    String address, {
    List<String>? types,
    int? pref,
  }) {
    return InstantMessaging(
      uri: address.startsWith('xmpp:') ? address : 'xmpp:$address',
      types: types ?? const [],
      pref: pref,
    );
  }

  /// Creates a Skype IM address.
  factory InstantMessaging.skype(
    String username, {
    List<String>? types,
    int? pref,
  }) {
    return InstantMessaging(
      uri: 'skype:$username',
      types: types ?? const [],
      pref: pref,
    );
  }

  /// Creates a SIP IM address.
  factory InstantMessaging.sip(
    String address, {
    List<String>? types,
    int? pref,
  }) {
    return InstantMessaging(
      uri: address.startsWith('sip:') ? address : 'sip:$address',
      types: types ?? const [],
      pref: pref,
    );
  }

  /// The scheme/protocol of the IM URI.
  String? get scheme {
    final colonIndex = uri.indexOf(':');
    return colonIndex > 0 ? uri.substring(0, colonIndex) : null;
  }

  /// The username/address part of the URI.
  String? get address {
    final colonIndex = uri.indexOf(':');
    return colonIndex > 0 ? uri.substring(colonIndex + 1) : uri;
  }

  /// Whether this is a work IM.
  bool get isWork => types.any((t) => t.toLowerCase() == 'work');

  /// Whether this is a home IM.
  bool get isHome => types.any((t) => t.toLowerCase() == 'home');

  /// Whether this is the preferred IM.
  bool get isPreferred =>
      (pref != null && pref! <= 1) ||
      types.any((t) => t.toLowerCase() == 'pref');

  /// Creates a copy with optional modifications.
  InstantMessaging copyWith({String? uri, List<String>? types, int? pref}) {
    return InstantMessaging(
      uri: uri ?? this.uri,
      types: types ?? this.types,
      pref: pref ?? this.pref,
    );
  }

  @override
  String toString() => uri;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InstantMessaging) return false;
    return uri == other.uri;
  }

  @override
  int get hashCode => uri.hashCode;
}

/// Represents a URL (URL property).
///
/// ## Example
///
/// ```dart
/// // Create a URL
/// final url = WebUrl(
///   url: 'https://example.com',
///   types: ['work'],
///   pref: 1,
/// );
///
/// // Use convenience constructors
/// final work = WebUrl.work('https://company.com');
/// final home = WebUrl.home('https://example.com');
///
/// // Check URL type
/// if (work.isWork) {
///   print('This is a work URL');
/// }
/// ```
class WebUrl {
  /// The URL value.
  final String url;

  /// URL types (e.g., "work", "home").
  final List<String> types;

  /// Preference order (1-100, lower is more preferred).
  final int? pref;

  /// Optional media type.
  final String? mediaType;

  /// Creates a new URL entry.
  const WebUrl({
    required this.url,
    this.types = const [],
    this.pref,
    this.mediaType,
  });

  /// Creates a work URL.
  factory WebUrl.work(String url, {int? pref}) {
    return WebUrl(url: url, types: const ['work'], pref: pref);
  }

  /// Creates a home/personal URL.
  factory WebUrl.home(String url, {int? pref}) {
    return WebUrl(url: url, types: const ['home'], pref: pref);
  }

  /// Whether this is a work URL.
  bool get isWork => types.any((t) => t.toLowerCase() == 'work');

  /// Whether this is a home URL.
  bool get isHome => types.any((t) => t.toLowerCase() == 'home');

  /// Whether this is the preferred URL.
  bool get isPreferred =>
      (pref != null && pref! <= 1) ||
      types.any((t) => t.toLowerCase() == 'pref');

  /// Creates a copy with optional modifications.
  WebUrl copyWith({
    String? url,
    List<String>? types,
    int? pref,
    String? mediaType,
  }) {
    return WebUrl(
      url: url ?? this.url,
      types: types ?? this.types,
      pref: pref ?? this.pref,
      mediaType: mediaType ?? this.mediaType,
    );
  }

  @override
  String toString() => url;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WebUrl) return false;
    return url == other.url;
  }

  @override
  int get hashCode => url.hashCode;
}
