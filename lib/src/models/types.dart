/// Represents gender information (GENDER property, vCard 4.0).
///
/// ## Example
///
/// ```dart
/// // Create gender values
/// final male = Gender.male();
/// final female = Gender.female();
/// final custom = Gender(sex: 'O', identity: 'Non-binary');
/// final unknown = Gender.unknown();
///
/// // Parse from vCard format
/// final parsed = Gender.parse('M;Transgender');
///
/// // Check gender type
/// if (male.isMale) {
///   print('This represents male');
/// }
///
/// // Convert to vCard format
/// final value = custom.toValue();  // 'O;Non-binary'
/// ```
class Gender {
  /// Sex component (single letter).
  ///
  /// Standard values:
  /// - 'M' = male
  /// - 'F' = female
  /// - 'O' = other
  /// - 'N' = none/not applicable
  /// - 'U' = unknown
  final String? sex;

  /// Gender identity (free-form text).
  final String? identity;

  /// Creates a new gender value.
  const Gender({this.sex, this.identity});

  /// Creates a male gender.
  const Gender.male() : sex = 'M', identity = null;

  /// Creates a female gender.
  const Gender.female() : sex = 'F', identity = null;

  /// Creates an other gender.
  const Gender.other([this.identity]) : sex = 'O';

  /// Creates a not applicable gender.
  const Gender.notApplicable() : sex = 'N', identity = null;

  /// Creates an unknown gender.
  const Gender.unknown() : sex = 'U', identity = null;

  /// Parses a gender value from vCard format.
  factory Gender.parse(String value) {
    if (value.isEmpty) {
      return const Gender();
    }
    final parts = value.split(';');
    return Gender(
      sex: parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : null,
      identity: parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null,
    );
  }

  /// Whether this represents male.
  bool get isMale => sex == 'M';

  /// Whether this represents female.
  bool get isFemale => sex == 'F';

  /// Whether this represents other.
  bool get isOther => sex == 'O';

  /// Whether this is not applicable.
  bool get isNotApplicable => sex == 'N';

  /// Whether this is unknown.
  bool get isUnknown => sex == 'U';

  /// Whether the sex component is empty.
  bool get isEmpty => sex == null && identity == null;

  /// Whether the sex component is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Converts to vCard format.
  String toValue() {
    if (sex == null && identity == null) return '';
    if (identity == null) return sex ?? '';
    return '${sex ?? ''};$identity';
  }

  /// Creates a copy with optional modifications.
  Gender copyWith({String? sex, String? identity}) {
    return Gender(sex: sex ?? this.sex, identity: identity ?? this.identity);
  }

  @override
  String toString() {
    if (identity != null) return '$sex ($identity)';
    return sex ?? '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Gender) return false;
    return sex == other.sex && identity == other.identity;
  }

  @override
  int get hashCode => Object.hash(sex, identity);
}

/// Represents kind of entity (KIND property, vCard 4.0).
///
/// ## Example
///
/// ```dart
/// // Create kind values
/// final individual = VCardKind.individual;
/// final group = VCardKind.group;
/// final org = VCardKind.organization;
///
/// // Parse from string
/// final parsed = VCardKind.tryParse('individual');
/// final fromOrg = VCardKind.tryParse('org');
///
/// // Get value string
/// print(individual.value);  // 'individual'
/// print(org.value);         // 'org'
/// ```
enum VCardKind {
  /// An individual person.
  individual,

  /// A group of people.
  group,

  /// An organization.
  organization,

  /// A location.
  location;

  /// Parses a kind value from string.
  static VCardKind? tryParse(String value) {
    switch (value.toLowerCase()) {
      case 'individual':
        return VCardKind.individual;
      case 'group':
        return VCardKind.group;
      case 'org':
      case 'organization':
        return VCardKind.organization;
      case 'location':
        return VCardKind.location;
      default:
        return null;
    }
  }

  /// Returns the vCard value string.
  String get value {
    switch (this) {
      case VCardKind.individual:
        return 'individual';
      case VCardKind.group:
        return 'group';
      case VCardKind.organization:
        return 'org';
      case VCardKind.location:
        return 'location';
    }
  }

