import 'dart:convert';

import '../core/parameter.dart';
import '../core/parameter_name.dart';
import '../core/property.dart';
import '../core/property_name.dart';
import '../core/version.dart';
import '../exceptions.dart';
import '../models/address.dart';
import '../models/binary_data.dart';
import '../models/contact_info.dart';
import '../models/organization.dart';
import '../models/structured_name.dart';
import '../models/types.dart';
import '../models/vcard.dart';
import 'content_line.dart';

/// Parses vCard text into [VCard] objects.
///
/// Supports vCard 2.1, 3.0, and 4.0 formats.
///
/// ## Example
///
/// ```dart
/// // Parse vCard text
/// final parser = VCardParser();
/// final vcards = parser.parse(vcardText);
///
/// // Parse a single vCard
/// final vcard = parser.parseSingle(vcardText);
///
/// // Parse with strict mode
/// final strictParser = VCardParser(lenient: false);
/// final vcards = strictParser.parse(vcardText);
/// ```
class VCardParser {
  /// Whether to be lenient with non-compliant input.
  final bool lenient;

  /// Whether to preserve raw properties for round-trip support.
  final bool preserveRaw;

  /// Creates a new vCard parser.
  const VCardParser({this.lenient = true, this.preserveRaw = true});

  /// Parses a vCard string and returns all vCards found.
  ///
  /// A single string may contain multiple vCards.
  List<VCard> parse(String input) {
    if (input.trim().isEmpty) {
      return [];
    }

    // Unfold content lines
    final unfolded = LineFolding.unfold(input);

    // Parse all content lines
    final lines = ContentLineParser.parseLines(unfolded);

    // Group lines into vCards
    return _parseVCards(lines);
  }

  /// Parses a single vCard string.
  ///
  /// Throws [VCardParseException] if the input doesn't contain exactly one vCard.
  VCard parseSingle(String input) {
    final vcards = parse(input);
    if (vcards.isEmpty) {
      throw const VCardParseException('No vCard found in input');
    }
    if (vcards.length > 1) {
      throw const VCardParseException('Multiple vCards found, expected single');
    }
    return vcards.first;
  }

  /// Groups properties into individual vCards.
  List<VCard> _parseVCards(List<VCardProperty> properties) {
    final vcards = <VCard>[];
    List<VCardProperty>? currentProperties;

    for (final prop in properties) {
      if (prop.upperName == PropertyName.begin &&
          prop.value.toUpperCase() == PropertyName.vcard) {
        currentProperties = [];
      } else if (prop.upperName == PropertyName.end &&
          prop.value.toUpperCase() == PropertyName.vcard) {
        if (currentProperties != null) {
          vcards.add(_buildVCard(currentProperties));
          currentProperties = null;
        }
      } else if (currentProperties != null) {
        currentProperties.add(prop);
      }
    }

    // Handle case where END:VCARD is missing (lenient mode)
    if (lenient && currentProperties != null && currentProperties.isNotEmpty) {
      vcards.add(_buildVCard(currentProperties));
    }

    return vcards;
  }

  /// Builds a VCard from a list of properties.
  VCard _buildVCard(List<VCardProperty> properties) {
    final vcard = VCard();

    // First, determine the version
    for (final prop in properties) {
      if (prop.upperName == PropertyName.version) {
        vcard.version = VCardVersion.tryParse(prop.value) ?? VCardVersion.v40;
        break;
      }
    }

    // Store raw properties if needed
    if (preserveRaw) {
      vcard.rawProperties.addAll(properties);
    }

    // Process each property
    for (final prop in properties) {
      _processProperty(vcard, prop);
    }

    return vcard;
  }

