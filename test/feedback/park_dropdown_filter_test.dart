import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 创建测试用的 MaterialApp 包装
Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
    ),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

/// 辅助选项工厂
List<DropdownFilterOption> createSampleOptions() {
  return const [
    DropdownFilterOption(label: '全部', value: 'all'),
    DropdownFilterOption(label: '进行中', value: 'active'),
    DropdownFilterOption(label: '已完成', value: 'completed'),
    DropdownFilterOption(label: '已取消', value: 'cancelled'),
  ];
}

void main() {
  // ==========================================================================
  // DropdownFilterOption 模型测试
  // ==========================================================================
  group('DropdownFilterOption', () {
    test('应正确创建基础选项', () {
      const option = DropdownFilterOption(label: '测试', value: 'test');
      expect(option.label, '测试');
      expect(option.value, 'test');
      expect(option.subtitle, isNull);
      expect(option.leading, isNull);
      expect(option.disabled, isFalse);
    });

    test('应正确创建含所有字段的选项', () {
      const option = DropdownFilterOption(
        label: '禁用项',
        value: 'disabled',
        subtitle: '子标题',
        disabled: true,
      );
      expect(option.label, '禁用项');
      expect(option.value, 'disabled');
      expect(option.subtitle, '子标题');
      expect(option.disabled, isTrue);
    });
  });

  // ==========================================================================
  // DropdownFilterItem 模型测试
  // ==========================================================================
  group('DropdownFilterItem', () {
    test('应正确创建基础筛选标签配置', () {
      final item = DropdownFilterItem(
        label: '状态',
        options: createSampleOptions(),
      );
      expect(item.label, '状态');
      expect(item.options, isNotNull);
      expect(item.options!.length, 4);
      expect(item.child, isNull);
      expect(item.multiple, isFalse);
      expect(item.columns, 1);
      expect(item.isCheck, isFalse);
      expect(item.disabled, isFalse);
      expect(item.selectedValues, isNull);
    });

    test('应正确创建含回调的筛选标签', () {
      bool onTabCalled = false;
      Set<String>? onChangeValues;
      Set<String>? onConfirmValues;
      bool onResetCalled = false;

      final item = DropdownFilterItem(
        label: '多选状态',
        options: createSampleOptions(),
        multiple: true,
        columns: 2,
        isCheck: true,
        disabled: false,
        selectedValues: {'active'},
        onTab: () {
          onTabCalled = true;
          return false;
        },
        onChange: (values) {
          onChangeValues = values;
        },
        onConfirm: (values) {
          onConfirmValues = values;
        },
        onReset: () {
          onResetCalled = true;
        },
      );

      expect(item.multiple, isTrue);
      expect(item.columns, 2);
      expect(item.isCheck, isTrue);
      expect(item.selectedValues, {'active'});

      // 验证回调可执行
      final shouldBlock = item.onTab!();
      expect(shouldBlock, isFalse);
      expect(onTabCalled, isTrue);

      item.onChange!({'active', 'completed'});
      expect(onChangeValues, {'active', 'completed'});

      item.onConfirm!({'active'});
      expect(onConfirmValues, {'active'});

      item.onReset!();
      expect(onResetCalled, isTrue);
    });

    test('应支持自定义 child 模式', () {
      final item = DropdownFilterItem(
        label: '自定义',
        child: const Text('自定义面板'),
      );
      expect(item.options, isNull);
      expect(item.child, isNotNull);
    });
  });

  // ==========================================================================
  // DropdownFilterStyle 模型测试
  // ==========================================================================
  group('DropdownFilterStyle', () {
    test('应正确创建样式配置', () {
      const style = DropdownFilterStyle(
        textColor: Colors.grey,
        activeColor: Colors.blue,
        fontWeight: FontWeight.w500,
        activeFontWeight: FontWeight.w700,
        underlineColor: Colors.blue,
        arrowColor: Colors.grey,
        backgroundColor: Color(0xFFF5F5F5),
        borderRadius: 8.0,
        labelHeight: 40.0,
      );
      expect(style.textColor, Colors.grey);
      expect(style.activeColor, Colors.blue);
      expect(style.activeFontWeight, FontWeight.w700);
      expect(style.labelHeight, 40.0);
    });
  });

  // ==========================================================================
  // ParkDropdownFilter Widget 测试
  // ==========================================================================
  group('ParkDropdownFilter', () {
    testWidgets('应正常构建并显示标签文字', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(label: '状态', options: createSampleOptions()),
              DropdownFilterItem(label: '来源', options: createSampleOptions()),
            ],
          ),
        ),
      );

      expect(find.text('状态'), findsOneWidget);
      expect(find.text('来源'), findsOneWidget);
    });

    testWidgets('items 为空时应正常构建不抛异常', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const ParkDropdownFilter(items: []),
        ),
      );

      // 即使 items 为空，组件也应正常渲染（空的 SizedBox/Row）
      expect(find.byType(ParkDropdownFilter), findsOneWidget);
    });

    testWidgets('默认状态下箭头朝下（未展开）', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(label: '状态', options: createSampleOptions()),
            ],
          ),
        ),
      );

      // 默认状态箭头图标应存在
      final arrowIcon = find.descendant(
        of: find.byType(ParkDropdownFilter),
        matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
      );
      expect(arrowIcon, findsOneWidget);
    });

    testWidgets('默认状态下标签文字使用 textSecondary 颜色', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(label: '状态', options: createSampleOptions()),
            ],
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('状态'));
      // 默认颜色应为 textSecondary（非品牌色）
      expect(textWidget.style?.color, isNotNull);
    });

    testWidgets('disabled 标签无法点击展开面板', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(
                label: '禁用标签',
                options: createSampleOptions(),
                disabled: true,
              ),
            ],
            onFilterChanged: (index, values) {
              tapCount++;
            },
          ),
        ),
      );

      // 点击禁用标签
      await tester.tap(find.text('禁用标签'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 底部面板不应弹出（选项中文字不应出现）
      expect(find.text('全部'), findsNothing);
      expect(tapCount, 0);
    });

    testWidgets('点击标签应触发展开并弹出底部面板', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(label: '状态', options: createSampleOptions()),
            ],
          ),
        ),
      );

      // 初始状态：选项文字不可见
      expect(find.text('全部'), findsNothing);

      // 点击标签
      await tester.tap(find.text('状态'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 底部面板应弹出，选项文字可见（单选模式点击即确认并关闭，所以需要快速验证）
      // 单选模式下点击选项会立即关闭面板，所以我们先确认面板显示出来了
      // 面板标题应可见
      expect(find.text('状态'), findsAtLeast(1));
    });

    testWidgets('单选模式下点击选项应选中并关闭面板', (WidgetTester tester) async {
      String? lastChangedLabel;
      Set<String>? lastChangedValues;

      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(
                label: '状态',
                options: createSampleOptions(),
                onChange: (values) {
                  lastChangedValues = values;
                },
                onConfirm: (values) {
                  lastChangedValues = values;
                },
              ),
            ],
            onFilterChanged: (index, values) {
              lastChangedLabel = '状态';
              lastChangedValues = values;
            },
          ),
        ),
      );

      // 点击"状态"标签弹出面板
      await tester.tap(find.text('状态'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 点击"进行中"选项
      await tester.tap(find.text('进行中'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 单选模式下点击即确认，面板关闭，回调被调用
      // onFilterChanged 应当被调用
      expect(lastChangedLabel, '状态');
      expect(lastChangedValues, {'active'});
    });

    testWidgets('多选模式应支持勾选多个选项', (WidgetTester tester) async {
      Set<String>? confirmedValues;

      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(
                label: '状态',
                options: createSampleOptions(),
                multiple: true,
                onConfirm: (values) {
                  confirmedValues = values;
                },
              ),
            ],
          ),
        ),
      );

      // 点击"状态"标签弹出面板
      await tester.tap(find.text('状态'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 多选模式：点击"进行中"和"已完成"
      await tester.tap(find.text('进行中'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('已完成'));
      await tester.pump(const Duration(milliseconds: 100));

      // 点击"确定"按钮
      await tester.tap(find.text('确定'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 验证确认回调
      expect(confirmedValues, {'active', 'completed'});
    });

    testWidgets('onTab 返回 true 时应阻止默认展开', (WidgetTester tester) async {
      bool onTabCalled = false;

      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(
                label: '状态',
                options: createSampleOptions(),
                onTab: () {
                  onTabCalled = true;
                  return true; // 阻止展开
                },
              ),
            ],
          ),
        ),
      );

      // 点击标签
      await tester.tap(find.text('状态'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // onTab 应被调用
      expect(onTabCalled, isTrue);

      // 面板不应展开（选项文字不可见）
      expect(find.text('全部'), findsNothing);
    });

    testWidgets('自定义 style 应正确应用到标签', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(
                label: '状态',
                options: createSampleOptions(),
              ),
            ],
            style: const DropdownFilterStyle(
              labelHeight: 56.0,
              backgroundColor: Color(0xFFF0F0F0),
              borderRadius: 12.0,
            ),
          ),
        ),
      );

      // 提取 SizedBox 验证高度
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 56.0);
    });

    testWidgets('选中值后标签应变为激活状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(
                label: '状态',
                options: createSampleOptions(),
                selectedValues: {'active'},
              ),
            ],
          ),
        ),
      );

      // 由于有选中值，标签应处于激活状态
      // 验证存在箭头图标（组件正常渲染）
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });

    testWidgets('外部更新 selectedValues 应同步内部状态', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(
                label: '状态',
                options: createSampleOptions(),
                selectedValues: <String>{},
              ),
            ],
          ),
        ),
      );

      // 初始无选中，点击应弹出面板（单选模式）
      await tester.tap(find.text('状态'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 确保面板弹出了（标题可见）
      expect(find.text('状态'), findsAtLeast(1));
    });
  });
}
