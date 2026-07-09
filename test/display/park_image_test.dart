import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkImage', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkImage.asset('placeholder')));
      expect(find.byType(ParkImage), findsOneWidget);
    });
    testWidgets('网络图片', (tester) async {
      await tester.pumpWidget(_wrap(const ParkImage.network('https://example.com/img.png')));
      expect(find.byType(ParkImage), findsOneWidget);
    });
    testWidgets('自定义宽高', (tester) async {
      await tester.pumpWidget(_wrap(const ParkImage.asset('placeholder', width: 100, height: 100)));
      expect(find.byType(ParkImage), findsOneWidget);
    });
    testWidgets('fit模式', (tester) async {
      await tester.pumpWidget(_wrap(const ParkImage.asset('placeholder', fit: BoxFit.cover)));
      expect(find.byType(ParkImage), findsOneWidget);
    });
  });
}
