import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/contact_local_datasource.dart';
import '../../data/repositories/contact_repository_impl.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../domain/usecases/usecases.dart';

/// Provider for SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for local data source.
final contactLocalDataSourceProvider = Provider<ContactLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ContactLocalDataSource(prefs);
});

/// Provider for contact repository.
final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final localDataSource = ref.watch(contactLocalDataSourceProvider);
  return ContactRepositoryImpl(localDataSource);
});

/// Provider for GetAllContactsUseCase.
final getAllContactsUseCaseProvider = Provider<GetAllContactsUseCase>((ref) {
  return GetAllContactsUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for GetContactByIdUseCase.
final getContactByIdUseCaseProvider = Provider<GetContactByIdUseCase>((ref) {
  return GetContactByIdUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for SaveContactUseCase.
final saveContactUseCaseProvider = Provider<SaveContactUseCase>((ref) {
  return SaveContactUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for DeleteContactUseCase.
final deleteContactUseCaseProvider = Provider<DeleteContactUseCase>((ref) {
  return DeleteContactUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for SearchContactsUseCase.
final searchContactsUseCaseProvider = Provider<SearchContactsUseCase>((ref) {
  return SearchContactsUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for GetFavoriteContactsUseCase.
final getFavoriteContactsUseCaseProvider = Provider<GetFavoriteContactsUseCase>(
  (ref) {
    return GetFavoriteContactsUseCase(ref.watch(contactRepositoryProvider));
  },
);

/// Provider for ToggleFavoriteUseCase.
final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for GetRecentContactsUseCase.
final getRecentContactsUseCaseProvider = Provider<GetRecentContactsUseCase>((
  ref,
) {
  return GetRecentContactsUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for ImportVCardsUseCase.
final importVCardsUseCaseProvider = Provider<ImportVCardsUseCase>((ref) {
  return ImportVCardsUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for ExportContactUseCase.
final exportContactUseCaseProvider = Provider<ExportContactUseCase>((ref) {
  return ExportContactUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for ExportContactsUseCase.
final exportContactsUseCaseProvider = Provider<ExportContactsUseCase>((ref) {
  return ExportContactsUseCase(ref.watch(contactRepositoryProvider));
});

/// Provider for ParseVCardsUseCase.
final parseVCardsUseCaseProvider = Provider<ParseVCardsUseCase>((ref) {
  return ParseVCardsUseCase(ref.watch(contactRepositoryProvider));
});
