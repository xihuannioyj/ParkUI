import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_watermark.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: SizedBox(width: 300, height: 200, child: child)),
    );

void main() {
  group('ParkWatermark', () {
    testWidgets('creates with text', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkWatermark(
          text: 'Confidential',
          child: Text('Content'),
        ),
      ));
      expect(find.byType(ParkWatermark), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    test('creates with image widget', () {
      final widget = ParkWatermark(
        image: const Icon(Icons.star, size: 24),
        child: const Text('Content'),
      );
      expect(widget.image, isA<Icon>());
      expect(widget.text, isNull);
    });

    testWidgets('custom color and fontSize', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkWatermark(
          text: 'Draft',
          color: Color(0xFF123456),
          fontSize: 20,
          child: Text('Body'),
        ),
      ));
      expect(find.byType(ParkWatermark), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('custom rotate and gap', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkWatermark(
          text: 'Sample',
          rotate: -45,
          gapX: 80,
          gapY: 60,
          child: Text('Data'),
        ),
      ));
      expect(find.byType(ParkWatermark), findsOneWidget);
    });

    test('asserts when neither text nor image provided', () {
      expect(
        () => ParkWatermark(child: const Text('x')),
        throwsAssertionError,
      );
    });
  });
}
