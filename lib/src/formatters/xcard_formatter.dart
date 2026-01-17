import '../core/version.dart';
import '../exceptions.dart';
import '../models/address.dart';
import '../models/binary_data.dart';
import '../models/contact_info.dart';
import '../models/organization.dart';
import '../models/structured_name.dart';
import '../models/types.dart';
import '../models/vcard.dart';

/// Converts between VCard objects and xCard (XML) format.
///
/// xCard is defined in RFC 6351 as the XML representation of vCard.
///
/// ## Example
///
/// ```dart
/// // Convert vCard to xCard XML
/// final formatter = XCardFormatter();
/// final xml = formatter.toXml(vcard);
///
/// // Convert to pretty XML
/// final prettyXml = formatter.toXml(vcard, pretty: true);
///
/// // Parse xCard XML to vCard
/// final parsed = formatter.fromXml(xml);
///
/// // Parse xCard XML string
/// final fromString = formatter.fromXmlString(xmlString);
/// ```
class XCardFormatter {
  /// The xCard XML namespace.
  static const namespace = 'urn:ietf:params:xml:ns:vcard-4.0';

  /// Creates a new xCard formatter.
  const XCardFormatter();

  /// Converts a VCard to xCard XML string.
  String toXml(VCard vcard, {bool pretty = false}) {
    final buffer = StringBuffer();
    final indent = pretty ? '  ' : '';
    final newline = pretty ? '\n' : '';

    buffer.write('<?xml version="1.0" encoding="UTF-8"?>$newline');
    buffer.write('<vcards xmlns="$namespace">$newline');
    buffer.write('$indent<vcard>$newline');

    // VERSION
    _writeElement(
      buffer,
      'version',
      'text',
      '4.0',
      indent: indent * 2,
      newline: newline,
    );

    // FN (required)
    _writeElement(
      buffer,
      'fn',
      'text',
      _escapeXml(vcard.formattedName),
      indent: indent * 2,
      newline: newline,
    );

    // N
    if (vcard.name != null && vcard.name!.isNotEmpty) {
      buffer.write('$indent$indent<n>$newline');
      _writeElement(
        buffer,
        'surname',
        null,
        _escapeXml(vcard.name!.family),
        indent: indent * 3,
        newline: newline,
      );
      _writeElement(
        buffer,
        'given',
        null,
        _escapeXml(vcard.name!.given),
        indent: indent * 3,
        newline: newline,
      );
      _writeElement(
        buffer,
        'additional',
        null,
        _escapeXml(vcard.name!.additional.join(',')),
        indent: indent * 3,
        newline: newline,
      );
      _writeElement(
        buffer,
        'prefix',
        null,
        _escapeXml(vcard.name!.prefixes.join(',')),
        indent: indent * 3,
        newline: newline,
      );
      _writeElement(
        buffer,
        'suffix',
        null,
        _escapeXml(vcard.name!.suffixes.join(',')),
        indent: indent * 3,
        newline: newline,
      );
      buffer.write('$indent$indent</n>$newline');
    }

    // NICKNAME
    if (vcard.nicknames.isNotEmpty) {
      for (final nick in vcard.nicknames) {
        _writeElement(
          buffer,
          'nickname',
          'text',
          _escapeXml(nick),
          indent: indent * 2,
          newline: newline,
        );
      }
    }

    // PHOTO
    for (final photo in vcard.photos) {
      _writeBinaryElement(
        buffer,
        'photo',
        photo,
        types: photo.types,
        pref: photo.pref,
        indent: indent * 2,
        newline: newline,
      );
    }

    // BDAY
    if (vcard.birthday != null && vcard.birthday!.isNotEmpty) {
      final type = vcard.birthday!.hasTime ? 'date-time' : 'date';
      _writeElement(
        buffer,
        'bday',
        type,
        vcard.birthday.toString(),
        indent: indent * 2,
        newline: newline,
      );
    }

    // ANNIVERSARY
    if (vcard.anniversary != null && vcard.anniversary!.isNotEmpty) {
      final type = vcard.anniversary!.hasTime ? 'date-time' : 'date';
      _writeElement(
        buffer,
        'anniversary',
        type,
        vcard.anniversary.toString(),
        indent: indent * 2,
        newline: newline,
      );
    }

    // GENDER
    if (vcard.gender != null && vcard.gender!.isNotEmpty) {
      buffer.write('$indent$indent<gender>$newline');
      if (vcard.gender!.sex != null) {
        _writeElement(
          buffer,
          'sex',
          null,
          vcard.gender!.sex!,
          indent: indent * 3,
          newline: newline,
        );
      }
      if (vcard.gender!.identity != null) {
        _writeElement(
          buffer,
          'identity',
          null,
          _escapeXml(vcard.gender!.identity!),
          indent: indent * 3,
          newline: newline,
        );
      }
      buffer.write('$indent$indent</gender>$newline');
    }

    // ADR
    for (final addr in vcard.addresses) {
      _writeAddressElement(buffer, addr, indent: indent * 2, newline: newline);
    }

    // TEL
    for (final tel in vcard.telephones) {
      _writeElement(
        buffer,
        'tel',
        'uri',
        tel.toUri(),
        types: tel.types,
        pref: tel.pref,
        indent: indent * 2,
        newline: newline,
      );
    }

    // EMAIL
    for (final email in vcard.emails) {
      _writeElement(
        buffer,
        'email',
        'text',
        _escapeXml(email.address),
        types: email.types,
        pref: email.pref,
        indent: indent * 2,
        newline: newline,
      );
    }

    // IMPP
    for (final impp in vcard.impps) {
      _writeElement(
        buffer,
        'impp',
        'uri',
        impp.uri,
        types: impp.types,
        pref: impp.pref,
        indent: indent * 2,
        newline: newline,
      );
    }

    // LANG
    for (final lang in vcard.languages) {
      _writeElement(
        buffer,
        'lang',
        'language-tag',
        lang.tag,
        types: lang.types,
        pref: lang.pref,
        indent: indent * 2,
        newline: newline,
      );
    }

    // TZ
    if (vcard.timezone != null && vcard.timezone!.isNotEmpty) {
      _writeElement(
        buffer,
        'tz',
        'text',
        _escapeXml(vcard.timezone!),
        indent: indent * 2,
        newline: newline,
      );
    }

    // GEO
    if (vcard.geo != null) {
      _writeElement(
        buffer,
        'geo',
        'uri',
        vcard.geo!.toUri(),
        indent: indent * 2,
        newline: newline,
      );
    }

    // TITLE
    if (vcard.title != null && vcard.title!.isNotEmpty) {
      _writeElement(
        buffer,
        'title',
        'text',
        _escapeXml(vcard.title!),
        indent: indent * 2,
        newline: newline,
      );
    }

    // ROLE
    if (vcard.role != null && vcard.role!.isNotEmpty) {
      _writeElement(
        buffer,
        'role',
        'text',
        _escapeXml(vcard.role!),
        indent: indent * 2,
        newline: newline,
      );
    }

    // LOGO
    if (vcard.logo != null && vcard.logo!.isNotEmpty) {
      _writeBinaryElement(
        buffer,
        'logo',
        vcard.logo!,
        indent: indent * 2,
        newline: newline,
      );
    }

    // ORG
    if (vcard.organization != null && vcard.organization!.isNotEmpty) {
      _writeOrgElement(
        buffer,
        vcard.organization!,
        indent: indent * 2,
        newline: newline,
      );
    }

    // MEMBER
    for (final member in vcard.members) {
      _writeElement(
        buffer,
        'member',
        'uri',
        member,
        indent: indent * 2,
        newline: newline,
      );
    }

    // RELATED
    for (final rel in vcard.related) {
      _writeElement(
        buffer,
        'related',
        'uri',
        rel.value,
        types: rel.type != null ? [rel.type!] : null,
        pref: rel.pref,
        indent: indent * 2,
        newline: newline,
      );
    }

    // CATEGORIES
    if (vcard.categories.isNotEmpty) {
      buffer.write('$indent$indent<categories>$newline');
      for (final cat in vcard.categories) {
        _writeElement(
          buffer,
          'text',
          null,
          _escapeXml(cat),
          indent: indent * 3,
          newline: newline,
        );
      }
      buffer.write('$indent$indent</categories>$newline');
    }

    // NOTE
    if (vcard.note != null && vcard.note!.isNotEmpty) {
      _writeElement(
        buffer,
        'note',
        'text',
        _escapeXml(vcard.note!),
        indent: indent * 2,
        newline: newline,
      );
    }

    // PRODID
    if (vcard.productId != null && vcard.productId!.isNotEmpty) {
      _writeElement(
        buffer,
        'prodid',
        'text',
        _escapeXml(vcard.productId!),
        indent: indent * 2,
        newline: newline,
      );
    }

    // REV
    if (vcard.revision != null && vcard.revision!.isNotEmpty) {
      _writeElement(
        buffer,
        'rev',
        'timestamp',
        vcard.revision!.toDateTimeString(),
        indent: indent * 2,
        newline: newline,
      );
    }

    // SOUND
    if (vcard.sound != null && vcard.sound!.isNotEmpty) {
      _writeBinaryElement(
        buffer,
        'sound',
        vcard.sound!,
        indent: indent * 2,
        newline: newline,
      );
    }

    // UID
    if (vcard.uid != null && vcard.uid!.isNotEmpty) {
      _writeElement(
        buffer,
        'uid',
        'uri',
        vcard.uid!,
        indent: indent * 2,
        newline: newline,
      );
    }

    // URL
    for (final url in vcard.urls) {
      _writeElement(
        buffer,
        'url',
        'uri',
        url.url,
        types: url.types,
        pref: url.pref,
        indent: indent * 2,
        newline: newline,
      );
    }

    // KEY
    for (final key in vcard.keys) {
      _writeBinaryElement(
        buffer,
        'key',
        key,
        indent: indent * 2,
        newline: newline,
      );
    }

    // Calendar properties
    for (final fbUrl in vcard.freeBusyUrls) {
      _writeElement(
        buffer,
        'fburl',
        'uri',
        fbUrl,
        indent: indent * 2,
        newline: newline,
      );
    }
    for (final calUrl in vcard.calendarUrls) {
      _writeElement(
        buffer,
        'caluri',
        'uri',
        calUrl,
        indent: indent * 2,
        newline: newline,
      );
    }
    for (final calAdrUrl in vcard.calendarAddressUrls) {
      _writeElement(
        buffer,
        'caladruri',
        'uri',
        calAdrUrl,
        indent: indent * 2,
        newline: newline,
      );
    }

    // KIND
    if (vcard.kind != null) {
      _writeElement(
        buffer,
        'kind',
        'text',
        vcard.kind!.value,
        indent: indent * 2,
        newline: newline,
      );
    }

    // SOURCE
    for (final source in vcard.sources) {
      _writeElement(
        buffer,
        'source',
        'uri',
        source,
        indent: indent * 2,
        newline: newline,
      );
    }

    // Extended properties
    for (final prop in vcard.extendedProperties) {
      _writeElement(
        buffer,
        prop.name.toLowerCase(),
        'unknown',
        _escapeXml(prop.value),
        indent: indent * 2,
        newline: newline,
      );
    }

    buffer.write('$indent</vcard>$newline');
    buffer.write('</vcards>');

    return buffer.toString();
  }

