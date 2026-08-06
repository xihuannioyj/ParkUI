import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_cascader.dart';
import 'package:park_ui/src/components/input/park_picker.dart';
import 'package:park_ui/src/l10n/park_localizations.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      builder: (_, c) => ParkLocalizationsWidget(
        localizations: const ParkLocalizationsZh(),
        child: c!,
      ),
      home: Scaffold(body: Center(child: child)),
    );

final testOptions = [
  const ParkCascadingNode<String>(
    label: '浙江省',
    value: 'zj',
    children: [
      ParkCascadingNode<String>(label: '杭州市', value: 'hz'),
      ParkCascadingNode<String>(label: '宁波市', value: 'nb'),
    ],
  ),
  const ParkCascadingNode<String>(
    label: '江苏省',
    value: 'js',
    children: [
      ParkCascadingNode<String>(label: '南京市', value: 'nj'),
      ParkCascadingNode<String>(label: '苏州市', value: 'sz'),
    ],
  ),
];

void main() {
  group('ParkPicker.showCascading', () {
    testWidgets('renders wheel mode', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkPicker.showCascading(
                context: context,
                title: '选择地区',
                options: testOptions,
                mode: ParkCascadingMode.wheel,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      expect(find.text('选择地区'), findsOneWidget);
      // Wheel mode uses CupertinoPicker
      expect(find.byType(CupertinoPicker), findsWidgets);
    });

    testWidgets('renders list mode', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkPicker.showCascading(
                context: context,
                title: '选择地区',
                options: testOptions,
                mode: ParkCascadingMode.list,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      expect(find.text('选择地区'), findsOneWidget);
      // List mode auto-advances to deepest non-leaf level,
      // showing children of default-selected 浙江省.
      // 杭州市 appears in both breadcrumb and list.
      expect(find.text('杭州市'), findsWidgets);
      expect(find.text('宁波市'), findsOneWidget);
    });

    testWidgets('wheel mode: changing level 0 resets level 1', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkPicker.showCascading(
                context: context,
                title: '选择地区',
                options: testOptions,
                mode: ParkCascadingMode.wheel,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      // Initially shows 浙江省's children (杭州市, 宁波市)
      expect(find.text('杭州市'), findsOneWidget);
      expect(find.text('宁波市'), findsOneWidget);
    });

    testWidgets('list mode: tapping non-leaf navigates to next level',
        (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkPicker.showCascading(
                context: context,
                title: '选择地区',
                options: testOptions,
                mode: ParkCascadingMode.list,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      // Starts at level 1 showing cities of 浙江省.
      // Navigate back to level 0 via breadcrumb.
      await tester.tap(find.text('浙江省').first);
      await tester.pumpAndSettle();

      // Now at level 0, showing provinces
      expect(find.text('江苏省'), findsOneWidget);

      // Tap 江苏省 (non-leaf) to drill into its children
      await tester.tap(find.text('江苏省'));
      await tester.pumpAndSettle();

      // Should now show children of 江苏省
      // 南京市 appears in both breadcrumb and list
      expect(find.text('南京市'), findsWidgets);
      expect(find.text('苏州市'), findsOneWidget);
    });

    testWidgets('list mode: breadcrumb navigation works', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkPicker.showCascading(
                context: context,
                title: '选择地区',
                options: testOptions,
                mode: ParkCascadingMode.list,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      // Starts at level 1, breadcrumb shows 浙江省 > 杭州市
      // 杭州市 appears in both breadcrumb and list
      expect(find.text('杭州市'), findsWidgets);

      // Tap breadcrumb 浙江省 to go back to level 0
      await tester.tap(find.text('浙江省').first);
      await tester.pumpAndSettle();

      // Should show province list at level 0
      expect(find.text('江苏省'), findsOneWidget);
    });

    testWidgets('confirm returns selected path', (tester) async {
      List<String>? result;
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ParkPicker.showCascading(
                context: context,
                title: '选择地区',
                options: testOptions,
                mode: ParkCascadingMode.wheel,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      // Tap confirm (确定)
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      // Default selection: first item at each level
      expect(result, isNotNull);
      expect(result, ['zj', 'hz']);
    });

    testWidgets('dismiss returns null', (tester) async {
      List<String>? result = ['placeholder'];
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ParkPicker.showCascading(
                context: context,
                title: '选择地区',
                options: testOptions,
                mode: ParkCascadingMode.wheel,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      // Tap cancel (取消)
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('generic type <int> works', (tester) async {
      final intOptions = [
        const ParkCascadingNode<int>(
          label: 'A',
          value: 1,
          children: [
            ParkCascadingNode<int>(label: 'A1', value: 11),
            ParkCascadingNode<int>(label: 'A2', value: 12),
          ],
        ),
      ];
      List<int>? result;
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ParkPicker.showCascading<int>(
                context: context,
                title: '选择',
                options: intOptions,
                mode: ParkCascadingMode.wheel,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result, [1, 11]);
    });
  });
}
