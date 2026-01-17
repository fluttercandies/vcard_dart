# vcard_dart RFC Standards Documentation

This directory contains RFC specification summary documents for the vcard_dart library.

## Document Index

### Core vCard Standards

| Document | Standard | Description |
|----------|----------|-------------|
| [RFC-6350.md](./RFC-6350.md) | RFC 6350 | vCard 4.0 - Current Standard, Full Property and Syntax Definitions |
| [RFC-2426.md](./RFC-2426.md) | RFC 2426 | vCard 3.0 - MIME Directory Profile |
| [VCARD-21.md](./VCARD-21.md) | vCard 2.1 | Legacy Specification - versit Consortium Standard |

### Foundation Framework

| Document | Standard | Description |
|----------|----------|-------------|
| [RFC-2425.md](./RFC-2425.md) | RFC 2425 | MIME Content-Type - Directory Information Base Framework |

### Alternative Representation Formats

| Document | Standard | Description |
|----------|----------|-------------|
| [RFC-7095.md](./RFC-7095.md) | RFC 7095 | jCard - JSON Representation of vCard |
| [RFC-6351.md](./RFC-6351.md) | RFC 6351 | xCard - XML Representation of vCard |

### Extension Specifications

| Document | Standard | Description |
|----------|----------|-------------|
| [RFC-2739.md](./RFC-2739.md) | RFC 2739 | Calendar Attributes - FBURL, CALURI, CALADRURI |
| [RFC-4770.md](./RFC-4770.md) | RFC 4770 | IMPP - Instant Messaging Extension |

---

## Standards Relationship

```
+------------------------------------------------------------------+
|                        vcard_dart Library                         |
+------------------------------------------------------------------+
|                                                                   |
|  +-------------------------------------------------------------+  |
|  |                    Core Parsing/Generation                   |  |
|  |  +-----------+  +-----------+  +-----------+                |  |
|  |  | vCard 2.1 |  | vCard 3.0 |  | vCard 4.0 |                |  |
|  |  |  (Legacy) |  | RFC 2426  |  | RFC 6350  |                |  |
|  |  +-----------+  +-----------+  +-----------+                |  |
|  |        |              |              |                       |  |
|  |        +--------------+--------------+                       |  |
|  |                       |                                      |  |
|  |                       v                                      |  |
|  |              +------------------+                            |  |
|  |              |   VCard Object   |                            |  |
|  |              +------------------+                            |  |
|  |                       |                                      |  |
|  |        +--------------+--------------+                       |  |
|  |        |              |              |                       |  |
|  |        v              v              v                       |  |
|  |  +-----------+  +-----------+  +-----------+                |  |
|  |  |   jCard   |  |   xCard   |  |  Calendar |                |  |
|  |  | RFC 7095  |  | RFC 6351  |  | RFC 2739  |                |  |
|  |  +-----------+  +-----------+  +-----------+                |  |
|  +-------------------------------------------------------------+  |
|                                                                   |
+------------------------------------------------------------------+
```

## Compliance Status

The vcard_dart library is **fully compliant** with all supported RFC standards:

| Standard | Version | Status |
|----------|---------|--------|
| RFC 6350 | vCard 4.0 | ✅ Fully Compliant |
| RFC 2426 | vCard 3.0 | ✅ Fully Compliant |
| vCard 2.1 | Legacy | ✅ Fully Compliant |
| RFC 7095 | jCard | ✅ Fully Compliant |
| RFC 6351 | xCard | ✅ Fully Compliant |
| RFC 2739 | Calendar | ✅ Fully Compliant |
| RFC 4770 | IMPP | ✅ Fully Compliant |
| RFC 2425 | MIME | ✅ Fully Compliant |

### Compliance Indicators

| Indicator | Meaning |
|-----------|---------|
| ✅ | Fully Supported - Fully compliant with standard requirements |
| ⚠️ | Partially Supported - Core functionality supported with limitations |
| ❌ | Not Supported - Not implemented in current version |

## Version Information

- **Library Version**: 2.0.0
- **Dart SDK**: >=3.10.4
- **Test Coverage**: 145/145 tests passing
- **Last Updated**: 2024-12

## Reference Resources

### RFC Document Links

- [RFC 6350 - vCard 4.0](https://www.rfc-editor.org/rfc/rfc6350.html)
- [RFC 2426 - vCard 3.0](https://www.rfc-editor.org/rfc/rfc2426.html)
- [RFC 7095 - jCard](https://www.rfc-editor.org/rfc/rfc7095.html)
- [RFC 6351 - xCard](https://www.rfc-editor.org/rfc/rfc6351.html)
- [RFC 2739 - Calendar Attributes](https://www.rfc-editor.org/rfc/rfc2739.html)
- [RFC 2425 - MIME Content-Type](https://www.rfc-editor.org/rfc/rfc2425.html) (Obsoleted by RFC 6350)
- [RFC 4770 - IMPP](https://www.rfc-editor.org/rfc/rfc4770.html) (Obsoleted by RFC 6350)

### Other Resources

- [vCard 2.1 Specification](http://www.imc.org/pdi/vcard-21.txt)
- [IANA vCard Registry](https://www.iana.org/assignments/vcard-elements/vcard-elements.xhtml)
