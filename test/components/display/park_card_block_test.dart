import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ParkCardBlock', () {
    testWidgets('renders title and widget list', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCardBlock(
        title: '收款信息',
        widgetList: [Text('内容块1'), Text('内容块2')],
      )));
      expect(find.text('收款信息'), findsOneWidget);
      expect(find.text('内容块1'), findsOneWidget);
      expect(find.text('内容块2'), findsOneWidget);
      expect(find.byType(ParkText), findsOneWidget);
    });

    testWidgets('renders extensionWidget with brand icon color',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkCardBlock(
        title: '收款信息',
        widgetList: [Text('内容块1')],
        extensionWidget: Icon(Icons.add_circle_outline),
      )));
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      final iconTheme = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.add_circle_outline),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(iconTheme.data.color, ParkThemeData.light().colors.brand);
    });

    testWidgets('hides extension area when extensionWidget is null',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkCardBlock(
        title: '收款信息',
        widgetList: [Text('内容块1')],
      )));
      expect(find.byIcon(Icons.add_circle_outline), findsNothing);
    });
  });
}