  @override
  String toString() => value;
}

/// Represents a language preference (LANG property, vCard 4.0).
///
/// ## Example
///
/// ```dart
/// // Create language preferences
/// final english = LanguagePref(tag: 'en');
/// final chinese = LanguagePref(tag: 'zh-CN');
/// final workLang = LanguagePref.work('en-US');
/// final homeLang = LanguagePref.home('es', pref: 1);
///
/// // Check language type
/// if (workLang.isWork) {
///   print('This is a work language');
/// }
///
/// // Check if preferred
/// if (homeLang.isPreferred) {
///   print('This is the preferred language');
/// }
/// ```
class LanguagePref {
  /// The language tag (e.g., "en", "zh-CN").
  final String tag;

  /// Language types (e.g., "work", "home").
  final List<String> types;

  /// Preference order (1-100).
  final int? pref;

  /// Creates a new language preference.
  const LanguagePref({required this.tag, this.types = const [], this.pref});

  /// Creates a work language preference.
  factory LanguagePref.work(String tag, {int? pref}) {
    return LanguagePref(tag: tag, types: const ['work'], pref: pref);
  }

  /// Creates a home language preference.
  factory LanguagePref.home(String tag, {int? pref}) {
    return LanguagePref(tag: tag, types: const ['home'], pref: pref);
  }

  /// Whether this is a work language.
  bool get isWork => types.any((t) => t.toLowerCase() == 'work');

  /// Whether this is a home language.
  bool get isHome => types.any((t) => t.toLowerCase() == 'home');

  /// Whether this is the preferred language.
  bool get isPreferred =>
      (pref != null && pref! <= 1) ||
      types.any((t) => t.toLowerCase() == 'pref');

  /// Creates a copy with optional modifications.
  LanguagePref copyWith({String? tag, List<String>? types, int? pref}) {
    return LanguagePref(
      tag: tag ?? this.tag,
      types: types ?? this.types,
      pref: pref ?? this.pref,
    );
  }

  @override
  String toString() => tag;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LanguagePref) return false;
    return tag.toLowerCase() == other.tag.toLowerCase();
  }

  @override
  int get hashCode => tag.toLowerCase().hashCode;
}

/// Represents calendar-related properties (RFC 2739).
///
/// ## Example
///
/// ```dart
/// // Create calendar information
/// final calendar = CalendarInfo(
///   freeBusyUrl: 'https://example.com/freebusy.ifb',
///   calendarUrl: 'https://example.com/calendar.ics',
///   calendarAddressUrl: 'mailto:calendar@example.com',
/// );
///
/// // Check if empty
/// if (calendar.isNotEmpty) {
///   print('Has calendar information');
/// }
/// ```
class CalendarInfo {
  /// Free/busy URL (FBURL property).
  final String? freeBusyUrl;

  /// Calendar URL (CALURI property).
  final String? calendarUrl;

  /// Calendar address URL (CALADRURI property).
  final String? calendarAddressUrl;

  /// Creates calendar information.
  const CalendarInfo({
    this.freeBusyUrl,
    this.calendarUrl,
    this.calendarAddressUrl,
  });

  /// Whether all fields are empty.
  bool get isEmpty =>
      freeBusyUrl == null && calendarUrl == null && calendarAddressUrl == null;

  /// Whether any field is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Creates a copy with optional modifications.
  CalendarInfo copyWith({
    String? freeBusyUrl,
    String? calendarUrl,
    String? calendarAddressUrl,
  }) {
    return CalendarInfo(
      freeBusyUrl: freeBusyUrl ?? this.freeBusyUrl,
      calendarUrl: calendarUrl ?? this.calendarUrl,
      calendarAddressUrl: calendarAddressUrl ?? this.calendarAddressUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CalendarInfo) return false;
    return freeBusyUrl == other.freeBusyUrl &&
        calendarUrl == other.calendarUrl &&
        calendarAddressUrl == other.calendarAddressUrl;
  }

