/// Supported export formats for vCard data.
enum ExportFormat {
  /// Standard vCard format (RFC 6350)
  vcard,

  /// jCard JSON format (RFC 7095)
  jcard,

  /// xCard XML format (RFC 6351)
  xcard,
}

/// Extension methods for ExportFormat.
extension ExportFormatExtension on ExportFormat {
  /// Get the display name for this format.
  String get displayName {
    switch (this) {
      case ExportFormat.vcard:
        return 'vCard (.vcf)';
      case ExportFormat.jcard:
        return 'jCard (JSON)';
      case ExportFormat.xcard:
        return 'xCard (XML)';
    }
  }

  /// Get the file extension for this format.
  String get fileExtension {
    switch (this) {
      case ExportFormat.vcard:
        return 'vcf';
      case ExportFormat.jcard:
        return 'json';
      case ExportFormat.xcard:
        return 'xml';
    }
  }

  /// Get the MIME type for this format.
  String get mimeType {
    switch (this) {
      case ExportFormat.vcard:
        return 'text/vcard';
      case ExportFormat.jcard:
        return 'application/json';
      case ExportFormat.xcard:
        return 'application/xml';
    }
  }
}
