# vcard_dart

<p align="center">
  <img src="vcard.svg" width="200" alt="vcard_dart logo">
</p>

<p align="center">
  English | <a href="README_zh-CN.md">简体中文</a>
</p>

<p align="center">
  A comprehensive vCard parsing and generation library for Dart/Flutter.
</p>

<p align="center">
  <a href="https://pub.dev/packages/vcard_dart">
    <img src="https://img.shields.io/pub/v/vcard_dart" alt="Pub Version">
  </a>
  <a href="https://pub.dev/packages/vcard_dart/score">
    <img src="https://img.shields.io/pub/points/vcard_dart" alt="Pub Points">
  </a>
  <a href="https://pub.dev/packages/vcard_dart/score">
    <img src="https://img.shields.io/pub/popularity/vcard_dart" alt="Pub Popularity">
  </a>
  <a href="https://pub.dev/packages/vcard_dart/score">
    <img src="https://img.shields.io/pub/likes/vcard_dart" alt="Pub Likes">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
  </a>
</p>

<p align="center">
  <a href="https://pub.dev/documentation/vcard_dart/latest/">📖 API Documentation</a> |
  <a href="https://pub.dev/packages/vcard_dart">📦 pub.dev</a>
</p>

## Features

- ✅ Full vCard 2.1, 3.0, and 4.0 support (RFC 2426, RFC 6350)
- ✅ jCard (JSON) representation (RFC 7095)
- ✅ xCard (XML) representation (RFC 6351)
- ✅ Platform-agnostic (Web, Mobile, Desktop)
- ✅ Type-safe API with comprehensive validation
- ✅ Zero dependencies - pure Dart implementation
- ✅ Extensive test coverage

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  vcard_dart: ^2.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:vcard_dart/vcard_dart.dart';

// Create a vCard
final vcard = VCard()
  ..formattedName = 'John Doe'
  ..name = const StructuredName(
    family: 'Doe',
    given: 'John',
  )
  ..emails.add(Email.work('john@example.com'))
  ..telephones.add(Telephone.cell('+1-555-123-4567'))
  ..addresses.add(const Address(
    street: '123 Main St',
    city: 'Anytown',
    region: 'CA',
    postalCode: '12345',
    country: 'USA',
    types: ['work'],
  ));

// Generate vCard 4.0 string
final generator = VCardGenerator();
final vcardString = generator.generate(vcard, version: VCardVersion.v40);

// Parse vCard
final parser = VCardParser();
final parsed = parser.parseSingle(vcardString);
print(parsed.formattedName); // John Doe
```

## Usage

### Creating vCards

```dart
final vcard = VCard()
  // Required
  ..formattedName = 'Dr. Jane Smith, PhD'
  
  // Structured name
  ..name = const StructuredName(
    family: 'Smith',
    given: 'Jane',
    additional: ['Marie'],
    prefixes: ['Dr.'],
    suffixes: ['PhD'],
  )
  
  // Communication
  ..telephones.addAll([
    Telephone.cell('+1-555-000-0000'),
    Telephone.work('+1-555-111-1111'),
  ])
  ..emails.addAll([
    Email.work('jane.smith@company.com'),
    Email.home('jane@personal.com'),
  ])
  
  // Organization
  ..organization = const Organization(
    name: 'Acme Corporation',
    units: ['Engineering', 'R&D'],
  )
  ..title = 'Senior Engineer'
  ..role = 'Lead Developer'
  
  // Address
  ..addresses.add(const Address(
    street: '456 Tech Park',
    city: 'Silicon Valley',
    region: 'CA',
    postalCode: '94000',
    country: 'USA',
    types: ['work'],
  ))
  
  // Additional info
  ..birthday = DateOrDateTime(year: 1985, month: 4, day: 15)
  ..note = 'Key contact for technical projects'
  ..urls.add(WebUrl.work('https://company.com/jsmith'))
  ..categories = ['Colleague', 'Tech', 'VIP'];
```

### Parsing vCards

```dart
final parser = VCardParser();

