# Contributing to vcard_dart

Thank you for your interest in contributing to vcard_dart! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and considerate in all interactions. We welcome contributors of all backgrounds and experience levels.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/iota9star/vcard_dart/issues)
2. If not, create a new issue with:
   - A clear, descriptive title
   - Steps to reproduce the bug
   - Expected vs actual behavior
   - vCard version affected (2.1, 3.0, 4.0)
   - Dart/Flutter version
   - Sample vCard data if applicable

### Suggesting Features

1. Check existing issues and discussions for similar suggestions
2. Create a new issue describing:
   - The feature you'd like to see
   - Use cases for the feature
   - Relevant RFC specifications if applicable

### Contributing Code

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/vcard_dart.git
   cd vcard_dart
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the coding standards below
   - Add tests for new functionality
   - Update documentation as needed

4. **Run quality checks**
   ```bash
   dart pub get
   dart test
   dart analyze
   dart format .
   ```

5. **Commit your changes**
   ```bash
   git commit -m "feat: add your feature description"
   ```
   
   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `test:` for test additions/changes
   - `refactor:` for code refactoring

6. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Coding Standards

### General Guidelines

- Write clear, self-documenting code
- Use meaningful variable and function names
- Keep functions focused and small
- Add documentation comments for public APIs

### Dart Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` for consistent formatting
- Ensure `dart analyze` reports no issues

### Documentation

- Document all public APIs with `///` comments
- Include parameter descriptions
- Provide code examples where helpful
- Keep comments in English only

### Testing

- Write unit tests for all new functionality
- Test edge cases and error conditions
- Maintain or improve code coverage
- Use descriptive test names

### Example Test Structure

```dart
group('FeatureName', () {
  test('should do something specific', () {
    // Arrange
    final input = ...;
    
    // Act
    final result = ...;
    
    // Assert
    expect(result, ...);
  });
});
```

## Project Structure

```
lib/
├── src/
│   ├── core/          # Core classes (Version, Property, Parameter)
│   ├── models/        # Data models (VCard, Address, etc.)
│   ├── parsers/       # Parsing logic
│   ├── generators/    # Generation logic
│   ├── formatters/    # jCard, xCard formatters
│   └── exceptions.dart
└── vcard_dart.dart    # Main export
```

## RFC Compliance

When implementing features, refer to the relevant RFCs:

- RFC 2425 - MIME Directory Framework
- RFC 2426 - vCard 3.0
- RFC 6350 - vCard 4.0
- RFC 6351 - xCard
- RFC 7095 - jCard

## Questions?

If you have questions, feel free to:
- Open an issue with the "question" label
- Start a discussion in the repository

Thank you for contributing!
