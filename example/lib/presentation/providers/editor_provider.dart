import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcard_dart/vcard_dart.dart';

import '../../core/config/app_config.dart';
import '../../domain/entities/contact_entity.dart';

/// State for the vCard editor.
class EditorState {
  EditorState({
    this.contactId,
    VCardVersion? version,
    this.formattedName = '',
    this.givenName = '',
    this.familyName = '',
    this.middleName = '',
    this.prefix = '',
    this.suffix = '',
    this.nickname = '',
    this.emails = const [],
    this.phones = const [],
    this.addresses = const [],
    this.organization = '',
    this.title = '',
    this.role = '',
    this.department = '',
    this.urls = const [],
    this.note = '',
    this.birthday,
    this.anniversary,
    this.gender,
    this.photoUri,
    this.isDirty = false,
    this.isSaving = false,
    this.error,
  }) : version = version ?? AppConfig.defaultVCardVersion;

  /// ID of the contact being edited (null for new contacts).
  final String? contactId;

  /// vCard version.
  final VCardVersion version;

  /// Formatted name (FN property).
  final String formattedName;

  /// Given (first) name.
  final String givenName;

  /// Family (last) name.
  final String familyName;

  /// Middle name.
  final String middleName;

  /// Name prefix (e.g., Mr., Dr.).
  final String prefix;

  /// Name suffix (e.g., Jr., III).
  final String suffix;

  /// Nickname.
  final String nickname;

  /// Email addresses with types.
  final List<EmailEntry> emails;

  /// Phone numbers with types.
  final List<PhoneEntry> phones;

  /// Addresses.
  final List<AddressEntry> addresses;

  /// Organization name.
  final String organization;

  /// Job title.
  final String title;

  /// Role.
  final String role;

  /// Department.
  final String department;

  /// URLs/websites.
  final List<UrlEntry> urls;

  /// Note/comments.
  final String note;

  /// Birthday.
  final DateTime? birthday;

  /// Anniversary.
  final DateTime? anniversary;

  /// Gender.
  final Gender? gender;

  /// Photo URI (data URI or URL).
  final String? photoUri;

  /// Whether the form has unsaved changes.
  final bool isDirty;

  /// Whether save is in progress.
  final bool isSaving;

  /// Error message if any.
  final String? error;

  /// Whether this is a new contact.
  bool get isNew => contactId == null;

  /// Get the computed formatted name.
  String get computedFormattedName {
    if (formattedName.isNotEmpty) return formattedName;

    final parts = <String>[];
    if (prefix.isNotEmpty) parts.add(prefix);
    if (givenName.isNotEmpty) parts.add(givenName);
    if (middleName.isNotEmpty) parts.add(middleName);
    if (familyName.isNotEmpty) parts.add(familyName);
    if (suffix.isNotEmpty) parts.add(suffix);

    return parts.join(' ');
  }

