# vCard Studio - vCard Dart Example App

A Neo-Brutalism styled Flutter application demonstrating the vcard_dart library capabilities.

## Features

- **vCard Management**: Create, edit, import, and export vCards
- **Multi-Format Support**: vCard 2.1, 3.0, 4.0, jCard (JSON), xCard (XML)
- **Neo-Brutalism UI**: Bold, high-contrast design with thick borders
- **Clean Architecture**: Domain-driven design with Riverpod state management
- **Cross-Platform**: Android, iOS, Windows, macOS, Linux, and Web

## Supported Fields

- Personal Information (Full Name, Given/Family Name, Nickname, Prefix, Suffix)
- Contact (Multiple Phone Numbers, Multiple Emails)
- Organization (Company, Job Title, Role, Department)
- Address (Multiple addresses with types)
- URLs and Social Links
- Birthday and Anniversary
- Notes

## Screenshots

The app features a distinctive Neo-Brutalism design with:

- Bold black borders
- Bright color accents (Yellow, Pink, Teal)
- High contrast text
- Shadow offsets for depth

## Getting Started

```bash
cd example
flutter pub get
flutter run
```

## Architecture

The app follows Clean Architecture principles:

```
lib/
├── core/          # Theme, config, constants
├── data/          # Data sources, models, repositories impl
├── domain/        # Entities, repositories, use cases
└── presentation/  # Pages, widgets, providers
```

## Design System

The app uses Neo-Brutalism design principles:

```dart
class AppColors {
  static const primary = Color(0xFFFFDE59);     // Bright Yellow
  static const secondary = Color(0xFFFF6B6B);   // Hot Pink
  static const accent = Color(0xFF4ECDC4);      // Teal
  static const dark = Color(0xFF1A1A1A);        // Near Black
  static const light = Color(0xFFF7F7F7);       // Off White
  static const border = Color(0xFF000000);      // Pure Black
}
```

## Library Usage Example

```dart
import 'package:vcard_dart/vcard_dart.dart';

// Create a vCard
final vcard = VCard()
  ..formattedName = 'John Doe'
  ..name = const StructuredName(
    family: 'Doe',
    given: 'John',
  )
  ..telephones.add(Telephone.cell('+1-555-123-4567'))
  ..emails.add(Email(address: 'john@example.com'));

// Generate vCard string
final generator = VCardGenerator();
final vcardString = generator.generate(vcard, version: VCardVersion.v40);

// Parse vCard string
final parser = VCardParser();
final vcards = parser.parse(vcardString);

// Export as jCard (JSON)
final jcardFormatter = JCardFormatter();
final jsonString = jcardFormatter.toJsonString(vcard);

// Export as xCard (XML)
final xcardFormatter = XCardFormatter();
final xmlString = xcardFormatter.toXml(vcard);
```

## Dependencies

- `flutter_riverpod` - State management
- `go_router` - Navigation
- `shared_preferences` - Local storage
- `uuid` - Unique ID generation

## Building

### Debug

```bash
flutter run
```

### Release

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

