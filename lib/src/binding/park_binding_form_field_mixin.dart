import 'package:flutter/widgets.dart';
import 'park_bindable.dart';
import 'park_binding_service.dart';
import 'park_binding_form_scope.dart';

/// FormField 状态类专用绑定混入。
///
/// 为 Park 输入组件（ParkInput/ParkTextarea/ParkSwitch/ParkSelect）提供
/// bindKey/bindingService 支持。通过重写 [didChange] 自动实现
/// FormFieldState.value ↔ ParkBindable.value 的双向同步。
///
/// 当 [bindKey] 为 null 时，绑定不启用，组件行为完全不变（零侵入）。
mixin BindableFormFieldMixin<T> on FormFieldState<T> {
  @protected
  ParkBindable<T>? get bindable => _bindable;
  ParkBindable<T>? _bindable;
  bool _isLinked = false;

  String? get _bindKey => (widget as dynamic).bindKey;
  ParkBindingService? get _bindingService => (widget as dynamic).bindingService;

  @override
  void initState() {
    super.initState();
    // widget 直接传了 service，立即绑定
    if (_bindKey != null && _bindingService != null) {
      _doLink(_bindingService!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // widget 没传 service 但设了 bindKey，从 InheritedWidget 获取
    if (!_isLinked && _bindKey != null && _bindingService == null) {
      final scope = ParkBindingFormScope.of(context);
      if (scope != null) {
        _doLink(scope.service);
      }
    }
  }

  void _doLink(ParkBindingService service) {
    final key = _bindKey;
    if (key != null) {
      _bindable = service.bind<T>(key);
      _bindable!.addListener(onBindableChanged);
      _isLinked = true;
      // 用 bindable 的初始值同步 FormField.value，确保表单字段显示默认值
      setValue(_bindable!.value as T?);
    }
  }

  void _unlinkBinding() {
    _bindable?.removeListener(onBindableChanged);
    _bindable = null;
    _isLinked = false;
  }

  @protected
  void onBindableChanged() {
    if (mounted && _bindable != null) {
      // 通过安全 cast 传递，避免 bindable.value 与 T 类型不匹配时崩溃
      didChange(_tryCast<T>(_bindable!.value));
    }
  }

  /// 将动态值安全转换为目标类型 [T]。
  ///
  /// - 值为 null 时返回 null。
  /// - 值本身即为 [T] 时直接返回。
  /// - 目标类型为 [String] 且值非 [String] 时，通过 [Object.toString] 兼容转换。
  /// - 其余类型不匹配且无法安全转换时返回 null（避免强制 cast 抛错）。
  static T? _tryCast<T>(dynamic value) {
    if (value == null) return null;
    if (value is T) return value;
    if (T == String) return value.toString() as T?;
    return null;
  }

  @override
  void didChange(T? value) {
    super.didChange(value);
    _syncToBindable(value);
  }

  void _syncToBindable(T? value) {
    if (_bindable != null && value != null) {
      _bindable!.value = value;
    }
  }

  @override
  void dispose() {
    _unlinkBinding();
    super.dispose();
  }
}
