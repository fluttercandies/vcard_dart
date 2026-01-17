import 'dart:convert';

import '../core/parameter.dart';
import '../core/property.dart';
import '../exceptions.dart';

/// Handles line folding and unfolding according to RFC 2425/6350.
///
/// vCard content lines are limited to 75 characters. Longer lines must be
/// folded by inserting a CRLF followed by a whitespace character.
///
/// ## Example
///
/// ```dart
/// // Unfold vCard content
/// final folded = 'FN:John\r\n Doe';
/// final unfolded = LineFolding.unfold(folded);  // 'FN:John Doe'
///
/// // Fold long lines
/// final long = 'NOTE:This is a very long note that needs to be folded to fit within 75 characters per the vCard specification';
/// final folded = LineFolding.foldLine(long);
///
/// // Fold entire content
/// final content = 'FN:John Doe\nTEL:+1-555-555-5555';
/// final foldedContent = LineFolding.foldContent(content);
/// ```
abstract final class LineFolding {
  /// The maximum line length before folding (75 characters per RFC).
  static const maxLineLength = 75;

  /// CRLF line ending.
  static const crlf = '\r\n';

  /// LF line ending.
  static const lf = '\n';

  /// Unfolds content lines by joining continuation lines.
  ///
  /// Continuation lines are indicated by a leading whitespace (space or tab)
  /// following a line break.
  static String unfold(String content) {
    // Normalize line endings to LF first
    var normalized = content.replaceAll(crlf, lf);

    // Remove leading whitespace continuation
    // Pattern: newline followed by space or tab
    normalized = normalized.replaceAllMapped(RegExp(r'\n[ \t]'), (match) => '');

    return normalized;
  }

  /// Folds a single content line to fit within the maximum line length.
  ///
  /// Uses CRLF followed by a space for continuation.
  static String foldLine(String line, {int maxLength = maxLineLength}) {
    if (line.length <= maxLength) {
      return line;
    }

    final buffer = StringBuffer();
    var remaining = line;
    var isFirst = true;

    while (remaining.isNotEmpty) {
      // For continuation lines, we have less space due to the leading space
      final effectiveMax = isFirst ? maxLength : maxLength - 1;

      if (remaining.length <= effectiveMax) {
        if (!isFirst) {
          buffer.write(' ');
        }
        buffer.write(remaining);
        break;
      }

      // Find a safe break point (don't break in the middle of a UTF-8 sequence)
      var breakPoint = effectiveMax;
      while (breakPoint > 0 && _isUtf8Continuation(remaining, breakPoint)) {
        breakPoint--;
      }

      if (breakPoint == 0) {
        // Couldn't find a safe break point, force break
        breakPoint = effectiveMax;
      }

      if (!isFirst) {
        buffer.write(' ');
      }
      buffer.write(remaining.substring(0, breakPoint));
      buffer.write(crlf);

      remaining = remaining.substring(breakPoint);
      isFirst = false;
    }

    return buffer.toString();
  }

  /// Checks if the character at position is a UTF-8 continuation byte.
  static bool _isUtf8Continuation(String s, int pos) {
    if (pos >= s.length) return false;
    final codeUnit = s.codeUnitAt(pos);
    // UTF-8 continuation bytes are in the range 0x80-0xBF
    // In UTF-16 (Dart strings), we need to check for surrogate pairs
    return codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;
  }

  /// Folds all lines in the content.
  static String foldContent(String content, {int maxLength = maxLineLength}) {
    final lines = content.split(lf);
    final folded = lines.map((line) => foldLine(line, maxLength: maxLength));
    return folded.join(crlf);
  }
}

