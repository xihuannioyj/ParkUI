import 'dart:async';

import 'park_abstract_control.dart';

/// Debounce utility for [ParkAbstractControl] value changes.
///
/// Provides a debounced stream that delays emitting values until after
/// [duration] has elapsed without new emissions. Useful for search inputs,
/// auto-save, and other scenarios where rapid changes should be coalesced.
extension ParkAbstractControlDebounce on ParkAbstractControl {
  /// Get a debounced version of [valueChanges].
  ///
  /// Each new emission resets the timer. Only when [duration] elapses
  /// without a new value does the debounced stream emit.
  ///
  /// ```dart
  /// control.debouncedValueChanges(
  ///   duration: Duration(milliseconds: 500),
  /// ).listen((value) {
  ///   // Fires only after 500ms of inactivity.
  ///   search(value);
  /// });
  /// ```
  Stream<dynamic> debouncedValueChanges({
    Duration duration = const Duration(milliseconds: 300),
  }) {
    late StreamController<dynamic> controller;
    Timer? timer;
    StreamSubscription<dynamic>? subscription;

    controller = StreamController<dynamic>.broadcast(
      onCancel: () {
        timer?.cancel();
        subscription?.cancel();
        controller.close();
      },
    );

    subscription = valueChanges.listen((dynamic value) {
      timer?.cancel();
      timer = Timer(duration, () {
        if (!controller.isClosed) {
          controller.add(value);
        }
      });
    });

    return controller.stream;
  }
}
