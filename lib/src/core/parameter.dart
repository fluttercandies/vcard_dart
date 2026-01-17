import 'dart:collection';

import 'parameter_name.dart';

/// Represents a vCard property parameter.
///
/// Parameters are key-value pairs that modify the behavior or meaning
/// of a vCard property. For example, `TYPE=work` or `PREF=1`.
///
/// ## Example
///
/// ```dart
/// // Create a TYPE parameter
/// final typeParam = VCardParameter(ParameterName.type, ['work', 'voice']);
///
/// // Create a PREF parameter
/// final prefParam = VCardParameter.single(ParameterName.pref, '1');
///
/// // Create a vCard 2.1 style bare parameter
/// final bareParam = VCardParameter('WORK');
///
/// // Check parameter type
/// if (typeParam.isType) {
///   print('This is a TYPE parameter');
/// }
/// ```
class VCardParameter {
  /// The parameter name (e.g., "TYPE", "PREF").
  final String name;

  /// The parameter values.
  ///
  /// Most parameters have a single value, but some (like TYPE) can have
  /// multiple values.
  final List<String> values;

  /// Creates a new parameter with the given name and values.
  VCardParameter(this.name, [List<String>? values])
    : values = List.unmodifiable(values ?? const []);

  /// Creates a new parameter with a single value.
  VCardParameter.single(this.name, String value)
    : values = List.unmodifiable([value]);

  /// The first value, or null if empty.
  String? get value => values.isNotEmpty ? values.first : null;

  /// Whether this is a TYPE parameter.
  bool get isType => name.toUpperCase() == ParameterName.type;

  /// Whether this is a PREF parameter.
  bool get isPref => name.toUpperCase() == ParameterName.pref;

  /// Whether this is a VALUE parameter.
  bool get isValue => name.toUpperCase() == ParameterName.value;

  /// Whether this is an ENCODING parameter.
  bool get isEncoding => name.toUpperCase() == ParameterName.encoding;

  /// Whether this is a CHARSET parameter.
  bool get isCharset => name.toUpperCase() == ParameterName.charset;

  /// Whether this is a LANGUAGE parameter.
  bool get isLanguage => name.toUpperCase() == ParameterName.language;

  /// Returns the preference value as an integer, or null if not a PREF parameter.
  int? get prefValue {
    if (!isPref || values.isEmpty) return null;
    return int.tryParse(values.first);
  }

