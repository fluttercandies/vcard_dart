import 'package:uuid/uuid.dart';
import 'package:vcard_dart/vcard_dart.dart';

import '../../domain/entities/contact_entity.dart';
import '../../domain/entities/export_format.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_local_datasource.dart';
import '../models/contact_model.dart';

/// Implementation of ContactRepository using local storage.
class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl(this._localDataSource);

  final ContactLocalDataSource _localDataSource;

  static const _uuid = Uuid();
  final _parser = VCardParser();
  final _generator = VCardGenerator();
  final _jcardFormatter = JCardFormatter();
  final _xcardFormatter = XCardFormatter();

  @override
  Future<List<ContactEntity>> getAllContacts() async {
    final models = _localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ContactEntity?> getContactById(String id) async {
    final model = _localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<ContactEntity> saveContact(ContactEntity contact) async {
    final model = ContactModel.fromEntity(contact);
    final saved = await _localDataSource.save(model);
    return saved.toEntity();
  }

  @override
  Future<void> deleteContact(String id) async {
    await _localDataSource.delete(id);
  }

  @override
  Future<List<ContactEntity>> searchContacts(String query) async {
    final models = _localDataSource.search(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ContactEntity>> getFavoriteContacts() async {
    final models = _localDataSource.getFavorites();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ContactEntity> toggleFavorite(String id) async {
    final model = _localDataSource.getById(id);
    if (model == null) {
      throw Exception('Contact not found: $id');
    }

    final updated = model.copyWith(isFavorite: !model.isFavorite);
    final saved = await _localDataSource.save(updated);
    return saved.toEntity();
  }

  @override
  Future<List<ContactEntity>> importVCards(String vcardData) async {
    final vcards = _parser.parse(vcardData);
    final entities = <ContactEntity>[];

    for (final vcard in vcards) {
      final entity = ContactEntity(
        id: _uuid.v4(),
        vCard: vcard,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final model = ContactModel.fromEntity(entity);
      final saved = await _localDataSource.save(model);
      entities.add(saved.toEntity());
    }

    return entities;
  }

  @override
  Future<String> exportContact(
    ContactEntity contact,
    ExportFormat format,
  ) async {
    return _formatVCard(contact.vCard, format);
  }

  @override
  Future<String> exportContacts(
    List<ContactEntity> contacts,
    ExportFormat format,
  ) async {
    if (format == ExportFormat.vcard) {
      // For vCard format, concatenate all cards
      final buffer = StringBuffer();
      for (final contact in contacts) {
        buffer.writeln(_generator.generate(contact.vCard));
      }
      return buffer.toString();
    } else if (format == ExportFormat.jcard) {
      // For jCard, create an array of jCards
      final jcards = contacts
          .map((c) => _jcardFormatter.toJsonString(c.vCard))
          .toList();
      return '[\n${jcards.join(',\n')}\n]';
    } else {
      // For xCard, wrap in a vcards element
      final buffer = StringBuffer();
      buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
      buffer.writeln('<vcards xmlns="urn:ietf:params:xml:ns:vcard-4.0">');
      for (final contact in contacts) {
        buffer.writeln(_xcardFormatter.toXml(contact.vCard));
      }
      buffer.writeln('</vcards>');
      return buffer.toString();
    }
  }

  @override
  Future<List<VCard>> parseVCards(String vcardData) async {
    return _parser.parse(vcardData);
  }

  @override
  Future<List<ContactEntity>> getRecentContacts({int limit = 10}) async {
    final models = _localDataSource.getRecent(limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  String _formatVCard(VCard vcard, ExportFormat format) {
    switch (format) {
      case ExportFormat.vcard:
        return _generator.generate(vcard);
      case ExportFormat.jcard:
        return _jcardFormatter.toJsonString(vcard);
      case ExportFormat.xcard:
        return _xcardFormatter.toXml(vcard);
    }
  }
}
