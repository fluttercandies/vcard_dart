import '../core/parameter.dart';
import '../core/parameter_name.dart';
import '../core/property_name.dart';
import '../core/version.dart';
import '../exceptions.dart';
import '../models/address.dart';
import '../models/binary_data.dart';
import '../models/contact_info.dart';
import '../models/organization.dart';
import '../models/structured_name.dart';
import '../models/vcard.dart';
import '../parsers/content_line.dart';

/// Generates vCard text from [VCard] objects.
///
/// Supports vCard 2.1, 3.0, and 4.0 output formats.
///
/// ## Example
///
/// ```dart
/// // Create a generator
/// final generator = VCardGenerator(
///   foldLines: true,
///   useModernTypes: true,
/// );
///
/// // Generate vCard string
/// final text = generator.generate(vcard, version: VCardVersion.v40);
///
/// // Generate multiple vCards
/// final allText = generator.generateAll(vcards);
///
/// // Generate without line folding
/// final unfolded = VCardGenerator(foldLines: false).generate(vcard);
/// ```
class VCardGenerator {
  /// Whether to fold long lines.
  final bool foldLines;

  /// Whether to use vCard 4.0 style type parameters.
  final bool useModernTypes;

  /// Product ID to include in generated vCards.
  final String? productId;

  /// Creates a new vCard generator.
  const VCardGenerator({
    this.foldLines = true,
    this.useModernTypes = true,
    this.productId,
  });

  /// Generates a vCard string from a VCard object.
  ///
  /// The [version] parameter overrides the version in the vCard object.
  String generate(VCard vcard, {VCardVersion? version}) {
    final v = version ?? vcard.version;
    final lines = <String>[];

    // BEGIN:VCARD
    lines.add('BEGIN:VCARD');

    // VERSION
    lines.add('VERSION:${v.value}');

    // Generate properties based on version
    _generateProperties(vcard, v, lines);

    // END:VCARD
    lines.add('END:VCARD');

    // Join and optionally fold lines
    final content = lines.join(LineFolding.crlf);
    if (foldLines) {
      return LineFolding.foldContent(content);
    }
    return content;
  }

  /// Generates vCard strings for multiple VCard objects.
  String generateAll(List<VCard> vcards, {VCardVersion? version}) {
    return vcards
        .map((v) => generate(v, version: version))
        .join(LineFolding.crlf);
  }

