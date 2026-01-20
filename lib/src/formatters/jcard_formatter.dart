import 'dart:convert';

import '../core/parameter.dart';
import '../core/property.dart';
import '../core/version.dart';
import '../exceptions.dart';
import '../models/address.dart';
import '../models/binary_data.dart';
import '../models/contact_info.dart';
import '../models/organization.dart';
import '../models/structured_name.dart';
import '../models/types.dart';
import '../models/vcard.dart';

/// Converts between VCard objects and jCard (JSON) format.
///
/// jCard is defined in RFC 7095 as the JSON representation of vCard.
///
/// ## Example
///
/// ```dart
/// // Convert vCard to jCard JSON
/// final formatter = JCardFormatter();
/// final json = formatter.toJson(vcard);
///
/// // Convert to JSON string
/// final jsonString = formatter.toJsonString(vcard, pretty: true);
///
/// // Parse jCard JSON to vCard
/// final parsed = formatter.fromJson(json);
///
/// // Parse jCard JSON string
/// final fromString = formatter.fromJsonString(jsonString);
/// ```
class JCardFormatter {
  /// Creates a new jCard formatter.
  const JCardFormatter();

  /// Converts a VCard to jCard JSON.
  ///
  /// Returns a JSON-encodable list representing the jCard.
  List<dynamic> toJson(VCard vcard) {
    final properties = <List<dynamic>>[];

    // VERSION (always 4.0 for jCard)
    properties.add(['version', {}, 'text', '4.0']);

    // FN (required)
    properties.add(['fn', {}, 'text', vcard.formattedName]);

    // N
    if (vcard.name != null && vcard.name!.isNotEmpty) {
      if (vcard.name!.isRaw && vcard.name!.rawValue != null) {
        // Raw value - output as single text
        properties.add(['n', {}, 'text', vcard.name!.rawValue!]);
      } else {
        properties.add([
          'n',
          {},
          'text',
          [
            vcard.name!.family,
            vcard.name!.given,
            vcard.name!.additional.join(','),
            vcard.name!.prefixes.join(','),
            vcard.name!.suffixes.join(','),
          ],
        ]);
      }
    }

    // NICKNAME
    if (vcard.nicknames.isNotEmpty) {
      properties.add(['nickname', {}, 'text', vcard.nicknames.join(',')]);
    }

    // PHOTO
    for (final photo in vcard.photos) {
      final params = _buildParams(types: photo.types, pref: photo.pref);
      if (photo.isUri) {
        properties.add(['photo', params, 'uri', photo.uri!]);
      } else if (photo.isInline) {
        properties.add(['photo', params, 'uri', photo.dataUri!]);
      }
    }

    // BDAY
    if (vcard.birthday != null && vcard.birthday!.isNotEmpty) {
      final valueType = vcard.birthday!.hasTime ? 'date-time' : 'date';
      properties.add(['bday', {}, valueType, vcard.birthday.toString()]);
    }

    // ANNIVERSARY
    if (vcard.anniversary != null && vcard.anniversary!.isNotEmpty) {
      final valueType = vcard.anniversary!.hasTime ? 'date-time' : 'date';
      properties.add([
        'anniversary',
        {},
        valueType,
        vcard.anniversary.toString(),
      ]);
    }

    // GENDER
    if (vcard.gender != null && vcard.gender!.isNotEmpty) {
      properties.add(['gender', {}, 'text', vcard.gender!.toValue()]);
    }

    // ADR
    for (final addr in vcard.addresses) {
      final params = _buildParams(
        types: addr.types,
        pref: addr.pref,
        label: addr.label,
        language: addr.language,
      );
      if (addr.geo != null) {
        params['geo'] = addr.geo!.toUri();
      }
      if (addr.timezone != null) {
        params['tz'] = addr.timezone!;
      }
      if (addr.isRaw && addr.rawValue != null) {
        // Raw value - output as single text
        properties.add(['adr', params, 'text', addr.rawValue!]);
      } else {
        properties.add(['adr', params, 'text', addr.toComponents()]);
      }
    }

    // TEL
    for (final tel in vcard.telephones) {
      final params = _buildParams(types: tel.types, pref: tel.pref);
      properties.add(['tel', params, 'uri', tel.toUri()]);
    }

    // EMAIL
    for (final email in vcard.emails) {
      final params = _buildParams(types: email.types, pref: email.pref);
      properties.add(['email', params, 'text', email.address]);
    }

    // IMPP
    for (final impp in vcard.impps) {
      final params = _buildParams(types: impp.types, pref: impp.pref);
      properties.add(['impp', params, 'uri', impp.uri]);
    }

    // LANG
    for (final lang in vcard.languages) {
      final params = _buildParams(types: lang.types, pref: lang.pref);
      properties.add(['lang', params, 'language-tag', lang.tag]);
    }

    // TZ
    if (vcard.timezone != null && vcard.timezone!.isNotEmpty) {
      properties.add(['tz', {}, 'text', vcard.timezone!]);
    }

    // GEO
    if (vcard.geo != null) {
      properties.add(['geo', {}, 'uri', vcard.geo!.toUri()]);
    }

    // TITLE
    if (vcard.title != null && vcard.title!.isNotEmpty) {
      properties.add(['title', {}, 'text', vcard.title!]);
    }

    // ROLE
    if (vcard.role != null && vcard.role!.isNotEmpty) {
      properties.add(['role', {}, 'text', vcard.role!]);
    }

    // LOGO
    if (vcard.logo != null && vcard.logo!.isNotEmpty) {
      if (vcard.logo!.isUri) {
        properties.add(['logo', {}, 'uri', vcard.logo!.uri!]);
      } else if (vcard.logo!.isInline) {
        properties.add(['logo', {}, 'uri', vcard.logo!.dataUri!]);
      }
    }

    // ORG
    if (vcard.organization != null && vcard.organization!.isNotEmpty) {
      final params = <String, dynamic>{};
      if (vcard.organization!.sortAs != null) {
        params['sort-as'] = vcard.organization!.sortAs!;
      }
      if (vcard.organization!.isRaw && vcard.organization!.rawValue != null) {
        // Raw value - output as single text
        properties.add(['org', params, 'text', vcard.organization!.rawValue!]);
      } else {
        properties.add([
          'org',
          params,
          'text',
          vcard.organization!.toComponents(),
        ]);
      }
    }

    // MEMBER
    for (final member in vcard.members) {
      properties.add(['member', {}, 'uri', member]);
    }

    // RELATED
    for (final rel in vcard.related) {
      final params = _buildParams(
        types: rel.type != null ? [rel.type!] : null,
        pref: rel.pref,
        mediaType: rel.mediaType,
        language: rel.language,
      );
      properties.add(['related', params, 'uri', rel.value]);
    }

    // CATEGORIES
    if (vcard.categories.isNotEmpty) {
      properties.add(['categories', {}, 'text', vcard.categories]);
    }

    // NOTE
    if (vcard.note != null && vcard.note!.isNotEmpty) {
      properties.add(['note', {}, 'text', vcard.note!]);
    }

    // PRODID
    if (vcard.productId != null && vcard.productId!.isNotEmpty) {
      properties.add(['prodid', {}, 'text', vcard.productId!]);
    }

    // REV
    if (vcard.revision != null && vcard.revision!.isNotEmpty) {
      properties.add([
        'rev',
        {},
        'timestamp',
        vcard.revision!.toDateTimeString(),
      ]);
    }

    // SOUND
    if (vcard.sound != null && vcard.sound!.isNotEmpty) {
      if (vcard.sound!.isUri) {
        properties.add(['sound', {}, 'uri', vcard.sound!.uri!]);
      } else if (vcard.sound!.isInline) {
        properties.add(['sound', {}, 'uri', vcard.sound!.dataUri!]);
      }
    }

    // UID
    if (vcard.uid != null && vcard.uid!.isNotEmpty) {
      properties.add(['uid', {}, 'uri', vcard.uid!]);
    }

    // URL
    for (final url in vcard.urls) {
      final params = _buildParams(types: url.types, pref: url.pref);
      properties.add(['url', params, 'uri', url.url]);
    }

    // KEY
    for (final key in vcard.keys) {
      if (key.isUri) {
        properties.add(['key', {}, 'uri', key.uri!]);
      } else if (key.isInline) {
        properties.add(['key', {}, 'uri', key.dataUri!]);
      }
    }

    // Calendar properties
    for (final fbUrl in vcard.freeBusyUrls) {
      properties.add(['fburl', {}, 'uri', fbUrl]);
    }
    for (final calUrl in vcard.calendarUrls) {
      properties.add(['caluri', {}, 'uri', calUrl]);
    }
    for (final calAdrUrl in vcard.calendarAddressUrls) {
      properties.add(['caladruri', {}, 'uri', calAdrUrl]);
    }

    // KIND
    if (vcard.kind != null) {
      properties.add(['kind', {}, 'text', vcard.kind!.value]);
    }

    // XML
    for (final xmlContent in vcard.xml) {
      properties.add(['xml', {}, 'text', xmlContent]);
    }

    // SOURCE
    for (final source in vcard.sources) {
      properties.add(['source', {}, 'uri', source]);
    }

    // Extended properties
    for (final prop in vcard.extendedProperties) {
      final params = prop.parameters.toMap();
      final lowerParams = <String, dynamic>{};
      for (final entry in params.entries) {
        lowerParams[entry.key.toLowerCase()] =
            entry.value.length == 1 ? entry.value.first : entry.value;
      }
      properties.add([
        prop.name.toLowerCase(),
        lowerParams,
        'text',
        prop.value,
      ]);
    }

    return ['vcard', properties];
  }

