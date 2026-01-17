# vCard 2.1 - The Electronic Business Card Specification

> **Status**: Industry Standard (Non-RFC, Legacy)  
> **Authors**: versit Consortium (IBM, Lucent, Siemens)  
> **Date**: September 18, 1996  
> **MIME Type**: `text/x-vCard` (non-standard)

---

## 1. Overview

vCard 2.1 is the original electronic business card specification developed by the versit Consortium. While not an official RFC, it became widely adopted and forms the basis for later RFC standards.

### Key Characteristics

- **Text-based format** (similar to MIME)
- **Property-value pairs** separated by colon
- **Multiple encoding options** (7BIT, QUOTED-PRINTABLE, BASE64)
- **Extensible** via X- properties
- **ISO 8601** date/time format

---

## 2. Basic Structure

### vCard Object

```
BEGIN:VCARD
VERSION:2.1
[properties]
END:VCARD
```

### Property Syntax

```
[group.]name[;param=value[;param=value]...]:value
```

### Example

```
BEGIN:VCARD
VERSION:2.1
N:Doe;John;M.;Mr.;Jr.
FN:Mr. John M. Doe Jr.
TEL;WORK;VOICE:+1-555-1234
EMAIL;INTERNET:john@example.com
END:VCARD
```

---

## 3. Delimiters

| Character | ASCII | Purpose |
|-----------|-------|---------|
| `;` | 59 | Field delimiter (component separator) |
| `:` | 58 | Property name/value separator |
| `.` | 46 | Group/property name separator |

---

## 4. Character Sets and Encoding

### Default Character Set

- **US-ASCII** (7-bit)
- Can specify other charsets with CHARSET parameter

### Encoding Types

| Encoding | Description | Use Case |
|----------|-------------|----------|
| 7BIT | Default, ASCII | Plain text |
| 8BIT | 8-bit characters | Extended ASCII |
| QUOTED-PRINTABLE | RFC 1521 QP encoding | Non-ASCII text |
| BASE64 | RFC 1521 Base64 | Binary data |

### Encoding Parameter

```
PHOTO;ENCODING=BASE64;TYPE=JPEG:
 /9j/4AAQSkZJRgABAQAAAQABAAD...

NOTE;ENCODING=QUOTED-PRINTABLE:Line 1=0D=0ALine 2

LABEL;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:=E4=B8=AD=E6=96=87
```

---

## 5. Line Folding

### Folding Rules

- Long lines SHOULD be folded
- Fold by inserting **CRLF + SPACE/TAB**
- Continuation indicated by leading whitespace

### Example

```
PHOTO;ENCODING=BASE64;TYPE=GIF:
 R0lGODdhfgA4AOYAAAAAAK+vr62trVIxa6WlpZ+fnzEpCEpzlAha/0Kc74+P
 jyGMSuecKRhrtX9/fzExORBSjCEYCGtra2NjYyF7nDGE50JrhAg51qWtOTl7
 vee1MWu150o5e3PO/3sxcwAx/4R7GBgQOcDAwFoAQt61hJyMGHuUSpRKIf8A
```

---

## 6. Grouping

### Property Grouping

Group related properties with prefix:

```
home.TEL;VOICE:+1-555-1234
home.TEL;FAX:+1-555-5678
home.LABEL:123 Main St...
```

### vCard Grouping (Nested vCards)

```
BEGIN:VCARD
VERSION:2.1
FN:Distribution List
X-DL;Design Work Group:Item1;Item2;Item3
BEGIN:VCARD
UID:Item1
N:Smith;John
END:VCARD
BEGIN:VCARD
UID:Item2
N:Doe;Jane
END:VCARD
END:VCARD
```

---

## 7. Identification Properties

### N (Structured Name)

**Required**. Components: Family; Given; Middle; Prefix; Suffix

```
N:Doe;John;Quincy;Mr.;Jr.,Esq.
```

### FN (Formatted Name)

**Required**. Display name as single string.

```
FN:Mr. John Quincy Doe Jr., Esq.
```

### PHOTO (Photograph)

```
PHOTO;VALUE=URL:file:///photos/john.gif
PHOTO;ENCODING=BASE64;TYPE=GIF:R0lGODdh...
```

**Type Values**: GIF, CGM, WMF, BMP, MET, PMB, DIB, PICT, TIFF, PDF, PS, JPEG, MPEG, MPEG2, AVI, QTIME

### BDAY (Birthday)

ISO 8601 format:

```
BDAY:1985-04-15
BDAY:19850415
```