  void _generateProperties(
    VCard vcard,
    VCardVersion version,
    List<String> lines,
  ) {
    // FN (required)
    if (vcard.formattedName.isEmpty) {
      throw const VCardGenerateException('FN (formatted name) is required');
    }
    lines.add(
      _formatProperty(PropertyName.fn, _escape(vcard.formattedName, version)),
    );

    // N
    if (vcard.name != null && vcard.name!.isNotEmpty) {
      lines.add(
        _formatProperty(
          PropertyName.n,
          _formatStructuredName(vcard.name!, version),
        ),
      );
    }

    // NICKNAME
    if (vcard.nicknames.isNotEmpty) {
      lines.add(
        _formatProperty(
          PropertyName.nickname,
          vcard.nicknames.map((n) => _escape(n, version)).join(','),
        ),
      );
    }

    // PHOTO
    for (final photo in vcard.photos) {
      final line = _formatBinaryProperty(
        PropertyName.photo,
        photo,
        version,
        types: photo.types,
        pref: photo.pref,
      );
      if (line != null) lines.add(line);
    }

    // BDAY
    if (vcard.birthday != null && vcard.birthday!.isNotEmpty) {
      lines.add(
        _formatProperty(PropertyName.bday, vcard.birthday!.toDateString()),
      );
    }

    // ANNIVERSARY (vCard 4.0)
    if (version == VCardVersion.v40 &&
        vcard.anniversary != null &&
        vcard.anniversary!.isNotEmpty) {
      lines.add(
        _formatProperty(
          PropertyName.anniversary,
          vcard.anniversary!.toDateString(),
        ),
      );
    }

    // GENDER (vCard 4.0)
    if (version == VCardVersion.v40 &&
        vcard.gender != null &&
        vcard.gender!.isNotEmpty) {
      lines.add(_formatProperty(PropertyName.gender, vcard.gender!.toValue()));
    }

    // ADR
    for (final addr in vcard.addresses) {
      lines.add(_formatAddress(addr, version));
    }

    // TEL
    for (final tel in vcard.telephones) {
      lines.add(_formatTelephone(tel, version));
    }

    // EMAIL
    for (final email in vcard.emails) {
      lines.add(_formatEmail(email, version));
    }

    // IMPP
    for (final impp in vcard.impps) {
      lines.add(_formatImpp(impp, version));
    }

    // LANG (vCard 4.0)
    if (version == VCardVersion.v40) {
      for (final lang in vcard.languages) {
        final params = _buildParams(
          version,
          types: lang.types,
          pref: lang.pref,
        );
        lines.add(
          _formatProperty(
            PropertyName.lang,
            lang.tag,
            params: params.isEmpty ? null : VCardParameters(params),
          ),
        );
      }
    }

    // TZ
    if (vcard.timezone != null && vcard.timezone!.isNotEmpty) {
      lines.add(
        _formatProperty(PropertyName.tz, _escape(vcard.timezone!, version)),
      );
    }

    // GEO
    if (vcard.geo != null) {
      final geoValue = version == VCardVersion.v40
          ? vcard.geo!.toUri()
          : vcard.geo!.toLegacy();
      lines.add(_formatProperty(PropertyName.geo, geoValue));
    }

    // TITLE
    if (vcard.title != null && vcard.title!.isNotEmpty) {
      lines.add(
        _formatProperty(PropertyName.title, _escape(vcard.title!, version)),
      );
    }

    // ROLE
    if (vcard.role != null && vcard.role!.isNotEmpty) {
      lines.add(
        _formatProperty(PropertyName.role, _escape(vcard.role!, version)),
      );
    }

    // LOGO
    if (vcard.logo != null && vcard.logo!.isNotEmpty) {
      final line = _formatBinaryProperty(
        PropertyName.logo,
        vcard.logo!,
        version,
      );
      if (line != null) lines.add(line);
    }

    // ORG
    if (vcard.organization != null && vcard.organization!.isNotEmpty) {
      lines.add(_formatOrganization(vcard.organization!, version));
    }

    // MEMBER (vCard 4.0)
    if (version == VCardVersion.v40) {
      for (final member in vcard.members) {
        lines.add(
          _formatProperty(PropertyName.member, _escape(member, version)),
        );
      }
    }

    // RELATED (vCard 4.0)
    if (version == VCardVersion.v40) {
      for (final rel in vcard.related) {
        final params = _buildParams(
          version,
          types: rel.type != null ? [rel.type!] : null,
          pref: rel.pref,
          mediaType: rel.mediaType,
          language: rel.language,
        );
        lines.add(
          _formatProperty(
            PropertyName.related,
            rel.value,
            params: params.isEmpty ? null : VCardParameters(params),
          ),
        );
      }
    }

    // CATEGORIES
    if (vcard.categories.isNotEmpty) {
      lines.add(
        _formatProperty(
          PropertyName.categories,
          vcard.categories.map((c) => _escape(c, version)).join(','),
        ),
      );
    }

    // NOTE
    if (vcard.note != null && vcard.note!.isNotEmpty) {
      lines.add(
        _formatProperty(PropertyName.note, _escape(vcard.note!, version)),
      );
    }

    // PRODID
    final prodId = productId ?? vcard.productId;
    if (prodId != null && prodId.isNotEmpty) {
      lines.add(_formatProperty(PropertyName.prodid, _escape(prodId, version)));
    }

    // REV
    if (vcard.revision != null && vcard.revision!.isNotEmpty) {
      lines.add(
        _formatProperty(PropertyName.rev, vcard.revision!.toDateTimeString()),
      );
    }

    // SOUND
    if (vcard.sound != null && vcard.sound!.isNotEmpty) {
      final line = _formatBinaryProperty(
        PropertyName.sound,
        vcard.sound!,
        version,
      );
      if (line != null) lines.add(line);
    }

    // UID
    if (vcard.uid != null && vcard.uid!.isNotEmpty) {
      lines.add(_formatProperty(PropertyName.uid, vcard.uid!));
    }

    // URL
    for (final url in vcard.urls) {
      final params = _buildParams(version, types: url.types, pref: url.pref);
      lines.add(
        _formatProperty(
          PropertyName.url,
          url.url,
          params: params.isEmpty ? null : VCardParameters(params),
        ),
      );
    }

    // KEY
    for (final key in vcard.keys) {
      final line = _formatBinaryProperty(PropertyName.key, key, version);
      if (line != null) lines.add(line);
    }

    // Calendar properties (RFC 2739)
    for (final fbUrl in vcard.freeBusyUrls) {
      lines.add(_formatProperty(PropertyName.fburl, fbUrl));
    }
    for (final calUrl in vcard.calendarUrls) {
      lines.add(_formatProperty(PropertyName.caluri, calUrl));
    }
    for (final calAdrUrl in vcard.calendarAddressUrls) {
      lines.add(_formatProperty(PropertyName.caladruri, calAdrUrl));
    }

    // KIND (vCard 4.0)
    if (version == VCardVersion.v40 && vcard.kind != null) {
      lines.add(_formatProperty(PropertyName.kind, vcard.kind!.value));
    }

    // XML (vCard 4.0)
    if (version == VCardVersion.v40) {
      for (final xmlContent in vcard.xml) {
        lines.add(_formatProperty(PropertyName.xml, xmlContent));
      }
    }

    // SOURCE
    for (final source in vcard.sources) {
      lines.add(_formatProperty(PropertyName.source, source));
    }

    // Extended properties
    for (final prop in vcard.extendedProperties) {
      lines.add(
        _formatProperty(
          prop.name,
          _escape(prop.value, version),
          params: prop.parameters,
        ),
      );
    }
  }

