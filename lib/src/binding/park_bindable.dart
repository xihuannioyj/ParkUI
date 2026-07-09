import 'package:flutter/foundation.dart';

/// 响应式值包装器，继承 [ValueNotifier<T>] 实现细粒度通知。
///
/// 每个 [ParkBindable] 实例包装一个字段值，值变化时自动通知监听者。
/// 通过 [ParkBindingService.bind] 创建和管理。
///
/// ```dart
/// final bindable = ParkBindable<String>('name', '初始值');
/// bindable.addListener(() => print('值变化: ${bindable.value}'));
/// bindable.value = '新值'; // 触发通知
/// ```
class ParkBindable<T> extends ValueNotifier<T> {
  /// 绑定的路径（如 `'user.name'`）。
  final String path;

  /// 创建 [ParkBindable]。
  ///
  /// [path] 绑定路径。
  /// [initialValue] 初始值。
  ParkBindable(this.path, T initialValue) : super(initialValue);

  /// 类型安全的值更新方法。
  ///
  /// 调用 [value] setter 触发 [notifyListeners]。
  void update(T newValue) {
    value = newValue;
  }

  /// 释放资源。
  @override
  void dispose() {
    super.dispose();
  }
}