/// Parses vCard content lines into property structures.
///
/// ## Example
///
/// ```dart
/// // Parse a single content line
/// final line = 'TEL;TYPE=work,voice:+1-555-555-5555';
/// final prop = ContentLineParser.parseLine(line);
/// print(prop.name);  // 'TEL'
/// print(prop.value);  // '+1-555-555-5555'
/// print(prop.parameters.types);  // ['work', 'voice']
///
/// // Parse multiple lines
/// final content = '''
/// FN:John Doe
/// TEL;TYPE=work:+1-555-555-5555
/// EMAIL;TYPE=work:john@example.com
/// ''';
/// final properties = ContentLineParser.parseLines(content);
/// ```
abstract final class ContentLineParser {
  /// Parses a single content line into a [VCardProperty].
  ///
  /// Content line format: `[group.]name[;param=value]*:value`
  static VCardProperty parseLine(String line, {int? lineNumber}) {
    if (line.isEmpty) {
      throw VCardParseException('Empty content line', line: lineNumber);
    }

    String? group;
    String name;
    final parameters = <VCardParameter>[];
    String value;

    // Find the colon separator (but not inside quoted parameter values)
    final colonIndex = _findColonIndex(line);
    if (colonIndex < 0) {
      throw VCardParseException(
        'Invalid content line: missing colon separator',
        line: lineNumber,
        source: line,
      );
    }

    // Split into property part and value
    final propertyPart = line.substring(0, colonIndex);
    value = line.substring(colonIndex + 1);

    // Parse the property part
    final parts = _splitPropertyPart(propertyPart);

    if (parts.isEmpty) {
      throw VCardParseException(
        'Invalid content line: empty property name',
        line: lineNumber,
        source: line,
      );
    }

    // First part is the name (possibly with group prefix)
    final nameOrGroup = parts[0];
    final dotIndex = nameOrGroup.indexOf('.');
    if (dotIndex > 0) {
      group = nameOrGroup.substring(0, dotIndex);
      name = nameOrGroup.substring(dotIndex + 1);
    } else {
      name = nameOrGroup;
    }

    // Remaining parts are parameters
    for (var i = 1; i < parts.length; i++) {
      final param = _parseParameter(parts[i]);
      if (param != null) {
        parameters.add(param);
      }
    }

    return VCardProperty(
      name: name.toUpperCase(),
      value: value,
      parameters: VCardParameters(parameters),
      group: group,
    );
  }

  /// Finds the index of the colon separator, handling quoted values.
  static int _findColonIndex(String line) {
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ':' && !inQuotes) {
        return i;
      }
    }
    return -1;
  }

  /// Splits the property part by semicolons, handling quoted values.
  static List<String> _splitPropertyPart(String part) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < part.length; i++) {
      final char = part[i];
      if (char == '"') {
        inQuotes = !inQuotes;
        buffer.write(char);
      } else if (char == ';' && !inQuotes) {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        }
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }

    return result;
  }

  /// Parses a single parameter string.
  static VCardParameter? _parseParameter(String param) {
    if (param.isEmpty) return null;

    final equalsIndex = param.indexOf('=');
    if (equalsIndex < 0) {
      // Parameter without value (vCard 2.1 style: TYPE alone)
      // Or it could be a bare type like "WORK" without TYPE=
      return VCardParameter(param.toUpperCase());
    }

    final name = param.substring(0, equalsIndex).toUpperCase();
    final valueStr = param.substring(equalsIndex + 1);

    // Parse the value(s) - could be comma-separated or quoted
    final values = _parseParameterValues(valueStr);

    return VCardParameter(name, values);
  }

  /// Parses parameter values, handling quotes and comma separation.
  static List<String> _parseParameterValues(String valueStr) {
    if (valueStr.isEmpty) return const [];

    // If the whole value is quoted, unquote it
    if (valueStr.startsWith('"') &&
        valueStr.endsWith('"') &&
        valueStr.length > 1) {
      return [valueStr.substring(1, valueStr.length - 1)];
    }

    // Split by comma, but not inside quotes
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < valueStr.length; i++) {
      final char = valueStr[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        if (buffer.isNotEmpty) {
          values.add(_unquote(buffer.toString()));
          buffer.clear();
        }
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      values.add(_unquote(buffer.toString()));
    }

    return values;
  }

  /// Removes surrounding quotes from a string.
  static String _unquote(String s) {
    if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
      return s.substring(1, s.length - 1);
    }
    return s;
  }

  /// Parses multiple content lines from unfolded content.
  static List<VCardProperty> parseLines(String content) {
    final properties = <VCardProperty>[];
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        properties.add(parseLine(line, lineNumber: i + 1));
      } catch (e) {
        if (e is VCardParseException) {
          rethrow;
        }
        throw VCardParseException(
          'Failed to parse line: $e',
          line: i + 1,
          source: line,
        );
      }
    }

    return properties;
  }
}

