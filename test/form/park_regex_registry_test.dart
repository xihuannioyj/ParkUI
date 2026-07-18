import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  group('ParkRegexRegistry', () {
    // -----------------------------------------------------------------------
    // Built-in regex tags
    // -----------------------------------------------------------------------

    group('built-in tags', () {
      test('has all expected built-in tags', () {
        final expectedTags = [
          'mobile',
          'email',
          'id_card',
          'cn_name',
          'url',
          'ipv4',
          'postal_code',
          'bank_card',
          'username',
          'password',
          'number',
          'integer',
          'positive_int',
          'amount',
          'date',
          'time',
          'chinese',
          'qq',
          'wechat',
          'plate_number',
          'unified_credit_code',
        ];
        for (final tag in expectedTags) {
          expect(ParkRegexRegistry.has(tag), isTrue,
              reason: 'Expected built-in tag "$tag" to exist');
        }
      });

      test('get returns non-null pattern for built-in tags', () {
        for (final tag in ParkRegexRegistry.allTags) {
          expect(ParkRegexRegistry.get(tag), isNotNull,
              reason: 'Pattern for "$tag" should not be null');
          expect(ParkRegexRegistry.get(tag), isNotEmpty,
              reason: 'Pattern for "$tag" should not be empty');
        }
      });

      test('getDescription returns non-null for built-in tags', () {
        for (final tag in ParkRegexRegistry.allTags) {
          expect(ParkRegexRegistry.getDescription(tag), isNotNull,
              reason: 'Description for "$tag" should not be null');
        }
      });
    });

    // -----------------------------------------------------------------------
    // Mobile regex
    // -----------------------------------------------------------------------

    group('mobile regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('mobile')!);
      });

      test('matches valid mobile numbers', () {
        expect(pattern.hasMatch('13800138000'), isTrue);
        expect(pattern.hasMatch('15912345678'), isTrue);
        expect(pattern.hasMatch('18600000000'), isTrue);
        expect(pattern.hasMatch('19900001111'), isTrue);
      });

      test('rejects invalid mobile numbers', () {
        expect(pattern.hasMatch('12345678901'), isFalse);
        expect(pattern.hasMatch('1380013800'), isFalse); // too short
        expect(pattern.hasMatch('138001380001'), isFalse); // too long
        expect(pattern.hasMatch('23800138000'), isFalse); // wrong prefix
        expect(pattern.hasMatch('abcdefghijk'), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Email regex
    // -----------------------------------------------------------------------

    group('email regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('email')!);
      });

      test('matches valid emails', () {
        expect(pattern.hasMatch('test@example.com'), isTrue);
        expect(pattern.hasMatch('user.name@domain.co'), isTrue);
        expect(pattern.hasMatch('a+b@c.com'), isTrue);
      });

      test('rejects invalid emails', () {
        expect(pattern.hasMatch('notanemail'), isFalse);
        expect(pattern.hasMatch('@domain.com'), isFalse);
        expect(pattern.hasMatch('user@'), isFalse);
        expect(pattern.hasMatch('user@domain'), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // URL regex
    // -----------------------------------------------------------------------

    group('url regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('url')!);
      });

      test('matches valid URLs', () {
        expect(pattern.hasMatch('http://example.com'), isTrue);
        expect(pattern.hasMatch('https://www.google.com'), isTrue);
        expect(pattern.hasMatch('https://sub.domain.com/path?q=1'), isTrue);
      });

      test('rejects invalid URLs', () {
        expect(pattern.hasMatch('ftp://example.com'), isFalse);
        expect(pattern.hasMatch('example.com'), isFalse);
        expect(pattern.hasMatch(''), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // ID card regex
    // -----------------------------------------------------------------------

    group('id_card regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('id_card')!);
      });

      test('matches valid 18-digit ID cards', () {
        expect(pattern.hasMatch('110101199003070912'), isTrue);
        expect(pattern.hasMatch('44030119900101123X'), isTrue);
      });

      test('rejects invalid ID cards', () {
        expect(pattern.hasMatch('11010119900307091'), isFalse); // too short
        expect(pattern.hasMatch('110101199013070912'), isFalse); // invalid month
        expect(pattern.hasMatch('abcdefghijklmnopqr'), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Chinese name regex
    // -----------------------------------------------------------------------

    group('cn_name regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('cn_name')!);
      });

      test('matches valid Chinese names', () {
        expect(pattern.hasMatch('张三'), isTrue);
        expect(pattern.hasMatch('欧阳修文'), isTrue);
      });

      test('rejects invalid names', () {
        expect(pattern.hasMatch('A'), isFalse);
        expect(pattern.hasMatch('张'), isFalse); // too short
        expect(pattern.hasMatch('abc'), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // IPv4 regex
    // -----------------------------------------------------------------------

    group('ipv4 regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('ipv4')!);
      });

      test('matches valid IPv4 addresses', () {
        expect(pattern.hasMatch('192.168.1.1'), isTrue);
        expect(pattern.hasMatch('0.0.0.0'), isTrue);
        expect(pattern.hasMatch('255.255.255.255'), isTrue);
      });

      test('rejects invalid IPv4 addresses', () {
        expect(pattern.hasMatch('256.1.1.1'), isFalse);
        expect(pattern.hasMatch('192.168.1'), isFalse);
        expect(pattern.hasMatch('abc.def.ghi.jkl'), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Postal code regex
    // -----------------------------------------------------------------------

    group('postal_code regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('postal_code')!);
      });

      test('matches valid postal codes', () {
        expect(pattern.hasMatch('100000'), isTrue);
        expect(pattern.hasMatch('518000'), isTrue);
      });

      test('rejects invalid postal codes', () {
        expect(pattern.hasMatch('012345'), isFalse);
        expect(pattern.hasMatch('12345'), isFalse);
        expect(pattern.hasMatch('1234567'), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Username regex
    // -----------------------------------------------------------------------

    group('username regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('username')!);
      });

      test('matches valid usernames', () {
        expect(pattern.hasMatch('abcdef'), isTrue);
        expect(pattern.hasMatch('User_123'), isTrue);
        expect(pattern.hasMatch('a123456789012345678'), isTrue);
      });

      test('rejects invalid usernames', () {
        expect(pattern.hasMatch('1abcde'), isFalse); // starts with digit
        expect(pattern.hasMatch('abc'), isFalse); // too short
        expect(pattern.hasMatch('_abcdef'), isFalse); // starts with underscore
      });
    });

    // -----------------------------------------------------------------------
    // Password regex
    // -----------------------------------------------------------------------

    group('password regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('password')!);
      });

      test('matches valid passwords', () {
        expect(pattern.hasMatch('Abcdef1g'), isTrue);
        expect(pattern.hasMatch('MyP@ssw0rd'), isTrue);
      });

      test('rejects weak passwords', () {
        expect(pattern.hasMatch('abcdef1g'), isFalse); // no uppercase
        expect(pattern.hasMatch('ABCDEF1G'), isFalse); // no lowercase
        expect(pattern.hasMatch('Abcdefgh'), isFalse); // no digit
        expect(pattern.hasMatch('Ab1'), isFalse); // too short
      });
    });

    // -----------------------------------------------------------------------
    // Number / Integer / Positive int
    // -----------------------------------------------------------------------

    group('number regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('number')!);
      });

      test('matches valid numbers', () {
        expect(pattern.hasMatch('123'), isTrue);
        expect(pattern.hasMatch('-456'), isTrue);
        expect(pattern.hasMatch('3.14'), isTrue);
        expect(pattern.hasMatch('-0.99'), isTrue);
      });

      test('rejects non-numbers', () {
        expect(pattern.hasMatch('abc'), isFalse);
        expect(pattern.hasMatch('12.34.56'), isFalse);
      });
    });

    group('integer regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('integer')!);
      });

      test('matches valid integers', () {
        expect(pattern.hasMatch('0'), isTrue);
        expect(pattern.hasMatch('-100'), isTrue);
        expect(pattern.hasMatch('999'), isTrue);
      });

      test('rejects non-integers', () {
        expect(pattern.hasMatch('3.14'), isFalse);
        expect(pattern.hasMatch('abc'), isFalse);
      });
    });

    group('positive_int regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('positive_int')!);
      });

      test('matches positive integers', () {
        expect(pattern.hasMatch('1'), isTrue);
        expect(pattern.hasMatch('100'), isTrue);
      });

      test('rejects non-positive integers', () {
        expect(pattern.hasMatch('0'), isFalse);
        expect(pattern.hasMatch('-1'), isFalse);
        expect(pattern.hasMatch('1.5'), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Amount regex
    // -----------------------------------------------------------------------

    group('amount regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('amount')!);
      });

      test('matches valid amounts', () {
        expect(pattern.hasMatch('0'), isTrue);
        expect(pattern.hasMatch('100'), isTrue);
        expect(pattern.hasMatch('99.99'), isTrue);
        expect(pattern.hasMatch('0.01'), isTrue);
      });

      test('rejects invalid amounts', () {
        expect(pattern.hasMatch('0.123'), isFalse); // more than 2 decimals
        expect(pattern.hasMatch('00.5'), isFalse); // leading zero
        expect(pattern.hasMatch('-1'), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Date / Time regex
    // -----------------------------------------------------------------------

    group('date regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('date')!);
      });

      test('matches valid dates', () {
        expect(pattern.hasMatch('2024-01-01'), isTrue);
        expect(pattern.hasMatch('2023-12-31'), isTrue);
      });

      test('rejects invalid dates', () {
        expect(pattern.hasMatch('2024-13-01'), isFalse);
        expect(pattern.hasMatch('2024-00-01'), isFalse);
        expect(pattern.hasMatch('2024-1-1'), isFalse);
      });
    });

    group('time regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('time')!);
      });

      test('matches valid times', () {
        expect(pattern.hasMatch('00:00'), isTrue);
        expect(pattern.hasMatch('23:59'), isTrue);
        expect(pattern.hasMatch('12:30:45'), isTrue);
      });

      test('rejects invalid times', () {
        expect(pattern.hasMatch('24:00'), isFalse);
        expect(pattern.hasMatch('12:60'), isFalse);
        expect(pattern.hasMatch('1:30'), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // Chinese / QQ / WeChat
    // -----------------------------------------------------------------------

    group('chinese regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('chinese')!);
      });

      test('matches pure Chinese characters', () {
        expect(pattern.hasMatch('你好世界'), isTrue);
        expect(pattern.hasMatch('中文'), isTrue);
      });

      test('rejects non-Chinese characters', () {
        expect(pattern.hasMatch('hello'), isFalse);
        expect(pattern.hasMatch('你好world'), isFalse);
        expect(pattern.hasMatch('123'), isFalse);
      });
    });

    group('qq regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('qq')!);
      });

      test('matches valid QQ numbers', () {
        expect(pattern.hasMatch('10000'), isTrue);
        expect(pattern.hasMatch('123456789'), isTrue);
      });

      test('rejects invalid QQ numbers', () {
        expect(pattern.hasMatch('1234'), isFalse);
        expect(pattern.hasMatch('012345'), isFalse);
      });
    });

    group('wechat regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('wechat')!);
      });

      test('matches valid WeChat IDs', () {
        expect(pattern.hasMatch('abcdef123'), isTrue);
        expect(pattern.hasMatch('wx_id-test'), isTrue);
      });

      test('rejects invalid WeChat IDs', () {
        expect(pattern.hasMatch('1abcde'), isFalse); // starts with digit
        expect(pattern.hasMatch('abc'), isFalse); // too short
      });
    });

    // -----------------------------------------------------------------------
    // Bank card regex
    // -----------------------------------------------------------------------

    group('bank_card regex', () {
      late RegExp pattern;

      setUpAll(() {
        pattern = RegExp(ParkRegexRegistry.get('bank_card')!);
      });

      test('matches valid bank card numbers', () {
        expect(pattern.hasMatch('6222021234567890123'), isTrue);
        expect(pattern.hasMatch('1234567890123456'), isTrue);
      });

      test('rejects invalid bank card numbers', () {
        expect(pattern.hasMatch('123456789012345'), isFalse); // 15 digits, too short
        expect(pattern.hasMatch('01234567890123456'), isFalse); // starts with 0
      });
    });

    // -----------------------------------------------------------------------
    // Custom regex registration
    // -----------------------------------------------------------------------

    group('custom registration', () {
      tearDown(() {
        // Clean up custom tags after each test
        ParkRegexRegistry.unregister('custom_test');
        ParkRegexRegistry.unregister('dangerous');
      });

      test('register adds a new tag', () {
        ParkRegexRegistry.register(
          'custom_test',
          r'^\d{3}$',
          description: 'Three-digit number',
        );
        expect(ParkRegexRegistry.has('custom_test'), isTrue);
        expect(ParkRegexRegistry.get('custom_test'), equals(r'^\d{3}$'));
        expect(
          ParkRegexRegistry.getDescription('custom_test'),
          equals('Three-digit number'),
        );
      });

      test('registered pattern works correctly', () {
        ParkRegexRegistry.register('custom_test', r'^[A-Z]{2}\d{4}$');
        final pattern = RegExp(ParkRegexRegistry.get('custom_test')!);
        expect(pattern.hasMatch('AB1234'), isTrue);
        expect(pattern.hasMatch('ab1234'), isFalse);
        expect(pattern.hasMatch('A1234'), isFalse);
      });

      test('register overwrites existing tag', () {
        ParkRegexRegistry.register('custom_test', r'^old$');
        ParkRegexRegistry.register('custom_test', r'^new$');
        expect(ParkRegexRegistry.get('custom_test'), equals(r'^new$'));
      });

      test('unregister removes a tag', () {
        ParkRegexRegistry.register('custom_test', r'^\d+$');
        expect(ParkRegexRegistry.has('custom_test'), isTrue);
        ParkRegexRegistry.unregister('custom_test');
        expect(ParkRegexRegistry.has('custom_test'), isFalse);
        expect(ParkRegexRegistry.get('custom_test'), isNull);
      });

      test('register rejects dangerous nested quantifier patterns', () {
        expect(
          () => ParkRegexRegistry.register('dangerous', r'(a+)+'),
          throwsA(isA<ArgumentError>()),
        );
        expect(ParkRegexRegistry.has('dangerous'), isFalse);
      });

      test('register rejects (x*)+ pattern', () {
        expect(
          () => ParkRegexRegistry.register('dangerous', r'([\w]+)*'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('get returns null for unknown tag', () {
        expect(ParkRegexRegistry.get('nonexistent_tag'), isNull);
      });

      test('getDescription returns null for unknown tag', () {
        expect(ParkRegexRegistry.getDescription('nonexistent_tag'), isNull);
      });

      test('has returns false for unknown tag', () {
        expect(ParkRegexRegistry.has('nonexistent_tag'), isFalse);
      });

      test('allTags includes built-in and custom tags', () {
        final tagsBefore = ParkRegexRegistry.allTags.length;
        ParkRegexRegistry.register('custom_test', r'^\d+$');
        expect(ParkRegexRegistry.allTags.length, equals(tagsBefore + 1));
        expect(ParkRegexRegistry.allTags, contains('custom_test'));
      });

      test('tagDescriptions returns all tags with descriptions', () {
        final descriptions = ParkRegexRegistry.tagDescriptions;
        expect(descriptions, isA<Map<String, String>>());
        expect(descriptions.containsKey('mobile'), isTrue);
        expect(descriptions.containsKey('email'), isTrue);
      });

      test('register uses tag as default description when none provided', () {
        ParkRegexRegistry.register('custom_test', r'^\d+$');
        expect(ParkRegexRegistry.getDescription('custom_test'), equals('custom_test'));
      });
    });
  });
}