### LOGO (Organization Logo)

Same format as PHOTO:

```
LOGO;VALUE=URL:http://example.com/logo.gif
LOGO;ENCODING=BASE64;TYPE=JPEG:...
```

---

## 8. Delivery Address Properties

### ADR (Structured Address)

Components: PO Box; Extended; Street; City; Region; Postal Code; Country

```
ADR;DOM;HOME:P.O. Box 101;Suite 101;123 Main St;Any Town;CA;91921-1234;USA
```

**Type Parameters**:

| Type | Description | Default |
|------|-------------|---------|
| DOM | Domestic | No |
| INTL | International | Yes |
| POSTAL | Postal delivery | Yes |
| PARCEL | Parcel delivery | Yes |
| HOME | Home address | No |
| WORK | Work address | Yes |

### LABEL (Delivery Label)

Formatted address for printing:

```
LABEL;DOM;POSTAL;ENCODING=QUOTED-PRINTABLE:P.O. Box 456=0D=0A=
123 Main Street=0D=0A=
Any Town, CA 91921-1234
```

---

## 9. Telecommunications Properties

### TEL (Telephone Number)

```
TEL;PREF;WORK;VOICE;MSG:+1-800-555-1234
TEL;HOME;FAX:+1-555-5678
```

**Type Parameters**:

| Type | Description |
|------|-------------|
| PREF | Preferred number |
| WORK | Work number |
| HOME | Home number |
| VOICE | Voice (default) |
| FAX | Facsimile |
| MSG | Messaging service |
| CELL | Cellular |
| PAGER | Pager |
| BBS | Bulletin board |
| MODEM | Modem |
| CAR | Car phone |
| ISDN | ISDN |
| VIDEO | Video phone |

### EMAIL (Electronic Mail)

```
EMAIL;INTERNET:john@example.com
EMAIL;AOL:johndoe
EMAIL;COMPUSERVE:71234,5678
```

**Type Parameters**:

| Type | Description |
|------|-------------|
| AOL | America Online |
| AppleLink | AppleLink |
| ATTMail | AT&T Mail |
| CIS | CompuServe |
| eWorld | eWorld |
| INTERNET | Internet SMTP (default) |
| IBMMail | IBM Mail |
| MCIMail | MCI Mail |
| POWERSHARE | PowerShare |
| PRODIGY | Prodigy |
| TLX | Telex |
| X400 | X.400 |

### MAILER

Email client software:

```
MAILER:ccMail 2.2
```

---

## 10. Geographical Properties

### TZ (Time Zone)

UTC offset in ISO 8601 format:

```
TZ:-05:00
TZ:+0530
```

### GEO (Geographic Position)

Latitude and longitude (decimal degrees):

```
GEO:37.386013;-122.082932
```

---

## 11. Organizational Properties

### TITLE (Job Title)

```
TITLE:Senior Software Engineer
```

### ROLE (Business Role)

```
ROLE:Project Manager
```

### ORG (Organization)

Components: Organization Name; Unit1; Unit2; ...

```
ORG:ABC Inc.;North American Division;Marketing
```

### AGENT (Assistant/Secretary)

Nested vCard for agent:

```
AGENT:
BEGIN:VCARD
VERSION:2.1
N:Friday;Fred
TEL;WORK;VOICE:+1-213-555-1234
END:VCARD
```

---

## 12. Explanatory Properties

### NOTE (Comment)

```
NOTE;ENCODING=QUOTED-PRINTABLE:This fax machine is operational=0D=0A=
0830 to 1715 hours Monday through Friday.
```

### REV (Last Revision)

ISO 8601 timestamp:

```
REV:19951031T222710
REV:1995-10-31T22:27:10Z
```

### SOUND (Pronunciation)

```
SOUND:JON Q PUBLIK
SOUND;VALUE=URL:file:///audio/name.wav
SOUND;WAVE;BASE64:UklGRhAsAABXQVZFZm10IBAAAAAB...
```

**Type Values**: WAVE, PCM, AIFF

### URL (Web Address)

```
URL:http://www.example.com/~jqpublic
```

### UID (Unique Identifier)

```
UID:19950401-080045-40000F192713-0052
```

### VERSION (Version)

**Required**. Must be "2.1":

```
VERSION:2.1
```

---

## 13. Security Properties

### KEY (Public Key)

```
KEY;X509;ENCODING=BASE64:MIICajCCAdOgAwIBAgICBEUwDQYJ...
KEY;PGP;ENCODING=BASE64:mQGiBD...
```

**Type Values**: X509, PGP

