import 'package:vcard_dart/vcard_dart.dart';

/// Domain entity representing a contact in the application.
/// This wraps the vCard model with additional app-specific metadata.
class ContactEntity {
  /// Creates a new contact entity.
  const ContactEntity({
    required this.id,
    required this.vCard,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.tags = const [],
  });

  /// Unique identifier for this contact.
  final String id;

  /// The underlying vCard data.
  final VCard vCard;

  /// When this contact was created.
  final DateTime? createdAt;

  /// When this contact was last updated.
  final DateTime? updatedAt;

  /// Whether this contact is marked as favorite.
  final bool isFavorite;

  /// Tags/labels for organizing contacts.
  final List<String> tags;

  /// Get the display name for this contact.
  String get displayName {
    final fn = vCard.formattedName;
    if (fn.isNotEmpty) {
      return fn;
    }

    final name = vCard.name;
    if (name != null) {
      final parts = <String>[];
      if (name.given.isNotEmpty) {
        parts.add(name.given);
      }
      if (name.family.isNotEmpty) {
        parts.add(name.family);
      }
      if (parts.isNotEmpty) {
        return parts.join(' ');
      }
    }

    final emails = vCard.emails;
    if (emails.isNotEmpty) {
      return emails.first.address;
    }

    final phones = vCard.telephones;
    if (phones.isNotEmpty) {
      return phones.first.number;
    }

    return 'Unnamed Contact';
  }

  /// Get the primary email if available.
  String? get primaryEmail {
    final emails = vCard.emails;
    if (emails.isEmpty) return null;
    return emails.first.address;
  }

  /// Get the primary phone if available.
  String? get primaryPhone {
    final phones = vCard.telephones;
    if (phones.isEmpty) return null;
    return phones.first.number;
  }

  /// Get the organization name if available.
  String? get organizationName {
    final org = vCard.organization;
    if (org == null) return null;
    return org.name;
  }

  /// Get the job title if available.
  String? get jobTitle {
    return vCard.title;
  }

  /// Get initials for avatar display.
  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Creates a copy of this entity with optional new values.
  ContactEntity copyWith({
    String? id,
    VCard? vCard,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return ContactEntity(
      id: id ?? this.id,
      vCard: vCard ?? this.vCard,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ContactEntity(id: $id, name: $displayName)';
}
