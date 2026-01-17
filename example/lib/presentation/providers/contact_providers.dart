import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:vcard_dart/vcard_dart.dart';

import '../../domain/entities/contact_entity.dart';
import '../../domain/entities/export_format.dart';
import 'core_providers.dart';

/// State for the contacts list.
class ContactsState {
  const ContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  final List<ContactEntity> contacts;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  ContactsState copyWith({
    List<ContactEntity>? contacts,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier for managing contacts.
class ContactsNotifier extends StateNotifier<ContactsState> {
  ContactsNotifier(this.ref) : super(const ContactsState());

  final Ref ref;

  static const _uuid = Uuid();

  /// Load all contacts.
  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(getAllContactsUseCaseProvider);
      final contacts = await useCase();
      state = state.copyWith(contacts: contacts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Search contacts.
  Future<void> searchContacts(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true, error: null);
    try {
      final useCase = ref.read(searchContactsUseCaseProvider);
      final contacts = await useCase(query);
      state = state.copyWith(contacts: contacts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new contact from a VCard.
  Future<ContactEntity> createContact(VCard vcard) async {
    final entity = ContactEntity(
      id: _uuid.v4(),
      vCard: vcard,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final useCase = ref.read(saveContactUseCaseProvider);
    final saved = await useCase(entity);

    state = state.copyWith(contacts: [...state.contacts, saved]);

    return saved;
  }

  /// Update an existing contact.
  Future<ContactEntity> updateContact(ContactEntity contact) async {
    final useCase = ref.read(saveContactUseCaseProvider);
    final updated = contact.copyWith(updatedAt: DateTime.now());
    final saved = await useCase(updated);

    final contacts = state.contacts.map((c) {
      return c.id == saved.id ? saved : c;
    }).toList();

    state = state.copyWith(contacts: contacts);
    return saved;
  }

  /// Delete a contact.
  Future<void> deleteContact(String id) async {
    final useCase = ref.read(deleteContactUseCaseProvider);
    await useCase(id);

    final contacts = state.contacts.where((c) => c.id != id).toList();
    state = state.copyWith(contacts: contacts);
  }

  /// Toggle favorite status.
  Future<void> toggleFavorite(String id) async {
    final useCase = ref.read(toggleFavoriteUseCaseProvider);
    final updated = await useCase(id);

    final contacts = state.contacts.map((c) {
      return c.id == updated.id ? updated : c;
    }).toList();

    state = state.copyWith(contacts: contacts);
  }

  /// Import vCards from string.
  Future<List<ContactEntity>> importVCards(String vcardData) async {
    final useCase = ref.read(importVCardsUseCaseProvider);
    final imported = await useCase(vcardData);

    state = state.copyWith(contacts: [...state.contacts, ...imported]);

    return imported;
  }
}

/// Provider for contacts state.
final contactsProvider = StateNotifierProvider<ContactsNotifier, ContactsState>(
  (ref) {
    return ContactsNotifier(ref);
  },
);

/// Provider for recent contacts.
final recentContactsProvider = FutureProvider<List<ContactEntity>>((ref) async {
  final useCase = ref.read(getRecentContactsUseCaseProvider);
  return useCase(limit: 10);
});

/// Provider for favorite contacts.
final favoriteContactsProvider = FutureProvider<List<ContactEntity>>((
  ref,
) async {
  final useCase = ref.read(getFavoriteContactsUseCaseProvider);
  return useCase();
});

/// Provider for a single contact by ID.
final contactByIdProvider = FutureProvider.family<ContactEntity?, String>((
  ref,
  id,
) async {
  final useCase = ref.read(getContactByIdUseCaseProvider);
  return useCase(id);
});

/// Provider for exporting a contact.
final exportContactProvider =
    FutureProvider.family<
      String,
      ({ContactEntity contact, ExportFormat format})
    >((ref, params) async {
      final useCase = ref.read(exportContactUseCaseProvider);
      return useCase(params.contact, params.format);
    });
