/// Golden test utilities — multi-device support and common helpers.
///
/// Provides device size presets and enhanced wrappers for consistent
/// golden test rendering across different screen sizes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

import 'golden_test_helper.dart';

/// Device size presets for responsive golden tests.
class ParkGoldenDevice {
  /// Mobile: 375x812 (iPhone X/11/12)
  static const Size mobile = Size(375, 812);

  /// Tablet: 768x1024 (iPad)
  static const Size tablet = Size(768, 1024);

  /// Desktop: 1440x900 (MacBook)
  static const Size desktop = Size(1440, 900);
}

/// Enhanced golden test wrapper with device size support.
///
/// Automatically sizes the viewport to [device] dimensions and
/// applies the standard Park UI theme.
Widget goldenTestWrap(
  Widget child, {
  Size device = ParkGoldenDevice.mobile,
  ParkThemeData? theme,
}) {
  return goldenWrapSized(
    child,
    width: device.width,
    height: device.height,
    theme: theme,
  );
}

/// Generic golden test helper.
///
/// Wraps [builder] output with standard theme and compares against
/// a golden file named [name].png in the goldens/ directory.
///
/// Example:
/// ```dart
/// testWidgets('my component', (tester) async {
///   await goldenTest(
///     tester,
///     'my_component',
///     () => MyComponent(),
///   );
/// });
/// ```
Future<void> goldenTest(
  WidgetTester tester,
  String name,
  Widget Function() builder, {
  Size device = ParkGoldenDevice.mobile,
  ParkThemeData? theme,
}) async {
  await tester.pumpWidget(
    goldenTestWrap(
      builder(),
      device: device,
      theme: theme,
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(Scaffold),
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Golden test for multiple component variants in a column layout.
///
/// Renders [children] vertically in a scrollable column with padding.
Future<void> goldenTestVariants(
  WidgetTester tester,
  String name,
  List<Widget> children, {
  ParkThemeData? theme,
}) async {
  await tester.pumpWidget(
    goldenWrapColumn(children, theme: theme),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(Scaffold),
    matchesGoldenFile('goldens/$name.png'),
  );
}