---

## 14. Extensions (X- Properties)

Custom properties with X- prefix:

```
X-ABC-VIDEO;MPEG2:http://example.com/video.mpg
X-CUSTOM-FIELD:custom value
```

**Vendor Recommendation**: Include vendor identifier after X-:
- `X-ABC-PROPERTY` (ABC vendor)
- `X-MS-PROPERTY` (Microsoft)

---

## 15. Formal BNF Grammar (Excerpt)

```bnf
vcard_file    = [wsls] vcard [wsls]
vcard         = "BEGIN:VCARD" [CRLF] items "END:VCARD"
items         = item / items item
item          = [groups "."] name *(";" param) ":" value CRLF
groups        = group / groups "." group
group         = word
name          = "FN" / "N" / "PHOTO" / ... / x-name
param         = param-name "=" param-value
value         = *VCHAR
x-name        = "X-" word

CR            = <ASCII 13>
LF            = <ASCII 10>
CRLF          = CR LF
SPACE         = <ASCII 32>
HTAB          = <ASCII 9>
ws            = 1*(SPACE / HTAB)
wsls          = 1*(SPACE / HTAB / CRLF)
word          = <any printable 7bit US-ASCII except []=:.,>
```

---

## 16. Differences from vCard 3.0/4.0

| Feature | vCard 2.1 | vCard 3.0+ |
|---------|-----------|------------|
| VERSION value | 2.1 | 3.0 / 4.0 |
| ENCODING values | BASE64, QUOTED-PRINTABLE | b, B |
| Type syntax | No TYPE= prefix needed | TYPE=value |
| LABEL property | Separate property | Parameter on ADR |
| CHARSET parameter | Yes | Removed (UTF-8 default) |
| URL value type | VALUE=URL | VALUE=uri |
| AGENT property | Inline vCard | Removed in 4.0 |
| PROFILE property | No | Yes (3.0) / No (4.0) |
| Line folding | CRLF + whitespace | Same |

---

## 17. Complete Example

```
BEGIN:VCARD
VERSION:2.1
N:Smith;John;M.;Mr.;Esq.
FN:Mr. John M. Smith, Esq.
TITLE:Senior Vice President
ORG:ABC Corporation;Executive Division
TEL;WORK;VOICE;MSG:+1 (919) 555-1234
TEL;WORK;FAX:+1 (919) 555-9876
TEL;CELL:+1 (919) 555-4321
ADR;WORK;PARCEL;POSTAL;DOM:Suite 101;1 Central St.;Any Town;NC;27654
ADR;HOME:;;123 Main St.;Hometown;NC;27601
LABEL;WORK;ENCODING=QUOTED-PRINTABLE:Suite 101=0D=0A=
1 Central St.=0D=0A=
Any Town, NC 27654
EMAIL;PREF;INTERNET:john.smith@abc.com
EMAIL;INTERNET:jsmith@home.net
URL:http://www.abc.com/~jsmith
GEO:35.7796;-78.6382
TZ:-05:00
BDAY:1960-05-15
PHOTO;ENCODING=BASE64;TYPE=JPEG:
 /9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkS
 Ew8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/...
NOTE;ENCODING=QUOTED-PRINTABLE:John joined ABC Corp in 1990.=0D=0A=
He leads the strategic planning team.
REV:1996-09-18T14:30:00Z
UID:19960918-143000-ABC-JSMITH
END:VCARD
```

---

## 18. Conformance Requirements

### vCard Writer MUST

- Include VERSION property (value "2.1")
- Support Formatted Name (FN) property
- Support Name (N) property
- Support Address (ADR) property
- Support Telephone (TEL) property
- Support Email (EMAIL) property
- Support Mailer (MAILER) property

### vCard Reader MUST

- Parse BEGIN:VCARD and END:VCARD
- Handle all property/value types
- Process grouping constructs
- Support QUOTED-PRINTABLE and BASE64 encodings

---

## 19. Key Implementation Notes

1. **VERSION is mandatory** and must appear in vCard
2. **ENCODING parameter** differs from vCard 3.0+ (BASE64 vs b)
3. **Type parameters** can omit TYPE= prefix
4. **CHARSET parameter** supported (not in 3.0+)
5. **Line folding** uses CRLF + whitespace continuation
6. **LABEL is separate property** (becomes parameter in 4.0)
7. **AGENT embeds full vCard** (removed in 4.0)
8. **Case insensitive** property and parameter names
9. **X- extensions** supported for custom properties
10. **Semicolon** separates structured value components