  String _formatProperty(String name, String value, {VCardParameters? params}) {
    final buffer = StringBuffer(name);
    if (params != null && params.isNotEmpty) {
      for (final param in params) {
        buffer.write(';');
        buffer.write(_formatParameter(param));
      }
    }
    buffer.write(':');
    buffer.write(value);
    return buffer.toString();
  }

  String _formatParameter(VCardParameter param) {
    if (param.values.isEmpty) {
      return param.name;
    }
    final values = param.values.map(_quoteIfNeeded).join(',');
    return '${param.name}=$values';
  }

  String _quoteIfNeeded(String value) {
    if (value.contains(':') ||
        value.contains(';') ||
        value.contains(',') ||
        value.contains('\n')) {
      return '"$value"';
    }
    return value;
  }

  String _escape(String value, VCardVersion version) {
    if (version == VCardVersion.v21) {
      // vCard 2.1 uses different escaping
      return value.replaceAll('\n', '=0D=0A');
    }
    return ValueEscaping.escape(value);
  }

  String _formatStructuredName(StructuredName name, VCardVersion version) {
    // If it's a raw value, return it escaped
    if (name.isRaw && name.rawValue != null) {
      return _escape(name.rawValue!, version);
    }
    final components = name.toComponents();
    return components.map((c) => _escape(c, version)).join(';');
  }

  String _formatAddress(Address addr, VCardVersion version) {
    final params = _buildParams(
      version,
      types: addr.types,
      pref: addr.pref,
      label: addr.label,
      language: addr.language,
    );

    if (version == VCardVersion.v40) {
      // Add GEO parameter if present
      if (addr.geo != null) {
        params.add(
          VCardParameter.single(ParameterName.geoPosition, addr.geo!.toUri()),
        );
      }
      // Add TZ parameter if present
      if (addr.timezone != null) {
        params.add(
          VCardParameter.single(ParameterName.timezone, addr.timezone!),
        );
      }
    }

    // If it's a raw value, return it escaped
    String value;
    if (addr.isRaw && addr.rawValue != null) {
      value = _escape(addr.rawValue!, version);
    } else {
      final components = addr.toComponents();
      value = components.map((c) => _escape(c, version)).join(';');
    }
    return _formatProperty(
      PropertyName.adr,
      value,
      params: params.isEmpty ? null : VCardParameters(params),
    );
  }

  String _formatTelephone(Telephone tel, VCardVersion version) {
    final params = _buildParams(version, types: tel.types, pref: tel.pref);

    if (version == VCardVersion.v40) {
      // vCard 4.0 uses VALUE=uri with tel: URI
      params.add(VCardParameter.single(ParameterName.value, ValueType.uri));
      return _formatProperty(
        PropertyName.tel,
        tel.toUri(),
        params: params.isEmpty ? null : VCardParameters(params),
      );
    }

    return _formatProperty(
      PropertyName.tel,
      tel.number,
      params: params.isEmpty ? null : VCardParameters(params),
    );
  }

