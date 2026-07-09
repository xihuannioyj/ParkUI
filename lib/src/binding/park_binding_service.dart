import 'park_binding_path.dart';
import 'park_bindable.dart';

/// 双向绑定引擎服务。
///
/// 管理所有 [ParkBindable] 实例池，维护模型镜像。
/// 同一路径始终返回同一 [ParkBindable] 实例（单例模式）。
///
/// ```dart
/// final service = ParkBindingService({'name': '张三', 'age': 18});
///
/// // 绑定字段
/// final nameBindable = service.bind<String>('name');
/// print(nameBindable.value); // '张三'
///
/// // 修改值
/// service.setValue('name', '李四');
///
/// // 批量更新模型
/// service.updateModel({'name': '王五'});
/// ```
class ParkBindingService {
  /// 模型数据镜像。
  Map<String, dynamic> _model;

  /// 绑定实例池（路径 → ParkBindable）。
  final Map<String, ParkBindable<dynamic>> _bindables =
      <String, ParkBindable<dynamic>>{};

  /// 已释放的绑定实例守卫集合。
  final Set<ParkBindable<dynamic>> _disposedGuard =
      <ParkBindable<dynamic>>{};

  /// 创建 [ParkBindingService]。
  ///
  /// [initialModel] 初始模型数据（可选）。
  ParkBindingService([Map<String, dynamic>? initialModel])
      : _model = initialModel != null
            ? Map<String, dynamic>.from(initialModel)
            : <String, dynamic>{};

  /// 当前模型数据的不可变快照。
  Map<String, dynamic> get model => Map<String, dynamic>.unmodifiable(_model);

  /// 绑定一个路径，返回 [ParkBindable<T>]。
  ///
  /// - 如果已绑定过该路径，返回缓存的 [ParkBindable]（单例模式）。
  /// - 如果未绑定，创建新的 [ParkBindable]。
  /// - [defaultValue] 在路径值不存在时生效。
  ParkBindable<T> bind<T>(String path, {T? defaultValue}) {
    // 检查是否已绑定
    if (_bindables.containsKey(path)) {
      return _bindables[path]! as ParkBindable<T>;
    }

    // 从模型中获取初始值
    dynamic initialValue = ParkBindingPath.resolve(path, _model);

    final T resolvedValue = _resolveBoundValue<T>(initialValue, defaultValue);
    final bindable = ParkBindable<T>(path, resolvedValue);
    _bindables[path] = bindable;

    // 监听 bindable 变化，同步到 _model
    bindable.addListener(() {
      _syncToModel(path, bindable.value);
    });

    return bindable;
  }

  /// 安全地解析绑定初始值，避免原始类型不匹配导致的类型转换异常。
  ///
  /// 规则：
  /// - [raw] 与 [defaultValue] 均为 null 时，返回 null（由调用方决定兜底）。
  /// - 目标类型 [T] 为 [String] 且原始值非 [String]（且非空）时，
  ///   通过 [Object.toString] 进行兼容转换（例如 int 28 → '28'）。
  /// - 其他类型尝试直接 `is T` 判定，命中则返回原值。
  /// - 类型不匹配且无法安全转换时，回退到 [defaultValue]；若仍不匹配，
  ///   保持原始 cast 以暴露极端错误（不影响常规使用）。
  T _resolveBoundValue<T>(dynamic raw, T? defaultValue) {
    final dynamic candidate = raw ?? defaultValue;
    if (candidate == null) {
      // 允许 null 透传（例如 ParkBindable<String?>）。
      return candidate as T;
    }
    // String 目标类型：对非 String 原始值做 toString 兼容。
    if (T == String && candidate is! String) {
      return candidate.toString() as T;
    }
    // 同类型直接返回（含兜底 cast，极端类型不匹配时暴露错误）。
    return candidate as T;
  }

  /// 将 bindable 的值同步到 _model。
  void _syncToModel(String path, dynamic value) {
    _model = ParkBindingPath.set(path, _model, value);
  }

  /// 快捷设置值。
  ///
  /// 调用此方法会同时更新 [ParkBindable] 和 _model。
  ///
  /// ```dart
  /// service.setValue('user.name', '张三');
  /// ```
  void setValue<T>(String path, T value) {
    // 如果已有 bindable，通过它设置（触发通知）
    if (_bindables.containsKey(path)) {
      final bindable = _bindables[path]! as ParkBindable<T>;
      bindable.value = value;
    } else {
      // 直接更新模型
      _model = ParkBindingPath.set(path, _model, value);
    }
  }

  /// 快捷获取值。
  ///
  /// ```dart
  /// final name = service.getValue<String>('user.name');
  /// ```
  T? getValue<T>(String path) {
    // 如果已有 bindable，从 bindable 获取
    if (_bindables.containsKey(path)) {
      final bindable = _bindables[path]! as ParkBindable<T>;
      return bindable.value;
    }
    // 从模型解析
    final dynamic result = ParkBindingPath.resolve(path, _model);
    return result as T?;
  }

  /// 批量更新模型，比对差异后通知变化路径。
  ///
  /// 遍历所有 [ParkBindable]，对比新旧值，仅实际变化的项触发通知。
  ///
  /// ```dart
  /// service.updateModel({'name': '王五', 'age': 20});
  /// ```
  void updateModel(Map<String, dynamic> newModel) {
    final Map<String, dynamic> oldModel =
        Map<String, dynamic>.from(_model);
    _model = Map<String, dynamic>.from(newModel);

    // 比对差异，通知变化路径
    for (final MapEntry<String, ParkBindable<dynamic>> entry
        in _bindables.entries) {
      final String path = entry.key;
      final ParkBindable<dynamic> bindable = entry.value;

      if (_disposedGuard.contains(bindable)) continue;

      final dynamic newValue = ParkBindingPath.resolve(path, _model);
      final dynamic oldValue = ParkBindingPath.resolve(path, oldModel);

      // 仅值实际变化时触发通知
      if (newValue != oldValue) {
        bindable.update(newValue);
      }
    }
  }

  /// 释放指定路径的绑定。
  void disposeBindable(String path) {
    final bindable = _bindables.remove(path);
    if (bindable != null) {
      _disposedGuard.add(bindable);
      bindable.dispose();
    }
  }

  /// 释放所有绑定和资源。
  void dispose() {
    for (final ParkBindable<dynamic> bindable in _bindables.values) {
      _disposedGuard.add(bindable);
      bindable.dispose();
    }
    _bindables.clear();
    _model.clear();
  }

  /// 内部：移除 bindable 引用（由 ParkBindable.dispose 调用）。
  void removeBindable(String path) {
    _bindables.remove(path);
  }
}
