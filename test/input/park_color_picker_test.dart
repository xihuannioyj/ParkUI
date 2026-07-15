import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkColorPicker', () {
    testWidgets('创建默认不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker()));
      expect(find.byType(ParkColorPicker), findsOneWidget);
    });

    testWidgets('预设色板默认展示 20 色 + HSV 面板', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker()));
      // 20 个预设色块 + hue slider + SV panel = 22 GestureDetectors
      expect(find.byType(GestureDetector), findsNWidgets(22));
    });

    testWidgets('presetColors=[] 隐藏预设区域但保留 HSV 面板', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker(
        presetColors: [],
        showFormatSwitch: true,
      )));
      // 3 个格式切换按钮 + 2 个 HSV 面板 = 5
      final detectors = find.byType(GestureDetector);
      expect(detectors, findsNWidgets(5));
    });

    testWidgets('enableCustom=false 不显示 HSV 面板', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker(
        enableCustom: false,
      )));
      // 20 个预设色块（无 HSV 面板）
      expect(find.byType(GestureDetector), findsNWidgets(20));
    });

    testWidgets('选择预设色块触发 onChanged', (tester) async {
      Color? picked;
      await tester.pumpWidget(_wrap(
        ParkColorPicker(
          onChanged: (c) => picked = c,
        ),
      ));

      // 点击第三个色块（presets 在前，HSV 在后）
      final detectors = find.byType(GestureDetector);
      await tester.tap(detectors.at(2));
      await tester.pumpAndSettle();

      expect(picked, isNotNull);
      expect(picked!.toARGB32(), Colors.purple.toARGB32());
    });

    testWidgets('HSV 面板色相条可拖拽', (tester) async {
      Color? picked;
      await tester.pumpWidget(_wrap(
        ParkColorPicker(
          value: Colors.red,
          onChanged: (c) => picked = c,
        ),
      ));

      // GestureDetector 顺序: 20 个预设色块(0-19) + SV面板(20) + 色相条(21)
      final detectors = find.byType(GestureDetector);
      final hueSlider = detectors.at(21);
      expect(hueSlider, findsOneWidget);

      // 在色相条上拖动
      await tester.tapAt(
        tester.getCenter(hueSlider) + const Offset(30, 0),
      );
      await tester.pumpAndSettle();

      // 颜色应该变化了（不再是纯红）
      expect(picked, isNotNull);
      expect(picked!.toARGB32(), isNot(Colors.red.toARGB32()));
    });

    testWidgets('HSV 面板 SV 区域可拖拽', (tester) async {
      Color? picked;
      await tester.pumpWidget(_wrap(
        ParkColorPicker(
          value: Colors.blue,
          onChanged: (c) => picked = c,
        ),
      ));

      // SV 面板是第 21 个 GestureDetector (index 20)
      final detectors = find.byType(GestureDetector);
      final svPicker = detectors.at(20);
      expect(svPicker, findsOneWidget);

      // 在 SV 面板上拖动
      await tester.drag(svPicker, const Offset(20, 20));
      await tester.pumpAndSettle();

      // 颜色应该变化了
      expect(picked, isNotNull);
    });

    testWidgets('showFormatSwitch=false 不显示格式切换', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker(showFormatSwitch: false)));
      // 不应有格式切换按钮文字
      expect(find.text('HEX'), findsNothing);
      expect(find.text('RGB'), findsNothing);
      expect(find.text('HSB'), findsNothing);
    });

    testWidgets('showFormatSwitch=true 显示格式切换', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker(
        showFormatSwitch: true,
        presetColors: [],
      )));
      expect(find.text('HEX'), findsOneWidget);
      expect(find.text('RGB'), findsOneWidget);
      expect(find.text('HSB'), findsOneWidget);
    });

    testWidgets('格式切换按钮可点击切换格式', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker(
        showFormatSwitch: true,
        presetColors: [],
      )));

      // 默认显示 HEX 格式值 (#...)
      expect(find.textContaining('#'), findsOneWidget);

      // 点击 RGB
      await tester.tap(find.text('RGB'));
      await tester.pumpAndSettle();

      // 应显示 rgb(...)
      expect(find.textContaining('rgb('), findsOneWidget);

      // 点击 HSB
      await tester.tap(find.text('HSB'));
      await tester.pumpAndSettle();

      // 应显示 hsb(...)
      expect(find.textContaining('hsb('), findsOneWidget);
    });

    testWidgets('自定义 presetColors', (tester) async {
      const customColors = [Colors.red, Colors.green, Colors.blue];
      await tester.pumpWidget(_wrap(
        const ParkColorPicker(presetColors: customColors),
      ));

      // 3 个预设色块 + 2 个 HSV 面板
      expect(find.byType(GestureDetector), findsNWidgets(5));
    });

    testWidgets('向后兼容: presetColors=null + showFormatSwitch=false + enableCustom=false', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker(
        enableCustom: false,
      )));

      // 展示 20 个默认预设色块（无 HSV 面板）
      expect(find.byType(GestureDetector), findsNWidgets(20));
      // 无格式切换
      expect(find.text('HEX'), findsNothing);
    });
  });
}
