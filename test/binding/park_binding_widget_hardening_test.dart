// 绑定 Widget 层加固回归测试。
//
// 覆盖：
// 1. ParkCheckbox / ParkCheckboxGroup 绑定 service 后的双向同步；
// 2. 外部写入「内容相等」的值不会 clobber UI 状态；
// 3. 改变 bindKey 会重新建链（新路径收值、旧路径不再收值）；
// 4. BindableFormFieldMixin 的相等短路：UI 回写触发的回声不再额外调用 didChange。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[
        ParkThemeData.light(),
      ]),
      home: Scaffold(body: Center(child: child)),
    );

/// 探针 FormField：直接混入 [BindableFormFieldMixin]，用于精确观测
/// 「相等短路后是否还会走 didChange（即一次多余的 setState）」。
class _ProbeField extends FormField<String> implements ParkBindableWidget {
  _ProbeField({
    this.bindKey,
    this.bindingService,
  }) : super(
          builder: (FormFieldState<String> state) => const SizedBox.shrink(),
        );

  @override
  final String? bindKey;

  @override
  final ParkBindingService? bindingService;

  @override
  FormFieldState<String> createState() => _ProbeFieldState();
}

class _ProbeFieldState extends FormFieldState<String>
    with BindableFormFieldMixin<String> {
  /// didChange 被调用的次数（含 onBindableChanged 回声触发的调用）。
  int didChangeCount = 0;

  /// 模拟用户输入：走 didChange → _syncToBindable → bindable 通知 → 回声链路。
  void simulateUserInput(String value) => didChange(value);

  @override
  void didChange(String? value) {
    didChangeCount++;
    super.didChange(value);
  }
}

const List<ParkCheckboxOption> _options = <ParkCheckboxOption>[
  ParkCheckboxOption(label: 'A', value: 'a'),
  ParkCheckboxOption(label: 'B', value: 'b'),
];

