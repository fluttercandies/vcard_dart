import '../entities/contact_entity.dart';
import '../repositories/contact_repository.dart';

/// Use case for getting all contacts.
class GetAllContactsUseCase {
  const GetAllContactsUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<List<ContactEntity>> call() {
    return _repository.getAllContacts();
  }
}

/// Use case for getting a contact by ID.
class GetContactByIdUseCase {
  const GetContactByIdUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<ContactEntity?> call(String id) {
    return _repository.getContactById(id);
  }
}

/// Use case for saving a contact.
class SaveContactUseCase {
  const SaveContactUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<ContactEntity> call(ContactEntity contact) {
    return _repository.saveContact(contact);
  }
}

/// Use case for deleting a contact.
class DeleteContactUseCase {
  const DeleteContactUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<void> call(String id) {
    return _repository.deleteContact(id);
  }
}

/// Use case for searching contacts.
class SearchContactsUseCase {
  const SearchContactsUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<List<ContactEntity>> call(String query) {
    return _repository.searchContacts(query);
  }
}

/// Use case for getting favorite contacts.
class GetFavoriteContactsUseCase {
  const GetFavoriteContactsUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<List<ContactEntity>> call() {
    return _repository.getFavoriteContacts();
  }
}

/// Use case for toggling favorite status.
class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<ContactEntity> call(String id) {
    return _repository.toggleFavorite(id);
  }
}

/// Use case for getting recent contacts.
class GetRecentContactsUseCase {
  const GetRecentContactsUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<List<ContactEntity>> call({int limit = 10}) {
    return _repository.getRecentContacts(limit: limit);
  }
}