  EditorState copyWith({
    String? contactId,
    VCardVersion? version,
    String? formattedName,
    String? givenName,
    String? familyName,
    String? middleName,
    String? prefix,
    String? suffix,
    String? nickname,
    List<EmailEntry>? emails,
    List<PhoneEntry>? phones,
    List<AddressEntry>? addresses,
    String? organization,
    String? title,
    String? role,
    String? department,
    List<UrlEntry>? urls,
    String? note,
    DateTime? birthday,
    DateTime? anniversary,
    Gender? gender,
    String? photoUri,
    bool? isDirty,
    bool? isSaving,
    String? error,
  }) {
    return EditorState(
      contactId: contactId ?? this.contactId,
      version: version ?? this.version,
      formattedName: formattedName ?? this.formattedName,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      middleName: middleName ?? this.middleName,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      nickname: nickname ?? this.nickname,
      emails: emails ?? this.emails,
      phones: phones ?? this.phones,
      addresses: addresses ?? this.addresses,
      organization: organization ?? this.organization,
      title: title ?? this.title,
      role: role ?? this.role,
      department: department ?? this.department,
      urls: urls ?? this.urls,
      note: note ?? this.note,
      birthday: birthday ?? this.birthday,
      anniversary: anniversary ?? this.anniversary,
      gender: gender ?? this.gender,
      photoUri: photoUri ?? this.photoUri,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  /// Build a VCard from the current state.
  VCard buildVCard() {
    // Build structured name
    StructuredName? structuredName;
    if (givenName.isNotEmpty ||
        familyName.isNotEmpty ||
        middleName.isNotEmpty ||
        prefix.isNotEmpty ||
        suffix.isNotEmpty) {
      structuredName = StructuredName(
        given: givenName,
        family: familyName,
        additional: middleName.isNotEmpty ? [middleName] : const [],
        prefixes: prefix.isNotEmpty ? [prefix] : const [],
        suffixes: suffix.isNotEmpty ? [suffix] : const [],
      );
    }

    // Build emails list
    final emailList = emails
        .where((e) => e.value.isNotEmpty)
        .map(
          (e) => Email(
            address: e.value,
            types: e.types,
            pref: e.isPref ? 1 : null,
          ),
        )
        .toList();

    // Build phones list
    final phoneList = phones
        .where((p) => p.value.isNotEmpty)
        .map(
          (p) => Telephone(
            number: p.value,
            types: p.types,
            pref: p.isPref ? 1 : null,
          ),
        )
        .toList();

    // Build addresses list
    final addressList = addresses
        .where((a) => a.hasValue)
        .map(
          (a) => Address(
            street: a.street,
            city: a.city,
            region: a.state,
            postalCode: a.postalCode,
            country: a.country,
            types: a.types,
            pref: a.isPref ? 1 : null,
          ),
        )
        .toList();

    // Build URLs list
    final urlList = urls
        .where((u) => u.value.isNotEmpty)
        .map((u) => WebUrl(url: u.value, types: u.types))
        .toList();

    // Build organization
    Organization? org;
    if (organization.isNotEmpty) {
      org = Organization(
        name: organization,
        units: department.isNotEmpty ? [department] : const [],
      );
    }

    // Build nicknames list
    final nicknameList = nickname.isNotEmpty ? [nickname] : <String>[];

    return VCard(
      version: version,
      formattedName: computedFormattedName,
      name: structuredName,
      nicknames: nicknameList,
      emails: emailList,
      telephones: phoneList,
      addresses: addressList,
      urls: urlList,
      organization: org,
      title: title.isNotEmpty ? title : null,
      role: role.isNotEmpty ? role : null,
      note: note.isNotEmpty ? note : null,
      birthday: birthday != null
          ? DateOrDateTime.fromDateTime(birthday!)
          : null,
      anniversary: anniversary != null
          ? DateOrDateTime.fromDateTime(anniversary!)
          : null,
      gender: gender,
    );
  }

  /// Create state from an existing contact entity.
  factory EditorState.fromContact(ContactEntity contact) {
    final vcard = contact.vCard;

    // Extract name components
    var givenName = '';
    var familyName = '';
    var middleName = '';
    var prefix = '';
    var suffix = '';

    final name = vcard.name;
    if (name != null) {
      givenName = name.given;
      familyName = name.family;
      middleName = name.additional.isNotEmpty ? name.additional.first : '';
      prefix = name.prefixes.isNotEmpty ? name.prefixes.first : '';
      suffix = name.suffixes.isNotEmpty ? name.suffixes.first : '';
    }

    // Extract emails
    final emails = vcard.emails.map((e) {
      return EmailEntry(
        value: e.address,
        types: e.types.toList(),
        isPref: e.isPreferred,
      );
    }).toList();

    // Extract phones
    final phones = vcard.telephones.map((t) {
      return PhoneEntry(
        value: t.number,
        types: t.types.toList(),
        isPref: t.isPreferred,
      );
    }).toList();

    // Extract addresses
    final addresses = vcard.addresses.map((a) {
      return AddressEntry(
        street: a.street,
        city: a.city,
        state: a.region,
        postalCode: a.postalCode,
        country: a.country,
        types: a.types.toList(),
        isPref: a.isPreferred,
      );
    }).toList();

    // Extract URLs
    final urls = vcard.urls.map((u) {
      return UrlEntry(value: u.url, types: u.types.toList());
    }).toList();

    // Extract organization
    var organization = '';
    var department = '';
    final org = vcard.organization;
    if (org != null) {
      organization = org.name;
      if (org.units.isNotEmpty) {
        department = org.units.first;
      }
    }

    return EditorState(
      contactId: contact.id,
      version: vcard.version,
      formattedName: vcard.formattedName,
      givenName: givenName,
      familyName: familyName,
      middleName: middleName,
      prefix: prefix,
      suffix: suffix,
      nickname: vcard.nicknames.isNotEmpty ? vcard.nicknames.first : '',
      emails: emails.isEmpty ? [EmailEntry()] : emails,
      phones: phones.isEmpty ? [PhoneEntry()] : phones,
      addresses: addresses.isEmpty ? [AddressEntry()] : addresses,
      organization: organization,
      title: vcard.title ?? '',
      role: vcard.role ?? '',
      department: department,
      urls: urls.isEmpty ? [UrlEntry()] : urls,
      note: vcard.note ?? '',
      birthday: vcard.birthday?.toDateTime(),
      anniversary: vcard.anniversary?.toDateTime(),
      gender: vcard.gender,
    );
  }
}

/// Entry for an email address.
class EmailEntry {
  EmailEntry({
    this.value = '',
    this.types = const ['home'],
    this.isPref = false,
  });

  final String value;
  final List<String> types;
  final bool isPref;

  EmailEntry copyWith({String? value, List<String>? types, bool? isPref}) {
    return EmailEntry(
      value: value ?? this.value,
      types: types ?? this.types,
      isPref: isPref ?? this.isPref,
    );
  }
}

/// Entry for a phone number.
class PhoneEntry {
  PhoneEntry({
    this.value = '',
    this.types = const ['cell'],
    this.isPref = false,
  });

  final String value;
  final List<String> types;
  final bool isPref;

  PhoneEntry copyWith({String? value, List<String>? types, bool? isPref}) {
    return PhoneEntry(
      value: value ?? this.value,
      types: types ?? this.types,
      isPref: isPref ?? this.isPref,
    );
  }
}

/// Entry for an address.
class AddressEntry {
  AddressEntry({
    this.street = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.country = '',
    this.types = const ['home'],
    this.isPref = false,
  });

  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final List<String> types;
  final bool isPref;

  bool get hasValue =>
      street.isNotEmpty ||
      city.isNotEmpty ||
      state.isNotEmpty ||
      postalCode.isNotEmpty ||
      country.isNotEmpty;

  AddressEntry copyWith({
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    List<String>? types,
    bool? isPref,
  }) {
    return AddressEntry(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      types: types ?? this.types,
      isPref: isPref ?? this.isPref,
    );
  }
}

/// Entry for a URL.
class UrlEntry {
  UrlEntry({this.value = '', this.types = const ['home']});

  final String value;
  final List<String> types;

  UrlEntry copyWith({String? value, List<String>? types}) {
    return UrlEntry(value: value ?? this.value, types: types ?? this.types);
  }
}

/// Notifier for the vCard editor.
class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier()
    : super(
        EditorState(
          emails: [EmailEntry()],
          phones: [PhoneEntry()],
          addresses: [AddressEntry()],
          urls: [UrlEntry()],
        ),
      );

  /// Initialize for a new contact.
  void initNew() {
    state = EditorState(
      emails: [EmailEntry()],
      phones: [PhoneEntry()],
      addresses: [AddressEntry()],
      urls: [UrlEntry()],
    );
  }

  /// Initialize from an existing contact.
  void initFromContact(ContactEntity contact) {
    state = EditorState.fromContact(contact);
  }

  /// Reset the editor.
  void reset() {
    state = EditorState(
      emails: [EmailEntry()],
      phones: [PhoneEntry()],
      addresses: [AddressEntry()],
      urls: [UrlEntry()],
    );
  }

  // Field setters
  void setVersion(VCardVersion version) {
    state = state.copyWith(version: version, isDirty: true);
  }

  void setFormattedName(String value) {
    state = state.copyWith(formattedName: value, isDirty: true);
  }

  void setGivenName(String value) {
    state = state.copyWith(givenName: value, isDirty: true);
  }

  void setFamilyName(String value) {
    state = state.copyWith(familyName: value, isDirty: true);
  }

  void setMiddleName(String value) {
    state = state.copyWith(middleName: value, isDirty: true);
  }

  void setPrefix(String value) {
    state = state.copyWith(prefix: value, isDirty: true);
  }

  void setSuffix(String value) {
    state = state.copyWith(suffix: value, isDirty: true);
  }

  void setNickname(String value) {
    state = state.copyWith(nickname: value, isDirty: true);
  }

  void setOrganization(String value) {
    state = state.copyWith(organization: value, isDirty: true);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value, isDirty: true);
  }

