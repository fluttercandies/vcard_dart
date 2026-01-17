import 'package:vcard_dart/vcard_dart.dart';

import '../entities/contact_entity.dart';
import '../entities/export_format.dart';
import '../repositories/contact_repository.dart';

/// Use case for importing vCards.
class ImportVCardsUseCase {
  const ImportVCardsUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<List<ContactEntity>> call(String vcardData) {
    return _repository.importVCards(vcardData);
  }
}

/// Use case for exporting a single contact.
class ExportContactUseCase {
  const ExportContactUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<String> call(ContactEntity contact, ExportFormat format) {
    return _repository.exportContact(contact, format);
  }
}

/// Use case for exporting multiple contacts.
class ExportContactsUseCase {
  const ExportContactsUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<String> call(List<ContactEntity> contacts, ExportFormat format) {
    return _repository.exportContacts(contacts, format);
  }
}

/// Use case for parsing vCard data without saving.
class ParseVCardsUseCase {
  const ParseVCardsUseCase(this._repository);

  final ContactRepository _repository;

  /// Execute the use case.
  Future<List<VCard>> call(String vcardData) {
    return _repository.parseVCards(vcardData);
  }
}