  @override
  int get hashCode => Object.hash(freeBusyUrl, calendarUrl, calendarAddressUrl);
}

/// Represents a date or date-time value.
///
/// Supports various formats including partial dates.
///
/// ## Example
///
/// ```dart
/// // Create dates
/// final birthday = DateOrDateTime.date(1990, 5, 15);
/// final meeting = DateOrDateTime.dateTime(2023, 12, 25, 14, 30);
/// final fromDt = DateOrDateTime.fromDateTime(DateTime.now());
///
/// // Parse from vCard format
/// final parsed = DateOrDateTime.parse('19850412T232000');
/// final partial = DateOrDateTime.parse('--0412');  // April 12
///
/// // Check type
/// if (birthday.isDateOnly) {
///   print('This is a date only');
/// }
///
/// // Convert to vCard format
/// final bdayStr = birthday.toDateString();  // '19900515'
/// final fullStr = meeting.toDateTimeString();  // '20231225T143000'
/// ```
class DateOrDateTime {
  /// The year (may be null for anniversary without year).
  final int? year;

  /// The month (1-12).
  final int? month;

  /// The day (1-31).
  final int? day;

  /// The hour (0-23).
  final int? hour;

  /// The minute (0-59).
  final int? minute;

  /// The second (0-59).
  final int? second;

  /// The timezone offset in minutes from UTC.
  final int? timezoneOffset;

  /// Creates a date-time value.
  const DateOrDateTime({
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.second,
    this.timezoneOffset,
  });

  /// Creates a date-only value.
  const DateOrDateTime.date(this.year, this.month, this.day)
    : hour = null,
      minute = null,
      second = null,
      timezoneOffset = null;

  /// Creates a date-time value without timezone.
  const DateOrDateTime.dateTime(
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute, [
    this.second,
  ]) : timezoneOffset = null;

  /// Creates from a Dart DateTime object.
  factory DateOrDateTime.fromDateTime(DateTime dt, {bool utc = false}) {
    return DateOrDateTime(
      year: dt.year,
      month: dt.month,
      day: dt.day,
      hour: dt.hour,
      minute: dt.minute,
      second: dt.second,
      timezoneOffset: utc ? 0 : null,
    );
  }

  /// Parses a vCard date/date-time value.
  factory DateOrDateTime.parse(String value) {
    // Handle various formats:
    // Date: 19850412, 1985-04-12, --0412, ---12
    // DateTime: 19850412T232000, 19850412T232000Z, 19850412T232000+0100

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const DateOrDateTime();
    }

    // Check for time component
    final tIndex = trimmed.indexOf('T');
    final dateStr = tIndex >= 0 ? trimmed.substring(0, tIndex) : trimmed;
    final timeStr = tIndex >= 0 ? trimmed.substring(tIndex + 1) : null;

    int? year;
    int? month;
    int? day;
    int? hour;
    int? minute;
    int? second;
    int? tzOffset;

    // Parse date part
    if (dateStr.startsWith('---')) {
      // Day only: ---12
      day = int.tryParse(dateStr.substring(3));
    } else if (dateStr.startsWith('--')) {
      // Month-day: --0412
      final md = dateStr.substring(2).replaceAll('-', '');
      if (md.length >= 2) {
        month = int.tryParse(md.substring(0, 2));
      }
      if (md.length >= 4) {
        day = int.tryParse(md.substring(2, 4));
      }
    } else {
      // Full date: 19850412 or 1985-04-12
      final dateOnly = dateStr.replaceAll('-', '');
      if (dateOnly.length >= 4) {
        year = int.tryParse(dateOnly.substring(0, 4));
      }
      if (dateOnly.length >= 6) {
        month = int.tryParse(dateOnly.substring(4, 6));
      }
      if (dateOnly.length >= 8) {
        day = int.tryParse(dateOnly.substring(6, 8));
      }
    }

