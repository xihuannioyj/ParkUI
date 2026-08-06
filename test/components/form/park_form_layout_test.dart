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
  group('ParkFormIntro', () {
    testWidgets('renders title, description and badge', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormIntro(
        title: '换房签约',
        description: '先确认新房间和合同周期。',
        icon: Icons.compare_arrows_rounded,
        badgeText: '第1步 / 3',
      )));
      expect(find.text('换房签约'), findsOneWidget);
      expect(find.text('先确认新房间和合同周期。'), findsOneWidget);
      expect(find.text('第1步 / 3'), findsOneWidget);
      expect(find.byIcon(Icons.compare_arrows_rounded), findsOneWidget);
    });

    testWidgets('defaults to description icon when icon is null',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormIntro(title: '标题')));
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('hides badge and description when absent', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormIntro(title: '标题')));
      expect(find.text('第1步 / 3'), findsNothing);
    });
  });

  group('ParkFormPageBody', () {
    testWidgets('renders sections and footer', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormPageBody(
        sections: [Text('区块A'), Text('区块B')],
        footer: Text('底部'),
      )));
      expect(find.text('区块A'), findsOneWidget);
      expect(find.text('区块B'), findsOneWidget);
      expect(find.text('底部'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('uses custom padding and sectionSpacing', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormPageBody(
        sections: [Text('A'), Text('B')],
        padding: EdgeInsets.all(24),
        sectionSpacing: 32,
      )));
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, const EdgeInsets.all(24));
      // 两个区块之间插入一个 32 高的间距
      final spacers = tester
          .widgetList<SizedBox>(find.descendant(
            of: find.byType(ListView),
            matching: find.byType(SizedBox),
          ))
          .where((s) => s.height == 32);
      expect(spacers.length, 1);
    });
  });

  group('ParkFormSectionCard', () {
    testWidgets('renders title, description, children with dividers',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormSectionCard(
        title: '基本信息',
        description: '先确定基本信息。',
        children: [Text('行1'), Text('行2'), Text('行3')],
      )));
      expect(find.text('基本信息'), findsOneWidget);
      expect(find.text('先确定基本信息。'), findsOneWidget);
      expect(find.text('行1'), findsOneWidget);
      expect(find.text('行2'), findsOneWidget);
      expect(find.text('行3'), findsOneWidget);
      // 3 个子项之间应有 2 条分割线
      expect(find.byType(ParkDivider), findsNWidgets(2));
      expect(find.byType(ParkCard), findsOneWidget);
    });

    testWidgets('renders extensionWidget and icon', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormSectionCard(
        title: '标题',
        icon: Icons.info_outline,
        extensionWidget: Icon(Icons.more_horiz),
        children: [Text('行1')],
      )));
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('single child renders without divider', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormSectionCard(
        title: '标题',
        children: [Text('行1')],
      )));
      expect(find.byType(ParkDivider), findsNothing);
    });
  });

  group('ParkFormSubmitButton', () {
    testWidgets('renders text and fires onPressed', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(_wrap(ParkFormSubmitButton(
        text: '提交',
        onPressed: () => pressed++,
      )));
      expect(find.text('提交'), findsOneWidget);
      await tester.tap(find.text('提交'));
      await tester.pump();
      expect(pressed, 1);
    });
  });

  group('ParkFormStepActions', () {
    testWidgets('renders back/next and fires callbacks', (tester) async {
      var back = 0;
      var next = 0;
      await tester.pumpWidget(_wrap(ParkFormStepActions(
        canGoBack: true,
        nextText: '下一步',
        onBack: () => back++,
        onNext: () => next++,
      )));
      expect(find.text('上一步'), findsOneWidget);
      expect(find.text('下一步'), findsOneWidget);
      await tester.tap(find.text('上一步'));
      await tester.pump();
      await tester.tap(find.text('下一步'));
      await tester.pump();
      expect(back, 1);
      expect(next, 1);
    });

    testWidgets('back button disabled when canGoBack is false',
        (tester) async {
      await tester.pumpWidget(_wrap(ParkFormStepActions(
        canGoBack: false,
        nextText: '下一步',
        onBack: () {},
        onNext: () {},
      )));
      final backButton = tester.widget<ParkButton>(
        find.ancestor(
          of: find.text('上一步'),
          matching: find.byType(ParkButton),
        ),
      );
      expect(backButton.onPressed, isNull);
    });
  });

  group('ParkFormModalHeader', () {
    testWidgets('renders title with localized cancel/confirm defaults',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormModalHeader(
        title: '编辑合同',
        onCancel: null,
        onConfirm: null,
      )));
      expect(find.text('编辑合同'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);
    });

    testWidgets('uses custom cancel/confirm texts', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormModalHeader(
        title: '标题',
        onCancel: null,
        onConfirm: null,
        cancelText: '返回',
        confirmText: '保存',
      )));
      expect(find.text('返回'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);
    });

    testWidgets('confirm disabled when confirmEnabled is false',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormModalHeader(
        title: '标题',
        onCancel: null,
        onConfirm: null,
        confirmEnabled: false,
      )));
      final confirmButton = tester.widget<ParkButton>(
        find.ancestor(
          of: find.text('确定'),
          matching: find.byType(ParkButton),
        ),
      );
      expect(confirmButton.onPressed, isNull);
    });

    testWidgets('fires cancel and confirm callbacks', (tester) async {
      var cancel = 0;
      var confirm = 0;
      await tester.pumpWidget(_wrap(ParkFormModalHeader(
        title: '标题',
        onCancel: () => cancel++,
        onConfirm: () => confirm++,
      )));
      await tester.tap(find.text('取消'));
      await tester.pump();
      await tester.tap(find.text('确定'));
      await tester.pump();
      expect(cancel, 1);
      expect(confirm, 1);
    });
  });

  group('ParkFormModalScaffold', () {
    testWidgets('renders header and child', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormModalScaffold(
        title: '弹层标题',
        onCancel: null,
        onConfirm: null,
        child: Text('内容'),
      )));
      expect(find.text('弹层标题'), findsOneWidget);
      expect(find.text('内容'), findsOneWidget);
    });

    testWidgets('applies bodyHeight to child', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormModalScaffold(
        title: '弹层标题',
        onCancel: null,
        onConfirm: null,
        bodyHeight: 200,
        child: Text('内容'),
      )));
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.text('内容'),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.height, 200);
    });
  });
}