  @override
  String toString() {
    if (values.isEmpty) {
      return name;
    }
    if (values.length == 1) {
      return '$name=${values.first}';
    }
    return '$name=${values.join(",")}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VCardParameter) return false;
    if (name.toUpperCase() != other.name.toUpperCase()) return false;
    if (values.length != other.values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (values[i] != other.values[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(name.toUpperCase(), Object.hashAll(values));

  /// Creates a copy of this parameter with optional modifications.
  VCardParameter copyWith({String? name, List<String>? values}) {
    return VCardParameter(name ?? this.name, values ?? this.values);
  }
}

/// A collection of vCard parameters.
///
/// This class provides convenient access to parameters by name and type.
///
/// ## Example
///
/// ```dart
/// // Create parameter collection
/// final params = VCardParameters([
///   VCardParameter(ParameterName.type, ['work', 'voice']),
///   VCardParameter.single(ParameterName.pref, '1'),
/// ]);
///
/// // Access parameters
/// final types = params.types;  // ['work', 'voice']
/// final pref = params.pref;    // 1
/// final isWork = params.isWork;  // true
///
/// // Build parameters using builder
/// final built = VCardParametersBuilder()
///     .type(['work', 'cell'])
///     .pref(1)
///     .build();
/// ```
class VCardParameters extends IterableBase<VCardParameter> {
  final List<VCardParameter> _parameters;

  /// Creates a new parameter collection.
  VCardParameters([List<VCardParameter>? parameters])
    : _parameters = List.unmodifiable(parameters ?? const []);

  /// Creates an empty parameter collection.
  const VCardParameters.empty() : _parameters = const [];

  @override
  Iterator<VCardParameter> get iterator => _parameters.iterator;

  /// Returns all parameters with the given name (case-insensitive).
  Iterable<VCardParameter> byName(String name) {
    final upper = name.toUpperCase();
    return _parameters.where((p) => p.name.toUpperCase() == upper);
  }

  /// Returns the first parameter with the given name, or null if not found.
  VCardParameter? firstByName(String name) {
    final upper = name.toUpperCase();
    for (final p in _parameters) {
      if (p.name.toUpperCase() == upper) {
        return p;
      }
    }
    return null;
  }

  /// Returns the first value of the parameter with the given name.
  String? getValue(String name) => firstByName(name)?.value;

  /// Returns all values of parameters with the given name.
  List<String> getValues(String name) {
    return byName(name).expand((p) => p.values).toList();
  }

  /// Whether any parameter with the given name exists.
  bool hasParameter(String name) => firstByName(name) != null;

  /// The TYPE parameter values.
  ///
  /// This includes both TYPE=value parameters and vCard 2.1 style
  /// bare type parameters (e.g., WORK, HOME, CELL).
  List<String> get types {
    final result = <String>[];
    // Add explicit TYPE parameter values
    result.addAll(getValues(ParameterName.type));
    // Add vCard 2.1 style bare type parameters (parameters without values)
    for (final p in _parameters) {
      if (p.values.isEmpty && _isKnownType(p.name)) {
        result.add(p.name.toLowerCase());
      }
    }
    return result;
  }

  /// Checks if a parameter name is a known vCard 2.1 bare type.
  static bool _isKnownType(String name) {
    final upper = name.toUpperCase();
    return const {
      'WORK',
      'HOME',
      'CELL',
      'VOICE',
      'FAX',
      'VIDEO',
      'PAGER',
      'TEXTPHONE',
      'TEXT',
      'MSG',
      'POSTAL',
      'PARCEL',
      'DOM',
      'INTL',
      'PREF',
      'INTERNET',
      'X400',
      'BBS',
      'MODEM',
      'CAR',
      'ISDN',
      'PCS',
    }.contains(upper);
  }

  /// The first TYPE parameter value, or null.
  String? get type => getValue(ParameterName.type);

  /// The VALUE parameter value (data type).
  String? get valueType => getValue(ParameterName.value);

  /// The PREF parameter value as an integer.
  int? get pref {
    final value = getValue(ParameterName.pref);
    return value != null ? int.tryParse(value) : null;
  }

  /// The LANGUAGE parameter value.
  String? get language => getValue(ParameterName.language);

  /// The ENCODING parameter value.
  String? get encoding => getValue(ParameterName.encoding);

  /// The CHARSET parameter value.
  String? get charset => getValue(ParameterName.charset);

  /// The MEDIATYPE parameter value.
  String? get mediaType => getValue(ParameterName.mediatype);

  /// The ALTID parameter value.
  String? get altId => getValue(ParameterName.altid);

  /// The PID parameter values.
  List<String> get pids => getValues(ParameterName.pid);

  /// Whether this is marked as preferred (TYPE=pref or PREF parameter).
  bool get isPreferred {
    if (pref != null && pref! <= 1) return true;
    return types.any((t) => t.toLowerCase() == 'pref');
  }

  /// Whether TYPE contains "work".
  bool get isWork => types.any((t) => t.toLowerCase() == TypeValue.work);

  /// Whether TYPE contains "home".
  bool get isHome => types.any((t) => t.toLowerCase() == TypeValue.home);

  /// Returns a new collection with the given parameter added.
  VCardParameters add(VCardParameter parameter) {
    return VCardParameters([..._parameters, parameter]);
  }

  /// Returns a new collection with all parameters of the given name removed.
  VCardParameters removeByName(String name) {
    final upper = name.toUpperCase();
    return VCardParameters(
      _parameters.where((p) => p.name.toUpperCase() != upper).toList(),
    );
  }

  /// Returns a new collection with the given parameter replaced or added.
  VCardParameters set(VCardParameter parameter) {
    return removeByName(parameter.name).add(parameter);
  }

  /// Converts to a map where keys are parameter names and values are lists.
  Map<String, List<String>> toMap() {
    final map = <String, List<String>>{};
    for (final p in _parameters) {
      final key = p.name.toUpperCase();
      if (map.containsKey(key)) {
        map[key]!.addAll(p.values);
      } else {
        map[key] = List.from(p.values);
      }
    }
    return map;
  }

  @override
  String toString() {
    if (_parameters.isEmpty) return '';
    return _parameters.map((p) => p.toString()).join(';');
  }
}

/// Builder for creating [VCardParameters].
///
/// ## Example
///
/// ```dart
/// final params = VCardParametersBuilder()
///     .type(['work', 'voice'])
///     .pref(1)
///     .language('en-US')
///     .build();
/// ```
class VCardParametersBuilder {
  final List<VCardParameter> _parameters = [];

  /// Adds a parameter with the given name and values.
  VCardParametersBuilder add(String name, [List<String>? values]) {
    _parameters.add(VCardParameter(name, values));
    return this;
  }

  /// Adds a parameter with a single value.
  VCardParametersBuilder addSingle(String name, String value) {
    _parameters.add(VCardParameter.single(name, value));
    return this;
  }

  /// Adds a TYPE parameter with the given types.
  VCardParametersBuilder type(List<String> types) {
    return add(ParameterName.type, types);
  }

  /// Adds a single TYPE value.
  VCardParametersBuilder addType(String typeValue) {
    // Find existing TYPE parameter and add to it, or create new
    final existingIndex = _parameters.indexWhere(
      (p) => p.name.toUpperCase() == ParameterName.type,
    );
    if (existingIndex >= 0) {
      final existing = _parameters[existingIndex];
      _parameters[existingIndex] = VCardParameter(existing.name, [
        ...existing.values,
        typeValue,
      ]);
    } else {
      _parameters.add(VCardParameter(ParameterName.type, [typeValue]));
    }
    return this;
  }

  /// Adds a PREF parameter.
  VCardParametersBuilder pref(int value) {
    return addSingle(ParameterName.pref, value.toString());
  }

  /// Sets the PREF parameter (alias for pref).
  VCardParametersBuilder setPref(int value) => pref(value);

  /// Adds a VALUE parameter.
  VCardParametersBuilder value(String type) {
    return addSingle(ParameterName.value, type);
  }

  /// Adds a LANGUAGE parameter.
  VCardParametersBuilder language(String lang) {
    return addSingle(ParameterName.language, lang);
  }

  /// Sets the LANGUAGE parameter (alias for language).
  VCardParametersBuilder setLanguage(String lang) => language(lang);

  /// Adds a MEDIATYPE parameter.
  VCardParametersBuilder mediaType(String type) {
    return addSingle(ParameterName.mediatype, type);
  }

  /// Adds an ENCODING parameter.
  VCardParametersBuilder encoding(String enc) {
    return addSingle(ParameterName.encoding, enc);
  }

  /// Adds a CHARSET parameter.
  VCardParametersBuilder charset(String cs) {
    return addSingle(ParameterName.charset, cs);
  }

  /// Adds an ALTID parameter.
  VCardParametersBuilder altId(String id) {
    return addSingle(ParameterName.altid, id);
  }

  /// Builds the parameters collection.
  VCardParameters build() => VCardParameters(_parameters);
}