  /// Converts a VCard to a jCard JSON string.
  String toJsonString(VCard vcard, {bool pretty = false}) {
    final json = toJson(vcard);
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(json);
    }
    return jsonEncode(json);
  }

  /// Parses a jCard JSON into a VCard.
  VCard fromJson(List<dynamic> json) {
    if (json.isEmpty || json[0] != 'vcard') {
      throw const FormatException.format(
        'jCard',
        'Invalid jCard: expected "vcard" type',
      );
    }

    if (json.length < 2 || json[1] is! List) {
      throw const FormatException.format(
        'jCard',
        'Invalid jCard: missing properties array',
      );
    }

    final properties = json[1] as List<dynamic>;
    final vcard = VCard(version: VCardVersion.v40);

    for (final prop in properties) {
      if (prop is! List || prop.length < 4) continue;
      _processProperty(vcard, prop);
    }

    return vcard;
  }

  /// Parses a jCard JSON string into a VCard.
  VCard fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    if (json is! List) {
      throw const FormatException.format(
        'jCard',
        'Invalid jCard: expected array',
      );
    }
    return fromJson(json);
  }

  void _processProperty(VCard vcard, List<dynamic> prop) {
    final name = (prop[0] as String).toLowerCase();
    final params = Map<String, dynamic>.from(prop[1] as Map);
    // valueType prop[2] indicates data type (text, uri, date, etc.)
    final _ = prop[2] as String; // Reserved for future use
    final value = prop[3];

    switch (name) {
      case 'fn':
        vcard.formattedName = _stringValue(value);

      case 'n':
        if (value is List) {
          vcard.name = StructuredName.fromComponents(
            value.map((e) => _stringValue(e)).toList(),
          );
        } else {
          // Raw value - single string
          final rawValue = _stringValue(value);
          if (rawValue.isNotEmpty) {
            vcard.name = StructuredName.raw(rawValue);
          }
        }

      case 'nickname':
        vcard.nicknames.addAll(_stringList(value));

      case 'photo':
        final photo = _parseBinaryValue<Photo>(
          value,
          params,
          (data, mediaType) => Photo.inline(data, mediaType: mediaType),
          (uri, mediaType) => Photo.uri(uri, mediaType: mediaType),
        );
        if (photo != null) vcard.photos.add(photo);

      case 'bday':
        vcard.birthday = DateOrDateTime.tryParse(_stringValue(value));

      case 'anniversary':
        vcard.anniversary = DateOrDateTime.tryParse(_stringValue(value));

      case 'gender':
        vcard.gender = Gender.parse(_stringValue(value));

      case 'adr':
        if (value is List) {
          vcard.addresses.add(
            Address.fromComponents(
              value.map((e) => _stringValue(e)).toList(),
              types: _getTypes(params),
              pref: _getPref(params),
              label: params['label'] as String?,
              language: params['language'] as String?,
              geo: params['geo'] != null
                  ? GeoLocation.tryParse(params['geo'] as String)
                  : null,
              timezone: params['tz'] as String?,
            ),
          );
        } else {
          // Raw value - single string
          final rawValue = _stringValue(value);
          if (rawValue.isNotEmpty) {
            vcard.addresses.add(
              Address.raw(
                rawValue,
                types: _getTypes(params),
                pref: _getPref(params),
                label: params['label'] as String?,
                language: params['language'] as String?,
                geo: params['geo'] != null
                    ? GeoLocation.tryParse(params['geo'] as String)
                    : null,
                timezone: params['tz'] as String?,
              ),
            );
          }
        }

      case 'tel':
        var number = _stringValue(value);
        if (number.startsWith('tel:')) {
          number = number.substring(4);
        }
        vcard.telephones.add(
          Telephone(
            number: number,
            types: _getTypes(params),
            pref: _getPref(params),
          ),
        );

      case 'email':
        vcard.emails.add(
          Email(
            address: _stringValue(value),
            types: _getTypes(params),
            pref: _getPref(params),
          ),
        );

      case 'impp':
        vcard.impps.add(
          InstantMessaging(
            uri: _stringValue(value),
            types: _getTypes(params),
            pref: _getPref(params),
          ),
        );

      case 'lang':
        vcard.languages.add(
          LanguagePref(
            tag: _stringValue(value),
            types: _getTypes(params),
            pref: _getPref(params),
          ),
        );

      case 'tz':
        vcard.timezone = _stringValue(value);

      case 'geo':
        vcard.geo = GeoLocation.tryParse(_stringValue(value));

      case 'title':
        vcard.title = _stringValue(value);

      case 'role':
        vcard.role = _stringValue(value);

      case 'logo':
        final logo = _parseBinaryValue<Logo>(
          value,
          params,
          (data, mediaType) => Logo.inline(data, mediaType: mediaType),
          (uri, mediaType) => Logo.uri(uri, mediaType: mediaType),
        );
        if (logo != null) vcard.logo = logo;

      case 'org':
        if (value is List) {
          vcard.organization = Organization.fromComponents(
            value.map((e) => _stringValue(e)).toList(),
            sortAs: params['sort-as'] as String?,
          );
        } else {
          // Raw value - single string
          final rawValue = _stringValue(value);
          if (rawValue.isNotEmpty) {
            vcard.organization = Organization.raw(
              rawValue,
              sortAs: params['sort-as'] as String?,
            );
          }
        }

      case 'member':
        vcard.members.add(_stringValue(value));

      case 'related':
        vcard.related.add(
          Related(
            value: _stringValue(value),
            type: _getTypes(params).isNotEmpty ? _getTypes(params).first : null,
            pref: _getPref(params),
            mediaType: params['mediatype'] as String?,
            language: params['language'] as String?,
          ),
        );

      case 'categories':
        vcard.categories.addAll(_stringList(value));

      case 'note':
        vcard.note = _stringValue(value);

      case 'prodid':
        vcard.productId = _stringValue(value);

      case 'rev':
        vcard.revision = DateOrDateTime.tryParse(_stringValue(value));

      case 'sound':
        final sound = _parseBinaryValue<Sound>(
          value,
          params,
          (data, mediaType) => Sound.inline(data, mediaType: mediaType),
          (uri, mediaType) => Sound.uri(uri, mediaType: mediaType),
        );
        if (sound != null) vcard.sound = sound;

      case 'uid':
        vcard.uid = _stringValue(value);

      case 'url':
        vcard.urls.add(
          WebUrl(
            url: _stringValue(value),
            types: _getTypes(params),
            pref: _getPref(params),
            mediaType: params['mediatype'] as String?,
          ),
        );

      case 'key':
        final key = _parseBinaryValue<Key>(
          value,
          params,
          (data, mediaType) => Key.inline(data, mediaType: mediaType),
          (uri, mediaType) => Key.uri(uri, mediaType: mediaType),
        );
        if (key != null) vcard.keys.add(key);

      case 'fburl':
        vcard.freeBusyUrls.add(_stringValue(value));

      case 'caluri':
        vcard.calendarUrls.add(_stringValue(value));

      case 'caladruri':
        vcard.calendarAddressUrls.add(_stringValue(value));

      case 'kind':
        vcard.kind = VCardKind.tryParse(_stringValue(value));

      case 'xml':
        vcard.xml.add(_stringValue(value));

      case 'source':
        vcard.sources.add(_stringValue(value));

      default:
        // Handle extended properties
        if (name.startsWith('x-')) {
          final propParams = <VCardParameter>[];
          for (final entry in params.entries) {
            if (entry.value is List) {
              propParams.add(
                VCardParameter(
                  entry.key.toUpperCase(),
                  (entry.value as List).map((e) => e.toString()).toList(),
                ),
              );
            } else {
              propParams.add(
                VCardParameter.single(
                  entry.key.toUpperCase(),
                  entry.value.toString(),
                ),
              );
            }
          }
          vcard.extendedProperties.add(
            VCardProperty(
              name: name.toUpperCase(),
              value: _stringValue(value),
              parameters: VCardParameters(propParams),
            ),
          );
        }
    }
  }

  Map<String, dynamic> _buildParams({
    List<String>? types,
    int? pref,
    String? label,
    String? mediaType,
    String? language,
  }) {
    final params = <String, dynamic>{};
    if (types != null && types.isNotEmpty) {
      params['type'] = types.length == 1 ? types.first : types;
    }
    if (pref != null) {
      params['pref'] = pref.toString();
    }
    if (label != null) {
      params['label'] = label;
    }
    if (mediaType != null) {
      params['mediatype'] = mediaType;
    }
    if (language != null) {
      params['language'] = language;
    }
    return params;
  }

  String _stringValue(dynamic value) {
    if (value is String) return value;
    if (value is List) return value.map((e) => e.toString()).join(',');
    return value?.toString() ?? '';
  }

  List<String> _stringList(dynamic value) {
    if (value is String) {
      return value
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  List<String> _getTypes(Map<String, dynamic> params) {
    final type = params['type'];
    if (type == null) return [];
    if (type is String) return [type];
    if (type is List) return type.map((e) => e.toString()).toList();
    return [];
  }

  int? _getPref(Map<String, dynamic> params) {
    final pref = params['pref'];
    if (pref == null) return null;
    if (pref is int) return pref;
    if (pref is String) return int.tryParse(pref);
    return null;
  }

  T? _parseBinaryValue<T>(
    dynamic value,
    Map<String, dynamic> params,
    T Function(dynamic data, String? mediaType) inlineFactory,
    T Function(String uri, String? mediaType) uriFactory,
  ) {
    final uri = _stringValue(value);
    if (uri.isEmpty) return null;

    final mediaType = params['mediatype'] as String?;

    if (uri.startsWith('data:')) {
      try {
        final binary = BinaryData.fromDataUri(uri);
        return inlineFactory(binary.data, binary.mediaType ?? mediaType);
      } catch (_) {
        return uriFactory(uri, mediaType);
      }
    }

    return uriFactory(uri, mediaType);
  }
}
