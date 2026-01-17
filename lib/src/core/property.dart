import 'parameter.dart';
import 'parameter_name.dart';
import 'property_name.dart';

/// Represents a single vCard property.
///
/// A vCard property consists of a name, optional parameters, and a value.
/// For example: `TEL;TYPE=work,voice:+1-555-555-5555`
///
/// ## Example
///
/// ```dart
/// // Create a basic property
/// final prop = VCardProperty(
///   name: PropertyName.tel,
///   value: '+1-555-555-5555',
/// );
///
/// // Create with TYPE parameter
/// final withType = VCardProperty.withType(
///   name: PropertyName.email,
///   value: 'john@example.com',
///   type: 'work',
/// );
///
/// // Create with multiple TYPE parameters
/// final withMultipleTypes = VCardProperty.withTypes(
///   name: PropertyName.tel,
///   value: '+1-555-555-5555',
///   types: ['work', 'voice'],
/// );
///
/// // Create with parameters
/// final withParams = VCardProperty(
///   name: PropertyName.tel,
///   value: '+1-555-555-5555',
///   parameters: VCardParameters([
///     VCardParameter(ParameterName.type, ['work', 'voice']),
///     VCardParameter.single(ParameterName.pref, '1'),
///   ]),
/// );
///
/// // Check property attributes
/// if (prop.isStandard) {
///   print('This is a standard vCard property');
/// }
/// ```
class VCardProperty {
  /// The property name (e.g., "TEL", "EMAIL").
  final String name;

  /// The property parameters.
  final VCardParameters parameters;

  /// The raw property value as a string.
  final String value;

  /// Optional property group name.
  final String? group;

  /// Creates a new vCard property.
  const VCardProperty({
    required this.name,
    required this.value,
    this.parameters = const VCardParameters.empty(),
    this.group,
  });

  /// Creates a property with a single TYPE parameter.
  factory VCardProperty.withType({
    required String name,
    required String value,
    required String type,
    String? group,
  }) {
    return VCardProperty(
      name: name,
      value: value,
      parameters: VCardParameters([
        VCardParameter.single(ParameterName.type, type),
      ]),
      group: group,
    );
  }

  /// Creates a property with multiple TYPE parameters.
  factory VCardProperty.withTypes({
    required String name,
    required String value,
    required List<String> types,
    String? group,
  }) {
    return VCardProperty(
      name: name,
      value: value,
      parameters: VCardParameters([VCardParameter(ParameterName.type, types)]),
      group: group,
    );
  }

  /// The full property name including group prefix.
  String get fullName => group != null ? '$group.$name' : name;

  /// The uppercase property name.
  String get upperName => name.toUpperCase();

  /// Whether this is an extended (X-) property.
  bool get isExtended => PropertyName.isExtended(name);

  /// Whether this is a standard property.
  bool get isStandard => PropertyName.isStandard(name);

  /// The TYPE parameter values.
  List<String> get types => parameters.types;

  /// The PREF parameter value.
  int? get pref => parameters.pref;

  /// Whether this property is marked as preferred.
  bool get isPreferred => parameters.isPreferred;

  /// The VALUE parameter (data type).
  String? get valueType => parameters.valueType;

  /// The ENCODING parameter.
  String? get encoding => parameters.encoding;

  /// The LANGUAGE parameter.
  String? get language => parameters.language;

  /// Creates a copy of this property with optional modifications.
  VCardProperty copyWith({
    String? name,
    String? value,
    VCardParameters? parameters,
    String? group,
  }) {
    return VCardProperty(
      name: name ?? this.name,
      value: value ?? this.value,
      parameters: parameters ?? this.parameters,
      group: group ?? this.group,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    if (group != null) {
      buffer.write('$group.');
    }
    buffer.write(name);
    if (parameters.isNotEmpty) {
      buffer.write(';');
      buffer.write(parameters.toString());
    }
    buffer.write(':');
    buffer.write(value);
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VCardProperty) return false;
    return name.toUpperCase() == other.name.toUpperCase() &&
        value == other.value &&
        parameters == other.parameters &&
        group == other.group;
  }

  @override
  int get hashCode => Object.hash(name.toUpperCase(), value, parameters, group);
}
