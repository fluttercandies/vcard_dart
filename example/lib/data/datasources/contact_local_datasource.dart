import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact_model.dart';

/// Local data source for contacts using SharedPreferences.
class ContactLocalDataSource {
  ContactLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _contactsKey = 'contacts';

  /// Get all stored contacts.
  List<ContactModel> getAll() {
    final jsonString = _prefs.getString(_contactsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => ContactModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get a contact by ID.
  ContactModel? getById(String id) {
    final contacts = getAll();
    try {
      return contacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Save a contact (creates or updates).
  Future<ContactModel> save(ContactModel contact) async {
    final contacts = getAll();
    final index = contacts.indexWhere((c) => c.id == contact.id);

    final now = DateTime.now();
    final updated = contact.copyWith(
      createdAt: index == -1 ? now : contact.createdAt ?? now,
      updatedAt: now,
    );

    if (index != -1) {
      contacts[index] = updated;
    } else {
      contacts.add(updated);
    }

    await _saveAll(contacts);
    return updated;
  }

  /// Delete a contact by ID.
  Future<void> delete(String id) async {
    final contacts = getAll();
    contacts.removeWhere((c) => c.id == id);
    await _saveAll(contacts);
  }

  /// Save all contacts.
  Future<void> _saveAll(List<ContactModel> contacts) async {
    final jsonList = contacts.map((c) => c.toJson()).toList();
    await _prefs.setString(_contactsKey, jsonEncode(jsonList));
  }

  /// Search contacts by query.
  List<ContactModel> search(String query) {
    if (query.isEmpty) return getAll();

    final lowerQuery = query.toLowerCase();
    return getAll().where((contact) {
      final entity = contact.toEntity();
      return entity.displayName.toLowerCase().contains(lowerQuery) ||
          (entity.primaryEmail?.toLowerCase().contains(lowerQuery) ?? false) ||
          (entity.primaryPhone?.toLowerCase().contains(lowerQuery) ?? false) ||
          (entity.organizationName?.toLowerCase().contains(lowerQuery) ??
              false);
    }).toList();
  }

  /// Get favorite contacts.
  List<ContactModel> getFavorites() {
    return getAll().where((c) => c.isFavorite).toList();
  }

  /// Get recent contacts sorted by update time.
  List<ContactModel> getRecent({int limit = 10}) {
    final contacts = getAll();
    contacts.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
      final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });
    return contacts.take(limit).toList();
  }

  /// Clear all contacts (for testing).
  Future<void> clear() async {
    await _prefs.remove(_contactsKey);
  }
}