void main() {
  group('ParkCheckbox 与 service 双向绑定', () {
    testWidgets('UI → service：点击后写回绑定路径', (tester) async {
      final service = ParkBindingService(<String, dynamic>{'agree': false});

      await tester.pumpWidget(_wrap(ParkCheckbox(
        bindKey: 'agree',
        bindingService: service,
        label: const Text('同意'),
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(service.getValue<bool>('agree'), isFalse);

      await tester.tap(find.byType(ParkCheckbox));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(service.getValue<bool>('agree'), isTrue);

      service.dispose();
    });

    testWidgets('service → UI：外部写值后勾选外观同步', (tester) async {
      final service = ParkBindingService(<String, dynamic>{'agree': false});

      await tester.pumpWidget(_wrap(ParkCheckbox(
        bindKey: 'agree',
        bindingService: service,
        label: const Text('同意'),
      )));
      await tester.pumpAndSettle();

      service.setValue<bool>('agree', true);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      service.setValue<bool>('agree', false);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      service.dispose();
    });

    testWidgets('外部写入内容相等的值不 clobber UI 状态', (tester) async {
      final service = ParkBindingService(<String, dynamic>{'agree': true});

      await tester.pumpWidget(_wrap(ParkCheckbox(
        bindKey: 'agree',
        bindingService: service,
        label: const Text('同意'),
      )));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // 重复写入同一个值（ParkBindable 相等检测 → 不通知、不重建）
      service.setValue<bool>('agree', true);
      await tester.pumpAndSettle();

      expect(
        find.byIcon(Icons.check_rounded),
        findsOneWidget,
        reason: '内容相等的写入不应改变 UI 状态',
      );

      service.dispose();
    });

    testWidgets('改变 bindKey 会重新建链：新路径收值、旧路径不再收值', (tester) async {
      final service = ParkBindingService(<String, dynamic>{'a': false, 'b': false});
      late StateSetter setOuterState;
      String key = 'a';

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: <ThemeExtension<dynamic>>[
          ParkThemeData.light(),
        ]),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              setOuterState = setState;
              return ParkCheckbox(
                bindKey: key,
                bindingService: service,
                label: const Text('选项'),
              );
            },
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // 初始绑定到 'a'
      await tester.tap(find.byType(ParkCheckbox));
      await tester.pumpAndSettle();
      expect(service.getValue<bool>('a'), isTrue);
      expect(service.getValue<bool>('b'), isFalse);

      // 把旧路径复位，避免后续断言受历史值影响
      service.setValue<bool>('a', false);
      await tester.pumpAndSettle();

      // 切换绑定键 → 必须重新建链（旧实现仍写旧路径 'a'）
      setOuterState(() => key = 'b');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ParkCheckbox));
      await tester.pumpAndSettle();

      expect(service.getValue<bool>('b'), isTrue, reason: '新路径应收到写入');
      expect(service.getValue<bool>('a'), isFalse, reason: '旧路径不应再收到写入');

      service.dispose();
    });
  });

  group('ParkCheckboxGroup 与 service 双向绑定', () {
    testWidgets('UI → service 与 service → UI 双向同步', (tester) async {
      final service = ParkBindingService(<String, dynamic>{
        'hobbies': <String>[],
      });

      await tester.pumpWidget(_wrap(ParkCheckboxGroup(
        bindKey: 'hobbies',
        bindingService: service,
        options: _options,
      )));
      await tester.pumpAndSettle();

      // UI → service：点击 A
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(service.getValue<List<String>>('hobbies'), <String>['a']);

      // service → UI：外部改为只选 B
      service.setValue<List<String>>('hobbies', <String>['b']);
      await tester.pumpAndSettle();

      final List<ParkCheckbox> checkboxes =
          tester.widgetList<ParkCheckbox>(find.byType(ParkCheckbox)).toList();
      expect(checkboxes[0].initialValue, isFalse, reason: 'A 应被外部值取消选中');
      expect(checkboxes[1].initialValue, isTrue, reason: 'B 应被外部值选中');

      service.dispose();
    });

    testWidgets('外部写入内容相等的值不 clobber 组件选中状态', (tester) async {
      final service = ParkBindingService(<String, dynamic>{
        'hobbies': <String>['a'],
      });
      // 与组件共用同一个 bindable 实例，用于统计通知次数
      final ParkBindable<List<String>> bindable =
          service.bind<List<String>>('hobbies');
      int notifyCount = 0;
      bindable.addListener(() => notifyCount++);

      await tester.pumpWidget(_wrap(ParkCheckboxGroup(
        bindKey: 'hobbies',
        bindingService: service,
        options: _options,
      )));
      await tester.pumpAndSettle();

      // UI → service：用户再选 B
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(service.getValue<List<String>>('hobbies'), <String>['a', 'b']);
      final int notifyAfterTap = notifyCount;

      // 外部写入「内容相等、顺序不同、实例不同」的列表
      service.setValue<List<String>>('hobbies', <String>['b', 'a']);
      await tester.pumpAndSettle();

      expect(
        notifyCount,
        notifyAfterTap + 1,
        reason: '组件不应因内容相等的回收值再写回一次（无多余通知）',
      );

      final List<ParkCheckbox> checkboxes =
          tester.widgetList<ParkCheckbox>(find.byType(ParkCheckbox)).toList();
      expect(checkboxes[0].initialValue, isTrue, reason: 'A 仍应选中');
      expect(checkboxes[1].initialValue, isTrue, reason: 'B 仍应选中');

      service.dispose();
    });

    testWidgets('同长度但内容不同的外部值必须刷新 UI（相等判定不能只看长度+集合）',
        (tester) async {
      final service = ParkBindingService(<String, dynamic>{
        'hobbies': <String>[],
      });

      await tester.pumpWidget(_wrap(ParkCheckboxGroup(
        bindKey: 'hobbies',
        bindingService: service,
        // 初始值含重复元素：['a','a']（长度为 2）；模型初始为空，
        // 因此 _tryLinkBinding 保留 widget.value 作为内部选中态。
        value: const <String>['a', 'a'],
        options: _options,
      )));
      await tester.pumpAndSettle();

      List<ParkCheckbox> checkboxes =
          tester.widgetList<ParkCheckbox>(find.byType(ParkCheckbox)).toList();
      expect(checkboxes[0].initialValue, isTrue);
      expect(checkboxes[1].initialValue, isFalse);

      // 外部写入 ['a','b']：长度相同、集合也包含 a —— 旧启发式会漏判为「无变化」
      service.setValue<List<String>>('hobbies', <String>['a', 'b']);
      await tester.pumpAndSettle();

      checkboxes =
          tester.widgetList<ParkCheckbox>(find.byType(ParkCheckbox)).toList();
      expect(checkboxes[0].initialValue, isTrue);
      expect(
        checkboxes[1].initialValue,
        isTrue,
        reason: 'B 必须在外部值变化后被刷新为选中',
      );

      service.dispose();
    });
  });

  group('BindableFormFieldMixin 相等短路', () {
    testWidgets('UI 回写触发的回声不再额外调用 didChange', (tester) async {
      final service = ParkBindingService(<String, dynamic>{'name': 'Alice'});

      await tester.pumpWidget(_wrap(_ProbeField(
        bindKey: 'name',
        bindingService: service,
      )));
      await tester.pumpAndSettle();

      final _ProbeFieldState state =
          tester.state<_ProbeFieldState>(find.byType(_ProbeField));
      // _doLink 用 setValue 同步初始值，不经过 didChange
      expect(state.didChangeCount, 0);

      // 用户输入：didChange → _syncToBindable → bindable 通知 → onBindableChanged
      // 回声中的值与本状态当前值相等 → 必须短路，不产生第二次 didChange/setState
      state.simulateUserInput('Bob');
      await tester.pumpAndSettle();

      expect(state.didChangeCount, 1, reason: '回声应被相等短路拦下');
      expect(state.value, 'Bob');
      expect(service.getValue<String>('name'), 'Bob');

      // model → UI 方向仍然有效
      service.setValue<String>('name', 'Carol');
      await tester.pumpAndSettle();
      expect(state.didChangeCount, 2);
      expect(state.value, 'Carol');

      service.dispose();
    });

    testWidgets('改变 bindKey 会重新建链', (tester) async {
      final service = ParkBindingService(<String, dynamic>{
        'first': 'one',
        'second': 'two',
      });
      late StateSetter setOuterState;
      String key = 'first';

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: <ThemeExtension<dynamic>>[
          ParkThemeData.light(),
        ]),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              setOuterState = setState;
              return _ProbeField(bindKey: key, bindingService: service);
            },
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final _ProbeFieldState state =
          tester.state<_ProbeFieldState>(find.byType(_ProbeField));
      expect(state.value, 'one');

      setOuterState(() => key = 'second');
      await tester.pumpAndSettle();

      expect(state.value, 'two', reason: '重新建链后应取新路径的初始值');

      // 新路径收到写入，旧路径不受影响
      state.simulateUserInput('changed');
      await tester.pumpAndSettle();
      expect(service.getValue<String>('second'), 'changed');
      expect(service.getValue<String>('first'), 'one');

      service.dispose();
    });
  });
}
