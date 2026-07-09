import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('ParkDescriptions', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            items: [
              ParkDescriptionItem(label: '姓名', value: '张三'),
              ParkDescriptionItem(label: '年龄', value: '28'),
            ],
          ),
        ),
      );
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
    });

    testWidgets('显示标题与 action', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkDescriptions(
            title: '订单详情',
            action: const Text('编辑'),
            items: const [
              ParkDescriptionItem(label: '订单号', value: 'DD001'),
            ],
          ),
        ),
      );
      expect(find.text('订单详情'), findsOneWidget);
      expect(find.text('编辑'), findsOneWidget);
    });

    testWidgets('不显示标题时无标题栏', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            items: [
              ParkDescriptionItem(label: '姓名', value: '李四'),
            ],
          ),
        ),
      );
      expect(find.text('李四'), findsOneWidget);
    });

    testWidgets('bordered 模式渲染 label 和 value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            bordered: true,
            column: 2,
            items: [
              ParkDescriptionItem(label: '订单号', value: 'DD002'),
              ParkDescriptionItem(label: '状态', value: '已支付'),
            ],
          ),
        ),
      );
      expect(find.text('订单号'), findsOneWidget);
      expect(find.text('DD002'), findsOneWidget);
      expect(find.text('状态'), findsOneWidget);
      expect(find.text('已支付'), findsOneWidget);
    });

    testWidgets('borderless 模式渲染 label 和 value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            bordered: false,
            column: 2,
            items: [
              ParkDescriptionItem(label: '姓名', value: '王五'),
              ParkDescriptionItem(label: '邮箱', value: 'wangwu@test.com'),
            ],
          ),
        ),
      );
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('王五'), findsOneWidget);
      expect(find.text('邮箱'), findsOneWidget);
      expect(find.text('wangwu@test.com'), findsOneWidget);
    });

    testWidgets('span=2 跨列渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            bordered: true,
            column: 2,
            items: [
              ParkDescriptionItem(label: '订单号', value: 'DD003'),
              ParkDescriptionItem(label: '状态', value: '已发货'),
              ParkDescriptionItem(label: '收货地址', value: '北京市朝阳区', span: 2),
            ],
          ),
        ),
      );
      expect(find.text('收货地址'), findsOneWidget);
      expect(find.text('北京市朝阳区'), findsOneWidget);
    });

    testWidgets('空值显示占位符', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            emptyText: '暂无',
            items: [
              ParkDescriptionItem(label: '姓名', value: null),
              ParkDescriptionItem(label: '年龄', value: ''),
            ],
          ),
        ),
      );
      // 两个空值都应显示占位符
      expect(find.text('暂无'), findsNWidgets(2));
    });

    testWidgets('默认空值占位符为破折号', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            items: [
              ParkDescriptionItem(label: '备注', value: null),
            ],
          ),
        ),
      );
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('自定义 valueWidget 优先于 value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkDescriptions(
            items: [
              ParkDescriptionItem(
                label: '状态',
                value: '文本值',
                valueWidget: const Icon(Icons.check_circle, size: 16),
              ),
            ],
          ),
        ),
      );
      // valueWidget 显示，value 文本不显示
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('文本值'), findsNothing);
    });

    testWidgets('单列布局', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            column: 1,
            bordered: true,
            items: [
              ParkDescriptionItem(label: '合同编号', value: 'HT-001'),
              ParkDescriptionItem(label: '甲方', value: '公司A'),
            ],
          ),
        ),
      );
      expect(find.text('合同编号'), findsOneWidget);
      expect(find.text('HT-001'), findsOneWidget);
      expect(find.text('甲方'), findsOneWidget);
      expect(find.text('公司A'), findsOneWidget);
    });

    testWidgets('三列布局', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            column: 3,
            bordered: true,
            items: [
              ParkDescriptionItem(label: 'A', value: '1'),
              ParkDescriptionItem(label: 'B', value: '2'),
              ParkDescriptionItem(label: 'C', value: '3'),
            ],
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('labelWidth 固定宽度', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            labelWidth: 120,
            items: [
              ParkDescriptionItem(label: '较长的标签文本', value: '值'),
            ],
          ),
        ),
      );
      expect(find.text('较长的标签文本'), findsOneWidget);
      expect(find.text('值'), findsOneWidget);
    });

    testWidgets('空 items 列表不抛异常', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            title: '空列表',
            items: [],
          ),
        ),
      );
      expect(find.text('空列表'), findsOneWidget);
    });

    testWidgets('span 超出列数时自动 clamp', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkDescriptions(
            column: 2,
            bordered: true,
            items: [
              ParkDescriptionItem(label: '备注', value: '跨列内容', span: 5),
            ],
          ),
        ),
      );
      expect(find.text('备注'), findsOneWidget);
      expect(find.text('跨列内容'), findsOneWidget);
    });
  });

  group('ParkDescriptionItem', () {
    test('默认 span 为 1', () {
      const item = ParkDescriptionItem(label: '测试', value: '值');
      expect(item.span, 1);
    });

    test('label 必填', () {
      const item = ParkDescriptionItem(label: '标签');
      expect(item.label, '标签');
      expect(item.value, isNull);
      expect(item.valueWidget, isNull);
    });
  });
}
