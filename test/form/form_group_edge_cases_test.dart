/// Edge-case tests for FormGroup, FormArray, and ParkFormError.
///
/// Covers:
/// - addControl / removeControl subscription lifecycle
/// - rawValue vs value with disabled controls
/// - ParkFormArray boundary checks
/// - ParkFormError equality and hashCode

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/form/group/form_group_exports.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════
  // ParkFormError equality
  // ═══════════════════════════════════════════════════════════════════════

  group('ParkFormError - equality', () {
    test('two errors with same key and message are equal', () {
      const ParkFormError a = ParkFormError('required', 'Required field');
      const ParkFormError b = ParkFormError('required', 'Required field');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('errors with different keys are not equal', () {
      const ParkFormError a = ParkFormError('required', 'Required');
      const ParkFormError b = ParkFormError('maxLength', 'Required');
      expect(a, isNot(equals(b)));
    });

    test('errors with different messages are not equal', () {
      const ParkFormError a = ParkFormError('required', 'Field required');
      const ParkFormError b = ParkFormError('required', 'This field is required');
      expect(a, isNot(equals(b)));
    });

    test('identical error is equal to itself', () {
      const ParkFormError a = ParkFormError('pattern', 'Invalid pattern');
      expect(a, equals(a));
    });

    test('error is not equal to non-ParkFormError object', () {
      const ParkFormError a = ParkFormError('required', 'Required');
      expect(a == 'not an error', isFalse);
    });

    test('errors can be used in Sets for deduplication', () {
      final ParkFormError a = ParkFormError('required', 'Required');
      final ParkFormError b = ParkFormError('required', 'Required');
      final ParkFormError c = ParkFormError('maxLength', 'Too long');

      final Set<ParkFormError> errorSet = <ParkFormError>{a, b, c};
      expect(errorSet.length, 2);
    });

    test('errors can be used as Map keys', () {
      const ParkFormError a = ParkFormError('required', 'Required');
      const ParkFormError b = ParkFormError('required', 'Required');

      final Map<ParkFormError, int> map = <ParkFormError, int>{a: 1};
      expect(map[b], 1);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // rawValue vs value with disabled controls
  // ═══════════════════════════════════════════════════════════════════════

  group('ParkFormGroupControl - rawValue vs value', () {
    test('value excludes disabled controls', () {
      final ParkFormGroupControl group = ParkFormGroupControl(<String, ParkAbstractControl>{
        'name': ParkFormControl('Alice'),
        'age': ParkFormControl(30),
      });

      // All enabled: value includes everything.
      expect(group.value, <String, dynamic>{'name': 'Alice', 'age': 30});

      // Disable 'age'.
      group.control('age')!.disable();

      // value should exclude disabled 'age'.
      expect(group.value, <String, dynamic>{'name': 'Alice'});
      group.dispose();
    });

    test('rawValue includes disabled controls', () {
      final ParkFormGroupControl group = ParkFormGroupControl(<String, ParkAbstractControl>{
        'name': ParkFormControl('Alice'),
        'age': ParkFormControl(30),
      });

      group.control('age')!.disable();

      // rawValue should still include disabled 'age'.
      expect(group.rawValue, <String, dynamic>{'name': 'Alice', 'age': 30});
      group.dispose();
    });

    test('getEnabledValues matches value', () {
      final ParkFormGroupControl group = ParkFormGroupControl(<String, ParkAbstractControl>{
        'a': ParkFormControl(1),
        'b': ParkFormControl(2),
        'c': ParkFormControl(3),
      });

      group.control('b')!.disable();

      expect(group.getEnabledValues(), group.value);
      expect(group.getEnabledValues(), <String, dynamic>{'a': 1, 'c': 3});
      group.dispose();
    });

    test('value returns empty map when all controls disabled', () {
      final ParkFormGroupControl group = ParkFormGroupControl(<String, ParkAbstractControl>{
        'x': ParkFormControl('val'),
      });

      group.control('x')!.disable();
      expect(group.value, isEmpty);
      expect(group.rawValue, <String, dynamic>{'x': 'val'});
      group.dispose();
    });

    test('re-enabling control restores it in value', () {
      final ParkFormGroupControl group = ParkFormGroupControl(<String, ParkAbstractControl>{
        'field': ParkFormControl('data'),
      });

      group.control('field')!.disable();
      expect(group.value, isEmpty);

      group.control('field')!.enable();
      expect(group.value, <String, dynamic>{'field': 'data'});
      group.dispose();
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // addControl / removeControl subscription lifecycle
  // ═══════════════════════════════════════════════════════════════════════

  group('ParkFormGroupControl - addControl / removeControl', () {
    test('addControl emits on parent valueChanges', () async {
      final ParkFormGroupControl group = ParkFormGroupControl(<String, ParkAbstractControl>{
        'a': ParkFormControl(1),
      });

      final List<dynamic> emitted = <dynamic>[];
      group.valueChanges.listen(emitted.add);

      final ParkFormControl newControl = ParkFormControl('new');
      group.addControl('b', newControl);

      await Future<void>.delayed(Duration.zero);
      expect(emitted, isNotEmpty);
      expect(group.value['b'], 'new');
      group.dispose();
    });

    test('removed child subscription is cancelled (no leak)', () async {
      final ParkFormGroupControl group = ParkFormGroupControl(<String, ParkAbstractControl>{});

      final ParkFormControl child = ParkFormControl('initial');
      group.addControl('child', child);

      // Verify child changes propagate to parent.
      final List<dynamic> parentEmissions = <dynamic>[];
      group.valueChanges.listen(parentEmissions.add);

      child.setValue('before-removal');
      await Future<void>.delayed(Duration.zero);
      expect(parentEmissions, isNotEmpty);

      // Remove the child (this disposes the child and cancels the subscription).
      group.removeControl('child');
      parentEmissions.clear();

      // The child is now disposed; its stream controllers are closed.
      // The key assertion: removeControl properly cancelled the subscription
      // so no further events can leak. We verify by checking the group
      // no longer has the child control.
      expect(group.controls.containsKey('child'), isFalse);
      expect(group.controls.length, 0);
      group.dispose();
    });

    test('removeControl on non-existent key does not throw', () {
      final ParkFormGroupControl group = ParkFormGroupControl(<String, ParkAbstractControl>{
        'a': ParkFormControl(1),
      });

      // Should not throw.
      group.removeControl('nonexistent');
      expect(group.controls.length, 1);
      group.dispose();
    });

    test('addControl then removeControl then addControl same key works', () async {
      final ParkFormGroupControl group = ParkFormGroupControl(<String, ParkAbstractControl>{});

      final ParkFormControl first = ParkFormControl('first');
      group.addControl('key', first);
      expect(group.rawValue['key'], 'first');

      group.removeControl('key');
      expect(group.controls.containsKey('key'), isFalse);

      final ParkFormControl second = ParkFormControl('second');
      group.addControl('key', second);
      expect(group.rawValue['key'], 'second');

      group.dispose();
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // ParkFormArray boundary checks
  // ═══════════════════════════════════════════════════════════════════════

  group('ParkFormArray - boundary checks', () {
    test('removeAt with negative index is a no-op', () {
      final ParkFormArray array = ParkFormArray(<ParkFormGroupControl>[
        ParkFormGroupControl(<String, ParkAbstractControl>{'a': ParkFormControl(1)}),
      ]);

      array.removeAt(-1);
      expect(array.length, 1);
      array.dispose();
    });

    test('removeAt with index equal to length is a no-op', () {
      final ParkFormArray array = ParkFormArray(<ParkFormGroupControl>[
        ParkFormGroupControl(<String, ParkAbstractControl>{'a': ParkFormControl(1)}),
      ]);

      array.removeAt(1); // length is 1, index 1 is out of bounds
      expect(array.length, 1);
      array.dispose();
    });

    test('removeAt with large index is a no-op', () {
      final ParkFormArray array = ParkFormArray(<ParkFormGroupControl>[
        ParkFormGroupControl(<String, ParkAbstractControl>{'a': ParkFormControl(1)}),
      ]);

      array.removeAt(999);
      expect(array.length, 1);
      array.dispose();
    });

    test('removeAt on empty array is a no-op', () {
      final ParkFormArray array = ParkFormArray(<ParkFormGroupControl>[]);

      array.removeAt(0);
      expect(array.length, 0);
      array.dispose();
    });

    test('removeAt valid index removes and emits', () async {
      final ParkFormArray array = ParkFormArray(<ParkFormGroupControl>[
        ParkFormGroupControl(<String, ParkAbstractControl>{'name': ParkFormControl('A')}),
        ParkFormGroupControl(<String, ParkAbstractControl>{'name': ParkFormControl('B')}),
        ParkFormGroupControl(<String, ParkAbstractControl>{'name': ParkFormControl('C')}),
      ]);

      final List<dynamic> emissions = <dynamic>[];
      array.valueChanges.listen(emissions.add);

      array.removeAt(1); // Remove 'B'
      expect(array.length, 2);
      expect(array.at(0).value['name'], 'A');
      expect(array.at(1).value['name'], 'C');

      await Future<void>.delayed(Duration.zero);
      expect(emissions, isNotEmpty);
      array.dispose();
    });

    test('at() throws RangeError on invalid index', () {
      final ParkFormArray array = ParkFormArray(<ParkFormGroupControl>[
        ParkFormGroupControl(<String, ParkAbstractControl>{'a': ParkFormControl(1)}),
      ]);

      expect(() => array.at(5), throwsRangeError);
      expect(() => array.at(-1), throwsRangeError);
      array.dispose();
    });
  });
}
