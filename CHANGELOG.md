# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-16

### Added

- **Core vCard Support**
  - Full support for vCard 2.1, 3.0, and 4.0 specifications
  - RFC 2425 MIME directory framework implementation
  - Line folding/unfolding per RFC specifications
  - Quoted-Printable encoding support for vCard 2.1
  - Value escaping and unescaping

- **Alternative Format Support**
  - jCard (JSON) format support (RFC 7095)
  - xCard (XML) format support (RFC 6351)
  - Round-trip conversion between formats

- **Property Support**
  - All essential properties (FN, N, NICKNAME, PHOTO, BDAY, ANNIVERSARY, GENDER)
  - Communication properties (TEL, EMAIL, IMPP, LANG)
  - Address and location (ADR, LABEL, GEO, TZ)
  - Organization properties (ORG, TITLE, ROLE, LOGO, MEMBER, RELATED)
  - Other properties (NOTE, PRODID, REV, SOUND, UID, URL, VERSION, KEY, CATEGORIES, SOURCE, KIND)
  - Extended X- properties support

- **API Features**
  - Type-safe API with full Dart type system integration
  - Lenient parsing mode for malformed vCards
  - Detailed exception hierarchy for error handling
  - Version detection and automatic parsing
  - Multi-vCard file support

- **Platform Support**
  - Platform-agnostic implementation (no dart:io dependencies)
  - Works on Web, Mobile (iOS/Android), and Desktop

- **Documentation**
  - Comprehensive API documentation
  - Usage examples in README
  - RFC reference documentation

### Technical Details

- Pure Dart implementation with zero runtime dependencies
- Extensive unit test coverage
- Follows Dart style guidelines and best practices