// Parse a single vCard
const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:John Doe
N:Doe;John;;;
TEL;TYPE=CELL:+1-555-123-4567
EMAIL:john@example.com
END:VCARD
''';

final vcard = parser.parseSingle(vcardText);
print(vcard.formattedName); // John Doe
print(vcard.telephones.first.number); // +1-555-123-4567

// Parse multiple vCards
const multipleVcards = '''
BEGIN:VCARD
VERSION:4.0
FN:Person One
END:VCARD
BEGIN:VCARD
VERSION:4.0
FN:Person Two
END:VCARD
''';

final vcards = parser.parse(multipleVcards);
print(vcards.length); // 2

// Lenient parsing mode (tolerates some errors)
final lenientParser = VCardParser(lenient: true);
final recovered = lenientParser.parse(malformedVcardText);
```

### Generating vCards

```dart
final generator = VCardGenerator();

// Generate vCard 4.0 (default)
final v40 = generator.generate(vcard);

// Generate vCard 3.0
final v30 = generator.generate(vcard, version: VCardVersion.v30);

// Generate vCard 2.1
final v21 = generator.generate(vcard, version: VCardVersion.v21);

// Generate multiple vCards
final multipleVcards = generator.generateAll([vcard1, vcard2]);
```

### jCard (JSON Format)

```dart
final formatter = JCardFormatter();

// Convert to jCard
final json = formatter.toJson(vcard);
final jsonString = formatter.toJsonString(vcard);

// Parse from jCard
final fromJson = formatter.fromJson(json);
final fromString = formatter.fromJsonString(jsonString);
```

### xCard (XML Format)

```dart
final formatter = XCardFormatter();

// Convert to xCard
final xml = formatter.toXml(vcard);
final prettyXml = formatter.toXml(vcard, pretty: true);

// Parse from xCard
final fromXml = formatter.fromXml(xmlString);
```

## Supported Properties

### Essential Properties
| Property | vCard 2.1 | vCard 3.0 | vCard 4.0 | Description |
|----------|-----------|-----------|-----------|-------------|
| FN | ✅ | ✅ | ✅ | Formatted Name (Required) |
| N | ✅ | ✅ | ✅ | Structured Name |
| NICKNAME | ❌ | ✅ | ✅ | Nickname |
| PHOTO | ✅ | ✅ | ✅ | Photograph |
| BDAY | ✅ | ✅ | ✅ | Birthday |
| ANNIVERSARY | ❌ | ❌ | ✅ | Anniversary |
| GENDER | ❌ | ❌ | ✅ | Gender |

### Communication
| Property | vCard 2.1 | vCard 3.0 | vCard 4.0 | Description |
|----------|-----------|-----------|-----------|-------------|
| TEL | ✅ | ✅ | ✅ | Telephone Number |
| EMAIL | ✅ | ✅ | ✅ | Email Address |
| IMPP | ❌ | ✅ | ✅ | Instant Messaging |
| LANG | ❌ | ❌ | ✅ | Language Preference |

### Address/Location
| Property | vCard 2.1 | vCard 3.0 | vCard 4.0 | Description |
|----------|-----------|-----------|-----------|-------------|
| ADR | ✅ | ✅ | ✅ | Postal Address |
| LABEL | ✅ | ✅ | ❌ | Address Label |
| GEO | ✅ | ✅ | ✅ | Geographic Position |
| TZ | ✅ | ✅ | ✅ | Timezone |

### Organization
| Property | vCard 2.1 | vCard 3.0 | vCard 4.0 | Description |
|----------|-----------|-----------|-----------|-------------|
| ORG | ✅ | ✅ | ✅ | Organization Name |
| TITLE | ✅ | ✅ | ✅ | Job Title |
| ROLE | ✅ | ✅ | ✅ | Role |
| LOGO | ✅ | ✅ | ✅ | Organization Logo |
| MEMBER | ❌ | ❌ | ✅ | Group Member |
| RELATED | ❌ | ❌ | ✅ | Related Person |

### Other
| Property | vCard 2.1 | vCard 3.0 | vCard 4.0 | Description |
|----------|-----------|-----------|-----------|-------------|
| NOTE | ✅ | ✅ | ✅ | Notes |
| PRODID | ❌ | ✅ | ✅ | Product ID |
| REV | ✅ | ✅ | ✅ | Revision |
| SOUND | ✅ | ✅ | ✅ | Sound |
| UID | ✅ | ✅ | ✅ | Unique Identifier |
| URL | ✅ | ✅ | ✅ | Website |
| VERSION | ✅ | ✅ | ✅ | Version (Required) |
| KEY | ✅ | ✅ | ✅ | Public Key |
| CATEGORIES | ❌ | ✅ | ✅ | Categories |
| SOURCE | ❌ | ✅ | ✅ | Source Directory |
| KIND | ❌ | ❌ | ✅ | Kind (individual/org/group/location) |

## Error Handling

The library provides detailed exception types:

```dart
try {
  final vcard = parser.parseSingle(invalidText);
} on VCardParseException catch (e) {
  print('Parse error: ${e.message}');
  print('Line: ${e.line}');
} on MissingPropertyException catch (e) {
  print('Missing required property: ${e.propertyName}');
} on UnsupportedVersionException catch (e) {
  print('Version error: ${e.message}');
}
```

## RFC Compliance

This library implements the following RFCs:

- [RFC 2425](https://www.rfc-editor.org/rfc/rfc2425.html) - MIME Content-Type for Directory Information
- [RFC 2426](https://www.rfc-editor.org/rfc/rfc2426.html) - vCard 3.0
- [RFC 6350](https://datatracker.ietf.org/doc/html/rfc6350) - vCard 4.0
- [RFC 6351](https://datatracker.ietf.org/doc/html/rfc6351) - xCard XML Representation
- [RFC 7095](https://www.rfc-editor.org/rfc/rfc7095.html) - jCard JSON Format
- [vCard 2.1](https://github.com/emacsmirror/addressbook/blob/master/vcard-21.txt) - Legacy Format

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests: `dart test`
5. Run analysis: `dart analyze`
6. Format code: `dart format .`
7. Commit: `git commit -m 'feat: add amazing feature'`
8. Push: `git push origin feature/amazing-feature`
9. Open a Pull Request

