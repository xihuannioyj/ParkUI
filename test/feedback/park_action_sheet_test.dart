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
  // ===========================================================================
  // ParkActionSheet — 直接渲染
  // ===========================================================================
  group('ParkActionSheet - rendering', () {
    testWidgets('renders all action labels and default cancel button',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkActionSheet(
        actions: [
          ParkAction(label: '编辑'),
          ParkAction(label: '删除'),
        ],
      )));

      expect(find.text('编辑'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);
      // showCancel defaults to true → cancel text from l10n (取消)
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('renders title and description when provided', (tester) async {
      await tester.pumpWidget(_wrap(const ParkActionSheet(
        title: '请选择操作',
        description: '此操作不可撤销',
        actions: [ParkAction(label: '删除')],
      )));

      expect(find.text('请选择操作'), findsOneWidget);
      expect(find.text('此操作不可撤销'), findsOneWidget);
    });

    testWidgets('showCancel=false hides the cancel button', (tester) async {
      await tester.pumpWidget(_wrap(const ParkActionSheet(
        actions: [ParkAction(label: '编辑')],
        showCancel: false,
      )));

      expect(find.text('编辑'), findsOneWidget);
      expect(find.text('取消'), findsNothing);
    });

    testWidgets('custom cancelText overrides the default label',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkActionSheet(
        actions: [ParkAction(label: '编辑')],
        cancelText: '关闭面板',
      )));

      expect(find.text('关闭面板'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkActionSheet.show — 交互
  // ===========================================================================
  group('ParkActionSheet - show() interactions', () {
    testWidgets('show() displays actions in a modal bottom sheet',
        (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => ParkActionSheet.show(
            context,
            actions: const [
              ParkAction(label: '分享'),
              ParkAction(label: '收藏'),
            ],
          ),
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('分享'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('tapping an action fires its onTap and returns the action',
        (tester) async {
      bool shareTapped = false;
      ParkAction? returned;
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            returned = await ParkActionSheet.show(
              context,
              actions: [
                ParkAction(label: '分享', onTap: () => shareTapped = true),
                const ParkAction(label: '收藏'),
              ],
            );
          },
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('分享'));
      await tester.pumpAndSettle();

      expect(shareTapped, isTrue);
      expect(returned, isNotNull);
      expect(returned!.label, '分享');
      // closeOnTapAction defaults to true → sheet dismissed
      expect(find.text('收藏'), findsNothing);
    });

    testWidgets('tapping cancel fires onCancel, dismisses and returns null',
        (tester) async {
      bool cancelCalled = false;
      ParkAction? returned = const ParkAction(label: 'sentinel');
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            returned = await ParkActionSheet.show(
              context,
              onCancel: () => cancelCalled = true,
              actions: const [ParkAction(label: '分享')],
            );
          },
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
      expect(returned, isNull);
      expect(find.text('分享'), findsNothing);
    });

    testWidgets('disabled action ignores tap and keeps the sheet open',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => ParkActionSheet.show(
            context,
            isDismissible: false,
            actions: [
              ParkAction(
                label: '禁用项',
                style: ParkActionStyle.disabled,
                onTap: () => tapped = true,
              ),
            ],
          ),
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('禁用项'), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
      // sheet still open (isDismissible=false)
      expect(find.text('禁用项'), findsOneWidget);
    });
  });
}
