import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

// ---------------------------------------------------------------------------
// ParkBindingPath Tests
// ---------------------------------------------------------------------------
void main() {
  group('ParkBindingPath', () {
    // ---------- split ----------
    group('split()', () {
      test('splits dotted path into key list', () {
        expect(ParkBindingPath.split('user.address.city'), ['user', 'address', 'city']);
      });

      test('single key returns one-element list', () {
        expect(ParkBindingPath.split('name'), ['name']);
      });

      test('empty string returns empty list', () {
        expect(ParkBindingPath.split(''), <String>[]);
      });

      test('root path "/" returns empty list', () {
        expect(ParkBindingPath.split('/'), <String>[]);
      });
    });

    // ---------- resolve ----------
    group('resolve()', () {
      test('resolves nested value', () {
        final data = {'a': {'b': 1}};
        expect(ParkBindingPath.resolve('a.b', data), 1);
      });

      test('returns null for non-existent path', () {
        final data = {'a': 1};
        expect(ParkBindingPath.resolve('x.y', data), isNull);
      });

      test('returns null for missing intermediate key', () {
        final data = {'a': {'b': 1}};
        expect(ParkBindingPath.resolve('a.c', data), isNull);
      });

      test('returns entire data for empty path', () {
        final data = {'a': 1};
        expect(ParkBindingPath.resolve('', data), data);
      });

      test('returns null when intermediate node is not a Map', () {
        final data = {'a': 'not_a_map', 'b': 1};
        expect(ParkBindingPath.resolve('a.b', data), isNull);
      });

      test('resolves three-level deep path', () {
        final data = {'x': {'y': {'z': 42}}};
        expect(ParkBindingPath.resolve('x.y.z', data), 42);
      });
    });

    // ---------- hasPath ----------
    group('hasPath()', () {
      test('returns true for existing path', () {
        final data = {'a': {'b': 1}};
        expect(ParkBindingPath.hasPath('a.b', data), isTrue);
      });

      test('returns false for non-existent path', () {
        final data = {'a': {'b': 1}};
        expect(ParkBindingPath.hasPath('a.c', data), isFalse);
      });

      test('returns true for empty path', () {
        final data = {'a': 1};
        expect(ParkBindingPath.hasPath('', data), isTrue);
      });

      test('returns false when intermediate is not a Map', () {
        final data = {'a': 'string_value'};
        expect(ParkBindingPath.hasPath('a.b', data), isFalse);
      });
    });

    // ---------- set ----------
    group('set()', () {
      test('sets value at nested path immutably', () {
        final original = <dynamic, dynamic>{'a': <dynamic, dynamic>{}};
        final result = ParkBindingPath.set('a.b', original, 42);
        expect(result, {'a': {'b': 42}});
      });

      test('does not mutate original map', () {
        final original = <dynamic, dynamic>{'a': <dynamic, dynamic>{}};
        ParkBindingPath.set('a.b', original, 42);
        expect(original, {'a': <dynamic, dynamic>{}});
      });

      test('creates intermediate maps when missing', () {
        final original = <dynamic, dynamic>{};
        final result = ParkBindingPath.set('x.y.z', original, 99);
        expect(result, {'x': {'y': {'z': 99}}});
      });

      test('removes key when value is null', () {
        final original = <dynamic, dynamic>{'a': {'b': 1}};
        final result = ParkBindingPath.set('a.b', original, null);
        expect(result, {'a': <dynamic, dynamic>{}});
      });

      test('returns copy for empty path', () {
        final original = <dynamic, dynamic>{'a': 1};
        final result = ParkBindingPath.set('', original, 42);
        expect(result, {'a': 1});
        expect(identical(result, original), isFalse);
      });

      test('replaces leaf value', () {
        final original = <dynamic, dynamic>{'user': {'name': 'Alice', 'age': 30}};
        final result = ParkBindingPath.set('user.name', original, 'Bob');
        expect(result, {'user': {'name': 'Bob', 'age': 30}});
      });
    });
  });

  // ---------------------------------------------------------------------------
  // ParkBindable Tests
  // ---------------------------------------------------------------------------
  group('ParkBindable', () {
    test('creates with initial value', () {
      final bindable = ParkBindable<String>('user.name', 'Alice');
      expect(bindable.path, 'user.name');
      expect(bindable.value, 'Alice');
    });

    test('update() changes value and notifies listeners', () {
      final bindable = ParkBindable<String>('name', 'old');
      String? notified;
      bindable.addListener(() {
        notified = bindable.value;
      });
      bindable.update('new');
      expect(bindable.value, 'new');
      expect(notified, 'new');
    });

    test('value setter triggers notification', () {
      final bindable = ParkBindable<int>('count', 0);
      int notifyCount = 0;
      bindable.addListener(() {
        notifyCount++;
      });
      bindable.value = 1;
      expect(bindable.value, 1);
      expect(notifyCount, 1);
    });

    test('dispose() releases resources', () {
      final bindable = ParkBindable<String>('x', 'val');
      int notifyCount = 0;
      bindable.addListener(() {
        notifyCount++;
      });
      bindable.dispose();
      // After dispose, ValueNotifier asserts on value set — verify it is disposed
      expect(() => bindable.value = 'new', throwsA(isA<AssertionError>()));
      // Listener should not have been called
      expect(notifyCount, 0);
    });

    test('supports int type value', () {
      final bindable = ParkBindable<int>('age', 25);
      expect(bindable.value, 25);
      bindable.value = 30;
      expect(bindable.value, 30);
    });

    test('supports bool type value', () {
      final bindable = ParkBindable<bool>('active', false);
      expect(bindable.value, isFalse);
      bindable.value = true;
      expect(bindable.value, isTrue);
    });

    test('supports null initial value', () {
      // ParkBindable requires non-null T but value itself can be null
      // through explicit assignment
      final bindable = ParkBindable<String?>('test', null);
      expect(bindable.value, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // ParkBindingService Tests
  // ---------------------------------------------------------------------------
  group('ParkBindingService', () {
    group('constructor and model', () {
      test('creates with empty model when no initial data', () {
        final service = ParkBindingService();
        expect(service.model, <String, dynamic>{});
      });

      test('creates with initial model data', () {
        final service = ParkBindingService({'name': 'Alice', 'age': 30});
        expect(service.model['name'], 'Alice');
        expect(service.model['age'], 30);
      });

      test('model is unmodifiable', () {
        final service = ParkBindingService({'name': 'Alice'});
        expect(
          () => service.model['name'] = 'Bob',
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('does not share reference with initial model', () {
        final initial = <String, dynamic>{'name': 'Alice'};
        final service = ParkBindingService(initial);
        initial['name'] = 'Bob';
        expect(service.model['name'], 'Alice');
      });
    });

    group('bind()', () {
      test('bind returns ParkBindable with resolved value', () {
        final service = ParkBindingService({'name': 'Alice'});
        final bindable = service.bind<String>('name');
        expect(bindable, isA<ParkBindable<String>>());
        expect(bindable.value, 'Alice');
      });

      test('bind same path returns same instance (singleton)', () {
        final service = ParkBindingService({'name': 'Alice'});
        final a = service.bind<String>('name');
        final b = service.bind<String>('name');
        expect(identical(a, b), isTrue);
      });

      test('bind uses defaultValue when path does not exist', () {
        final service = ParkBindingService();
        final bindable = service.bind<String>('missing', defaultValue: 'fallback');
        expect(bindable.value, 'fallback');
      });

      test('bind creates value from model when available, ignoring defaultValue', () {
        final service = ParkBindingService({'key': 'real'});
        final bindable = service.bind<String>('key', defaultValue: 'fallback');
        expect(bindable.value, 'real');
      });

      test('bind on nested path resolves correctly', () {
        final service = ParkBindingService({'user': {'name': 'Alice'}});
        final bindable = service.bind<String>('user.name');
        expect(bindable.value, 'Alice');
      });

      test('bind triggers listener on value change via bindable', () async {
        final service = ParkBindingService({'count': 0});
        final bindable = service.bind<int>('count');
        int? received;
        bindable.addListener(() {
          received = bindable.value;
        });
        bindable.value = 42;
        expect(received, 42);
      });

      test('bind syncs value back to model on change', () async {
        final service = ParkBindingService({'name': 'Alice'});
        final bindable = service.bind<String>('name');
        bindable.value = 'Bob';
        expect(service.model['name'], 'Bob');
      });
    });

    group('setValue()', () {
      test('setValue updates bound path and triggers notification', () {
        final service = ParkBindingService({'name': 'Alice'});
        final bindable = service.bind<String>('name');
        String? notified;
        bindable.addListener(() {
          notified = bindable.value;
        });
        service.setValue('name', 'Bob');
        expect(bindable.value, 'Bob');
        expect(notified, 'Bob');
        expect(service.model['name'], 'Bob');
      });

      test('setValue updates model directly when no bindable exists', () {
        final service = ParkBindingService({});
        service.setValue('newKey', 'value');
        expect(service.model['newKey'], 'value');
      });

      test('setValue on nested path works without bindable', () {
        final service = ParkBindingService({});
        service.setValue('user.name', 'Alice');
        expect(ParkBindingPath.resolve('user.name', service.model), 'Alice');
      });
    });

    group('getValue()', () {
      test('getValue returns bound value when bindable exists', () {
        final service = ParkBindingService({'name': 'Alice'});
        service.bind<String>('name');
        expect(service.getValue<String>('name'), 'Alice');
      });

      test('getValue resolves from model when no bindable exists', () {
        final service = ParkBindingService({'name': 'Alice'});
        expect(service.getValue<String>('name'), 'Alice');
      });

      test('getValue returns null for missing path', () {
        final service = ParkBindingService({});
        expect(service.getValue<String>('missing'), isNull);
      });

      test('getValue reflects updated value after setValue', () {
        final service = ParkBindingService({'name': 'Alice'});
        service.setValue('name', 'Bob');
        expect(service.getValue<String>('name'), 'Bob');
      });
    });

    group('updateModel()', () {
      test('updateModel replaces model data', () {
        final service = ParkBindingService({'name': 'Alice'});
        service.updateModel({'name': 'Bob'});
        expect(service.model['name'], 'Bob');
      });

      test('updateModel notifies bindables with changed values', () {
        final service = ParkBindingService({'name': 'Alice', 'age': 30});
        final nameBindable = service.bind<String>('name');
        final ageBindable = service.bind<int>('age');

        int nameNotifyCount = 0;
        int ageNotifyCount = 0;
        nameBindable.addListener(() => nameNotifyCount++);
        ageBindable.addListener(() => ageNotifyCount++);

        service.updateModel({'name': 'Bob', 'age': 30});

        expect(nameNotifyCount, 1, reason: 'name changed from Alice to Bob');
        expect(ageNotifyCount, 0, reason: 'age unchanged at 30');
      });

      test('updateModel updates bindable values', () {
        final service = ParkBindingService({'name': 'Alice'});
        final nameBindable = service.bind<String>('name');
        service.updateModel({'name': 'Charlie'});
        expect(nameBindable.value, 'Charlie');
      });

      test('updateModel only notifies changed paths', () {
        final service = ParkBindingService({'a': 1, 'b': 2, 'c': 3});
        service.bind<int>('a');
        service.bind<int>('b');
        service.bind<int>('c');

        int notifyCount = 0;
        // Add one global listener per bindable to count
        for (final entry in [service.bind<int>('a'), service.bind<int>('b'), service.bind<int>('c')]) {
          entry.addListener(() => notifyCount++);
        }

        service.updateModel({'a': 1, 'b': 999, 'c': 3});

        // Only 'b' should have triggered
        expect(notifyCount, 1);
      });

      test('updateModel handles nested paths', () {
        final service = ParkBindingService({'user': {'name': 'Alice'}});
        final bindable = service.bind<String>('user.name');
        service.updateModel({'user': {'name': 'Bob'}});
        expect(bindable.value, 'Bob');
      });
    });

    group('dispose() and disposeBindable()', () {
      test('disposeBindable removes single binding', () {
        final service = ParkBindingService({'a': 1, 'b': 2});
        final ba = service.bind<int>('a');
        final bb = service.bind<int>('b');
        service.disposeBindable('a');
        // After dispose, 'a' bindable is removed but model data remains
        // getValue falls back to model so it still returns 1
        expect(service.getValue<int>('a'), 1);
        // 'b' still works
        expect(service.getValue<int>('b'), 2);
        // Re-binding 'a' returns a fresh instance (not the disposed one)
        final ba2 = service.bind<int>('a');
        expect(identical(ba, ba2), isFalse);
      });

      test('disposeBindable prevents further notifications', () {
        final service = ParkBindingService({'name': 'Alice'});
        final bindable = service.bind<String>('name');
        int notifyCount = 0;
        bindable.addListener(() => notifyCount++);

        service.disposeBindable('name');

        // After dispose, setting value via service should not crash
        // and the listener should not fire
        service.setValue('name', 'Bob');
        // The disposed bindable's listener won't fire
        // The model is still updated
        expect(service.model['name'], 'Bob');
      });

      test('dispose cleans all bindings', () {
        final service = ParkBindingService({'a': 1, 'b': 2, 'c': 3});
        service.bind<int>('a');
        service.bind<int>('b');
        service.bind<int>('c');
        service.dispose();
        expect(service.model, <String, dynamic>{});
        // New bind after dispose works (fresh state)
        final newBindable = service.bind<int>('new', defaultValue: 99);
        expect(newBindable.value, 99);
      });

      test('dispose is idempotent', () {
        final service = ParkBindingService({'a': 1});
        service.bind<int>('a');
        service.dispose();
        // Calling dispose twice should not throw
        expect(() => service.dispose(), returnsNormally);
      });
    });

    group('edge cases', () {
      test('bind with empty path resolves to entire model', () {
        final service = ParkBindingService({'key': 'value'});
        // Empty path returns the whole model map
        final bindable = service.bind<Map>('');
        expect(bindable.value, {'key': 'value'});
      });

      test('setValue on path with missing intermediate keys creates them', () {
        final service = ParkBindingService({});
        service.setValue('a.b.c', 42);
        expect(ParkBindingPath.resolve('a.b.c', service.model), 42);
      });

      test('multiple independent bindings work', () {
        final service = ParkBindingService({'x': 10, 'y': 20});
        final bx = service.bind<int>('x');
        final by = service.bind<int>('y');
        bx.value = 100;
        expect(service.model['x'], 100);
        expect(service.model['y'], 20); // y unchanged
        expect(by.value, 20);
      });

      test('updateModel with empty map clears model', () {
        final service = ParkBindingService({'name': 'Alice'});
        service.updateModel(<String, dynamic>{});
        expect(service.model, <String, dynamic>{});
      });
    });
  });

  // ---------------------------------------------------------------------------
  // ParkForm + ParkBindingService integration regression tests
  // ---------------------------------------------------------------------------
  group('ParkForm binding integration', () {
    testWidgets('submit returns binding values for bindKey fields', (WidgetTester tester) async {
      final service = ParkBindingService({'name': 'Alice', 'city': '北京'});
      Map<String, dynamic>? submitted;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParkForm(
              bindingService: service,
              onSubmit: (values) => submitted = values,
              submitLabel: '提交',
              showDefaultActions: true,
              children: <Widget>[
                ParkInput(label: '姓名', bindKey: 'name'),
                ParkSelect(
                  label: '城市',
                  bindKey: 'city',
                  items: <ParkSelectOption>[
                    ParkSelectOption(label: '北京', value: '北京'),
                    ParkSelectOption(label: '上海', value: '上海'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Change name input
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Bob');
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(find.text('提交'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!['name'], 'Bob');
      expect(submitted!['city'], '北京');
      expect(submitted!.length, 2);

      service.dispose();
    });
  });
}