  void setRole(String value) {
    state = state.copyWith(role: value, isDirty: true);
  }

  void setDepartment(String value) {
    state = state.copyWith(department: value, isDirty: true);
  }

  void setNote(String value) {
    state = state.copyWith(note: value, isDirty: true);
  }

  void setBirthday(DateTime? value) {
    state = state.copyWith(birthday: value, isDirty: true);
  }

  void setAnniversary(DateTime? value) {
    state = state.copyWith(anniversary: value, isDirty: true);
  }

  void setGender(Gender? value) {
    state = state.copyWith(gender: value, isDirty: true);
  }

  // Email methods
  void addEmail() {
    state = state.copyWith(
      emails: [...state.emails, EmailEntry()],
      isDirty: true,
    );
  }

  void updateEmail(int index, EmailEntry email) {
    final emails = [...state.emails];
    emails[index] = email;
    state = state.copyWith(emails: emails, isDirty: true);
  }

  void removeEmail(int index) {
    if (state.emails.length > 1) {
      final emails = [...state.emails];
      emails.removeAt(index);
      state = state.copyWith(emails: emails, isDirty: true);
    }
  }

  // Phone methods
  void addPhone() {
    state = state.copyWith(
      phones: [...state.phones, PhoneEntry()],
      isDirty: true,
    );
  }

