# vcard_dart

<p align="center">
  <img src="vcard.svg" width="200" alt="vcard_dart logo">
</p>

<p align="center">
  <a href="README.md">English</a> | 简体中文
</p>

<p align="center">
  为 Dart/Flutter 提供的综合性 vCard 解析与生成库。
</p>

<p align="center">
  <a href="https://pub.dev/packages/vcard_dart">
    <img src="https://img.shields.io/pub/v/vcard_dart" alt="Pub Version">
  </a>
  <a href="https://pub.dev/packages/vcard_dart/score">
    <img src="https://img.shields.io/pub/points/vcard_dart" alt="Pub Points">
  </a>
  <a href="https://pub.dev/packages/vcard_dart/score">
    <img src="https://img.shields.io/pub/popularity/vcard_dart" alt="Pub Popularity">
  </a>
  <a href="https://pub.dev/packages/vcard_dart/score">
    <img src="https://img.shields.io/pub/likes/vcard_dart" alt="Pub Likes">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
  </a>
</p>

<p align="center">
  <a href="https://pub.dev/documentation/vcard_dart/latest/">📖 API 文档</a> |
  <a href="https://pub.dev/packages/vcard_dart">📦 pub.dev</a>
</p>

## 特性

- ✅ 完整支持 vCard 2.1、3.0 和 4.0（RFC 2426、RFC 6350）
- ✅ jCard（JSON）表示（RFC 7095）
- ✅ xCard（XML）表示（RFC 6351）
- ✅ 平台无关（Web、移动端、桌面端）
- ✅ 类型安全的 API，全面的验证
- ✅ 零依赖 - 纯 Dart 实现
- ✅ 广泛的测试覆盖

## 安装

添加到 `pubspec.yaml`：

```yaml
dependencies:
  vcard_dart: any
```

然后运行：

```bash
dart pub get
```

## 快速开始

```dart
import 'package:vcard_dart/vcard_dart.dart';

// 创建 vCard
final vcard = VCard()
  ..formattedName = '张三'
  ..name = const StructuredName(
    family: '张',
    given: '三',
  )
  ..emails.add(Email.work('zhangsan@example.com'))
  ..telephones.add(Telephone.cell('+86-138-0000-0000'))
  ..addresses.add(const Address(
    street: '中关村大街1号',
    city: '北京',
    region: '北京市',
    postalCode: '100000',
    country: '中国',
    types: ['work'],
  ));

// 生成 vCard 4.0 字符串
final generator = VCardGenerator();
final vcardString = generator.generate(vcard, version: VCardVersion.v40);

// 解析 vCard
final parser = VCardParser();
final parsed = parser.parseSingle(vcardString);
print(parsed.formattedName); // 张三
```

## 使用方法

### 创建 vCard

```dart
final vcard = VCard()
  // 必填项
  ..formattedName = '王五 博士'

  // 结构化姓名
  ..name = const StructuredName(
    family: '王',
    given: '五',
    additional: ['建国'],
    prefixes: ['博士'],
    suffixes: ['工程师'],
  )

  // 通讯方式
  ..telephones.addAll([
    Telephone.cell('+86-138-0000-0000'),
    Telephone.work('+86-010-8888-8888'),
  ])
  ..emails.addAll([
    Email.work('wangwu@company.com'),
    Email.home('wangwu@personal.com'),
  ])

  // 组织信息
  ..organization = const Organization(
    name: '科技股份公司',
    units: ['研发部', '技术组'],
  )
  ..title = '高级工程师'
  ..role = '技术负责人'

  // 地址
  ..addresses.add(const Address(
    street: '科技园区路456号',
    city: '深圳市',
    region: '广东省',
    postalCode: '518000',
    country: '中国',
    types: ['work'],
  ))

  // 附加信息
  ..birthday = DateOrDateTime(year: 1985, month: 4, day: 15)
  ..note = '项目负责人'
  ..urls.add(WebUrl.work('https://company.com/wangwu'))
  ..categories = ['同事', '技术', 'VIP'];
```

### 解析 vCard

```dart
final parser = VCardParser();

// 解析单个 vCard
const vcardText = '''
BEGIN:VCARD
VERSION:4.0
FN:张三
N:张;三;;;
TEL;TYPE=CELL:+86-138-0000-0000
EMAIL:zhangsan@example.com
END:VCARD
''';

final vcard = parser.parseSingle(vcardText);
print(vcard.formattedName); // 张三
print(vcard.telephones.first.number); // +86-138-0000-0000

// 解析多个 vCard
const multipleVcards = '''
BEGIN:VCARD
VERSION:4.0
FN:人员一
END:VCARD
BEGIN:VCARD
VERSION:4.0
FN:人员二
END:VCARD
''';

final vcards = parser.parse(multipleVcards);
print(vcards.length); // 2

// 宽松解析模式（容忍某些错误）
final lenientParser = VCardParser(lenient: true);
final recovered = lenientParser.parse(malformedVcardText);
```

### 生成 vCard

```dart
final generator = VCardGenerator();

// 生成 vCard 4.0（默认）
final v40 = generator.generate(vcard);

// 生成 vCard 3.0
final v30 = generator.generate(vcard, version: VCardVersion.v30);

// 生成 vCard 2.1
final v21 = generator.generate(vcard, version: VCardVersion.v21);

// 生成多个 vCard
final multipleVcards = generator.generateAll([vcard1, vcard2]);
```

