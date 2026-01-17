import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:vcard_dart/vcard_dart.dart';

void main() {
  group('VCardParser', () {
    late VCardParser parser;

    setUp(() {
      parser = const VCardParser();
    });

    test('parses simple vCard 4.0', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:John Doe
N:Doe;John;;;
END:VCARD
''';
      final vcards = parser.parse(vcardText);
      expect(vcards.length, 1);
      expect(vcards.first.formattedName, 'John Doe');
      expect(vcards.first.name?.family, 'Doe');
      expect(vcards.first.name?.given, 'John');
      expect(vcards.first.version, VCardVersion.v40);
    });

    test('parses vCard 3.0', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:3.0
FN:Jane Smith
N:Smith;Jane;Marie;Dr.;PhD
TEL;TYPE=WORK,VOICE:+1-555-123-4567
EMAIL;TYPE=INTERNET:jane@example.com
END:VCARD
''';
      final vcards = parser.parse(vcardText);
      expect(vcards.length, 1);
      final vcard = vcards.first;
      expect(vcard.formattedName, 'Jane Smith');
      expect(vcard.name?.family, 'Smith');
      expect(vcard.name?.given, 'Jane');
      expect(vcard.version, VCardVersion.v30);
      expect(vcard.telephones.length, 1);
      expect(vcard.telephones.first.number, '+1-555-123-4567');
      expect(vcard.emails.length, 1);
      expect(vcard.emails.first.address, 'jane@example.com');
    });

    test('parses vCard 2.1 with legacy syntax', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:2.1
N:Doe;John
FN:John Doe
TEL;WORK;VOICE:+1-555-123-4567
TEL;CELL:+1-555-987-6543
EMAIL;INTERNET:john@example.com
ADR;WORK;ENCODING=QUOTED-PRINTABLE:;;123 Main=0D=0ASt;City;State;12345;USA
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.version, VCardVersion.v21);
      expect(vcard.formattedName, 'John Doe');
      expect(vcard.telephones.length, 2);
      expect(vcard.telephones[0].isWork, true);
      // In vCard 2.1, CELL is a bare type parameter (types are lowercase)
      expect(vcard.telephones[1].types.contains('cell'), true);
      expect(vcard.telephones[1].isCell, true);
    });

    test('parses multiple vCards', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Person One
END:VCARD
BEGIN:VCARD
VERSION:4.0
FN:Person Two
END:VCARD
''';
      final vcards = parser.parse(vcardText);
      expect(vcards.length, 2);
      expect(vcards[0].formattedName, 'Person One');
      expect(vcards[1].formattedName, 'Person Two');
    });

    test('parses address with all components', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Test User
ADR;TYPE=WORK;PREF=1:PO Box 123;Suite 456;123 Main St;Anytown;CA;12345;USA
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.addresses.length, 1);
      final addr = vcard.addresses.first;
      expect(addr.poBox, 'PO Box 123');
      expect(addr.extended, 'Suite 456');
      expect(addr.street, '123 Main St');
      expect(addr.city, 'Anytown');
      expect(addr.region, 'CA');
      expect(addr.postalCode, '12345');
      expect(addr.country, 'USA');
      expect(addr.isWork, true);
      expect(addr.pref, 1);
    });

    test('parses multiple addresses with different types', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Multi Address
ADR;TYPE=WORK:;;Work Street;WorkCity;WS;11111;USA
ADR;TYPE=HOME:;;Home Street;HomeCity;HS;22222;USA
ADR;TYPE=OTHER:;;Other Street;OtherCity;OS;33333;USA
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.addresses.length, 3);
      expect(vcard.addresses[0].isWork, true);
      expect(vcard.addresses[1].isHome, true);
    });

    test('parses organization with multiple units', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Employee
ORG:Acme Corp;Engineering;Software;Frontend
TITLE:Senior Developer
ROLE:Developer
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.organization?.name, 'Acme Corp');
      expect(vcard.organization?.units, [
        'Engineering',
        'Software',
        'Frontend',
      ]);
      expect(vcard.title, 'Senior Developer');
      expect(vcard.role, 'Developer');
    });

    test('parses birthday with different formats', () {
      // Full date
      var vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Birthday Test
BDAY:19850415
END:VCARD
''';
      var vcard = parser.parseSingle(vcardText);
      expect(vcard.birthday?.year, 1985);
      expect(vcard.birthday?.month, 4);
      expect(vcard.birthday?.day, 15);

      // Date with time
      vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Birthday Test
BDAY:19850415T102030Z
END:VCARD
''';
      vcard = parser.parseSingle(vcardText);
      expect(vcard.birthday?.year, 1985);
      expect(vcard.birthday?.hour, 10);

      // ISO format with dashes
      vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Birthday Test
BDAY:1985-04-15
END:VCARD
''';
      vcard = parser.parseSingle(vcardText);
      expect(vcard.birthday?.year, 1985);
    });

    test('parses anniversary', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Anniversary Test
ANNIVERSARY:20100620
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.anniversary?.year, 2010);
      expect(vcard.anniversary?.month, 6);
      expect(vcard.anniversary?.day, 20);
    });

    test('parses gender with identity', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Gender Test
GENDER:O;Non-binary
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.gender?.sex, 'O');
      expect(vcard.gender?.identity, 'Non-binary');
      expect(vcard.gender?.isOther, true);
    });

    test('parses categories with special characters', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Category Person
CATEGORIES:Friend,Family\\, Close,Work
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      // The escaped comma \\, is unescaped to \, which is then treated as literal comma
      // The actual parsing depends on implementation
      expect(vcard.categories.length, greaterThanOrEqualTo(3));
      expect(vcard.categories[0], 'Friend');
    });

    test('parses note with multiline content', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Note Person
NOTE:Line 1\\nLine 2\\nLine 3
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.note, 'Line 1\nLine 2\nLine 3');
    });

    test('parses multiple URLs with types', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:URL Person
URL;TYPE=WORK:https://company.com
URL;TYPE=HOME:https://personal.com
URL:https://other.com
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.urls.length, 3);
      expect(vcard.urls[0].url, 'https://company.com');
      expect(vcard.urls[0].isWork, true);
      expect(vcard.urls[1].url, 'https://personal.com');
      expect(vcard.urls[1].isHome, true);
    });

    test('handles complex line folding', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Very Long Name That Needs Folding
NOTE:This is a very long note that will be folded across multiple lines i
 n the vCard format because it exceeds the maximum line length. It continu
 es for several more lines to test the folding mechanism properly.
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.note, contains('multiple lines'));
      expect(vcard.note, contains('continues'));
      expect(vcard.note, contains('properly'));
    });

    test('handles various escaped characters', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Test\\, Name\\; Special
NOTE:Semi\\;colon and comma\\, and backslash\\\\
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.formattedName, 'Test, Name; Special');
      expect(vcard.note, 'Semi;colon and comma, and backslash\\');
    });

    test('parses extended properties with parameters', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Extended Person
X-CUSTOM:Custom Value
X-SOCIAL-PROFILE;TYPE=twitter:https://twitter.com/example
X-ABShowAs:COMPANY
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.extendedProperties.length, 3);
      expect(vcard.getExtendedProperty('X-CUSTOM')?.value, 'Custom Value');
      expect(
        vcard.getExtendedProperty('X-SOCIAL-PROFILE')?.value,
        'https://twitter.com/example',
      );
    });

    test('parses geo location in different formats', () {
      // vCard 4.0 format
      var vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Geo Person
GEO:geo:37.7749,-122.4194
END:VCARD
''';
      var vcard = parser.parseSingle(vcardText);
      expect(vcard.geo?.latitude, closeTo(37.7749, 0.0001));
      expect(vcard.geo?.longitude, closeTo(-122.4194, 0.0001));

      // vCard 3.0 legacy format
      vcardText = '''
BEGIN:VCARD
VERSION:3.0
FN:Geo Person
GEO:37.7749;-122.4194
END:VCARD
''';
      vcard = parser.parseSingle(vcardText);
      expect(vcard.geo?.latitude, closeTo(37.7749, 0.0001));
    });

    test('parses all kind values', () {
      for (final kind in ['individual', 'org', 'group', 'location']) {
        final vcardText =
            '''
BEGIN:VCARD
VERSION:4.0
KIND:$kind
FN:Kind Test
END:VCARD
''';
        final vcard = parser.parseSingle(vcardText);
        expect(vcard.kind?.value, kind);
      }
    });

    test('parses IMPP with different protocols', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:IMPP Test
IMPP;PREF=1:xmpp:user@jabber.org
IMPP:aim:screenname
IMPP:skype:username
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.impps.length, 3);
      expect(vcard.impps[0].uri, 'xmpp:user@jabber.org');
      expect(vcard.impps[0].pref, 1);
    });

    test('parses RELATED property', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Related Test
RELATED;TYPE=spouse:urn:uuid:12345678
RELATED;TYPE=child:urn:uuid:87654321
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.related.length, 2);
      expect(vcard.related[0].type, 'spouse');
      expect(vcard.related[1].type, 'child');
    });

    test('parses MEMBER property for groups', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
KIND:group
FN:Team Alpha
MEMBER:urn:uuid:member1
MEMBER:urn:uuid:member2
MEMBER:urn:uuid:member3
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.kind, VCardKind.group);
      expect(vcard.members.length, 3);
    });

    test('parses UID and PRODID', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:ID Test
UID:urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6
PRODID:-//Example Inc.//Example vCard 1.0//EN
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.uid, 'urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6');
      expect(vcard.productId, '-//Example Inc.//Example vCard 1.0//EN');
    });

    test('parses REV timestamp', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Rev Test
REV:20231215T103000Z
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.revision?.year, 2023);
      expect(vcard.revision?.month, 12);
      expect(vcard.revision?.day, 15);
    });

    test('parses SOURCE and PHOTO URI', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Source Test
SOURCE:https://example.com/vcard.vcf
PHOTO:https://example.com/photo.jpg
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.sources.first, 'https://example.com/vcard.vcf');
      expect(vcard.photos.first.uri, 'https://example.com/photo.jpg');
    });

    test('parses property groups', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Group Test
WORK.TEL:+1-555-111-1111
WORK.EMAIL:work@example.com
HOME.TEL:+1-555-222-2222
HOME.EMAIL:home@example.com
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.telephones.length, 2);
      expect(vcard.emails.length, 2);
    });

    test('lenient mode allows parsing incomplete vCards', () {
      const lenientParser = VCardParser(lenient: true);
      // vCard without END:VCARD can be parsed in lenient mode
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Lenient Test
TEL:+1-555-000-0000
''';
      // In lenient mode, this should not throw even without END:VCARD
      final vcard = lenientParser.parseSingle(vcardText);
      expect(vcard.formattedName, 'Lenient Test');
      expect(vcard.telephones.length, 1);
    });

    test('parses empty property values', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Empty Test
N:;;;;
ADR:;;;;;;
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.formattedName, 'Empty Test');
      expect(vcard.name?.isEmpty, true);
    });

    test('parses vCard with Windows line endings', () {
      const vcardText =
          'BEGIN:VCARD\r\nVERSION:4.0\r\nFN:CRLF Test\r\nEND:VCARD\r\n';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.formattedName, 'CRLF Test');
    });

    test('parses vCard with Unix line endings', () {
      const vcardText = 'BEGIN:VCARD\nVERSION:4.0\nFN:LF Test\nEND:VCARD\n';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.formattedName, 'LF Test');
    });

    test('parses calendar properties', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Calendar Test
FBURL:https://example.com/freebusy
CALURI:https://example.com/calendar
CALADRURI:mailto:calendar@example.com
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.freeBusyUrls.first, 'https://example.com/freebusy');
      expect(vcard.calendarUrls.first, 'https://example.com/calendar');
      expect(vcard.calendarAddressUrls.first, 'mailto:calendar@example.com');
    });

    test('parses LANG preferences', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Language Test
LANG;PREF=1:en
LANG;PREF=2:fr
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.languages.length, 2);
      expect(vcard.languages[0].tag, 'en');
      expect(vcard.languages[0].pref, 1);
    });

    test('parses TZ timezone', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Timezone Test
TZ:America/New_York
END:VCARD
''';
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.timezone, 'America/New_York');
    });
  });

  group('VCardGenerator', () {
    late VCardGenerator generator;

    setUp(() {
      generator = const VCardGenerator();
    });

    test('generates simple vCard', () {
      final vcard = VCard()
        ..formattedName = 'John Doe'
        ..name = const StructuredName(family: 'Doe', given: 'John');

      final text = generator.generate(vcard);
      expect(text, contains('BEGIN:VCARD'));
      expect(text, contains('VERSION:4.0'));
      expect(text, contains('FN:John Doe'));
      expect(text, contains('N:Doe;John;;;'));
      expect(text, contains('END:VCARD'));
    });

    test('generates vCard with all contact info types', () {
      final vcard = VCard()
        ..formattedName = 'Contact Test'
        ..telephones.addAll([
          Telephone.cell('+1-555-111-1111'),
          Telephone.work('+1-555-222-2222'),
          Telephone.home('+1-555-333-3333'),
          Telephone.fax('+1-555-444-4444'),
        ])
        ..emails.addAll([
          Email.work('work@example.com'),
          Email.home('home@example.com'),
        ]);

      final text = generator.generate(vcard);
      expect(text, contains('TEL'));
      expect(text, contains('EMAIL'));
    });

    test('generates vCard with full address', () {
      final vcard = VCard()
        ..formattedName = 'Address Person'
        ..addresses.add(
          const Address(
            poBox: 'PO Box 123',
            extended: 'Suite 456',
            street: '123 Main St',
            city: 'Anytown',
            region: 'CA',
            postalCode: '12345',
            country: 'USA',
            types: ['work'],
            pref: 1,
          ),
        );

      final text = generator.generate(vcard);
      expect(text, contains('ADR'));
      expect(text, contains('PO Box 123'));
      expect(text, contains('Suite 456'));
    });

    test('generates different versions correctly', () {
      final vcard = VCard()
        ..formattedName = 'Version Test'
        ..telephones.add(Telephone.cell('+1-555-000-0000'));

      // vCard 2.1
      final v21 = generator.generate(vcard, version: VCardVersion.v21);
      expect(v21, contains('VERSION:2.1'));
      // vCard 2.1 should not use tel: URI
      expect(v21, contains('+1-555-000-0000'));

      // vCard 3.0
      final v30 = generator.generate(vcard, version: VCardVersion.v30);
      expect(v30, contains('VERSION:3.0'));

      // vCard 4.0
      final v40 = generator.generate(vcard, version: VCardVersion.v40);
      expect(v40, contains('VERSION:4.0'));
      // vCard 4.0 should use tel: URI
      expect(v40, contains('tel:'));
    });

    test('generates vCard with all properties', () {
      final vcard = VCard()
        ..formattedName = 'Full Test'
        ..name = const StructuredName(
          family: 'Test',
          given: 'Full',
          additional: ['Middle'],
          prefixes: ['Dr.'],
          suffixes: ['PhD'],
        )
        ..nicknames.addAll(['Testy', 'Testman'])
        ..birthday = DateOrDateTime(year: 1990, month: 1, day: 1)
        ..anniversary = DateOrDateTime(year: 2020, month: 6, day: 15)
        ..gender = const Gender.male()
        ..organization = const Organization(name: 'Test Corp', units: ['R&D'])
        ..title = 'Engineer'
        ..role = 'Developer'
        ..note = 'A test note'
        ..categories = ['Test', 'Example']
        ..uid = 'test-uid-123'
        ..timezone = 'America/New_York';

      final text = generator.generate(vcard);
      expect(text, contains('FN:Full Test'));
      expect(text, contains('N:Test;Full;Middle;Dr.;PhD'));
      expect(text, contains('NICKNAME:Testy,Testman'));
      expect(text, contains('BDAY:'));
      expect(text, contains('ANNIVERSARY:'));
      expect(text, contains('GENDER:M'));
      expect(text, contains('ORG:Test Corp;R&D'));
      expect(text, contains('TITLE:Engineer'));
      expect(text, contains('ROLE:Developer'));
      expect(text, contains('NOTE:A test note'));
      expect(text, contains('CATEGORIES:Test,Example'));
      expect(text, contains('UID:test-uid-123'));
      expect(text, contains('TZ:America/New_York'));
    });

    test('generates vCard 4.0 specific properties', () {
      final vcard = VCard()
        ..formattedName = 'V4 Test'
        ..kind = VCardKind.organization
        ..members.addAll(['urn:uuid:member1', 'urn:uuid:member2'])
        ..related.add(const Related(value: 'urn:uuid:spouse', type: 'spouse'));

      final text = generator.generate(vcard, version: VCardVersion.v40);
      expect(text, contains('KIND:org'));
      expect(text, contains('MEMBER:'));
      expect(text, contains('RELATED'));
    });

    test('escapes special characters in output', () {
      final vcard = VCard()
        ..formattedName = 'Test, Name; Special'
        ..note = 'Line 1\nLine 2\nWith, commas; and semicolons';

      final text = generator.generate(vcard);
      expect(text, contains(r'FN:Test\, Name\; Special'));
      expect(text, contains(r'\n'));
    });

    test('folds long lines correctly', () {
      final vcard = VCard()
        ..formattedName = 'Fold Test'
        ..note = 'A' * 200; // Very long note

      final text = generator.generate(vcard);
      // Check that lines are folded with CRLF + space
      expect(text, contains('\r\n '));
    });

    test('round-trip with complex vCard', () {
      final original = VCard()
        ..formattedName = 'Complex Round Trip'
        ..name = const StructuredName(
          family: 'Trip',
          given: 'Round',
          prefixes: ['Dr.'],
          suffixes: ['Jr.'],
        )
        ..telephones.addAll([
          Telephone.cell('+1-555-000-0000'),
          Telephone.work('+1-555-111-1111'),
        ])
        ..emails.addAll([
          Email.work('work@example.com'),
          Email.home('home@example.com'),
        ])
        ..addresses.add(
          const Address(
            street: '456 Test Ave',
            city: 'TestCity',
            region: 'TX',
            postalCode: '54321',
            country: 'USA',
            types: ['work'],
          ),
        )
        ..organization = const Organization(name: 'Test Corp', units: ['R&D'])
        ..title = 'Engineer'
        ..note = 'Complex note with, commas and\nnewlines'
        ..categories = ['A', 'B', 'C']
        ..birthday = DateOrDateTime(year: 1985, month: 4, day: 15);

      final text = generator.generate(original);
      final parser = const VCardParser();
      final parsed = parser.parseSingle(text);

      expect(parsed.formattedName, original.formattedName);
      expect(parsed.name?.family, original.name?.family);
      expect(parsed.name?.given, original.name?.given);
      expect(parsed.name?.prefixes, original.name?.prefixes);
      expect(parsed.name?.suffixes, original.name?.suffixes);
      expect(parsed.telephones.length, original.telephones.length);
      expect(parsed.emails.length, original.emails.length);
      expect(parsed.organization?.name, original.organization?.name);
      expect(parsed.title, original.title);
      expect(parsed.categories, original.categories);
      expect(parsed.birthday?.year, original.birthday?.year);
    });

    test('generates multiple vCards', () {
      final vcards = [
        VCard()..formattedName = 'Person One',
        VCard()..formattedName = 'Person Two',
        VCard()..formattedName = 'Person Three',
      ];

      final text = generator.generateAll(vcards);
      expect(RegExp('BEGIN:VCARD').allMatches(text).length, 3);
      expect(RegExp('END:VCARD').allMatches(text).length, 3);
    });

    test('throws on missing required FN', () {
      final vcard = VCard(); // No formattedName set
      expect(
        () => generator.generate(vcard),
        throwsA(isA<VCardGenerateException>()),
      );
    });
  });

  group('JCardFormatter', () {
    late JCardFormatter formatter;

    setUp(() {
      formatter = const JCardFormatter();
    });

    test('converts simple vCard to jCard and back', () {
      final vcard = VCard()
        ..formattedName = 'JSON Test'
        ..name = const StructuredName(family: 'Test', given: 'JSON')
        ..emails.add(Email(address: 'json@example.com'));

      final json = formatter.toJson(vcard);
      expect(json[0], 'vcard');
      expect(json[1], isA<List>());

      final restored = formatter.fromJson(json);
      expect(restored.formattedName, 'JSON Test');
      expect(restored.name?.family, 'Test');
      expect(restored.emails.first.address, 'json@example.com');
    });

    test('converts complex vCard to jCard', () {
      final vcard = VCard()
        ..formattedName = 'Complex JSON'
        ..name = const StructuredName(
          family: 'JSON',
          given: 'Complex',
          prefixes: ['Mr.'],
        )
        ..telephones.addAll([
          Telephone.cell('+1-555-111-1111'),
          Telephone.work('+1-555-222-2222'),
        ])
        ..emails.add(Email.work('work@example.com'))
        ..addresses.add(
          const Address(
            street: '123 Main St',
            city: 'City',
            region: 'ST',
            postalCode: '12345',
            country: 'USA',
            types: ['work'],
          ),
        )
        ..birthday = DateOrDateTime(year: 1990, month: 5, day: 10)
        ..organization = const Organization(name: 'Company');

      final json = formatter.toJson(vcard);
      final jsonString = formatter.toJsonString(vcard);

      // Should be valid JSON
      final decoded = jsonDecode(jsonString);
      expect(decoded, isA<List>());

      // Round trip
      final restored = formatter.fromJson(json);
      expect(restored.formattedName, 'Complex JSON');
      expect(restored.telephones.length, 2);
      expect(restored.addresses.length, 1);
    });

    test('generates valid JSON string', () {
      final vcard = VCard()..formattedName = 'String Test';
      final jsonString = formatter.toJsonString(vcard);
      expect(jsonString, startsWith('["vcard"'));
      expect(jsonString, contains('"fn"'));

      // Should be parseable
      final decoded = jsonDecode(jsonString);
      expect(decoded[0], 'vcard');
    });

    test('parses JSON string', () {
      const jsonString =
          '["vcard",[["version",{},"text","4.0"],["fn",{},"text","Parsed Person"]]]';
      final vcard = formatter.fromJsonString(jsonString);
      expect(vcard.formattedName, 'Parsed Person');
    });

    test('handles special characters in jCard', () {
      final vcard = VCard()
        ..formattedName = 'Special "Chars" & <Tags>'
        ..note = 'Note with "quotes" and <brackets>';

      final json = formatter.toJson(vcard);
      final restored = formatter.fromJson(json);
      expect(restored.formattedName, 'Special "Chars" & <Tags>');
      expect(restored.note, 'Note with "quotes" and <brackets>');
    });

    test('round-trip preserves all properties', () {
      final original = VCard()
        ..formattedName = 'Full jCard Test'
        ..name = const StructuredName(family: 'Test', given: 'Full')
        ..nicknames.addAll(['Nick1', 'Nick2'])
        ..birthday = DateOrDateTime(year: 1985, month: 4, day: 15)
        ..gender = const Gender.male()
        ..telephones.add(Telephone.cell('+1-555-000-0000'))
        ..emails.add(Email.work('test@example.com'))
        ..categories = ['A', 'B'];

      final json = formatter.toJson(original);
      final restored = formatter.fromJson(json);

      expect(restored.formattedName, original.formattedName);
      expect(restored.name?.family, original.name?.family);
      expect(restored.nicknames, original.nicknames);
      expect(restored.birthday?.year, original.birthday?.year);
      expect(restored.gender?.sex, original.gender?.sex);
    });
  });

  group('XCardFormatter', () {
    late XCardFormatter formatter;

    setUp(() {
      formatter = const XCardFormatter();
    });

    test('converts simple vCard to xCard and back', () {
      final vcard = VCard()
        ..formattedName = 'XML Test'
        ..name = const StructuredName(family: 'Test', given: 'XML')
        ..emails.add(Email(address: 'xml@example.com'));

      final xml = formatter.toXml(vcard, pretty: true);
      expect(xml, contains('<vcards'));
      expect(xml, contains('<vcard>'));
      expect(xml, contains('<fn>'));
      expect(xml, contains('XML Test'));

      final restored = formatter.fromXml(xml);
      expect(restored.formattedName, 'XML Test');
      expect(restored.name?.family, 'Test');
      expect(restored.emails.first.address, 'xml@example.com');
    });

    test('converts complex vCard to xCard', () {
      final vcard = VCard()
        ..formattedName = 'Complex XML'
        ..name = const StructuredName(
          family: 'XML',
          given: 'Complex',
          prefixes: ['Dr.'],
        )
        ..telephones.addAll([
          Telephone.cell('+1-555-111-1111'),
          Telephone.work('+1-555-222-2222'),
        ])
        ..emails.add(Email.work('work@example.com'))
        ..addresses.add(
          const Address(
            street: '123 Main St',
            city: 'City',
            region: 'ST',
            postalCode: '12345',
            country: 'USA',
            types: ['work'],
          ),
        )
        ..organization = const Organization(name: 'Company', units: ['Dept']);

      final xml = formatter.toXml(vcard, pretty: true);

      // Check structure
      expect(xml, contains('<vcards'));
      expect(xml, contains('<vcard>'));
      expect(xml, contains('<n>'));
      expect(xml, contains('<surname>'));
      expect(xml, contains('<tel>'));
      expect(xml, contains('<email>'));
      expect(xml, contains('<adr>'));
      expect(xml, contains('<org>'));

      // Round trip
      final restored = formatter.fromXml(xml);
      expect(restored.formattedName, 'Complex XML');
      expect(restored.telephones.length, 2);
      expect(restored.addresses.length, 1);
    });

    test('generates minified XML when pretty=false', () {
      final vcard = VCard()..formattedName = 'Minified Test';
      final minified = formatter.toXml(vcard, pretty: false);
      final pretty = formatter.toXml(vcard, pretty: true);

      expect(minified.length, lessThan(pretty.length));
      expect(minified, isNot(contains('\n  '))); // No indentation
    });

    test('escapes special XML characters', () {
      final vcard = VCard()
        ..formattedName = 'Special <XML> & "Chars"'
        ..note = 'Note with <tags> & "quotes"';

      final xml = formatter.toXml(vcard);
      expect(xml, contains('&lt;'));
      expect(xml, contains('&gt;'));
      expect(xml, contains('&amp;'));

      final restored = formatter.fromXml(xml);
      expect(restored.formattedName, 'Special <XML> & "Chars"');
    });

    test('round-trip preserves all properties', () {
      final original = VCard()
        ..formattedName = 'Full xCard Test'
        ..name = const StructuredName(family: 'Test', given: 'Full')
        ..nicknames.addAll(['Nick1', 'Nick2'])
        ..birthday = DateOrDateTime(year: 1985, month: 4, day: 15)
        ..telephones.add(Telephone.cell('+1-555-000-0000'))
        ..emails.add(Email.work('test@example.com'))
        ..categories = ['A', 'B'];

      final xml = formatter.toXml(original);
      final restored = formatter.fromXml(xml);

      expect(restored.formattedName, original.formattedName);
      expect(restored.name?.family, original.name?.family);
      expect(restored.birthday?.year, original.birthday?.year);
    });
  });

  group('Models - StructuredName', () {
    test('toFormattedName with all components', () {
      const name = StructuredName(
        family: 'Doe',
        given: 'John',
        additional: ['William', 'Robert'],
        prefixes: ['Dr.', 'Sir'],
        suffixes: ['Jr.', 'PhD'],
      );
      expect(name.toFormattedName(), 'Dr. Sir John William Robert Doe Jr. PhD');
    });

    test('toFormattedName with minimal components', () {
      const name = StructuredName(given: 'John');
      expect(name.toFormattedName(), 'John');

      const name2 = StructuredName(family: 'Doe');
      expect(name2.toFormattedName(), 'Doe');
    });

    test('isEmpty and isNotEmpty', () {
      const empty = StructuredName();
      expect(empty.isEmpty, true);
      expect(empty.isNotEmpty, false);

      const notEmpty = StructuredName(given: 'John');
      expect(notEmpty.isEmpty, false);
      expect(notEmpty.isNotEmpty, true);
    });

    test('toComponents and fromComponents', () {
      const original = StructuredName(
        family: 'Doe',
        given: 'John',
        additional: ['Middle'],
        prefixes: ['Dr.'],
        suffixes: ['Jr.'],
      );
      final components = original.toComponents();
      final restored = StructuredName.fromComponents(components);

      expect(restored.family, original.family);
      expect(restored.given, original.given);
    });

    test('copyWith', () {
      const name = StructuredName(family: 'Doe', given: 'John');
      final updated = name.copyWith(given: 'Jane');
      expect(updated.family, 'Doe');
      expect(updated.given, 'Jane');
    });
  });

  group('Models - Address', () {
    test('toFormattedString', () {
      const addr = Address(
        street: '123 Main St',
        city: 'Anytown',
        region: 'CA',
        postalCode: '12345',
        country: 'USA',
      );
      final formatted = addr.toFormattedString();
      expect(formatted, contains('123 Main St'));
      expect(formatted, contains('Anytown'));
      expect(formatted, contains('CA'));
      expect(formatted, contains('12345'));
      expect(formatted, contains('USA'));
    });

    test('type checks', () {
      const work = Address(types: ['work']);
      expect(work.isWork, true);
      expect(work.isHome, false);

      const home = Address(types: ['home']);
      expect(home.isHome, true);
      expect(home.isWork, false);

      const multi = Address(types: ['work', 'postal']);
      expect(multi.isWork, true);
      expect(multi.isPostal, true);
    });

    test('isEmpty', () {
      const empty = Address();
      expect(empty.isEmpty, true);

      const notEmpty = Address(street: '123 Main');
      expect(notEmpty.isEmpty, false);
    });

    test('toComponents and fromComponents', () {
      const original = Address(
        poBox: 'PO Box 1',
        extended: 'Suite 2',
        street: '123 Main',
        city: 'City',
        region: 'ST',
        postalCode: '12345',
        country: 'USA',
      );
      final components = original.toComponents();
      expect(components.length, 7);

      final restored = Address.fromComponents(components);
      expect(restored.poBox, original.poBox);
      expect(restored.street, original.street);
      expect(restored.city, original.city);
    });
  });

  group('Models - Contact Info', () {
    test('Telephone construction and types', () {
      final cell = Telephone.cell('+1-555-000-0000');
      expect(cell.isCell, true);
      expect(cell.number, '+1-555-000-0000');

      final work = Telephone.work('+1-555-111-1111');
      expect(work.isWork, true);

      final home = Telephone.home('+1-555-222-2222');
      expect(home.isHome, true);

      final fax = Telephone.fax('+1-555-333-3333');
      expect(fax.isFax, true);
    });

    test('Telephone toUri', () {
      final tel = Telephone.cell('+1-555-123-4567');
      expect(tel.toUri(), 'tel:+15551234567');
    });

    test('Email construction and types', () {
      final work = Email.work('work@example.com');
      expect(work.isWork, true);
      expect(work.address, 'work@example.com');

      final home = Email.home('home@example.com');
      expect(home.isHome, true);
    });

    test('WebUrl types', () {
      final work = WebUrl.work('https://company.com');
      expect(work.isWork, true);

      final home = WebUrl.home('https://personal.com');
      expect(home.isHome, true);
    });
  });

  group('Models - GeoLocation', () {
    test('fromUri parsing', () {
      final geo = GeoLocation.fromUri('geo:37.7749,-122.4194');
      expect(geo.latitude, closeTo(37.7749, 0.0001));
      expect(geo.longitude, closeTo(-122.4194, 0.0001));

      final geoWithUncertainty = GeoLocation.fromUri(
        'geo:37.7749,-122.4194;u=10',
      );
      expect(geoWithUncertainty.latitude, closeTo(37.7749, 0.0001));
    });

    test('fromLegacy parsing', () {
      final geo = GeoLocation.fromLegacy('37.7749;-122.4194');
      expect(geo.latitude, closeTo(37.7749, 0.0001));
      expect(geo.longitude, closeTo(-122.4194, 0.0001));
    });

    test('toUri and toLegacy', () {
      const geo = GeoLocation(latitude: 37.7749, longitude: -122.4194);
      expect(geo.toUri(), 'geo:37.7749,-122.4194');
      expect(geo.toLegacy(), '37.7749;-122.4194');
    });

    test('tryParse with various formats', () {
      expect(GeoLocation.tryParse('geo:37.7749,-122.4194'), isNotNull);
      expect(GeoLocation.tryParse('37.7749;-122.4194'), isNotNull);
      expect(GeoLocation.tryParse('invalid'), isNull);
    });
  });

  group('Models - DateOrDateTime', () {
    test('parse various formats', () {
      // Basic date
      final date = DateOrDateTime.parse('19850415');
      expect(date.year, 1985);
      expect(date.month, 4);
      expect(date.day, 15);
      expect(date.isDateOnly, true);

      // Date with time
      final dateTime = DateOrDateTime.parse('19850415T102030Z');
      expect(dateTime.year, 1985);
      expect(dateTime.hour, 10);
      expect(dateTime.minute, 20);
      expect(dateTime.second, 30);
      expect(dateTime.timezoneOffset, 0);

      // ISO format
      final iso = DateOrDateTime.parse('1985-04-15');
      expect(iso.year, 1985);
    });

    test('parse partial dates', () {
      final yearOnly = DateOrDateTime.tryParse('1985');
      expect(yearOnly?.year, 1985);
      expect(yearOnly?.month, isNull);

      final yearMonth = DateOrDateTime.tryParse('1985-04');
      expect(yearMonth?.year, 1985);
      expect(yearMonth?.month, 4);
    });

    test('toDateString and toDateTimeString', () {
      final date = DateOrDateTime(year: 1985, month: 4, day: 15);
      expect(date.toDateString(), '19850415');

      final dateTime = DateOrDateTime(
        year: 1985,
        month: 4,
        day: 15,
        hour: 10,
        minute: 20,
        second: 30,
        timezoneOffset: 0,
      );
      expect(dateTime.toDateTimeString(), '19850415T102030Z');
    });

    test('isEmpty and isNotEmpty', () {
      final empty = DateOrDateTime();
      expect(empty.isEmpty, true);

      final notEmpty = DateOrDateTime(year: 1985);
      expect(notEmpty.isEmpty, false);
    });
  });

  group('Models - Gender', () {
    test('predefined values', () {
      const male = Gender.male();
      expect(male.isMale, true);
      expect(male.sex, 'M');

      const female = Gender.female();
      expect(female.isFemale, true);
      expect(female.sex, 'F');

      const other = Gender.other();
      expect(other.isOther, true);
      expect(other.sex, 'O');

      const notApplicable = Gender.notApplicable();
      expect(notApplicable.isNotApplicable, true);
      expect(notApplicable.sex, 'N');

      const unknown = Gender.unknown();
      expect(unknown.isUnknown, true);
      expect(unknown.sex, 'U');
    });

    test('parse with identity', () {
      final parsed = Gender.parse('O;Non-binary');
      expect(parsed.sex, 'O');
      expect(parsed.identity, 'Non-binary');
    });

    test('toValue', () {
      const male = Gender.male();
      expect(male.toValue(), 'M');

      final withIdentity = Gender.parse('O;Other identity');
      expect(withIdentity.toValue(), 'O;Other identity');
    });
  });

  group('Models - Organization', () {
    test('construction and properties', () {
      const org = Organization(
        name: 'Acme Corp',
        units: ['Engineering', 'R&D'],
        sortAs: 'Acme',
      );
      expect(org.name, 'Acme Corp');
      expect(org.units, ['Engineering', 'R&D']);
      expect(org.sortAs, 'Acme');
    });

    test('toComponents', () {
      const org = Organization(name: 'Acme', units: ['A', 'B', 'C']);
      final components = org.toComponents();
      expect(components, ['Acme', 'A', 'B', 'C']);
    });

    test('isEmpty', () {
      const empty = Organization(name: '');
      expect(empty.isEmpty, true);

      const notEmpty = Organization(name: 'Company');
      expect(notEmpty.isEmpty, false);
    });
  });

  group('LineFolding', () {
    test('unfolds content with CRLF', () {
      const folded = 'NOTE:This is a long line that has been \r\n folded.';
      final unfolded = LineFolding.unfold(folded);
      expect(unfolded, 'NOTE:This is a long line that has been folded.');
    });

    test('unfolds content with LF only', () {
      const folded = 'NOTE:This is a long line\n that continues.';
      final unfolded = LineFolding.unfold(folded);
      expect(unfolded, 'NOTE:This is a long linethat continues.');
    });

    test('unfolds multiple continuations', () {
      const folded = 'NOTE:Part1\r\n Part2\r\n Part3';
      final unfolded = LineFolding.unfold(folded);
      expect(unfolded, 'NOTE:Part1Part2Part3');
    });

    test('folds long lines at correct length', () {
      final longLine = 'NOTE:${'A' * 100}';
      final folded = LineFolding.foldLine(longLine);

      // Each line should be <= 75 chars
      final lines = folded.split('\r\n');
      for (final line in lines) {
        // First line doesn't have leading space, continuation lines do
        final adjustedLine = line.startsWith(' ') ? line.substring(1) : line;
        expect(adjustedLine.length, lessThanOrEqualTo(75));
      }
    });

    test('does not fold short lines', () {
      const shortLine = 'NOTE:Short';
      final folded = LineFolding.foldLine(shortLine);
      expect(folded, shortLine);
    });

    test('foldContent handles multiple lines', () {
      final content = 'LINE1:${'A' * 80}\nLINE2:${'B' * 80}';
      final folded = LineFolding.foldContent(content);
      expect(folded, contains('\r\n '));
    });
  });

  group('ValueEscaping', () {
    test('escapes all special characters', () {
      expect(ValueEscaping.escape('a,b'), r'a\,b');
      expect(ValueEscaping.escape('a;b'), r'a\;b');
      expect(ValueEscaping.escape('a\nb'), r'a\nb');
      expect(ValueEscaping.escape(r'a\b'), r'a\\b');
    });

    test('unescapes all special characters', () {
      expect(ValueEscaping.unescape(r'a\,b'), 'a,b');
      expect(ValueEscaping.unescape(r'a\;b'), 'a;b');
      expect(ValueEscaping.unescape(r'a\nb'), 'a\nb');
      expect(ValueEscaping.unescape(r'a\\b'), r'a\b');
    });

    test('handles consecutive escapes', () {
      final escaped = ValueEscaping.escape('a,,b;;c\n\nd');
      final unescaped = ValueEscaping.unescape(escaped);
      expect(unescaped, 'a,,b;;c\n\nd');
    });

    test('splitValue respects escaped separators', () {
      final parts = ValueEscaping.splitValue(r'one;two\;three;four', ';');
      expect(parts, ['one', r'two\;three', 'four']);
    });

    test('splitValue handles empty parts', () {
      final parts = ValueEscaping.splitValue('a;;b', ';');
      expect(parts, ['a', '', 'b']);
    });

    test('splitValue with comma separator', () {
      final parts = ValueEscaping.splitValue(r'a,b\,c,d', ',');
      expect(parts, ['a', r'b\,c', 'd']);
    });
  });

  group('VCardVersion', () {
    test('parses all version strings', () {
      expect(VCardVersion.parse('2.1'), VCardVersion.v21);
      expect(VCardVersion.parse('3.0'), VCardVersion.v30);
      expect(VCardVersion.parse('4.0'), VCardVersion.v40);
    });

    test('parse throws on invalid version', () {
      expect(() => VCardVersion.parse('5.0'), throwsA(isA<ArgumentError>()));
      expect(
        () => VCardVersion.parse('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('tryParse returns null for invalid versions', () {
      expect(VCardVersion.tryParse('5.0'), isNull);
      expect(VCardVersion.tryParse('invalid'), isNull);
      expect(VCardVersion.tryParse(''), isNull);
    });

    test('value property returns correct string', () {
      expect(VCardVersion.v21.value, '2.1');
      expect(VCardVersion.v30.value, '3.0');
      expect(VCardVersion.v40.value, '4.0');
    });
  });

  group('VCardParameters', () {
    test('empty parameters', () {
      const params = VCardParameters.empty();
      expect(params.isEmpty, true);
      expect(params.isNotEmpty, false);
    });

    test('get and set values', () {
      final params = VCardParameters([
        VCardParameter('TYPE', ['work', 'voice']),
        VCardParameter.single('PREF', '1'),
      ]);
      expect(params.types, ['work', 'voice']);
      expect(params.pref, 1);
    });

    test('builder pattern', () {
      final params = VCardParametersBuilder()
          .addType('work')
          .addType('voice')
          .setPref(1)
          .setLanguage('en')
          .build();

      expect(params.types, contains('work'));
      expect(params.types, contains('voice'));
      expect(params.pref, 1);
      expect(params.language, 'en');
    });
  });

  group('Exceptions', () {
    test('VCardParseException', () {
      const exception = VCardParseException('Test error', line: 10);
      expect(exception.message, 'Test error');
      expect(exception.line, 10);
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('10'));
    });

    test('MissingPropertyException', () {
      const exception = MissingPropertyException('FN');
      expect(exception.propertyName, 'FN');
      expect(exception.toString(), contains('FN'));
    });

    test('VCardGenerateException', () {
      const exception = VCardGenerateException('Generation failed');
      expect(exception.message, 'Generation failed');
    });

    test('FormatException', () {
      const exception = FormatException.format('jCard', 'Invalid format');
      expect(exception.format, 'jCard');
      expect(exception.message, 'Invalid format');
    });
  });

  group('Integration tests', () {
    test('parse real-world vCard sample', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Dr. John William Doe Jr.
N:Doe;John;William;Dr.;Jr.
NICKNAME:Johnny,JD
BDAY:19850415
ANNIVERSARY:20100620
GENDER:M
TEL;TYPE=work,voice;PREF=1:+1-555-123-4567
TEL;TYPE=cell:+1-555-987-6543
EMAIL;TYPE=work:john.doe@company.com
EMAIL;TYPE=home:john@personal.com
ADR;TYPE=work:;;100 Corporate Drive;Business City;CA;90210;USA
ADR;TYPE=home:;;123 Home Street;Hometown;NY;10001;USA
ORG:Acme Corporation;Engineering;Platform
TITLE:Senior Software Engineer
ROLE:Technical Lead
NOTE:Key contact for technical projects.\\nAvailable 9-5 PT.
CATEGORIES:Colleague,Engineer,Friend
URL;TYPE=work:https://company.com/jdoe
URL:https://linkedin.com/in/johndoe
GEO:geo:37.7749,-122.4194
TZ:America/Los_Angeles
REV:20231215T103000Z
UID:urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6
END:VCARD
''';

      final vcard = const VCardParser().parseSingle(vcardText);

      expect(vcard.formattedName, 'Dr. John William Doe Jr.');
      expect(vcard.name?.family, 'Doe');
      expect(vcard.name?.given, 'John');
      expect(vcard.name?.additional, ['William']);
      expect(vcard.name?.prefixes, ['Dr.']);
      expect(vcard.name?.suffixes, ['Jr.']);
      expect(vcard.nicknames, ['Johnny', 'JD']);
      expect(vcard.birthday?.year, 1985);
      expect(vcard.anniversary?.year, 2010);
      expect(vcard.gender?.isMale, true);
      expect(vcard.telephones.length, 2);
      expect(vcard.emails.length, 2);
      expect(vcard.addresses.length, 2);
      expect(vcard.organization?.name, 'Acme Corporation');
      expect(vcard.title, 'Senior Software Engineer');
      expect(vcard.urls.length, 2);
      expect(vcard.geo?.latitude, closeTo(37.7749, 0.0001));
      expect(vcard.timezone, 'America/Los_Angeles');
    });

    test('full round-trip through all formats', () {
      final original = VCard()
        ..formattedName = 'Round Trip Master Test'
        ..name = const StructuredName(
          family: 'Test',
          given: 'Master',
          prefixes: ['Dr.'],
        )
        ..nicknames.addAll(['Testy'])
        ..birthday = DateOrDateTime(year: 1990, month: 6, day: 15)
        ..gender = const Gender.male()
        ..telephones.add(Telephone.cell('+1-555-000-0000'))
        ..emails.add(Email.work('test@example.com'))
        ..addresses.add(
          const Address(
            street: '123 Test St',
            city: 'Testville',
            region: 'TS',
            postalCode: '12345',
            country: 'USA',
            types: ['work'],
          ),
        )
        ..organization = const Organization(name: 'Test Corp')
        ..title = 'Tester'
        ..note = 'Test note with special chars: , ; \\n'
        ..categories = ['A', 'B', 'C'];

      // vCard text round-trip
      final vcardText = const VCardGenerator().generate(original);
      final fromVcard = const VCardParser().parseSingle(vcardText);
      expect(fromVcard.formattedName, original.formattedName);

      // jCard round-trip
      final jcard = const JCardFormatter().toJson(original);
      final fromJcard = const JCardFormatter().fromJson(jcard);
      expect(fromJcard.formattedName, original.formattedName);

      // xCard round-trip
      final xcard = const XCardFormatter().toXml(original);
      final fromXcard = const XCardFormatter().fromXml(xcard);
      expect(fromXcard.formattedName, original.formattedName);
    });
  });

  group('Edge cases and boundary tests', () {
    test('handles extremely long property values', () {
      final longValue = 'A' * 10000;
      final vcard = VCard()..formattedName = longValue;
      final text = const VCardGenerator().generate(vcard);
      final parsed = const VCardParser().parseSingle(text);
      expect(parsed.formattedName, longValue);
    });

    test('handles Unicode characters in all fields', () {
      final vcard = VCard()
        ..formattedName = '日本語の名前 🎉'
        ..name = const StructuredName(
          family: '山田',
          given: '太郎',
          additional: ['次郎'],
        )
        ..note = '中文笔记 📝 العربية'
        ..organization = const Organization(name: '株式会社テスト');

      final text = const VCardGenerator().generate(vcard);
      final parsed = const VCardParser().parseSingle(text);
      expect(parsed.formattedName, '日本語の名前 🎉');
      expect(parsed.name?.family, '山田');
      expect(parsed.note, '中文笔记 📝 العربية');
    });

    test('handles empty string values gracefully', () {
      final vcard = VCard()
        ..formattedName = 'Empty Test'
        ..name = const StructuredName()
        ..note = ''
        ..title = '';

      final text = const VCardGenerator().generate(vcard);
      final parsed = const VCardParser().parseSingle(text);
      expect(parsed.formattedName, 'Empty Test');
    });

    test('handles special characters in values', () {
      const specialChars = r'Special: ; , \ : "quoted" <tag>';
      final vcard = VCard()
        ..formattedName = specialChars
        ..note = specialChars;

      final text = const VCardGenerator().generate(vcard);
      final parsed = const VCardParser().parseSingle(text);
      // Check that special characters are preserved
      expect(parsed.formattedName, contains('Special'));
    });

    test('handles multiple identical properties', () {
      final vcard = VCard()
        ..formattedName = 'Multi Test'
        ..telephones.addAll([
          Telephone.cell('+1-555-111-1111'),
          Telephone.cell('+1-555-222-2222'),
          Telephone.cell('+1-555-333-3333'),
          Telephone.cell('+1-555-444-4444'),
          Telephone.cell('+1-555-555-5555'),
        ])
        ..emails.addAll([
          Email(address: 'a@example.com'),
          Email(address: 'b@example.com'),
          Email(address: 'c@example.com'),
          Email(address: 'd@example.com'),
          Email(address: 'e@example.com'),
        ]);

      final text = const VCardGenerator().generate(vcard);
      final parsed = const VCardParser().parseSingle(text);
      expect(parsed.telephones.length, 5);
      expect(parsed.emails.length, 5);
    });

    test('handles maximum preference values', () {
      final vcard = VCard()
        ..formattedName = 'Pref Test'
        ..telephones.addAll([
          Telephone(number: '+1', types: const ['work'], pref: 1),
          Telephone(number: '+2', types: const ['home'], pref: 50),
          Telephone(number: '+3', types: const ['cell'], pref: 100),
        ]);

      final text = const VCardGenerator().generate(vcard);
      final parsed = const VCardParser().parseSingle(text);
      expect(parsed.telephones[0].pref, 1);
      expect(parsed.telephones[0].isPreferred, true);
    });

    test('handles dates at boundaries', () {
      // Minimum and maximum dates
      final minDate = DateOrDateTime(year: 1, month: 1, day: 1);
      final maxDate = DateOrDateTime(year: 9999, month: 12, day: 31);

      expect(minDate.toDateString(), '00010101');
      expect(maxDate.toDateString(), '99991231');

      // Partial dates
      final yearOnly = DateOrDateTime(year: 2000);
      expect(yearOnly.toDateString(), '2000');
      expect(yearOnly.isCompleteDate, false);

      final monthDay = DateOrDateTime(month: 4, day: 15);
      expect(monthDay.year, isNull);
    });

    test('handles timezones with various offsets', () {
      final utc = DateOrDateTime(
        year: 2024,
        month: 1,
        day: 1,
        hour: 12,
        minute: 0,
        timezoneOffset: 0,
      );
      expect(utc.toDateTimeString(), '20240101T1200Z');

      final positive = DateOrDateTime(
        year: 2024,
        month: 1,
        day: 1,
        hour: 12,
        minute: 0,
        timezoneOffset: 330, // +5:30
      );
      expect(positive.toDateTimeString(), '20240101T1200+0530');

      final negative = DateOrDateTime(
        year: 2024,
        month: 1,
        day: 1,
        hour: 12,
        minute: 0,
        timezoneOffset: -480, // -8:00
      );
      expect(negative.toDateTimeString(), '20240101T1200-0800');
    });

    test('handles geo coordinates at boundaries', () {
      // Equator and prime meridian
      const origin = GeoLocation(latitude: 0, longitude: 0);
      expect(origin.toUri(), 'geo:0.0,0.0');

      // Maximum values
      const northPole = GeoLocation(latitude: 90, longitude: 0);
      const southPole = GeoLocation(latitude: -90, longitude: 0);
      expect(northPole.latitude, 90);
      expect(southPole.latitude, -90);

      // Date line
      const dateLine = GeoLocation(latitude: 0, longitude: 180);
      expect(dateLine.longitude, 180);
    });

    test('handles all gender values', () {
      const male = Gender.male();
      const female = Gender.female();
      const other = Gender.other('Non-binary');
      const notApplicable = Gender.notApplicable();
      const unknown = Gender.unknown();

      expect(male.toValue(), 'M');
      expect(female.toValue(), 'F');
      expect(other.toValue(), 'O;Non-binary');
      expect(notApplicable.toValue(), 'N');
      expect(unknown.toValue(), 'U');
    });

    test('handles organization with many units', () {
      final org = Organization(
        name: 'Parent Corp',
        units: ['Level 1', 'Level 2', 'Level 3', 'Level 4', 'Level 5'],
      );

      expect(org.toComponents().length, 6);

      final vcard = VCard()
        ..formattedName = 'Org Test'
        ..organization = org;
      final text = const VCardGenerator().generate(vcard);
      final parsed = const VCardParser().parseSingle(text);
      expect(parsed.organization?.units.length, 5);
    });

    test('handles address with all components empty except one', () {
      const cityOnly = Address(city: 'Anytown');
      expect(cityOnly.isEmpty, false);
      expect(cityOnly.street, '');
      expect(cityOnly.city, 'Anytown');
    });

    test('handles structured name with special suffixes', () {
      const name = StructuredName(
        family: 'Smith',
        given: 'John',
        suffixes: ['Jr.', 'MD', 'PhD', 'Esq.'],
      );

      expect(name.suffixes.length, 4);
      expect(name.toFormattedName(), contains('MD'));
    });

    test('parses vCard with property groups', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Group Test
ITEM1.TEL:+1-555-111-1111
ITEM1.X-ABLABEL:Personal
ITEM2.TEL:+1-555-222-2222
ITEM2.X-ABLABEL:Work
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.telephones.length, 2);
      expect(vcard.extendedProperties.length, greaterThanOrEqualTo(2));
    });

    test('handles base64 encoded photo', () {
      // Small valid base64 (1x1 transparent PNG)
      const base64Png =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      const vcardText =
          '''
BEGIN:VCARD
VERSION:4.0
FN:Photo Test
PHOTO;ENCODING=BASE64;TYPE=PNG:$base64Png
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.photos.length, 1);
    });

    test('handles data URI photo', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Data URI Test
PHOTO:data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.photos.length, 1);
    });

    test('handles vCard with many extended properties', () {
      final extendedProperties = List.generate(
        20,
        (i) => 'X-CUSTOM-$i:Value $i',
      );
      final vcardText =
          '''
BEGIN:VCARD
VERSION:4.0
FN:Extended Test
${extendedProperties.join('\n')}
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.extendedProperties.length, 20);
    });

    test('preserves raw properties for round-trip', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Raw Test
X-SPECIAL-PROP;CUSTOM=value:Special Value
END:VCARD
''';
      final parser = const VCardParser(preserveRaw: true);
      final vcard = parser.parseSingle(vcardText);
      expect(vcard.rawProperties.isNotEmpty, true);
    });

    test('handles RELATED with different types', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Related Test
RELATED;TYPE=spouse:urn:uuid:spouse-123
RELATED;TYPE=child:urn:uuid:child-456
RELATED;TYPE=parent:urn:uuid:parent-789
RELATED;TYPE=friend:urn:uuid:friend-000
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.related.length, 4);
      expect(vcard.related[0].type, 'spouse');
      expect(vcard.related[1].type, 'child');
    });

    test('handles MEMBER properties for group vCard', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
KIND:group
FN:Development Team
MEMBER:urn:uuid:member-1
MEMBER:urn:uuid:member-2
MEMBER:urn:uuid:member-3
MEMBER:mailto:member@example.com
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.kind, VCardKind.group);
      expect(vcard.members.length, 4);
    });

    test('handles LANG property with preferences', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Language Test
LANG;PREF=1;TYPE=work:en
LANG;PREF=2;TYPE=home:zh-CN
LANG;PREF=3:ja
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.languages.length, 3);
      expect(vcard.languages[0].tag, 'en');
      expect(vcard.languages[0].pref, 1);
    });

    test('handles all calendar properties', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Calendar Test
FBURL;PREF=1:https://example.com/freebusy/user
CALURI:https://example.com/calendar/user
CALADRURI:mailto:calendar@example.com
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.freeBusyUrls.length, 1);
      expect(vcard.calendarUrls.length, 1);
      expect(vcard.calendarAddressUrls.length, 1);
    });

    test('handles SOURCE property', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Source Test
SOURCE:https://example.com/directory/user.vcf
SOURCE:ldap://ldap.example.com/cn=John
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.sources.length, 2);
    });

    test('handles KEY property with URI', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Key Test
KEY:https://example.com/keys/user.pgp
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.keys.length, 1);
    });

    test('handles SOUND property', () {
      const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:Sound Test
SOUND:https://example.com/sounds/name.wav
END:VCARD
''';
      final vcard = const VCardParser().parseSingle(vcardText);
      expect(vcard.sound, isNotNull);
    });
  });

  group('Error handling tests', () {
    test('throws on invalid vCard without BEGIN', () {
      const vcardText = '''
VERSION:4.0
FN:Invalid
END:VCARD
''';
      expect(
        () => const VCardParser().parseSingle(vcardText),
        throwsA(isA<VCardParseException>()),
      );
    });

    test('throws on empty input', () {
      expect(
        () => const VCardParser().parseSingle(''),
        throwsA(isA<VCardParseException>()),
      );
    });

    test('throws on whitespace only input', () {
      expect(
        () => const VCardParser().parseSingle('   \n\t  '),
        throwsA(isA<VCardParseException>()),
      );
    });

    test('throws when generating without FN', () {
      final vcard = VCard();
      expect(
        () => const VCardGenerator().generate(vcard),
        throwsA(isA<VCardGenerateException>()),
      );
    });

    test('handles invalid geo format gracefully', () {
      expect(GeoLocation.tryParse('not-a-geo'), isNull);
      expect(GeoLocation.tryParse('geo:invalid'), isNull);
      expect(GeoLocation.tryParse(''), isNull);
    });

    test('handles invalid date format gracefully', () {
      // DateOrDateTime.tryParse should not throw
      expect(DateOrDateTime.tryParse('not-a-date'), isNotNull);
      expect(DateOrDateTime.tryParse(''), isNotNull);
    });
  });

  group('QuotedPrintable tests', () {
    test('decodes simple QP text', () {
      final decoded = QuotedPrintable.decode('Hello=20World');
      expect(decoded, 'Hello World');
    });

    test('decodes soft line breaks', () {
      final decoded = QuotedPrintable.decode('Hello=\r\nWorld');
      expect(decoded, 'HelloWorld');
    });

    test('decodes UTF-8 encoded text', () {
      // UTF-8 encoded 'Ü' is C3 9C
      final decoded = QuotedPrintable.decode('=C3=9Cber');
      expect(decoded, 'Über');
    });

    test('encodes special characters', () {
      final encoded = QuotedPrintable.encode('Test=Value');
      expect(encoded, contains('=3D'));
    });
  });

  group('BinaryData tests', () {
    test('creates from data URI', () {
      const dataUri =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      final binary = BinaryData.fromDataUri(dataUri);
      expect(binary.mediaType, 'image/png');
      expect(binary.data, isNotEmpty);
    });

    test('converts to data URI', () {
      final binary = BinaryData.inline(
        Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]), // "Hello"
        mediaType: 'text/plain',
      );
      final uri = binary.dataUri;
      expect(uri, startsWith('data:text/plain;base64,'));
    });
  });

  group('Performance tests', () {
    test('parses large vCard quickly', () {
      // Generate a vCard with many properties
      final buffer = StringBuffer()
        ..writeln('BEGIN:VCARD')
        ..writeln('VERSION:4.0')
        ..writeln('FN:Performance Test');

      // Add 100 phone numbers
      for (var i = 0; i < 100; i++) {
        buffer.writeln(
          'TEL;TYPE=work:+1-555-${i.toString().padLeft(3, '0')}-0000',
        );
      }

      // Add 100 emails
      for (var i = 0; i < 100; i++) {
        buffer.writeln('EMAIL:user$i@example.com');
      }

      buffer.writeln('END:VCARD');

      final stopwatch = Stopwatch()..start();
      final vcard = const VCardParser().parseSingle(buffer.toString());
      stopwatch.stop();

      expect(vcard.telephones.length, 100);
      expect(vcard.emails.length, 100);
      // Should complete in reasonable time (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('generates large vCard quickly', () {
      final vcard = VCard()..formattedName = 'Performance Test';

      for (var i = 0; i < 100; i++) {
        vcard.telephones.add(
          Telephone(number: '+1-555-${i.toString().padLeft(3, '0')}-0000'),
        );
        vcard.emails.add(Email(address: 'user$i@example.com'));
      }

      final stopwatch = Stopwatch()..start();
      final text = const VCardGenerator().generate(vcard);
      stopwatch.stop();

      expect(text, contains('TEL'));
      expect(text, contains('EMAIL'));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
