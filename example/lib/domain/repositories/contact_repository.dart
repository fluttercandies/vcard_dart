import 'package:vcard_dart/vcard_dart.dart';

import '../entities/contact_entity.dart';
import '../entities/export_format.dart';

/// Abstract repository interface for contact operations.
/// This defines the contract that data layer implementations must fulfill.
abstract class ContactRepository {
  /// Get all contacts.
  Future<List<ContactEntity>> getAllContacts();

  /// Get a contact by ID.
  Future<ContactEntity?> getContactById(String id);

  /// Save a contact (creates or updates).
  Future<ContactEntity> saveContact(ContactEntity contact);

  /// Delete a contact by ID.
  Future<void> deleteContact(String id);

  /// Search contacts by query.
  Future<List<ContactEntity>> searchContacts(String query);

  /// Get favorite contacts.
  Future<List<ContactEntity>> getFavoriteContacts();

  /// Toggle favorite status for a contact.
  Future<ContactEntity> toggleFavorite(String id);

  /// Import vCard data and create contacts.
  Future<List<ContactEntity>> importVCards(String vcardData);

  /// Export a contact to a specific format.
  Future<String> exportContact(ContactEntity contact, ExportFormat format);

  /// Export multiple contacts to vCard format.
  Future<String> exportContacts(
    List<ContactEntity> contacts,
    ExportFormat format,
  );

  /// Parse vCard string and return VCard objects.
  Future<List<VCard>> parseVCards(String vcardData);

  /// Get recently updated contacts.
  Future<List<ContactEntity>> getRecentContacts({int limit = 10});
}
