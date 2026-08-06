import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'park_binding_path.dart';
import 'park_bindable.dart';
import 'park_binding_scheduler.dart';

/// 依赖追踪上下文（用于 [watchEffect] 自动收集依赖）。
///
/// 每个 [ParkBindingService] 实例持有独立的 [TrackContext]，
/// 避免跨实例的自动依赖追踪串扰（B52）。
class TrackContext {
  /// 当前正在执行的副作用函数。
  void Function()? activeEffect;

  /// 当前副作用的已收集依赖路径。
  Set<String>? collectedDeps;

  /// 记录一个依赖路径。
  void trackPath(String path) {
    if (activeEffect != null && collectedDeps != null) {
      collectedDeps!.add(path);
    }
  }
}

/// 双向绑定引擎服务。...
///
/// 管理所有 [ParkBindable] 实例池，维护模型镜像。
/// 同一路径始终返回同一 [ParkBindable] 实例（单例模式）。
///
/// 性能特性：
/// - **批量调度**：通过 [beginBatch]/[endBatch] 将多次更新合并到单次微任务帧通知
/// - **值相等检测**：仅值实际变化时触发通知
/// - **惰性绑定**：组件销毁时自动解绑
/// - **自动依赖追踪**：通过 [watchEffect] 自动收集依赖路径，值变化时自动重执行
///
/// ```dart
/// final service = ParkBindingService({'name': '张三', 'age': 18});
///
/// // 绑定字段
/// final nameBindable = service.bind<String>('name');
/// print(nameBindable.value); // '张三'
///
/// // 批量更新多字段（合并到单次通知）
/// service.batch(() {
///   service.setValue('name', '李四');
///   service.setValue('age', 20);
/// });
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

  /// Counter for periodic cleanup of [_disposedGuard] (R5-011).
  int _disposeCounter = 0;

  /// bind() 注册的监听引用（path → listener），用于 dispose 时精确移除，避免监听器泄漏（B15）。
  final Map<String, VoidCallback> _bindListeners = <String, VoidCallback>{};

  /// 批量调度器（微任务合并）。
  final ParkBindingScheduler _scheduler = ParkBindingScheduler();

  /// 批量模式嵌套深度（>0 表示在 batch 作用域内）。
  int _batchDepth = 0;

  /// 本实例独立的依赖追踪上下文（B52：不再使用全局单例）。
  final TrackContext _trackContext = TrackContext();

  /// 创建 [ParkBindingService]。
  ///
  /// [initialModel] 初始模型数据（可选）。
  ParkBindingService([Map<String, dynamic>? initialModel])
      : _model = initialModel != null
            ? Map<String, dynamic>.from(initialModel)
            : <String, dynamic>{};

  /// 当前模型数据的不可变快照。
  Map<String, dynamic> get model => Map<String, dynamic>.unmodifiable(_model);

  /// 开始批量更新模式。
  ///
  /// 在批量模式内多次调用 [setValue] 将合并到单次通知帧，
  /// 避免中间态导致的不必要 UI 重建。
  ///
  /// 必须与 [endBatch] 成对使用。推荐使用 [batch] 高阶方法。
  void beginBatch() {
    _batchDepth++;
  }

  /// 结束批量更新模式。
  ///
  /// 当批量嵌套归零时，刷新所有待通知监听器。
  void endBatch() {
    if (_batchDepth <= 0) return;
    _batchDepth--;
    if (_batchDepth == 0) {
      _scheduler.flushNow();
    }
  }

  /// 执行批量更新操作。
  ///
  /// 将 [fn] 内的所有 [setValue] / [updateModel] 调用合并到单次通知。
  ///
  /// ```dart
  /// service.batch(() {
  ///   service.setValue('name', '李四');
  ///   service.setValue('age', 20);
  ///   service.setValue('city', '上海');
  /// });
  /// // 仅触发一次批量通知
  /// ```
  void batch(void Function() fn) {
    beginBatch();
    try {
      fn();
    } finally {
      endBatch();
    }
  }

  /// 绑定一个路径，返回 [ParkBindable<T>]。
  ///
  /// - 如果已绑定过该路径，返回缓存的 [ParkBindable]（单例模式）。
  /// - 如果未绑定，创建新的 [ParkBindable]。
  /// - [defaultValue] 在路径值不存在时生效。
  ParkBindable<T> bind<T>(String path, {T? defaultValue}) {
    // 自动追踪：如果当前在 [watchEffect] 内，记录此路径
    _trackContext.trackPath(path);
    // 检查是否已绑定（缓存按 path 区分，但泛型 T 必须一致，否则抛明确异常，见 B16）。
    if (_bindables.containsKey(path)) {
      final ParkBindable<dynamic> existing = _bindables[path]!;
      if (existing is! ParkBindable<T>) {
        throw StateError(
          'ParkBindingService.bind: 路径 "$path" 已以类型 '
          '${existing.runtimeType} 绑定，无法以类型 $T 重复绑定。'
          '同一路径必须使用相同的泛型类型。',
        );
      }
      return existing;
    }

    // 从模型中获取初始值
    dynamic initialValue = ParkBindingPath.resolve(path, _model);

    final T resolvedValue = _resolveBoundValue<T>(initialValue, defaultValue);
    final bindable = ParkBindable<T>(path, resolvedValue);
    bindable.setupOwner(this);
    _bindables[path] = bindable;

    // 监听 bindable 变化：同步到 _model，并经调度器合帧触发依赖副作用（D2）。
    // 保存引用以便 dispose 时精确移除，避免监听器泄漏（B15）。
    final VoidCallback listener = () {
      _syncToModel(path, bindable.value);
      _scheduler.scheduleNotify(() => _triggerEffects(path));
    };
    _bindListeners[path] = listener;
    bindable.addListener(listener);

    return bindable;
  }

  /// 安全地解析绑定初始值，避免原始类型不匹配导致的类型转换异常。
  ///
  /// 当模型中没有该路径且未提供 [defaultValue] 时，返回类型空值兜底
  /// （String→''、int→0、double→0.0、bool→false），而不是对非空类型
  /// 执行 `null as T`（会抛 `type 'Null' is not a subtype of type 'T'`）。
  /// 数值类型（int↔double）之间自动转换。
  T _resolveBoundValue<T>(dynamic raw, T? defaultValue) {
    final dynamic candidate = raw ?? defaultValue;
    if (candidate == null) {
      if (T == String) return '' as T;
      if (T == int) return 0 as T;
      if (T == double) return 0.0 as T;
      if (T == bool) return false as T;
      return null as T;
    }
    if (T == String && candidate is! String) {
      return candidate.toString() as T;
    }
    if (T == double && candidate is int) {
      return (candidate as num).toDouble() as T;
    }
    if (T == int && candidate is double) {
      return (candidate as num).toInt() as T;
    }
    return candidate as T;
  }

  /// 将 bindable 的值同步到 _model。
  void _syncToModel(String path, dynamic value) {
    _model = ParkBindingPath.set(path, _model, value);
  }

  /// 快捷设置值。
  ///
  /// 在 [batch] 作用域内调用时，通知被延迟到批量结束。
  /// 在批量作用域外，立即触发通知。会自动唤醒依赖该路径的 [watchEffect]。
  ///
  /// ```dart
  /// service.setValue('user.name', '张三');
  /// ```
  void setValue<T>(String path, T value) {
    if (_bindables.containsKey(path)) {
      // 设置值会触发 bindable 的监听器（model-sync + 经调度器合帧的副作用）。
      // 在 batch 作用域内，这些通知由 ParkBindingScheduler 合并到单次微任务帧（D2）。
      final ParkBindable<T> bindable = _bindables[path]! as ParkBindable<T>;
      bindable.value = value;
    } else {
      _model = ParkBindingPath.set(path, _model, value);
      // 未绑定路径也需要触发依赖此路径的 watchEffect。
      _triggerEffects(path);
    }
  }

  /// 快捷获取值。
  ///
  /// 如果在 [watchEffect] 内部被调用，会自动追踪此依赖路径。
  ///
  /// ```dart
  /// final name = service.getValue<String>('user.name');
  /// ```
  T? getValue<T>(String path) {
    // 自动依赖追踪
    _trackContext.trackPath(path);

    if (_bindables.containsKey(path)) {
      final bindable = _bindables[path]! as ParkBindable<T>;
      return bindable.value;
    }
    final dynamic result = ParkBindingPath.resolve(path, _model);
    if (result == null) return null;
    if (T == double && result is int) {
      return (result as num).toDouble() as T;
    }
    if (T == int && result is double) {
      return (result as num).toInt() as T;
    }
    if (T == String && result is! String) {
      return result.toString() as T;
    }
    return result as T?;
  }

  /// 批量更新模型，比对差异后通知变化路径。
  ///
  /// 遍历所有 [ParkBindable]，对比新旧值，仅实际变化的项触发通知。
  /// 变更通知总是通过批量调度器合并。
  ///
  /// ```dart
  /// service.updateModel({'name': '王五', 'age': 20});
  /// ```
  void updateModel(Map<String, dynamic> newModel) {
    final oldModel = Map<String, dynamic>.from(_model);
    _model = Map<String, dynamic>.from(newModel);

    // 仅对实际变化的 bindable 更新值。值的更新会触发其监听器
    // （model-sync + 经调度器合帧的副作用）。在 batch 作用域内，
    // 这些通知会被 ParkBindingScheduler 合并到单次微任务帧（D2）。
    for (final entry in _bindables.entries) {
      final bindable = entry.value;
      if (_disposedGuard.contains(bindable)) continue;
      final newValue = ParkBindingPath.resolve(entry.key, _model);
      final oldValue = ParkBindingPath.resolve(entry.key, oldModel);
      if (newValue != oldValue) {
        bindable.update(newValue);
      }
    }
  }

  /// 释放指定路径的绑定。
  void disposeBindable(String path) {
    final bindable = _bindables.remove(path);
    if (bindable != null) {
      final VoidCallback? listener = _bindListeners.remove(path);
      if (listener != null) bindable.removeListener(listener);
      _disposedGuard.add(bindable);
      bindable.dispose();
      // R5-011: Periodic cleanup every 100 disposals to prevent infinite growth.
      _disposeCounter++;
      if (_disposeCounter >= 100) {
        _disposedGuard.clear();
        _disposeCounter = 0;
      }
    }
    _triggerEffects(path);
  }

  /// 释放所有绑定和资源。
  void dispose() {
    // 清理所有 watchEffect
    for (final effect in _watchEffects.toList()) {
      effect.stop();
    }
    _watchEffects.clear();
    // 移除 bind() 注册的监听器引用，避免泄漏（B15）。
    _bindListeners.clear();
    _scheduler.dispose();
    for (final bindable in _bindables.values.toList()) {
      _disposedGuard.add(bindable);
      bindable.dispose();
    }
    _bindables.clear();
    _model.clear();
    _batchDepth = 0;
  }

  /// 内部：移除 bindable 引用（由 ParkBindable.dispose 调用）。
  void removeBindable(String path) {
    final ParkBindable<dynamic>? bindable = _bindables.remove(path);
    _bindListeners.remove(path);
    // CR-08: 同步清理 _disposedGuard，避免依赖周期性清理。
    if (bindable != null) {
      _disposedGuard.remove(bindable);
    }
  }

  /// 等待所有待处理的批量更新完成。
  ///
  /// 类似 Vue3 的 [nextTick]，在批量更新后获取最新状态。
  ///
  /// ```dart
  /// await service.nextTick();
  /// print(service.getValue('name')); // 确保最新
  /// ```
  Future<void> nextTick() {
    if (_scheduler.pendingCount > 0) {
      _scheduler.flushNow();
    }
    return Future.value();
  }

  /// 当前待通知的监听器数量。
  int get pendingCount => _scheduler.pendingCount;

  // ========================================================================
  // 自动依赖追踪（类似 Vue3 watchEffect）
  // ========================================================================

  final Set<_WatchEffect> _watchEffects = {};

  /// 注册一个副作用函数，自动追踪其依赖的绑定路径。
  ///
  /// 当任何被依赖的路径值变化时，自动重新执行 [fn]。
  /// 返回 [WatchEffectHandle] 可用于手动停止追踪。
  ///
  /// 类似 Vue3 的 [watchEffect]。
  ///
  /// ```dart
  /// final stop = service.watchEffect(() {
  ///   final name = service.getValue<String>('name');
  ///   print('name changed to: $name');
  /// });
  ///
  /// // 停止追踪
  /// stop();
  /// ```
  WatchEffectHandle watchEffect(void Function() fn) {
    final effect = _WatchEffect(fn, this);
    _watchEffects.add(effect);
    effect._run();
    return effect.stop;
  }

  /// 内部：触发所有依赖了 [path] 的副作用。
  ///
  /// B124：增加最大深度限制（10），防止循环依赖导致栈溢出。
  void _triggerEffects(String path, [int depth = 0]) {
    if (depth > 10) return;
    for (final effect in _watchEffects.toList()) {
      if (effect._deps.contains(path)) {
        effect._run(depth);
      }
    }
  }
}