### jCard（JSON 格式）

```dart
final formatter = JCardFormatter();

// 转换为 jCard
final json = formatter.toJson(vcard);
final jsonString = formatter.toJsonString(vcard);

// 从 jCard 解析
final fromJson = formatter.fromJson(json);
final fromString = formatter.fromJsonString(jsonString);
```

### xCard（XML 格式）

```dart
final formatter = XCardFormatter();

// 转换为 xCard
final xml = formatter.toXml(vcard);
final prettyXml = formatter.toXml(vcard, pretty: true);

// 从 xCard 解析
final fromXml = formatter.fromXml(xmlString);
```

## 支持的属性

### 基础属性
| 属性 | vCard 2.1 | vCard 3.0 | vCard 4.0 | 描述 |
|----------|-----------|-----------|-----------|-------------|
| FN | ✅ | ✅ | ✅ | 格式化姓名（必填） |
| N | ✅ | ✅ | ✅ | 结构化姓名 |
| NICKNAME | ❌ | ✅ | ✅ | 昵称 |
| PHOTO | ✅ | ✅ | ✅ | 照片 |
| BDAY | ✅ | ✅ | ✅ | 生日 |
| ANNIVERSARY | ❌ | ❌ | ✅ | 纪念日 |
| GENDER | ❌ | ❌ | ✅ | 性别 |

### 通讯方式
| 属性 | vCard 2.1 | vCard 3.0 | vCard 4.0 | 描述 |
|----------|-----------|-----------|-----------|-------------|
| TEL | ✅ | ✅ | ✅ | 电话号码 |
| EMAIL | ✅ | ✅ | ✅ | 邮箱地址 |
| IMPP | ❌ | ✅ | ✅ | 即时通讯 |
| LANG | ❌ | ❌ | ✅ | 语言偏好 |

### 地址/位置
| 属性 | vCard 2.1 | vCard 3.0 | vCard 4.0 | 描述 |
|----------|-----------|-----------|-----------|-------------|
| ADR | ✅ | ✅ | ✅ | 邮政地址 |
| LABEL | ✅ | ✅ | ❌ | 地址标签 |
| GEO | ✅ | ✅ | ✅ | 地理位置 |
| TZ | ✅ | ✅ | ✅ | 时区 |

### 组织
| 属性 | vCard 2.1 | vCard 3.0 | vCard 4.0 | 描述 |
|----------|-----------|-----------|-----------|-------------|
| ORG | ✅ | ✅ | ✅ | 组织名称 |
| TITLE | ✅ | ✅ | ✅ | 职位 |
| ROLE | ✅ | ✅ | ✅ | 角色 |
| LOGO | ✅ | ✅ | ✅ | 组织徽标 |
| MEMBER | ❌ | ❌ | ✅ | 群组成员 |
| RELATED | ❌ | ❌ | ✅ | 相关人员 |

### 其他
| 属性 | vCard 2.1 | vCard 3.0 | vCard 4.0 | 描述 |
|----------|-----------|-----------|-----------|-------------|
| NOTE | ✅ | ✅ | ✅ | 备注 |
| PRODID | ❌ | ✅ | ✅ | 产品 ID |
| REV | ✅ | ✅ | ✅ | 修订时间 |
| SOUND | ✅ | ✅ | ✅ | 语音 |
| UID | ✅ | ✅ | ✅ | 唯一标识符 |
| URL | ✅ | ✅ | ✅ | 网站 |
| VERSION | ✅ | ✅ | ✅ | 版本（必填） |
| KEY | ✅ | ✅ | ✅ | 公钥 |
| CATEGORIES | ❌ | ✅ | ✅ | 分类 |
| SOURCE | ❌ | ✅ | ✅ | 源目录 |
| KIND | ❌ | ❌ | ✅ | 类型（个人/组织/群组/地点） |

## 错误处理

本库提供详细的异常类型：

```dart
try {
  final vcard = parser.parseSingle(invalidText);
} on VCardParseException catch (e) {
  print('解析错误: ${e.message}');
  print('行号: ${e.line}');
} on MissingPropertyException catch (e) {
  print('缺少必填属性: ${e.propertyName}');
} on UnsupportedVersionException catch (e) {
  print('版本错误: ${e.message}');
}
```

## RFC 规范遵循

本库实现以下 RFC 规范：

- [RFC 2425](https://www.rfc-editor.org/rfc/rfc2425.html) - MIME 内容类型目录信息
- [RFC 2426](https://www.rfc-editor.org/rfc/rfc2426.html) - vCard 3.0
- [RFC 6350](https://datatracker.ietf.org/doc/html/rfc6350) - vCard 4.0
- [RFC 6351](https://datatracker.ietf.org/doc/html/rfc6351) - xCard XML 表示
- [RFC 7095](https://www.rfc-editor.org/rfc/rfc7095.html) - jCard JSON 格式
- [vCard 2.1](https://github.com/emacsmirror/addressbook/blob/master/vcard-21.txt) - 传统格式

## 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)。

## 贡献

欢迎贡献！请先阅读[贡献指南](CONTRIBUTING.md)。

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/amazing-feature`
3. 提交更改
4. 运行测试：`dart test`
5. 运行分析：`dart analyze`
6. 格式化代码：`dart format .`
7. 提交：`git commit -m 'feat: add amazing feature'`
8. 推送：`git push origin feature/amazing-feature`
9. 创建 Pull Request
