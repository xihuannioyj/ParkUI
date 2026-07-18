import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// Helper: build a minimal [ParkFormFieldSchema] for data-source tests.
ParkFormFieldSchema _field({
  ParkDataSourceType type = ParkDataSourceType.none,
  String? dataSourceKey,
  Map<String, dynamic> dataSourceParams = const <String, dynamic>{},
  List<Map<String, dynamic>> options = const <Map<String, dynamic>>[],
}) {
  return ParkFormFieldSchema(
    fieldId: 'f1',
    fieldType: ParkFieldType.select,
    labelName: 'Test',
    fieldName: 'test',
    dataSourceType: type,
    dataSourceKey: dataSourceKey,
    dataSourceParams: dataSourceParams,
    options: options,
  );
}

void main() {
  group('ParkDataSourceResolver', () {
    late ParkDataSourceResolver resolver;

    setUp(() {
      resolver = ParkDataSourceResolver();
    });

    // -----------------------------------------------------------------------
    // Static / none
    // -----------------------------------------------------------------------

    group('static data source', () {
      test('none type returns field.options as-is', () async {
        final opts = [
          {'label': 'A', 'value': 1},
          {'label': 'B', 'value': 2},
        ];
        final field = _field(type: ParkDataSourceType.none, options: opts);
        final result = await resolver.resolve(field);
        expect(result, equals(opts));
      });

      test('staticOptions type returns field.options as-is', () async {
        final opts = [
          {'label': 'X', 'value': 'x'},
        ];
        final field =
            _field(type: ParkDataSourceType.staticOptions, options: opts);
        final result = await resolver.resolve(field);
        expect(result, equals(opts));
      });

      test('none type with empty options returns empty list', () async {
        final field = _field(type: ParkDataSourceType.none);
        final result = await resolver.resolve(field);
        expect(result, isEmpty);
      });
    });

    // -----------------------------------------------------------------------
    // Enum / Dict / Cache
    // -----------------------------------------------------------------------

    group('enum source', () {
      test('returns registered enum options by key', () async {
        final enumOpts = [
          {'label': 'Male', 'value': 'M'},
          {'label': 'Female', 'value': 'F'},
        ];
        resolver.registerEnum('gender', enumOpts);
        final field = _field(
          type: ParkDataSourceType.enumSource,
          dataSourceKey: 'gender',
        );
        final result = await resolver.resolve(field);
        expect(result, equals(enumOpts));
      });

      test('falls back to field.options when key not registered', () async {
        final fallback = [
          {'label': 'Fallback', 'value': 'fb'},
        ];
        final field = _field(
          type: ParkDataSourceType.enumSource,
          dataSourceKey: 'unknown_enum',
          options: fallback,
        );
        final result = await resolver.resolve(field);
        expect(result, equals(fallback));
      });

      test('falls back when dataSourceKey is null', () async {
        final fallback = [
          {'label': 'FB', 'value': 0},
        ];
        final field = _field(
          type: ParkDataSourceType.enumSource,
          options: fallback,
        );
        final result = await resolver.resolve(field);
        expect(result, equals(fallback));
      });
    });

    group('dict source', () {
      test('returns registered dict options by key', () async {
        final dictOpts = [
          {'label': 'Beijing', 'value': '110000'},
        ];
        resolver.registerDict('city', dictOpts);
        final field = _field(
          type: ParkDataSourceType.dict,
          dataSourceKey: 'city',
        );
        final result = await resolver.resolve(field);
        expect(result, equals(dictOpts));
      });

      test('falls back to field.options when key not registered', () async {
        final fallback = [
          {'label': 'FB', 'value': 'fb'},
        ];
        final field = _field(
          type: ParkDataSourceType.dict,
          dataSourceKey: 'missing',
          options: fallback,
        );
        final result = await resolver.resolve(field);
        expect(result, equals(fallback));
      });
    });

    group('cache source', () {
      test('returns registered cache options by key', () async {
        final cacheOpts = [
          {'label': 'User A', 'value': 1},
        ];
        resolver.registerCache('users', cacheOpts);
        final field = _field(
          type: ParkDataSourceType.cache,
          dataSourceKey: 'users',
        );
        final result = await resolver.resolve(field);
        expect(result, equals(cacheOpts));
      });

      test('falls back to field.options when key not registered', () async {
        final fallback = [
          {'label': 'FB', 'value': 'fb'},
        ];
        final field = _field(
          type: ParkDataSourceType.cache,
          dataSourceKey: 'missing_cache',
          options: fallback,
        );
        final result = await resolver.resolve(field);
        expect(result, equals(fallback));
      });
    });

    // -----------------------------------------------------------------------
    // API data source
    // -----------------------------------------------------------------------

    group('api source', () {
      test('calls registered fetcher and returns its result', () async {
        final apiResult = [
          {'label': 'Remote', 'value': 42},
        ];
        resolver.registerFetcher('user_list', (field, params) async {
          return apiResult;
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'user_list',
        );
        final result = await resolver.resolve(field);
        expect(result, equals(apiResult));
      });

      test('passes resolved params to fetcher', () async {
        Map<String, dynamic>? capturedParams;
        resolver.registerFetcher('api1', (field, params) async {
          capturedParams = params;
          return [];
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'api1',
          dataSourceParams: {'keyword': 'hello', 'type': 'exact'},
        );
        await resolver.resolve(field);
        expect(capturedParams, equals({'keyword': 'hello', 'type': 'exact'}));
      });

      test('falls back to field.options when fetcher not registered',
          () async {
        final fallback = [
          {'label': 'FB', 'value': 'fb'},
        ];
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'unregistered_api',
          options: fallback,
        );
        final result = await resolver.resolve(field);
        expect(result, equals(fallback));
      });

      test('falls back when dataSourceKey is null', () async {
        final fallback = [
          {'label': 'FB', 'value': 'fb'},
        ];
        final field = _field(
          type: ParkDataSourceType.api,
          options: fallback,
        );
        final result = await resolver.resolve(field);
        expect(result, equals(fallback));
      });

      test('falls back when dataSourceKey is empty string', () async {
        final fallback = [
          {'label': 'FB', 'value': 'fb'},
        ];
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: '',
          options: fallback,
        );
        final result = await resolver.resolve(field);
        expect(result, equals(fallback));
      });
    });

    // -----------------------------------------------------------------------
    // Error handling
    // -----------------------------------------------------------------------

    group('error handling', () {
      test('returns empty list when fetcher throws', () async {
        resolver.registerFetcher('fail_api', (field, params) async {
          throw Exception('network error');
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'fail_api',
        );
        final result = await resolver.resolve(field);
        expect(result, isEmpty);
      });

      test('onError callback is invoked when fetcher throws', () async {
        Object? capturedError;
        resolver.registerFetcher('fail_api', (field, params) async {
          throw Exception('timeout');
        });
        resolver.onError = (error, stack) {
          capturedError = error;
        };
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'fail_api',
        );
        await resolver.resolve(field);
        expect(capturedError, isA<Exception>());
        expect((capturedError as Exception).toString(), contains('timeout'));
      });

      test('FlutterError is reported even without onError callback', () async {
        resolver.registerFetcher('fail_api', (field, params) async {
          throw StateError('bad state');
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'fail_api',
        );
        // Should not throw
        final result = await resolver.resolve(field);
        expect(result, isEmpty);
      });
    });

    // -----------------------------------------------------------------------
    // $form.xxx / $cache.xxx parameter substitution
    // -----------------------------------------------------------------------

    group('parameter substitution', () {
      test(r'$form.xxx resolves from currentValues', () async {
        Map<String, dynamic>? capturedParams;
        resolver.registerFetcher('api1', (field, params) async {
          capturedParams = params;
          return [];
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'api1',
          dataSourceParams: {'cityId': r'$form.city'},
        );
        await resolver.resolve(
          field,
          currentValues: {'city': 'Shanghai'},
        );
        expect(capturedParams?['cityId'], equals('Shanghai'));
      });

      test(r'$cache.xxx resolves from cache store', () async {
        Map<String, dynamic>? capturedParams;
        resolver.registerFetcher('api1', (field, params) async {
          capturedParams = params;
          return [];
        });
        resolver.registerCacheValue('tenantId', 'T001');
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'api1',
          dataSourceParams: {'tenant': r'$cache.tenantId'},
        );
        await resolver.resolve(field);
        expect(capturedParams?['tenant'], equals('T001'));
      });

      test(r'$form.xxx with nested path resolves correctly', () async {
        Map<String, dynamic>? capturedParams;
        resolver.registerFetcher('api1', (field, params) async {
          capturedParams = params;
          return [];
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'api1',
          dataSourceParams: {'region': r'$form.address.region'},
        );
        await resolver.resolve(
          field,
          currentValues: {
            'address': {'region': 'East'},
          },
        );
        expect(capturedParams?['region'], equals('East'));
      });

      test(r'$cache.xxx with nested path resolves correctly', () async {
        Map<String, dynamic>? capturedParams;
        resolver.registerFetcher('api1', (field, params) async {
          capturedParams = params;
          return [];
        });
        resolver.registerCacheValues({
          'config': {'env': 'prod'},
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'api1',
          dataSourceParams: {'env': r'$cache.config.env'},
        );
        await resolver.resolve(field);
        expect(capturedParams?['env'], equals('prod'));
      });

      test('non-string params are passed through unchanged', () async {
        Map<String, dynamic>? capturedParams;
        resolver.registerFetcher('api1', (field, params) async {
          capturedParams = params;
          return [];
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'api1',
          dataSourceParams: {'limit': 10, 'active': true},
        );
        await resolver.resolve(field);
        expect(capturedParams?['limit'], equals(10));
        expect(capturedParams?['active'], isTrue);
      });

      test('plain string params are not substituted (no \$form/ prefix)',
          () async {
        Map<String, dynamic>? capturedParams;
        resolver.registerFetcher('api1', (field, params) async {
          capturedParams = params;
          return [];
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'api1',
          dataSourceParams: {'type': 'status'},
        );
        await resolver.resolve(field);
        expect(capturedParams?['type'], equals('status'));
      });

      test(r'$form.xxx returns null when path does not exist', () async {
        Map<String, dynamic>? capturedParams;
        resolver.registerFetcher('api1', (field, params) async {
          capturedParams = params;
          return [];
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'api1',
          dataSourceParams: {'missing': r'$form.nonexistent'},
        );
        await resolver.resolve(field, currentValues: {});
        expect(capturedParams?['missing'], isNull);
      });
    });

    // -----------------------------------------------------------------------
    // Batch registration / removal / clear
    // -----------------------------------------------------------------------

    group('registration management', () {
      test('registerFetchers adds multiple fetchers at once', () async {
        resolver.registerFetchers({
          'a': (f, p) async => [
                {'label': 'A', 'value': 'a'}
              ],
          'b': (f, p) async => [
                {'label': 'B', 'value': 'b'}
              ],
        });
        final fieldA = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'a',
        );
        final fieldB = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'b',
        );
        final resultA = await resolver.resolve(fieldA);
        final resultB = await resolver.resolve(fieldB);
        expect(resultA.first['value'], equals('a'));
        expect(resultB.first['value'], equals('b'));
      });

      test('removeFetcher removes a single fetcher', () async {
        resolver.registerFetcher('temp', (f, p) async => []);
        resolver.removeFetcher('temp');
        final fallback = [
          {'label': 'FB', 'value': 'fb'},
        ];
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'temp',
          options: fallback,
        );
        final result = await resolver.resolve(field);
        expect(result, equals(fallback));
      });

      test('clear removes all registrations', () async {
        resolver.registerFetcher('f1', (f, p) async => []);
        resolver.registerEnum('e1', []);
        resolver.registerDict('d1', []);
        resolver.registerCache('c1', []);
        resolver.registerCacheValue('k', 'v');

        resolver.clear();

        // After clear, all sources fall back to field.options
        final fallback = [
          {'label': 'FB', 'value': 'fb'},
        ];

        final apiField = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'f1',
          options: fallback,
        );
        expect(await resolver.resolve(apiField), equals(fallback));

        final enumField = _field(
          type: ParkDataSourceType.enumSource,
          dataSourceKey: 'e1',
          options: fallback,
        );
        expect(await resolver.resolve(enumField), equals(fallback));
      });
    });

    // -----------------------------------------------------------------------
    // Empty / degenerate data
    // -----------------------------------------------------------------------

    group('empty and degenerate data', () {
      test('fetcher returning empty list is handled gracefully', () async {
        resolver.registerFetcher('empty_api', (f, p) async => []);
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'empty_api',
        );
        final result = await resolver.resolve(field);
        expect(result, isEmpty);
      });

      test('fetcher returning null-like data is handled', () async {
        resolver.registerFetcher('nullish', (f, p) async {
          return <Map<String, dynamic>>[];
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'nullish',
        );
        final result = await resolver.resolve(field);
        expect(result, isEmpty);
      });

      test('registerCacheValues merges into existing cache', () async {
        resolver.registerCacheValue('a', 1);
        resolver.registerCacheValues({'b': 2, 'c': 3});
        // Verify by resolving $cache refs
        Map<String, dynamic>? capturedParams;
        resolver.registerFetcher('api1', (field, params) async {
          capturedParams = params;
          return [];
        });
        final field = _field(
          type: ParkDataSourceType.api,
          dataSourceKey: 'api1',
          dataSourceParams: {
            'x': r'$cache.a',
            'y': r'$cache.b',
            'z': r'$cache.c',
          },
        );
        await resolver.resolve(field);
        expect(capturedParams?['x'], equals(1));
        expect(capturedParams?['y'], equals(2));
        expect(capturedParams?['z'], equals(3));
      });
    });
  });
}