/// 自动依赖追踪的副作用实例。
class _WatchEffect {
  final void Function() _fn;
  final ParkBindingService _service;
  final Set<String> _deps = {};
  bool _disposed = false;

  /// B124：当前是否正在执行中，用于检测重入。
  bool _isRunning = false;

  /// 重入期间如果有新的触发，标记为 dirty，执行完后调度一次重跑。
  bool _dirty = false;

  /// CR-07：微任务重跑计数器，防止无限重入绕过深度限制。
  int _rerunCount = 0;

  _WatchEffect(this._fn, this._service);

  /// 执行副作用并收集依赖。
  ///
  /// [depth] 当前触发链深度，用于限制递归深度（B124）。
  void _run([int depth = 0]) {
    if (_disposed) return;
    // B124：重入检测 — 如果当前 effect 正在执行，标记 dirty 以便执行完后重跑。
    if (_isRunning) {
      _dirty = true;
      return;
    }
    _isRunning = true;
    _deps.clear();

    final ctx = _service._trackContext;
    ctx.activeEffect = _fn;
    ctx.collectedDeps = _deps;
    try {
      _fn();
    } finally {
      ctx.activeEffect = null;
      ctx.collectedDeps = null;
      _isRunning = false;
      // 如果执行期间有新的触发，调度一次微任务重跑。
      if (_dirty) {
        _dirty = false;
        _rerunCount++;
        if (_rerunCount > 10) {
          debugPrint(
            '[ParkBindingService] watchEffect 微任务重跑超过 10 次，'
            '可能存在循环依赖，已停止重跑。',
          );
          _rerunCount = 0;
        } else {
          scheduleMicrotask(() => _run(_rerunCount));
        }
      } else {
        // 正常执行完毕，重置重跑计数器。
        _rerunCount = 0;
      }
    }
  }

  /// 停止追踪。
  void stop() {
    _disposed = true;
    _deps.clear();
    _service._watchEffects.remove(this);
  }
}

/// [watchEffect] 返回的句柄，调用即可停止追踪。
typedef WatchEffectHandle = void Function();
