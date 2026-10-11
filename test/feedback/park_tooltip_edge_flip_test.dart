import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_tooltip.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

/// Regression tests for [ParkTooltip] placement near screen edges.
///
/// The default placement is [ParkTooltipPlacement.top]. A trigger sitting at
/// the top of the screen (e.g. an app-bar action button) has no room above it,
/// so the bubble used to be clamped against the top edge and was drawn on top
/// of the very control it describes. It must flip to the opposite side instead.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(body: child),
      );

  testWidgets('flips below the trigger when there is no room above',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3.0; // 360 x 760 logical
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(
      const Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: 20, right: 12),
          child: ParkTooltip(
            message: 'Switch housing',
            trigger: ParkTooltipTrigger.tap,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.location_city),
            ),
          ),
        ),
      ),
    ));

    final Rect trigger = tester.getRect(find.byIcon(Icons.location_city));

    await tester.tap(find.byIcon(Icons.location_city));
    await tester.pump(); // show + measure the bubble
    await tester.pump(const Duration(milliseconds: 250)); // place + animate

    final Rect bubble = tester.getRect(find.text('Switch housing'));

    expect(
      bubble.top,
      greaterThanOrEqualTo(trigger.bottom),
      reason: 'no room above: bubble must flip below the trigger, '
          'bubble=$bubble trigger=$trigger',
    );
    expect(bubble.left, greaterThanOrEqualTo(0.0));
    expect(
      bubble.right,
      lessThanOrEqualTo(360.5),
      reason: 'bubble must stay on screen for a right-edge trigger, '
          'bubble=$bubble',
    );
  });

  testWidgets('keeps the requested placement when it fits', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(
      const Center(
        child: ParkTooltip(
          message: 'Centered tip',
          placement: ParkTooltipPlacement.bottom,
          trigger: ParkTooltipTrigger.tap,
          child: SizedBox(width: 48, height: 48, child: Icon(Icons.settings)),
        ),
      ),
    ));

    final Rect trigger = tester.getRect(find.byIcon(Icons.settings));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final Rect bubble = tester.getRect(find.text('Centered tip'));

    expect(
      bubble.top,
      greaterThanOrEqualTo(trigger.bottom),
      reason: 'bottom placement fits: bubble stays below, '
          'bubble=$bubble trigger=$trigger',
    );
    expect(
      (bubble.center.dx - trigger.center.dx).abs(),
      lessThan(1.0),
      reason: 'bubble stays centred on the trigger when nothing is clamped, '
          'bubble=$bubble trigger=$trigger',
    );
  });
}
