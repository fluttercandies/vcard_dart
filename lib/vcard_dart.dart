/// A comprehensive Dart library for parsing, generating, and manipulating
/// vCard data according to RFC 2426 (vCard 3.0), RFC 6350 (vCard 4.0),
/// RFC 7095 (jCard), and RFC 6351 (xCard).
///
/// ## Features
///
/// - **Multi-version support**: Parse and generate vCard 2.1, 3.0, and 4.0
/// - **Multiple formats**: Support for standard vCard, jCard (JSON), and xCard (XML)
/// - **Type-safe models**: Strongly-typed Dart classes for all vCard properties
/// - **Extensible**: Support for custom X- properties
/// - **Round-trip safe**: Preserve unknown properties during parse/generate cycle
///
/// ## Quick Start
///
/// ```dart
/// import 'package:vcard_dart/vcard_dart.dart';
///
/// // Parse a vCard
/// final parser = VCardParser();
/// final vcards = parser.parse(vcardText);
///
/// // Create a vCard programmatically
/// final vcard = VCard()
///   ..formattedName = 'John Doe'
///   ..name = StructuredName(family: 'Doe', given: 'John')
///   ..emails.add(Email(address: 'john@example.com'))
///   ..telephones.add(Telephone.cell('+1-555-555-5555'));
///
/// // Generate vCard text
/// final generator = VCardGenerator();
/// final text = generator.generate(vcard);
///
/// // Convert to/from jCard
/// final jcard = JCardFormatter();
/// final json = jcard.toJsonString(vcard);
/// final restored = jcard.fromJsonString(json);
///
/// // Convert to/from xCard
/// final xcard = XCardFormatter();
/// final xml = xcard.toXml(vcard);
/// final restored2 = xcard.fromXml(xml);
/// ```
library;

// Core types
export 'src/core/core.dart';

// Models
export 'src/models/models.dart';

// Parsers
export 'src/parsers/parsers.dart';

// Generators
export 'src/generators/generators.dart';

// Formatters
export 'src/formatters/formatters.dart';

// Exceptions
export 'src/exceptions.dart';
