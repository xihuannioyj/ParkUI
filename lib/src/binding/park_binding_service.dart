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

  /// bind() 注册的监听引用（path → listener），用于 dispose 时精确移除，避免监听器泄漏（B15）。
  final Map<String, VoidCallback> _bindListeners = <String, VoidCallback>{};

  /// 路径 → 本帧已调度的副作用触发闭包（合帧去重）。
  ///
  /// 旧实现每次值变化都新建一个闭包交给 [ParkBindingScheduler]，
  /// 而调度器按闭包身份去重，导致同一路径在同一帧内被重复触发、
  /// 依赖它的 watchEffect 被重复执行 N 次（N = 本帧变更次数）。
  /// 这里以「路径」为键复用同一个闭包，保证同一帧只触发一次。
  final Map<String, VoidCallback> _pendingTriggerNotifiers =
      <String, VoidCallback>{};

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
      _scheduleTriggerEffects(path);
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
    //
    // 遍历快照而非 entries 本身：监听器回调中可能 dispose / 重新绑定同一路径，
    // 直接遍历会抛并发修改异常。同时校验池中仍是同一实例，避免向已被替换的实例写值。
    // （旧实现用 _disposedGuard 黑名单跳过已释放实例；但 ParkBindable.dispose()
    // 会同步回调 removeBindable 把实例摘出池子，池中不可能残留已释放实例，
    // 因此该黑名单只增不减、毫无作用，已连同「每 100 次整体 clear()」的兜底一并移除。）
    for (final MapEntry<String, ParkBindable<dynamic>> entry
        in _bindables.entries.toList()) {
      if (!identical(_bindables[entry.key], entry.value)) continue;
      final bindable = entry.value;
      final newValue = ParkBindingPath.resolve(entry.key, _model);
      final oldValue = ParkBindingPath.resolve(entry.key, oldModel);
      if (newValue != oldValue) {
        bindable.update(newValue);
      }
    }
  }

  /// 释放指定路径的绑定。
  void disposeBindable(String path) {
    // 先 dispose：由 ParkBindable.dispose 回调 removeBindable 完成注销
    // （保证「注销恰好一次」）。旧实现先摘除映射再 dispose，导致
    // removeBindable 找不到实例、守卫集合条目只增不减。
    final ParkBindable<dynamic>? bindable = _bindables[path];
    if (bindable != null) {
      bindable.dispose();
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
    _effectIndex.clear();
    // 移除 bind() 注册的监听器引用，避免泄漏（B15）。
    _bindListeners.clear();
    // 调度器中尚未执行的合帧触发也不再需要。
    _pendingTriggerNotifiers.clear();
    _scheduler.dispose();
    for (final bindable in _bindables.values.toList()) {
      bindable.dispose();
    }
    _bindables.clear();
    _model.clear();
    _batchDepth = 0;
    _effectDepth = 0;
  }

  /// 内部：移除 bindable 引用（由 ParkBindable.dispose 调用）。
  void removeBindable(String path) {
    final ParkBindable<dynamic>? bindable = _bindables.remove(path);
    final VoidCallback? listener = _bindListeners.remove(path);
    if (bindable != null) {
      // 真正摘掉监听器（旧实现只丢弃引用，已建链但未释放的实例仍会回写模型）。
      if (listener != null) bindable.removeListener(listener);
      // 注销后清除 owner：避免实例被再次注销时误删同路径的新绑定（见 ParkBindable.dispose）。
      bindable.setupOwner(null);
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

  /// 路径 → 依赖该路径的副作用集合（依赖索引）。
  ///
  /// 由副作用在「执行完毕收集到依赖」与「停止追踪」时维护，
  /// 使一次路径变更只访问真正依赖它的副作用，而不是全量扫描 [_watchEffects]。
  final Map<String, Set<_WatchEffect>> _effectIndex =
      <String, Set<_WatchEffect>>{};

  /// 当前副作用执行链深度（B124：限制自触发导致的无限递归）。
  int _effectDepth = 0;

  /// 副作用执行链最大深度。
  static const int _maxEffectDepth = 10;

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

  /// 内部：从索引中摘除副作用当前记录的依赖。
  ///
  /// 停止追踪时调用，避免索引残留已停止副作用，
  /// 否则「曾经依赖过的路径」变更时会错误地访问它。
  void _unindexEffect(_WatchEffect effect) {
    for (final String dep in effect._deps) {
      _removeFromIndex(dep, effect);
    }
  }

  /// 内部：按「执行前 / 执行后」依赖集合的差异同步索引。
  ///
  /// 副作用执行期间不摘除执行前的依赖（见 [_WatchEffect._execute] 注释），
  /// 因此需要在这里做差集：摘除不再依赖的路径、登记新增路径。
  /// 若副作用在执行期间被停止，则不再登记任何依赖。
  void _resyncEffectIndex(_WatchEffect effect, Set<String> previousDeps) {
    for (final String dep in previousDeps) {
      if (effect._deps.contains(dep)) continue;
      _removeFromIndex(dep, effect);
    }
    if (effect._disposed) {
      // 执行期间被停止：把本次收集到的依赖也一并摘净
      for (final String dep in effect._deps) {
        _removeFromIndex(dep, effect);
      }
      return;
    }
    for (final String dep in effect._deps) {
      if (previousDeps.contains(dep)) continue;
      _addToIndex(dep, effect);
    }
  }

  /// 内部：把副作用登记进 [path] 的依赖集合。
  void _addToIndex(String path, _WatchEffect effect) {
    _effectIndex.putIfAbsent(path, () => <_WatchEffect>{}).add(effect);
  }

  /// 内部：把副作用从 [path] 的依赖集合摘除（空桶一并移除，避免索引无界增长）。
  void _removeFromIndex(String path, _WatchEffect effect) {
    final Set<_WatchEffect>? bucket = _effectIndex[path];
    if (bucket == null) return;
    bucket.remove(effect);
    if (bucket.isEmpty) _effectIndex.remove(path);
  }

  /// 内部：安排一次 [path] 的副作用触发。
  ///
  /// 同一帧内同一路径的多次变更只调度一个闭包（见 [_pendingTriggerNotifiers]），
  /// 因此依赖它的副作用在同一帧最多执行一次。
  void _scheduleTriggerEffects(String path) {
    if (_pendingTriggerNotifiers.containsKey(path)) return;
    void notifier() {
      // 执行后立即摘除，保证后续帧/后续批次可以重新调度本路径。
      _pendingTriggerNotifiers.remove(path);
      _triggerEffects(path);
    }
    _pendingTriggerNotifiers[path] = notifier;
    _scheduler.scheduleNotify(notifier);
  }

  /// 内部：触发所有依赖了 [path] 的副作用。
  ///
  /// B124：增加最大深度限制（10），防止循环依赖导致栈溢出。
  /// 优化：通过 [_effectIndex] 精确定位依赖副作用，复杂度与依赖者数量相关，
  /// 而不是与副作用总数相关（旧实现每次都遍历全部副作用）。
  void _triggerEffects(String path, [int depth = 0]) {
    // 深度取「入参」与「当前执行链深度」的较大值：副作用内部再次写值时会以
    // 默认深度 0 回调本方法（见 setValue 的未绑定路径分支），只看入参会限流失效。
    final int currentDepth = depth > _effectDepth ? depth : _effectDepth;
    if (currentDepth > _maxEffectDepth) return;
    final Set<_WatchEffect>? effects = _effectIndex[path];
    if (effects == null || effects.isEmpty) return;
    // 复制一份再遍历：副作用执行时会重新收集依赖（增删索引），
    // 直接遍历原集合会抛并发修改异常。
    for (final _WatchEffect effect in effects.toList()) {
      effect._run(currentDepth + 1);
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

  /// CR-07：连续重跑计数器，防止无限重入绕过深度限制。
  ///
  /// 旧实现把清零放在「本次执行没有产生重入」的分支里，等价于每次正常执行都
  /// 归还预算；一旦出现「重入 → 正常 → 重入 → 正常」的交替链，计数器会被反复
  /// 清零而使限流形同虚设。现在只在「外部触发重新进入」（[_run]）时重置，
  /// 同一条自触发链累加到上限后保持停止，直到下一次外部触发重新授予预算。
  int _rerunCount = 0;

  /// 单条自触发链允许的最大重跑次数。
  static const int _maxRerun = 10;

  _WatchEffect(this._fn, this._service);

  /// 外部入口：注册时首次执行，或依赖路径变更时由 [_triggerEffects] 调用。
  ///
  /// [depth] 当前触发链深度，用于限制递归深度（B124）。
  void _run([int depth = 0]) {
    if (_disposed) return;
    // B124：重入检测 — 如果当前 effect 正在执行，标记 dirty 以便执行完后重跑。
    // 注意：重入路径不改动 _rerunCount，否则自触发链的计数会被反复清零。
    if (_isRunning) {
      _dirty = true;
      return;
    }
    // 外部触发 → 开启新的重跑链，重置重跑预算。
    _rerunCount = 0;
    _execute(depth);
  }

  /// 实际执行副作用并收集依赖（供外部入口与内部重跑复用，不重置重跑计数）。
  void _execute(int depth) {
    if (_disposed) return;
    _isRunning = true;
    // 执行前的依赖快照：执行期间索引中仍保留这些依赖（不提前摘除），
    // 这样副作用运行中回写自身依赖时，_triggerEffects 仍能命中本副作用
    // 并走重入检测（_dirty），与旧实现按实时 _deps 判定的语义保持一致。
    // 执行结束后再由 _resyncEffectIndex 做差集，摘除不再依赖的路径。
    final Set<String> previousDeps = Set<String>.from(_deps);
    _deps.clear();

    final ctx = _service._trackContext;
    // 记录执行链深度：副作用内部同步写值时，_triggerEffects 会读到它并 +1，
    // 使深度限制真正生效（旧实现只把入参往下传，副作用内部写值恒为 0）。
    final int prevDepth = _service._effectDepth;
    _service._effectDepth = depth;
    ctx.activeEffect = _fn;
    ctx.collectedDeps = _deps;
    try {
      _fn();
    } finally {
      ctx.activeEffect = null;
      ctx.collectedDeps = null;
      _service._effectDepth = prevDepth;
      _isRunning = false;
      // 按依赖差集同步索引，使后续变更可以精确命中本副作用。
      _service._resyncEffectIndex(this, previousDeps);
      // 如果执行期间有新的触发，调度一次微任务重跑。
      if (_dirty) {
        _dirty = false;
        _rerunCount++;
        if (_rerunCount > _maxRerun) {
          debugPrint(
            '[ParkBindingService] watchEffect 重跑超过 $_maxRerun 次，'
            '可能存在循环依赖，已停止重跑（等待下一次外部触发）。',
          );
        } else {
          // 重跑发生在新的微任务帧中，不在当前触发链内，深度重新从 0 起算。
          scheduleMicrotask(() {
            if (_disposed) return;
            _execute(0);
          });
        }
      }
    }
  }

  /// 停止追踪。
  void stop() {
    if (_disposed) return;
    _disposed = true;
    // 先按当前依赖摘除索引，再清空依赖（顺序反了会残留索引条目）。
    _service._unindexEffect(this);
    _deps.clear();
    _service._watchEffects.remove(this);
  }
}

/// [watchEffect] 返回的句柄，调用即可停止追踪。
typedef WatchEffectHandle = void Function();