    // Parse time part
    if (timeStr != null && timeStr.isNotEmpty) {
      var ts = timeStr;

      // Check for timezone
      if (ts.endsWith('Z')) {
        tzOffset = 0;
        ts = ts.substring(0, ts.length - 1);
      } else {
        final tzMatch = RegExp(r'([+-])(\d{2}):?(\d{2})?$').firstMatch(ts);
        if (tzMatch != null) {
          final sign = tzMatch.group(1) == '+' ? 1 : -1;
          final tzHours = int.parse(tzMatch.group(2)!);
          final tzMins = int.tryParse(tzMatch.group(3) ?? '0') ?? 0;
          tzOffset = sign * (tzHours * 60 + tzMins);
          ts = ts.substring(0, tzMatch.start);
        }
      }

      // Parse time: 232000 or 23:20:00
      final timeOnly = ts.replaceAll(':', '');
      if (timeOnly.length >= 2) {
        hour = int.tryParse(timeOnly.substring(0, 2));
      }
      if (timeOnly.length >= 4) {
        minute = int.tryParse(timeOnly.substring(2, 4));
      }
      if (timeOnly.length >= 6) {
        second = int.tryParse(timeOnly.substring(4, 6));
      }
    }

    return DateOrDateTime(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      timezoneOffset: tzOffset,
    );
  }

  /// Tries to parse, returns null on failure.
  static DateOrDateTime? tryParse(String value) {
    try {
      return DateOrDateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Whether this is a date only (no time component).
  bool get isDateOnly => hour == null && minute == null && second == null;

  /// Whether this has a time component.
  bool get hasTime => hour != null || minute != null || second != null;

  /// Whether this is a complete date.
  bool get isCompleteDate => year != null && month != null && day != null;

  /// Whether this is empty.
  bool get isEmpty => year == null && month == null && day == null && !hasTime;

  /// Whether this is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Converts to a Dart DateTime if possible.
  DateTime? toDateTime() {
    if (year == null || month == null || day == null) return null;
    return DateTime(year!, month!, day!, hour ?? 0, minute ?? 0, second ?? 0);
  }

  /// Converts to vCard date format (for BDAY, ANNIVERSARY).
  String toDateString() {
    if (year == null && month == null && day == null) return '';

    final buffer = StringBuffer();

    if (year != null) {
      buffer.write(year.toString().padLeft(4, '0'));
    }
    if (month != null) {
      if (year == null) buffer.write('--');
      buffer.write(month.toString().padLeft(2, '0'));
    }
    if (day != null) {
      if (year == null && month == null) buffer.write('---');
      buffer.write(day.toString().padLeft(2, '0'));
    }

    return buffer.toString();
  }

  /// Converts to vCard date-time format.
  String toDateTimeString({bool includeTimezone = true}) {
    final buffer = StringBuffer(toDateString());

    if (hasTime) {
      buffer.write('T');
      buffer.write((hour ?? 0).toString().padLeft(2, '0'));
      buffer.write((minute ?? 0).toString().padLeft(2, '0'));
      if (second != null) {
        buffer.write(second.toString().padLeft(2, '0'));
      }

      if (includeTimezone && timezoneOffset != null) {
        if (timezoneOffset == 0) {
          buffer.write('Z');
        } else {
          final sign = timezoneOffset! >= 0 ? '+' : '-';
          final absOffset = timezoneOffset!.abs();
          final tzHours = absOffset ~/ 60;
          final tzMins = absOffset % 60;
          buffer.write(sign);
          buffer.write(tzHours.toString().padLeft(2, '0'));
          buffer.write(tzMins.toString().padLeft(2, '0'));
        }
      }
    }

    return buffer.toString();
  }

  @override
  String toString() {
    return hasTime ? toDateTimeString() : toDateString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateOrDateTime) return false;
    return year == other.year &&
        month == other.month &&
        day == other.day &&
        hour == other.hour &&
        minute == other.minute &&
        second == other.second &&
        timezoneOffset == other.timezoneOffset;
  }

  @override
  int get hashCode =>
      Object.hash(year, month, day, hour, minute, second, timezoneOffset);
}
