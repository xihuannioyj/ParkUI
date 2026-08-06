import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_tooltip.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

void main() {
  testWidgets('tooltip bubble appears near trigger, not fullscreen', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0; // 360x640 logical
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: const Scaffold(
        body: Align(
          alignment: Alignment.center,
          child: ParkTooltip(
            message: '设置',
            placement: ParkTooltipPlacement.bottom,
            trigger: ParkTooltipTrigger.tap,
            child: SizedBox(width: 48, height: 48, child: Icon(Icons.settings)),
          ),
        ),
      ),
    ));

    final iconCenter = tester.getCenter(find.byType(Icon));
    await tester.tap(find.byType(Icon));
    await tester.pump(); // show
    await tester.pump(const Duration(milliseconds: 200)); // let animation finish

    final bubble = find.text('设置');
    expect(bubble, findsOneWidget);
    final bubbleRect = tester.getRect(bubble);

    // Bubble must be NEAR the icon (below it), NOT at screen edge/fullscreen.
    // Screen is 360x640 logical. Bubble should be within ~200px of icon.
    final dx = (bubbleRect.center.dx - iconCenter.dx).abs();
    final dy = bubbleRect.top - iconCenter.dy;
    expect(dx, lessThan(150), reason: 'bubble horizontally centered near trigger, got dx=$dx');
    expect(dy, greaterThan(0), reason: 'bottom placement: bubble below trigger');
    expect(dy, lessThan(150), reason: 'bubble close below trigger, got dy=$dy');
    expect(bubbleRect.width, lessThan(200), reason: 'bubble must not be fullscreen width, got ${bubbleRect.width}');
    expect(bubbleRect.height, lessThan(200), reason: 'bubble must not be fullscreen height, got ${bubbleRect.height}');
  });
}
