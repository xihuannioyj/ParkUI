import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'park_bindable.dart';
import 'park_binding_service.dart';

/// 组件绑定混入。
///
/// 混入给 park 输入组件，提供 [bindKey] 属性和自动双向绑定能力。
/// 通过 [ValueListenableBuilder] 驱动 UI 自动重建。
///
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with BindableWidgetMixin<String> {
///   // 自动获得 bindKey / bindingService 支持
/// }
/// ```
mixin BindableWidgetMixin<T, S extends StatefulWidget> on State<S> {
  /// 绑定键（点号分隔的路径，如 `'user.name'`）。
  String? bindKey;

  /// 绑定服务实例。
  ParkBindingService? bindingService;

  /// 当前绑定的 [ParkBindable]。
  ParkBindable<T>? _bindable;

  /// 获取当前绑定的可监听对象（供 [ValueListenableBuilder] 使用）。
  ValueListenable<T?> get boundListenable =>
      _bindable ?? _createEmptyListenable();

  /// 创建空的 ValueNotifier（未绑定时的安全占位）。
  static ValueNotifier<T?> _createEmptyListenable<T>() =>
      ValueNotifier<T?>(null);

  @override
  void initState() {
    super.initState();
    _linkBinding();
  }

  @override
  void dispose() {
    _unlinkBinding();
    super.dispose();
  }

  /// 连接绑定。
  ///
  /// 在 [initState] 或 [didUpdateWidget] 中调用。
  /// 如果 [bindKey] 和 [bindingService] 均已设置，创建绑定关系。
  void _linkBinding() {
    if (bindKey != null && bindingService != null) {
      _bindable = bindingService!.bind<T>(bindKey!);
      _bindable?.addListener(_onBindableChanged);
    }
  }

  /// 断开绑定。
  ///
  /// 在 [dispose] 或 [didUpdateWidget] 中调用。
  void _unlinkBinding() {
    _bindable?.removeListener(_onBindableChanged);
    _bindable = null;
  }

  /// 当 [ParkBindable] 值变化时更新本地状态。
  ///
  /// 默认调用 [setState] 触发重建。
  void _onBindableChanged() {
    if (mounted) setState(() {});
  }

  /// 获取当前绑定的值。
  T? get boundValue => _bindable?.value;

  /// 设置绑定的值。
  set boundValue(T? value) {
    if (value != null && _bindable != null) {
      _bindable!.value = value;
    }
  }
}
