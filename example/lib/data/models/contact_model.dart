import 'package:vcard_dart/vcard_dart.dart';

import '../../domain/entities/contact_entity.dart';

/// Data model for contact storage.
/// This handles JSON serialization for local storage.
class ContactModel {
  const ContactModel({
    required this.id,
    required this.vcardString,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.tags = const [],
  });

  /// Unique identifier.
  final String id;

  /// The vCard data as a string.
  final String vcardString;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  /// Favorite status.
  final bool isFavorite;

  /// Tags for organization.
  final List<String> tags;

  /// Create from JSON map.
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      vcardString: json['vcardString'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vcardString': vcardString,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'tags': tags,
    };
  }

  /// Convert to domain entity.
  ContactEntity toEntity() {
    final parser = VCardParser();
    final vcards = parser.parse(vcardString);
    final vcard = vcards.isNotEmpty ? vcards.first : _createEmptyVCard();

    return ContactEntity(
      id: id,
      vCard: vcard,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
      tags: tags,
    );
  }

  /// Create from domain entity.
  factory ContactModel.fromEntity(ContactEntity entity) {
    final generator = VCardGenerator();
    return ContactModel(
      id: entity.id,
      vcardString: generator.generate(entity.vCard),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isFavorite: entity.isFavorite,
      tags: entity.tags,
    );
  }

  /// Create an empty vCard.
  static VCard _createEmptyVCard() {
    return VCard(version: VCardVersion.v40);
  }

  /// Copy with new values.
  ContactModel copyWith({
    String? id,
    String? vcardString,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return ContactModel(
      id: id ?? this.id,
      vcardString: vcardString ?? this.vcardString,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }
}
