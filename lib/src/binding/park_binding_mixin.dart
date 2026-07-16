import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'park_bindable.dart';
import 'park_binding_service.dart';
import 'park_binding_form_scope.dart';

/// 组件绑定混入。
///
/// 混入给 park 输入组件，提供 [bindKey] 属性和自动双向绑定能力。
/// 通过 [ValueListenableBuilder] 驱动 UI 自动重建。
///
/// 绑定服务解析顺序（B22 / 开发文档.md §5.x）：
/// 1. 显式传入的 [bindingService]；
/// 2. 未传时尝试从最近的 [ParkBindingFormScope] 获取（表单作用域内自动绑定）。
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

  /// 绑定服务引用（dispose 时用于释放注册）。
  ParkBindingService? _bindingService;

  /// 是否已建立绑定连接（避免重复链接）。
  bool _isLinked = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 若显式 bindingService 未提供，尝试从最近的 ParkBindingFormScope 获取，
    // 使组件在表单作用域内仅凭 bindKey 即自动双向绑定（对齐 BindableFormFieldMixin）。
    if (!_isLinked && bindKey != null) {
      final ParkBindingService? svc =
          bindingService ?? ParkBindingFormScope.of(context)?.service;
      if (svc != null) _linkBindingWith(svc);
    }
  }

  @override
  void dispose() {
    _unlinkBinding();
    if (bindKey != null) {
      _bindingService?.disposeBindable(bindKey!);
    }
    super.dispose();
  }

  /// 连接绑定。
  ///
  /// 如果 [bindKey] 和 [bindingService] 均已设置，创建绑定关系。
  void _linkBinding() {
    if (bindKey != null && bindingService != null) {
      _linkBindingWith(bindingService!);
    }
  }

  /// 使用指定服务建立绑定连接（幂等）。
  void _linkBindingWith(ParkBindingService svc) {
    if (_isLinked || bindKey == null) return;
    _bindingService = svc;
    _bindable = svc.bind<T>(bindKey!);
    _bindable?.addListener(onBindableChanged);
    _isLinked = true;
  }

  /// 断开绑定。
  void _unlinkBinding() {
    _bindable?.removeListener(onBindableChanged);
    _bindable = null;
    _isLinked = false;
  }

  /// 当 [ParkBindable] 值变化时更新本地状态。
  ///
  /// 默认调用 [setState] 触发重建。子类可重写以同步内部控制器等。
  void onBindableChanged() {
    if (mounted) setState(() {});
  }

  /// 获取当前绑定的值。
  T? get boundValue => _bindable?.value;

  /// 设置绑定的值。
  set boundValue(T? value) {
    if (_bindable != null && value != null) {
      _bindable!.value = value;
    }
  }
}