/// Handles value escaping and unescaping according to vCard specs.
///
/// ## Example
///
/// ```dart
/// // Escape special characters
/// final escaped = ValueEscaping.escape('John, Doe Jr.');  // 'John\, Doe Jr\.'
///
/// // Unescape special characters
/// final unescaped = ValueEscaping.unescape('John\, Doe');  // 'John, Doe'
///
/// // Split by separator (respects escaping)
/// final parts = ValueEscaping.splitValue('one\, two,three', ',');  // ['one, two', 'three']
///
/// // Join values with escaping
/// final joined = ValueEscaping.joinValues(['one, two', 'three'], ',');  // 'one\, two,three'
/// ```
abstract final class ValueEscaping {
  /// Escapes special characters in a value.
  static String escape(String value) {
    var result = value;
    // Backslash must be escaped first
    result = result.replaceAll(r'\', r'\\');
    result = result.replaceAll('\n', r'\n');
    result = result.replaceAll(',', r'\,');
    result = result.replaceAll(';', r'\;');
    return result;
  }

  /// Unescapes special characters in a value.
  static String unescape(String value) {
    final buffer = StringBuffer();
    var i = 0;

    while (i < value.length) {
      if (value[i] == '\\' && i + 1 < value.length) {
        final next = value[i + 1];
        switch (next) {
          case 'n':
          case 'N':
            buffer.write('\n');
            i += 2;
          case ',':
            buffer.write(',');
            i += 2;
          case ';':
            buffer.write(';');
            i += 2;
          case '\\':
            buffer.write('\\');
            i += 2;
          default:
            buffer.write(value[i]);
            i++;
        }
      } else {
        buffer.write(value[i]);
        i++;
      }
    }

    return buffer.toString();
  }

  /// Splits a value by a separator, respecting escaping.
  static List<String> splitValue(String value, String separator) {
    final parts = <String>[];
    final buffer = StringBuffer();
    var i = 0;

    while (i < value.length) {
      if (value[i] == '\\' && i + 1 < value.length) {
        buffer.write(value[i]);
        buffer.write(value[i + 1]);
        i += 2;
      } else if (value.substring(i).startsWith(separator)) {
        parts.add(buffer.toString());
        buffer.clear();
        i += separator.length;
      } else {
        buffer.write(value[i]);
        i++;
      }
    }

    parts.add(buffer.toString());
    return parts;
  }

  /// Joins values with a separator, escaping as needed.
  static String joinValues(
    List<String> values,
    String separator, {
    bool escapeValues = true,
  }) {
    if (escapeValues) {
      return values.map(escape).join(separator);
    }
    return values.join(separator);
  }
}

/// Handles Quoted-Printable encoding/decoding (vCard 2.1).
///
/// ## Example
///
/// ```dart
/// // Decode Quoted-Printable text
/// final encoded = 'Hello=0AThis=20is=20a=20test';
/// final decoded = QuotedPrintable.decode(encoded);  // 'Hello\nThis is a test'
///
/// // Encode text to Quoted-Printable
/// final text = 'Hello\nThis is a test';
/// final encoded = QuotedPrintable.encode(text);  // 'Hello=0AThis is a test'
///
/// // Decode with specific charset
/// final decodedUtf8 = QuotedPrintable.decode(encoded, charset: 'UTF-8');
/// ```
abstract final class QuotedPrintable {
  /// Decodes a Quoted-Printable encoded string.
  static String decode(String input, {String charset = 'UTF-8'}) {
    final buffer = <int>[];
    var i = 0;

    while (i < input.length) {
      if (input[i] == '=') {
        if (i + 2 < input.length) {
          final hex = input.substring(i + 1, i + 3);
          if (hex == '\r\n' || hex.startsWith('\n') || hex.startsWith('\r')) {
            // Soft line break - skip
            i += hex.startsWith('\r\n') ? 3 : 2;
            continue;
          }
          try {
            final byte = int.parse(hex, radix: 16);
            buffer.add(byte);
            i += 3;
            continue;
          } catch (_) {
            // Invalid hex, treat as literal
          }
        } else if (i + 1 < input.length &&
            (input[i + 1] == '\n' || input[i + 1] == '\r')) {
          // Soft line break
          i += 2;
          continue;
        }
      }
      buffer.add(input.codeUnitAt(i));
      i++;
    }

    // Decode as UTF-8 (or specified charset)
    try {
      return utf8.decode(buffer);
    } catch (_) {
      // Fallback to Latin-1
      return String.fromCharCodes(buffer);
    }
  }

  /// Encodes a string using Quoted-Printable encoding.
  static String encode(String input) {
    final bytes = utf8.encode(input);
    final buffer = StringBuffer();
    var lineLength = 0;

    for (final byte in bytes) {
      String encoded;
      if (byte >= 33 && byte <= 126 && byte != 61) {
        // Printable ASCII except '='
        encoded = String.fromCharCode(byte);
      } else if (byte == 32 || byte == 9) {
        // Space and tab (might need encoding at end of line)
        encoded = String.fromCharCode(byte);
      } else {
        // Encode as =XX
        encoded = '=${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}';
      }

      if (lineLength + encoded.length > 73) {
        buffer.write('=\r\n');
        lineLength = 0;
      }

      buffer.write(encoded);
      lineLength += encoded.length;
    }

    return buffer.toString();
  }
}