  String _formatEmail(Email email, VCardVersion version) {
    final params = _buildParams(version, types: email.types, pref: email.pref);

    if (version == VCardVersion.v21) {
      // vCard 2.1 often includes INTERNET type
      if (email.types.isEmpty || !email.types.contains('INTERNET')) {
        params.add(VCardParameter.single(ParameterName.type, 'INTERNET'));
      }
    }

    return _formatProperty(
      PropertyName.email,
      email.address,
      params: params.isEmpty ? null : VCardParameters(params),
    );
  }

  String _formatImpp(InstantMessaging impp, VCardVersion version) {
    final params = _buildParams(version, types: impp.types, pref: impp.pref);
    return _formatProperty(
      PropertyName.impp,
      impp.uri,
      params: params.isEmpty ? null : VCardParameters(params),
    );
  }

  String _formatOrganization(Organization org, VCardVersion version) {
    final params = <VCardParameter>[];
    if (org.sortAs != null) {
      params.add(VCardParameter.single(ParameterName.sortAs, org.sortAs!));
    }

    // If it's a raw value, return it escaped
    String value;
    if (org.isRaw && org.rawValue != null) {
      value = _escape(org.rawValue!, version);
    } else {
      final components = org.toComponents();
      value = components.map((c) => _escape(c, version)).join(';');
    }
    return _formatProperty(
      PropertyName.org,
      value,
      params: params.isEmpty ? null : VCardParameters(params),
    );
  }

  String? _formatBinaryProperty(
    String name,
    BinaryData data,
    VCardVersion version, {
    List<String>? types,
    int? pref,
  }) {
    if (data.isEmpty) return null;

    final params = _buildParams(version, types: types, pref: pref);

    if (data.isUri) {
      if (version == VCardVersion.v40) {
        // vCard 4.0 might need VALUE=uri
        if (!data.uri!.startsWith('data:')) {
          params.add(VCardParameter.single(ParameterName.value, ValueType.uri));
        }
      }
      if (data.mediaType != null) {
        params.add(
          VCardParameter.single(ParameterName.mediatype, data.mediaType!),
        );
      }
      return _formatProperty(name, data.uri!, params: VCardParameters(params));
    }

    // Inline data
    if (version == VCardVersion.v40) {
      // vCard 4.0: use data: URI
      return _formatProperty(
        name,
        data.dataUri!,
        params: params.isEmpty ? null : VCardParameters(params),
      );
    } else {
      // vCard 2.1/3.0: use ENCODING parameter
      params.add(
        VCardParameter.single(
          ParameterName.encoding,
          version == VCardVersion.v21 ? EncodingValue.base64 : EncodingValue.b,
        ),
      );
      if (data.mediaType != null) {
        if (version == VCardVersion.v21) {
          // vCard 2.1 uses TYPE for media type
          params.add(
            VCardParameter.single(ParameterName.type, data.mediaType!),
          );
        } else {
          params.add(
            VCardParameter.single(ParameterName.mediatype, data.mediaType!),
          );
        }
      }
      return _formatProperty(
        name,
        data.base64!,
        params: params.isEmpty ? null : VCardParameters(params),
      );
    }
  }

  List<VCardParameter> _buildParams(
    VCardVersion version, {
    List<String>? types,
    int? pref,
    String? label,
    String? mediaType,
    String? language,
  }) {
    final params = <VCardParameter>[];

    if (types != null && types.isNotEmpty) {
      if (version == VCardVersion.v21 && !useModernTypes) {
        // vCard 2.1: types without TYPE= prefix
        for (final t in types) {
          params.add(VCardParameter(t.toUpperCase()));
        }
      } else {
        params.add(
          VCardParameter(
            ParameterName.type,
            types.map((t) => t.toUpperCase()).toList(),
          ),
        );
      }
    }

    if (version != VCardVersion.v21) {
      // PREF is vCard 3.0/4.0
      if (pref != null) {
        params.add(VCardParameter.single(ParameterName.pref, pref.toString()));
      }
    } else if (pref != null && pref <= 1) {
      // vCard 2.1: PREF as type
      params.add(VCardParameter('PREF'));
    }

    if (label != null && version == VCardVersion.v40) {
      params.add(VCardParameter.single(ParameterName.label, label));
    }

    if (mediaType != null) {
      params.add(VCardParameter.single(ParameterName.mediatype, mediaType));
    }

    if (language != null) {
      params.add(VCardParameter.single(ParameterName.language, language));
    }

    return params;
  }
}
