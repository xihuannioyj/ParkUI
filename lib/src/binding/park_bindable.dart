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
/// 响应式值包装器，继承 [ValueNotifier<T>] 实现细粒度通知。
///
/// 每个 [ParkBindable] 实例包装一个字段值，值变化时自动通知监听者。
/// 通过 [ParkBindingService.bind] 创建和管理。
///
/// 特性：
/// - **值相等检测**：设置与当前值相同的值时跳过通知，避免无用 UI 重建。
/// - **所属服务管理**：可通过 [owner] 关联 [ParkBindingService]，在 dispose 时自动解绑。
///
/// ```dart
/// final bindable = ParkBindable<String>('name', '初始值');
/// bindable.addListener(() => print('值变化: ${bindable.value}'));
/// bindable.value = '新值'; // 触发通知
/// bindable.value = '新值'; // 值相同，不触发通知（性能优化）
/// ```
class ParkBindable<T> extends ValueNotifier<T> {
  /// 绑定的路径（如 `'user.name'`）。
  final String path;

  /// 所属的 [ParkBindingService]，用于 dispose 时自动解绑。
  ///
  /// 由 [ParkBindingService.bind] 在创建时设置，开发者无需手动管理。
  /* late */ dynamic _owner;

  /// 创建 [ParkBindable]。
  ///
  /// [path] 绑定路径。
  /// [initialValue] 初始值。
  ParkBindable(this.path, T initialValue) : super(initialValue);

  /// 设置所属服务（由 [ParkBindingService.bind] 调用）。
  ///
  /// 内部方法，开发者无需手动调用。
  void setupOwner(dynamic owner) {
    _owner = owner;
  }

  /// 覆写 [value] setter，添加值相等检测。
  ///
  /// 仅当新值与当前值不同时触发 [notifyListeners]，
  /// 避免相同值重复通知导致的不必要 UI 重建。
  @override
  set value(T newValue) {
    if (newValue != super.value) {
      super.value = newValue;
    }
  }

  /// 类型安全的值更新方法。
  ///
  /// 与直接设置 [value] 语义相同，内部通过 [value=] 赋值，
  /// 同样走值相等检测：若 [newValue == 当前值]，则不触发通知。
  ///
  /// 此方法主要用于批量更新场景（如 [ParkBindingService.updateModel]），
  /// 调用方需自行确保值确实已变更；若需跳过相等判定，请改用 [forceUpdate]。
  void update(T newValue) {
    value = newValue;
  }

  /// 是否已释放（防止重复 dispose）。
  bool _disposed = false;

  /// 释放资源。
  ///
  /// 如果设置了 [owner]，会自动通知 [ParkBindingService] 移除本绑定的注册引用。
  /// 重复调用 [dispose] 是安全的——第二次起直接跳过。
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    // 通知所属服务移除引用
    try {
      // ignore: avoid_dynamic_calls
      _owner?.removeBindable(path);
    } catch (_) {}
    super.dispose();
  }
}
