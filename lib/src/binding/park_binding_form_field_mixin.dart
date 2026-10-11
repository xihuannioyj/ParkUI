import 'package:flutter/widgets.dart';
import 'park_bindable.dart';
import 'park_binding_service.dart';
import 'park_binding_form_scope.dart';

/// 可绑定表单组件的统一接口。
///
/// 所有支持数据绑定的 Park 表单组件（ParkInput、ParkSelect 等）均实现此接口，
/// 提供 [bindKey] 和 [bindingService] 两个属性。
/// [BindableFormFieldMixin] 通过此接口进行类型安全的访问，避免 `(widget as dynamic)`。
abstract class ParkBindableWidget {
  /// 绑定键（点号分隔的路径，如 user.name）。
  String? get bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  ParkBindingService? get bindingService;
}

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

  /// 读取任意 widget 上的绑定键（widget 未实现 [ParkBindableWidget] 时为 null）。
  /// 注意：[ParkBindableWidget] 不是 [Widget] 的子类型，无法类型提升，需显式 cast。
  static String? _bindKeyOf(Widget? widget) =>
      (widget is ParkBindableWidget) ? (widget as ParkBindableWidget).bindKey : null;

  /// 读取任意 widget 上的绑定服务（widget 未实现 [ParkBindableWidget] 时为 null）。
  static ParkBindingService? _bindingServiceOf(Widget? widget) =>
      (widget is ParkBindableWidget)
          ? (widget as ParkBindableWidget).bindingService
          : null;

  String? get _bindKey => _bindKeyOf(widget);
  ParkBindingService? get _bindingService => _bindingServiceOf(widget);

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

  @override
  void didUpdateWidget(covariant FormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 绑定参数（bindKey / bindingService）变化时必须重新建链：
    // 旧实现没有 didUpdateWidget，父级把 bindKey 从 'a' 改成 'b' 后，
    // 组件仍然写回旧路径 'a'（绑定的路径与新 widget 不一致 → 脏写 + 新路径永远收不到值）。
    if (_bindKeyOf(oldWidget) == _bindKey &&
        _bindingServiceOf(oldWidget) == _bindingService) {
      return; // 绑定参数未变化，保持既有绑定（避免每次父级重建都重新 bind）
    }
    _unlinkBinding();
    final ParkBindingService? service =
        _bindingService ?? ParkBindingFormScope.of(context)?.service;
    if (_bindKey != null && service != null) {
      _doLink(service);
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
      final T? incoming = _tryCast<T>(_bindable!.value);
      // 相等短路：FormFieldState.didChange 会无条件 setState，
      // 若值没变还调用它会引发无意义的重建（model→UI 回声也会造成重建风暴）。
      // 该短路同时切断 didChange → _syncToBindable → notify → onBindableChanged
      // 的回声链（另一道保险是 ParkBindable 的值相等检测）。
      if (incoming == value) return;
      didChange(incoming);
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

  /// 将 [FormField] 的值同步到 [ParkBindable]。
  ///
  /// 移除旧版 `value != null` 守卫，支持清空输入框时同步 null 值。
  /// 使用 dynamic 绕开 Dart 泛型协变限制（T? → T 不满足赋值兼容性）。
  ///
  /// 回声链终止：写入 bindable 会触发 [onBindableChanged]，但那里有值相等短路，
  /// 加上 [ParkBindable] setter 自身的相等检测，`didChange → 写 bindable →
  /// onBindableChanged → didChange` 最多走一轮即停止，不会无限递归。
  void _syncToBindable(T? value) {
    if (_bindable != null) {
      // ignore: avoid_dynamic_calls
      (_bindable! as dynamic).value = value;
    }
  }

  @override
  void dispose() {
    _unlinkBinding();
    super.dispose();
  }
}
