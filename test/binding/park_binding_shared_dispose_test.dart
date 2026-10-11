import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 同一 `bindKey` 被多个 widget 共用时的生命周期契约。
///
/// 旧实现里 [BindableWidgetMixin] 的 dispose 会无条件
/// `disposeBindable(bindKey)`：先销毁的那个 widget 会把共享的
/// [ParkBindable] 释放掉，另一个 widget 之后写值就会抛 AssertionError。
class _Probe extends StatefulWidget {
  const _Probe({super.key, required this.bindKey, required this.service});

  final String bindKey;
  final ParkBindingService service;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe>
    with BindableWidgetMixin<String, _Probe> {
  @override
  void initState() {
    // 必须在 super.initState() 之前赋值：混入的 initState 会立即建链。
    bindKey = widget.bindKey;
    bindingService = widget.service;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: boundListenable,
      builder: (BuildContext context, String? value, Widget? child) =>
          Text(value ?? ''),
    );
  }
}

Widget _host(ParkBindingService service, List<Widget> children) =>
    MaterialApp(home: Column(children: children));

void main() {
  testWidgets('同一路径多 widget：先销毁的不释放共享 bindable', (WidgetTester tester) async {
    final ParkBindingService service = ParkBindingService(<String, dynamic>{
      'name': 'A',
    });

    await tester.pumpWidget(
      _host(service, <Widget>[
        _Probe(key: const ValueKey<String>('a'), bindKey: 'name', service: service),
        _Probe(key: const ValueKey<String>('b'), bindKey: 'name', service: service),
      ]),
    );
    expect(find.text('A'), findsNWidgets(2));

    // 移除第一个 widget：共享 bindable 不能被释放
    await tester.pumpWidget(
      _host(service, <Widget>[
        _Probe(key: const ValueKey<String>('b'), bindKey: 'name', service: service),
      ]),
    );

    // 剩下那个仍能收到新值（旧实现这里会抛 AssertionError）
    service.setValue('name', 'B');
    await tester.pump();
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('最后一个监听者销毁后 bindable 才会被释放', (WidgetTester tester) async {
    final ParkBindingService service = ParkBindingService(<String, dynamic>{
      'name': 'A',
    });

    await tester.pumpWidget(
      _host(service, <Widget>[
        _Probe(key: const ValueKey<String>('a'), bindKey: 'name', service: service),
      ]),
    );

    // 唯一监听者销毁 -> 实例被释放；此时走服务层写值不应抛异常
    await tester.pumpWidget(_host(service, <Widget>[]));
    service.setValue('name', 'C');
    await tester.pump();

    expect(service.bind<String>('name').value, 'C');
  });
}