  void updatePhone(int index, PhoneEntry phone) {
    final phones = [...state.phones];
    phones[index] = phone;
    state = state.copyWith(phones: phones, isDirty: true);
  }

  void removePhone(int index) {
    if (state.phones.length > 1) {
      final phones = [...state.phones];
      phones.removeAt(index);
      state = state.copyWith(phones: phones, isDirty: true);
    }
  }

  // Address methods
  void addAddress() {
    state = state.copyWith(
      addresses: [...state.addresses, AddressEntry()],
      isDirty: true,
    );
  }

  void updateAddress(int index, AddressEntry address) {
    final addresses = [...state.addresses];
    addresses[index] = address;
    state = state.copyWith(addresses: addresses, isDirty: true);
  }

  void removeAddress(int index) {
    if (state.addresses.length > 1) {
      final addresses = [...state.addresses];
      addresses.removeAt(index);
      state = state.copyWith(addresses: addresses, isDirty: true);
    }
  }

  // URL methods
  void addUrl() {
    state = state.copyWith(urls: [...state.urls, UrlEntry()], isDirty: true);
  }

  void updateUrl(int index, UrlEntry url) {
    final urls = [...state.urls];
    urls[index] = url;
    state = state.copyWith(urls: urls, isDirty: true);
  }

  void removeUrl(int index) {
    if (state.urls.length > 1) {
      final urls = [...state.urls];
      urls.removeAt(index);
      state = state.copyWith(urls: urls, isDirty: true);
    }
  }

  /// Mark as saving.
  void setSaving(bool isSaving) {
    state = state.copyWith(isSaving: isSaving);
  }

  /// Set error.
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clear dirty flag after save.
  void clearDirty() {
    state = state.copyWith(isDirty: false);
  }
}

/// Provider for the editor state.
final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((
  ref,
) {
  return EditorNotifier();
});