  /// Processes a single property and updates the vCard.
  void _processProperty(VCard vcard, VCardProperty prop) {
    final value = _decodeValue(prop, vcard.version);

    switch (prop.upperName) {
      case PropertyName.fn:
        vcard.formattedName = value;

      case PropertyName.n:
        vcard.name = _parseStructuredName(value);

      case PropertyName.nickname:
        vcard.nicknames.addAll(_splitValues(value));

      case PropertyName.photo:
        final photo = _parsePhoto(prop, value);
        if (photo != null) {
          vcard.photos.add(photo);
        }

      case PropertyName.bday:
        vcard.birthday = DateOrDateTime.tryParse(value);

      case PropertyName.anniversary:
        vcard.anniversary = DateOrDateTime.tryParse(value);

      case PropertyName.gender:
        vcard.gender = Gender.parse(value);

      case PropertyName.adr:
        vcard.addresses.add(_parseAddress(prop, value));

      case PropertyName.tel:
        vcard.telephones.add(_parseTelephone(prop, value));

      case PropertyName.email:
        vcard.emails.add(_parseEmail(prop, value));

      case PropertyName.impp:
        vcard.impps.add(_parseImpp(prop, value));

      case PropertyName.lang:
        vcard.languages.add(_parseLanguage(prop, value));

      case PropertyName.tz:
        vcard.timezone = value;

      case PropertyName.geo:
        vcard.geo = GeoLocation.tryParse(value);

      case PropertyName.title:
        vcard.title = value;

      case PropertyName.role:
        vcard.role = value;

      case PropertyName.logo:
        final logo = _parseLogo(prop, value);
        if (logo != null) {
          vcard.logo = logo;
        }

      case PropertyName.org:
        vcard.organization = _parseOrganization(value, prop.parameters);

      case PropertyName.member:
        vcard.members.add(value);

      case PropertyName.related:
        vcard.related.add(_parseRelated(prop, value));

      case PropertyName.categories:
        vcard.categories.addAll(_splitValues(value));

      case PropertyName.note:
        vcard.note = value;

      case PropertyName.prodid:
        vcard.productId = value;

      case PropertyName.rev:
        vcard.revision = DateOrDateTime.tryParse(value);

      case PropertyName.sound:
        final sound = _parseSound(prop, value);
        if (sound != null) {
          vcard.sound = sound;
        }

      case PropertyName.uid:
        vcard.uid = value;

      case PropertyName.url:
        vcard.urls.add(_parseUrl(prop, value));

      case PropertyName.key:
        final key = _parseKey(prop, value);
        if (key != null) {
          vcard.keys.add(key);
        }

      case PropertyName.fburl:
        vcard.freeBusyUrls.add(value);

      case PropertyName.caluri:
        vcard.calendarUrls.add(value);

      case PropertyName.caladruri:
        vcard.calendarAddressUrls.add(value);

      case PropertyName.kind:
        vcard.kind = VCardKind.tryParse(value);

      case PropertyName.xml:
        vcard.xml.add(value);

      case PropertyName.source:
        vcard.sources.add(value);

      default:
        // Handle extended properties
        if (PropertyName.isExtended(prop.name)) {
          vcard.extendedProperties.add(prop.copyWith(value: value));
        }
    }
  }

  /// Decodes property value based on encoding parameters.
  String _decodeValue(VCardProperty prop, VCardVersion version) {
    var value = prop.value;
    final encoding = prop.parameters.encoding?.toUpperCase();

    // Handle Quoted-Printable (common in vCard 2.1)
    if (encoding == EncodingValue.quotedPrintable) {
      final charset = prop.parameters.charset ?? 'UTF-8';
      value = QuotedPrintable.decode(value, charset: charset);
    }

    // Unescape the value (for vCard 3.0/4.0)
    if (version != VCardVersion.v21 ||
        encoding != EncodingValue.quotedPrintable) {
      value = ValueEscaping.unescape(value);
    }

    return value;
  }

