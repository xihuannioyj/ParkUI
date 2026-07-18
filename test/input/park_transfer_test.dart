import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_transfer.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkTransfer', () {
    testWidgets('creates with data source', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTransfer(
          dataSource: const [
            ParkTransferItem(key: '1', title: 'Item A'),
            ParkTransferItem(key: '2', title: 'Item B'),
            ParkTransferItem(key: '3', title: 'Item C'),
          ],
        ),
      ));
      expect(find.byType(ParkTransfer), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
    });

    testWidgets('shows left and right titles', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTransfer(
          dataSource: const [
            ParkTransferItem(key: '1', title: 'A'),
            ParkTransferItem(key: '2', title: 'B'),
          ],
          leftTitle: const Text('Source'),
          rightTitle: const Text('Target'),
        ),
      ));
      expect(find.text('Source'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
    });

    testWidgets('targetKeys pre-select items', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTransfer(
          dataSource: const [
            ParkTransferItem(key: '1', title: 'A'),
            ParkTransferItem(key: '2', title: 'B'),
            ParkTransferItem(key: '3', title: 'C'),
          ],
          targetKeys: const ['2'],
        ),
      ));
      expect(find.byType(ParkTransfer), findsOneWidget);
    });

    testWidgets('disabled state renders', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTransfer(
          dataSource: const [
            ParkTransferItem(key: '1', title: 'A'),
          ],
          disabled: true,
        ),
      ));
      expect(find.byType(ParkTransfer), findsOneWidget);
    });

    testWidgets('showSearch renders search fields', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTransfer(
          dataSource: const [
            ParkTransferItem(key: '1', title: 'A'),
            ParkTransferItem(key: '2', title: 'B'),
          ],
          showSearch: true,
        ),
      ));
      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('ParkTransferItem', () {
    test('basic properties', () {
      const item = ParkTransferItem(key: 'k1', title: 'Title', subtitle: 'Sub');
      expect(item.key, 'k1');
      expect(item.title, 'Title');
      expect(item.subtitle, 'Sub');
    });
  });

  group('TransferDirection', () {
    test('has two values', () {
      expect(TransferDirection.values.length, 2);
      expect(TransferDirection.leftToRight.index, 0);
      expect(TransferDirection.rightToLeft.index, 1);
    });
  });
}