  /// Parses an xCard XML string into a VCard.
  VCard fromXml(String xml) {
    final vcard = VCard(version: VCardVersion.v40);

    // Simple XML parsing without external dependencies
    // Extract vcard element content
    final vcardMatch = RegExp(
      r'<vcard[^>]*>(.*?)</vcard>',
      dotAll: true,
    ).firstMatch(xml);
    if (vcardMatch == null) {
      throw const FormatException.format('xCard', 'No vcard element found');
    }

    final content = vcardMatch.group(1)!;

    // Parse FN
    final fnMatch = _extractTextValue(content, 'fn');
    if (fnMatch != null) {
      vcard.formattedName = _unescapeXml(fnMatch);
    }

    // Parse N
    final nMatch = RegExp(
      r'<n[^>]*>(.*?)</n>',
      dotAll: true,
    ).firstMatch(content);
    if (nMatch != null) {
      final nContent = nMatch.group(1)!;
      vcard.name = StructuredName(
        family: _unescapeXml(_extractSimpleValue(nContent, 'surname') ?? ''),
        given: _unescapeXml(_extractSimpleValue(nContent, 'given') ?? ''),
        additional: (_extractSimpleValue(nContent, 'additional') ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList(),
        prefixes: (_extractSimpleValue(nContent, 'prefix') ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList(),
        suffixes: (_extractSimpleValue(nContent, 'suffix') ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList(),
      );
    }

    // Parse NICKNAME
    final nicknames = _extractAllTextValues(content, 'nickname');
    vcard.nicknames.addAll(nicknames.map(_unescapeXml));

    // Parse PHOTO
    final photos = _extractAllUriValues(content, 'photo');
    for (final uri in photos) {
      if (uri.startsWith('data:')) {
        try {
          final binary = BinaryData.fromDataUri(uri);
          vcard.photos.add(
            Photo.inline(binary.data, mediaType: binary.mediaType),
          );
        } catch (_) {
          vcard.photos.add(Photo.uri(uri));
        }
      } else {
        vcard.photos.add(Photo.uri(uri));
      }
    }

    // Parse BDAY
    final bday = _extractDateValue(content, 'bday');
    if (bday != null) {
      vcard.birthday = DateOrDateTime.tryParse(bday);
    }

    // Parse ANNIVERSARY
    final anniversary = _extractDateValue(content, 'anniversary');
    if (anniversary != null) {
      vcard.anniversary = DateOrDateTime.tryParse(anniversary);
    }

    // Parse GENDER
    final genderMatch = RegExp(
      r'<gender[^>]*>(.*?)</gender>',
      dotAll: true,
    ).firstMatch(content);
    if (genderMatch != null) {
      final gContent = genderMatch.group(1)!;
      vcard.gender = Gender(
        sex: _extractSimpleValue(gContent, 'sex'),
        identity: _extractSimpleValue(gContent, 'identity'),
      );
    }

    // Parse ADR
    final adrMatches = RegExp(
      r'<adr[^>]*>(.*?)</adr>',
      dotAll: true,
    ).allMatches(content);
    for (final match in adrMatches) {
      final adrContent = match.group(1)!;
      vcard.addresses.add(
        Address(
          poBox: _unescapeXml(_extractSimpleValue(adrContent, 'pobox') ?? ''),
          extended: _unescapeXml(_extractSimpleValue(adrContent, 'ext') ?? ''),
          street: _unescapeXml(_extractSimpleValue(adrContent, 'street') ?? ''),
          city: _unescapeXml(_extractSimpleValue(adrContent, 'locality') ?? ''),
          region: _unescapeXml(_extractSimpleValue(adrContent, 'region') ?? ''),
          postalCode: _unescapeXml(
            _extractSimpleValue(adrContent, 'code') ?? '',
          ),
          country: _unescapeXml(
            _extractSimpleValue(adrContent, 'country') ?? '',
          ),
          types: _extractTypes(adrContent),
          pref: _extractPref(adrContent),
        ),
      );
    }

    // Parse TEL
    final tels = _extractAllUriValues(content, 'tel');
    for (final tel in tels) {
      var number = tel;
      if (number.startsWith('tel:')) {
        number = number.substring(4);
      }
      vcard.telephones.add(Telephone(number: number));
    }

    // Parse EMAIL
    final emails = _extractAllTextValues(content, 'email');
    for (final email in emails) {
      vcard.emails.add(Email(address: _unescapeXml(email)));
    }

    // Parse IMPP
    final impps = _extractAllUriValues(content, 'impp');
    for (final impp in impps) {
      vcard.impps.add(InstantMessaging(uri: impp));
    }

    // Parse LANG
    final langs = _extractAllValues(content, 'lang', 'language-tag');
    for (final lang in langs) {
      vcard.languages.add(LanguagePref(tag: lang));
    }

    // Parse TZ
    final tz = _extractTextValue(content, 'tz');
    if (tz != null) {
      vcard.timezone = _unescapeXml(tz);
    }

    // Parse GEO
    final geo = _extractUriValue(content, 'geo');
    if (geo != null) {
      vcard.geo = GeoLocation.tryParse(geo);
    }

    // Parse TITLE
    final title = _extractTextValue(content, 'title');
    if (title != null) {
      vcard.title = _unescapeXml(title);
    }

    // Parse ROLE
    final role = _extractTextValue(content, 'role');
    if (role != null) {
      vcard.role = _unescapeXml(role);
    }

    // Parse LOGO
    final logo = _extractUriValue(content, 'logo');
    if (logo != null) {
      if (logo.startsWith('data:')) {
        try {
          final binary = BinaryData.fromDataUri(logo);
          vcard.logo = Logo.inline(binary.data, mediaType: binary.mediaType);
        } catch (_) {
          vcard.logo = Logo.uri(logo);
        }
      } else {
        vcard.logo = Logo.uri(logo);
      }
    }

    // Parse ORG
    final orgMatch = RegExp(
      r'<org[^>]*>(.*?)</org>',
      dotAll: true,
    ).firstMatch(content);
    if (orgMatch != null) {
      final orgContent = orgMatch.group(1)!;
      final texts = RegExp(r'<text>([^<]*)</text>').allMatches(orgContent);
      final components = texts
          .map((m) => _unescapeXml(m.group(1) ?? ''))
          .toList();
      if (components.isNotEmpty) {
        vcard.organization = Organization.fromComponents(components);
      }
    }

    // Parse MEMBER
    final members = _extractAllUriValues(content, 'member');
    vcard.members.addAll(members);

    // Parse RELATED
    final relateds = _extractAllUriValues(content, 'related');
    for (final rel in relateds) {
      vcard.related.add(Related(value: rel));
    }

    // Parse CATEGORIES
    final catMatch = RegExp(
      r'<categories[^>]*>(.*?)</categories>',
      dotAll: true,
    ).firstMatch(content);
    if (catMatch != null) {
      final catContent = catMatch.group(1)!;
      final texts = RegExp(r'<text>([^<]*)</text>').allMatches(catContent);
      vcard.categories.addAll(texts.map((m) => _unescapeXml(m.group(1) ?? '')));
    }

    // Parse NOTE
    final note = _extractTextValue(content, 'note');
    if (note != null) {
      vcard.note = _unescapeXml(note);
    }

    // Parse PRODID
    final prodid = _extractTextValue(content, 'prodid');
    if (prodid != null) {
      vcard.productId = _unescapeXml(prodid);
    }

    // Parse REV
    final rev = _extractValue(content, 'rev', 'timestamp');
    if (rev != null) {
      vcard.revision = DateOrDateTime.tryParse(rev);
    }

    // Parse SOUND
    final sound = _extractUriValue(content, 'sound');
    if (sound != null) {
      if (sound.startsWith('data:')) {
        try {
          final binary = BinaryData.fromDataUri(sound);
          vcard.sound = Sound.inline(binary.data, mediaType: binary.mediaType);
        } catch (_) {
          vcard.sound = Sound.uri(sound);
        }
      } else {
        vcard.sound = Sound.uri(sound);
      }
    }

    // Parse UID
    final uid = _extractUriValue(content, 'uid');
    if (uid != null) {
      vcard.uid = uid;
    }

    // Parse URL
    final urls = _extractAllUriValues(content, 'url');
    for (final url in urls) {
      vcard.urls.add(WebUrl(url: url));
    }

    // Parse KEY
    final keys = _extractAllUriValues(content, 'key');
    for (final key in keys) {
      if (key.startsWith('data:')) {
        try {
          final binary = BinaryData.fromDataUri(key);
          vcard.keys.add(Key.inline(binary.data, mediaType: binary.mediaType));
        } catch (_) {
          vcard.keys.add(Key.uri(key));
        }
      } else {
        vcard.keys.add(Key.uri(key));
      }
    }

    // Parse calendar properties
    vcard.freeBusyUrls.addAll(_extractAllUriValues(content, 'fburl'));
    vcard.calendarUrls.addAll(_extractAllUriValues(content, 'caluri'));
    vcard.calendarAddressUrls.addAll(
      _extractAllUriValues(content, 'caladruri'),
    );

    // Parse KIND
    final kind = _extractTextValue(content, 'kind');
    if (kind != null) {
      vcard.kind = VCardKind.tryParse(kind);
    }

    // Parse SOURCE
    vcard.sources.addAll(_extractAllUriValues(content, 'source'));

    return vcard;
  }

  void _writeElement(
    StringBuffer buffer,
    String name,
    String? valueType,
    String value, {
    List<String>? types,
    int? pref,
    String indent = '',
    String newline = '',
  }) {
    buffer.write('$indent<$name>$newline');

    // Write parameters if any
    if ((types != null && types.isNotEmpty) || pref != null) {
      buffer.write('$indent  <parameters>$newline');
      if (types != null && types.isNotEmpty) {
        buffer.write('$indent    <type>$newline');
        for (final t in types) {
          buffer.write('$indent      <text>$t</text>$newline');
        }
        buffer.write('$indent    </type>$newline');
      }
      if (pref != null) {
        buffer.write(
          '$indent    <pref><integer>$pref</integer></pref>$newline',
        );
      }
      buffer.write('$indent  </parameters>$newline');
    }

    // Write value
    if (valueType != null) {
      buffer.write('$indent  <$valueType>$value</$valueType>$newline');
    } else {
      buffer.write('$indent  $value$newline');
    }

    buffer.write('$indent</$name>$newline');
  }

  void _writeAddressElement(
    StringBuffer buffer,
    Address addr, {
    String indent = '',
    String newline = '',
  }) {
    buffer.write('$indent<adr>$newline');

    // Parameters
    if (addr.types.isNotEmpty || addr.pref != null) {
      buffer.write('$indent  <parameters>$newline');
      if (addr.types.isNotEmpty) {
        buffer.write('$indent    <type>$newline');
        for (final t in addr.types) {
          buffer.write('$indent      <text>$t</text>$newline');
        }
        buffer.write('$indent    </type>$newline');
      }
      if (addr.pref != null) {
        buffer.write(
          '$indent    <pref><integer>${addr.pref}</integer></pref>$newline',
        );
      }
      buffer.write('$indent  </parameters>$newline');
    }

    // Address components
    buffer.write('$indent  <pobox>${_escapeXml(addr.poBox)}</pobox>$newline');
    buffer.write('$indent  <ext>${_escapeXml(addr.extended)}</ext>$newline');
    buffer.write(
      '$indent  <street>${_escapeXml(addr.street)}</street>$newline',
    );
    buffer.write(
      '$indent  <locality>${_escapeXml(addr.city)}</locality>$newline',
    );
    buffer.write(
      '$indent  <region>${_escapeXml(addr.region)}</region>$newline',
    );
    buffer.write(
      '$indent  <code>${_escapeXml(addr.postalCode)}</code>$newline',
    );
    buffer.write(
      '$indent  <country>${_escapeXml(addr.country)}</country>$newline',
    );

    buffer.write('$indent</adr>$newline');
  }

  void _writeOrgElement(
    StringBuffer buffer,
    Organization org, {
    String indent = '',
    String newline = '',
  }) {
    buffer.write('$indent<org>$newline');

    if (org.sortAs != null) {
      buffer.write('$indent  <parameters>$newline');
      buffer.write(
        '$indent    <sort-as><text>${_escapeXml(org.sortAs!)}</text></sort-as>$newline',
      );
      buffer.write('$indent  </parameters>$newline');
    }

    buffer.write('$indent  <text>${_escapeXml(org.name)}</text>$newline');
    for (final unit in org.units) {
      buffer.write('$indent  <text>${_escapeXml(unit)}</text>$newline');
    }

    buffer.write('$indent</org>$newline');
  }

  void _writeBinaryElement(
    StringBuffer buffer,
    String name,
    BinaryData data, {
    List<String>? types,
    int? pref,
    String indent = '',
    String newline = '',
  }) {
    String uri;
    if (data.isUri) {
      uri = data.uri!;
    } else if (data.isInline) {
      uri = data.dataUri!;
    } else {
      return;
    }

    _writeElement(
      buffer,
      name,
      'uri',
      uri,
      types: types,
      pref: pref,
      indent: indent,
      newline: newline,
    );
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String _unescapeXml(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }

  String? _extractTextValue(String content, String element) {
    return _extractValue(content, element, 'text');
  }

  String? _extractUriValue(String content, String element) {
    return _extractValue(content, element, 'uri');
  }

  String? _extractDateValue(String content, String element) {
    final dateTime = _extractValue(content, element, 'date-time');
    if (dateTime != null) return dateTime;
    return _extractValue(content, element, 'date');
  }

  String? _extractValue(String content, String element, String valueType) {
    final pattern = RegExp(
      '<$element[^>]*>.*?<$valueType>([^<]*)</$valueType>.*?</$element>',
      dotAll: true,
    );
    final match = pattern.firstMatch(content);
    return match?.group(1);
  }

  String? _extractSimpleValue(String content, String element) {
    final pattern = RegExp('<$element>([^<]*)</$element>');
    final match = pattern.firstMatch(content);
    return match?.group(1)?.trim();
  }

  List<String> _extractAllTextValues(String content, String element) {
    return _extractAllValues(content, element, 'text');
  }

  List<String> _extractAllUriValues(String content, String element) {
    return _extractAllValues(content, element, 'uri');
  }

  List<String> _extractAllValues(
    String content,
    String element,
    String valueType,
  ) {
    final pattern = RegExp(
      '<$element[^>]*>.*?<$valueType>([^<]*)</$valueType>.*?</$element>',
      dotAll: true,
    );
    return pattern.allMatches(content).map((m) => m.group(1) ?? '').toList();
  }

  List<String> _extractTypes(String content) {
    final types = <String>[];
    final paramMatch = RegExp(
      r'<parameters>(.*?)</parameters>',
      dotAll: true,
    ).firstMatch(content);
    if (paramMatch != null) {
      final typeMatches = RegExp(
        r'<type>.*?<text>([^<]*)</text>.*?</type>',
        dotAll: true,
      ).allMatches(paramMatch.group(1)!);
      for (final match in typeMatches) {
        final typeValue = match.group(1);
        if (typeValue != null && typeValue.isNotEmpty) {
          types.add(typeValue);
        }
      }
    }
    return types;
  }

  int? _extractPref(String content) {
    final paramMatch = RegExp(
      r'<parameters>(.*?)</parameters>',
      dotAll: true,
    ).firstMatch(content);
    if (paramMatch != null) {
      final prefMatch = RegExp(
        r'<pref>.*?<integer>(\d+)</integer>.*?</pref>',
        dotAll: true,
      ).firstMatch(paramMatch.group(1)!);
      if (prefMatch != null) {
        return int.tryParse(prefMatch.group(1) ?? '');
      }
    }
    return null;
  }
}