  /// Splits comma-separated values.
  List<String> _splitValues(String value) {
    return ValueEscaping.splitValue(
      value,
      ',',
    ).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  /// Parses a structured name (N property).
  StructuredName _parseStructuredName(String value) {
    final components = ValueEscaping.splitValue(value, ';');
    return StructuredName.fromComponents(
      components.map(ValueEscaping.unescape).toList(),
    );
  }

  /// Parses an address (ADR property).
  Address _parseAddress(VCardProperty prop, String value) {
    final components = ValueEscaping.splitValue(value, ';');
    return Address.fromComponents(
      components.map(ValueEscaping.unescape).toList(),
      types: prop.parameters.types,
      pref: prop.parameters.pref,
      label: prop.parameters.getValue(ParameterName.label),
      geo: _parseGeoParam(prop.parameters),
      timezone: prop.parameters.getValue(ParameterName.timezone),
      language: prop.parameters.language,
    );
  }

  /// Parses GEO parameter from address.
  GeoLocation? _parseGeoParam(VCardParameters params) {
    final geoValue = params.getValue(ParameterName.geoPosition);
    if (geoValue != null) {
      return GeoLocation.tryParse(geoValue);
    }
    return null;
  }

  /// Parses a telephone (TEL property).
  Telephone _parseTelephone(VCardProperty prop, String value) {
    // In vCard 4.0, TEL can have VALUE=uri with tel: URI
    var number = value;
    if (value.startsWith('tel:')) {
      number = value.substring(4);
      // Handle extension
      final extMatch = RegExp(r';ext=(\d+)').firstMatch(number);
      if (extMatch != null) {
        return Telephone(
          number: number.substring(0, extMatch.start),
          types: prop.parameters.types,
          pref: prop.parameters.pref,
          extension: extMatch.group(1),
        );
      }
    }
    return Telephone(
      number: number,
      types: prop.parameters.types,
      pref: prop.parameters.pref,
    );
  }

  /// Parses an email (EMAIL property).
  Email _parseEmail(VCardProperty prop, String value) {
    var address = value;
    if (value.startsWith('mailto:')) {
      address = value.substring(7);
    }
    return Email(
      address: address,
      types: prop.parameters.types,
      pref: prop.parameters.pref,
    );
  }

  /// Parses IMPP property.
  InstantMessaging _parseImpp(VCardProperty prop, String value) {
    return InstantMessaging(
      uri: value,
      types: prop.parameters.types,
      pref: prop.parameters.pref,
    );
  }

  /// Parses LANG property.
  LanguagePref _parseLanguage(VCardProperty prop, String value) {
    return LanguagePref(
      tag: value,
      types: prop.parameters.types,
      pref: prop.parameters.pref,
    );
  }

  /// Parses organization (ORG property).
  Organization _parseOrganization(String value, VCardParameters params) {
    final components = ValueEscaping.splitValue(
      value,
      ';',
    ).map(ValueEscaping.unescape).toList();
    final sortAs = params.getValue(ParameterName.sortAs);
    return Organization.fromComponents(components).copyWith(sortAs: sortAs);
  }

  /// Parses RELATED property.
  Related _parseRelated(VCardProperty prop, String value) {
    return Related(
      value: value,
      type: prop.parameters.type,
      pref: prop.parameters.pref,
      mediaType: prop.parameters.mediaType,
      language: prop.parameters.language,
    );
  }

  /// Parses URL property.
  WebUrl _parseUrl(VCardProperty prop, String value) {
    return WebUrl(
      url: value,
      types: prop.parameters.types,
      pref: prop.parameters.pref,
      mediaType: prop.parameters.mediaType,
    );
  }

  /// Parses PHOTO property.
  Photo? _parsePhoto(VCardProperty prop, String value) {
    return _parseBinaryData<Photo>(
      prop,
      value,
      (data, mediaType, types, pref) =>
          Photo.inline(data, mediaType: mediaType, types: types, pref: pref),
      (uri, mediaType, types, pref) =>
          Photo.uri(uri, mediaType: mediaType, types: types, pref: pref),
    );
  }

  /// Parses LOGO property.
  Logo? _parseLogo(VCardProperty prop, String value) {
    return _parseBinaryData<Logo>(
      prop,
      value,
      (data, mediaType, types, pref) =>
          Logo.inline(data, mediaType: mediaType, types: types, pref: pref),
      (uri, mediaType, types, pref) =>
          Logo.uri(uri, mediaType: mediaType, types: types, pref: pref),
    );
  }

  /// Parses SOUND property.
  Sound? _parseSound(VCardProperty prop, String value) {
    return _parseBinaryData<Sound>(
      prop,
      value,
      (data, mediaType, types, pref) =>
          Sound.inline(data, mediaType: mediaType, types: types, pref: pref),
      (uri, mediaType, types, pref) =>
          Sound.uri(uri, mediaType: mediaType, types: types, pref: pref),
    );
  }

  /// Parses KEY property.
  Key? _parseKey(VCardProperty prop, String value) {
    return _parseBinaryData<Key>(
      prop,
      value,
      (data, mediaType, types, pref) =>
          Key.inline(data, mediaType: mediaType, types: types, pref: pref),
      (uri, mediaType, types, pref) =>
          Key.uri(uri, mediaType: mediaType, types: types, pref: pref),
    );
  }

  /// Generic parser for binary data properties.
  T? _parseBinaryData<T>(
    VCardProperty prop,
    String value,
    T Function(dynamic data, String? mediaType, List<String> types, int? pref)
    inlineFactory,
    T Function(String uri, String? mediaType, List<String> types, int? pref)
    uriFactory,
  ) {
    if (value.isEmpty) return null;

    final types = prop.parameters.types;
    final pref = prop.parameters.pref;
    final mediaType = prop.parameters.mediaType;
    final valueType = prop.parameters.valueType?.toLowerCase();
    final encoding = prop.parameters.encoding?.toUpperCase();

    // Check if it's a URI
    if (valueType == 'uri' ||
        value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('data:')) {
      if (value.startsWith('data:')) {
        try {
          final binary = BinaryData.fromDataUri(value);
          return inlineFactory(
            binary.data,
            binary.mediaType ?? mediaType,
            types,
            pref,
          );
        } catch (_) {
          return uriFactory(value, mediaType, types, pref);
        }
      }
      return uriFactory(value, mediaType, types, pref);
    }

    // Check if it's base64 encoded
    if (encoding == EncodingValue.base64 ||
        encoding == EncodingValue.b ||
        valueType == 'binary') {
      try {
        final data = base64Decode(value.replaceAll(RegExp(r'\s'), ''));
        return inlineFactory(data, mediaType, types, pref);
      } catch (_) {
        if (lenient) {
          return uriFactory(value, mediaType, types, pref);
        }
        return null;
      }
    }

    // Default: treat as URI
    return uriFactory(value, mediaType, types, pref);
  }
}
