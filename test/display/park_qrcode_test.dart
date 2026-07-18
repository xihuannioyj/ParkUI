import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_qrcode.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkQRCode', () {
    testWidgets('creates with data', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkQRCode(data: 'https://example.com'),
      ));
      expect(find.byType(ParkQRCode), findsOneWidget);
    });

    testWidgets('custom size', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkQRCode(data: 'hello', size: 100),
      ));
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 100);
      expect(sizedBox.height, 100);
    });

    testWidgets('custom foreground and background colors', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkQRCode(
          data: 'colors',
          foregroundColor: Colors.red,
          backgroundColor: Colors.yellow,
        ),
      ));
      expect(find.byType(ParkQRCode), findsOneWidget);
    });

    testWidgets('empty data renders placeholder', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkQRCode(data: '', size: 80),
      ));
      expect(find.byType(ParkQRCode), findsOneWidget);
      // Should render a SizedBox with the given size, not a QrImageView
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('with logo overlay', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkQRCode(
          data: 'logo test',
          logo: Icon(Icons.star),
          logoSize: 40,
        ),
      ));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('ParkQRErrorCorrectionLevel', () {
    test('has four levels', () {
      expect(ParkQRErrorCorrectionLevel.values.length, 4);
      expect(ParkQRErrorCorrectionLevel.low.index, 0);
      expect(ParkQRErrorCorrectionLevel.high.index, 3);
    });
  });
}
