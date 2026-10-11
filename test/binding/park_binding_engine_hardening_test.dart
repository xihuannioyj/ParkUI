// 绑定引擎加固回归测试（纯 Dart 层，不含 Widget）。
//
// 覆盖本次加固的 5 个问题中与引擎直接相关的部分：
// 1. 值相等时不通知监听器、也不触发 watchEffect（ParkBindable 相等检测）；
// 2. batch() 内 N 次更新只触发一次 watchEffect（合帧 + 路径级去重）；
// 3. 路径变更只触发依赖该路径的 watchEffect（依赖索引正确性）；
// 4. 副作用重跑会重建依赖索引（旧依赖不再触发它）、停止后索引被清理；
// 5. 自触发副作用在有限次重跑内收敛，不会无限循环；
// 6. 长同步副作用链被深度上限截断（不会栈溢出）；
// 7. 释放后再写值不抛异常、不通知，且 dispose 幂等。

import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/binding/park_binding_service.dart';

void main() {
  group('ParkBindable 值相等检测', () {
    test('设置相同值不通知监听器，也不触发依赖副作用', () async {
      final service = ParkBindingService(<String, dynamic>{'name': 'Alice'});
      final bindable = service.bind<String>('name');

      int notifyCount = 0;
      bindable.addListener(() => notifyCount++);

      int effectRuns = 0;
      service.watchEffect(() {
        service.getValue<String>('name');
        effectRuns++;
      });
      expect(effectRuns, 1, reason: 'watchEffect 注册时立即执行一次');

      service.setValue<String>('name', 'Alice');
      await service.nextTick();

      expect(notifyCount, 0, reason: '值未变化不应通知监听器');
      expect(effectRuns, 1, reason: '值未变化不应触发依赖副作用');

      // 反向确认：真正变化时两者都要触发，避免上一条断言因「链路坏掉」而假通过
      service.setValue<String>('name', 'Bob');
      await service.nextTick();

      expect(notifyCount, 1);
      expect(effectRuns, 2);
    });
  });

  group('watchEffect 合帧与依赖索引', () {
    test('batch() 内 N 次更新只触发一次 effect，且读到最终值', () async {
      final service = ParkBindingService(<String, dynamic>{'count': 0});
      // 必须 bind：绑定路径通过调度器合帧，才能体现批量合并语义
      service.bind<int>('count');

      int effectRuns = 0;
      int? observed;
      service.watchEffect(() {
        observed = service.getValue<int>('count');
        effectRuns++;
      });
      expect(effectRuns, 1);

      service.batch(() {
        for (int i = 1; i <= 5; i++) {
          service.setValue<int>('count', i);
        }
      });

      expect(effectRuns, 2, reason: '5 次更新必须合并为 1 次副作用执行');
      expect(observed, 5, reason: '副作用应读到批量更新后的最终值');
    });

    test('路径变更只触发依赖该路径的副作用', () async {
      final service = ParkBindingService(<String, dynamic>{'a': 1, 'b': 2});
      service.bind<int>('a');
      service.bind<int>('b');

      int aRuns = 0;
      int bRuns = 0;
      service.watchEffect(() {
        service.getValue<int>('a');
        aRuns++;
      });
      service.watchEffect(() {
        service.getValue<int>('b');
        bRuns++;
      });
      expect(aRuns, 1);
      expect(bRuns, 1);

      service.setValue<int>('a', 10);
      await service.nextTick();

      expect(aRuns, 2);
      expect(bRuns, 1, reason: '不依赖 a 的副作用不应被执行');

      service.setValue<int>('b', 20);
      await service.nextTick();

      expect(aRuns, 2, reason: '不依赖 b 的副作用不应被执行');
      expect(bRuns, 2);
    });

    test('副作用重新收集依赖后，旧依赖路径不再触发它', () async {
      final service = ParkBindingService(
        <String, dynamic>{'a': 1, 'b': 2, 'useA': true},
      );
      service.bind<int>('a');
      service.bind<int>('b');
      service.bind<bool>('useA');

      int runs = 0;
      service.watchEffect(() {
        // 按开关只依赖 a 或 b：依赖集合在两次执行之间会发生变化
        if (service.getValue<bool>('useA') == true) {
          service.getValue<int>('a');
        } else {
          service.getValue<int>('b');
        }
        runs++;
      });
      expect(runs, 1);

      // 切换开关 → 依赖集合变为 {useA, b}，索引中的旧依赖 a 必须被摘除
      service.setValue<bool>('useA', false);
      await service.nextTick();
      expect(runs, 2);

      service.setValue<int>('a', 100);
      await service.nextTick();
      expect(runs, 2, reason: 'a 已不在依赖集合中，索引若残留旧依赖会误触发');

      service.setValue<int>('b', 200);
      await service.nextTick();
      expect(runs, 3, reason: 'b 是新依赖，必须触发');
    });

    test('停止追踪后副作用不再执行（索引同步清理）', () async {
      final service = ParkBindingService(<String, dynamic>{'x': 1});
      service.bind<int>('x');

      int runs = 0;
      final WatchEffectHandle stop = service.watchEffect(() {
        service.getValue<int>('x');
        runs++;
      });
      expect(runs, 1);

      stop();
      service.setValue<int>('x', 2);
      await service.nextTick();

      expect(runs, 1, reason: '已停止的副作用不应再被执行');
      // 重复停止是安全的
      expect(() => stop(), returnsNormally);
    });

    test('自触发副作用在有限次重跑内收敛（不会无限循环）', () async {
      final service = ParkBindingService(<String, dynamic>{'tick': 0});

      int runs = 0;
      service.watchEffect(() {
        // 副作用写回自身依赖（未绑定路径 → 同步触发）构成重入，
        // 必须由 _rerunCount 上限截断，否则会形成无限微任务链。
        final int current = service.getValue<int>('tick') ?? 0;
        runs++;
        service.setValue<int>('tick', current + 1);
      });
      // 首次执行时依赖刚被收集、尚未登记进依赖索引，因此自写回不构成重入
      //（索引登记以「一次执行」为粒度，见 _WatchEffect._execute 注释）。
      expect(runs, 1);

      // 外部触发一次：此后副作用已在索引中，自写回会命中重入检测 → 形成重跑链
      service.setValue<int>('tick', 100);
      await Future<void>.delayed(Duration.zero);
      final int afterChain = runs;
      expect(afterChain, greaterThan(2), reason: '重入应导致若干次重跑');
      expect(afterChain, lessThanOrEqualTo(20), reason: '重跑必须被上限截断');

      await Future<void>.delayed(Duration.zero);
      expect(runs, afterChain, reason: '重跑链停止后不应再自我延续');

      // 外部触发应重新授予重跑预算（计数器在外部进入时重置）
      service.setValue<int>('tick', 1000);
      await Future<void>.delayed(Duration.zero);
      final int afterExternal = runs;
      expect(afterExternal, greaterThan(afterChain));

      await Future<void>.delayed(Duration.zero);
      expect(runs, afterExternal, reason: '外部触发开启的新链同样必须收敛');
    });

    test('长同步副作用链会被深度上限截断（不会栈溢出）', () async {
      final Map<String, dynamic> model = <String, dynamic>{};
      for (int i = 0; i <= 30; i++) {
        model['p$i'] = 0;
      }
      final service = ParkBindingService(model);

      int totalRuns = 0;
      // 31 个副作用首尾相连：E(i) 写 p(i+1)，形成同步触发链
      for (int i = 0; i <= 30; i++) {
        final int index = i;
        service.watchEffect(() {
          totalRuns++;
          final int current = service.getValue<int>('p$index') ?? 0;
          if (index < 30) {
            service.setValue<int>('p${index + 1}', current + 1);
          }
        });
      }
      final int afterRegistration = totalRuns;
      expect(afterRegistration, 31, reason: '注册时各自执行一次（下游尚未注册）');

      // 一次外部变更重新拉起整条链：必须被深度上限（10）截断而不是无限递归
      expect(() => service.setValue<int>('p0', 999), returnsNormally);
      final int chainRuns = totalRuns - afterRegistration;
      expect(chainRuns, greaterThan(0));
      expect(
        chainRuns,
        lessThanOrEqualTo(15),
        reason: '深度上限应把同步链截断在有限层，而非跑完 31 个副作用',
      );
    });
  });

  group('释放与注销', () {
    test('bindable 释放后再写值不抛异常且不通知', () {
      final service = ParkBindingService(<String, dynamic>{'name': 'Alice'});
      final bindable = service.bind<String>('name');

      int notifyCount = 0;
      bindable.addListener(() => notifyCount++);

      service.disposeBindable('name');

      // 释放后通过 service 写值：走模型分支，不抛异常，也不触发已释放实例的监听器
      expect(() => service.setValue<String>('name', 'Bob'), returnsNormally);
      expect(notifyCount, 0);
      expect(service.model['name'], 'Bob', reason: '模型值仍然会被更新');

      // 重复释放是幂等的
      expect(() => bindable.dispose(), returnsNormally);
      expect(() => service.disposeBindable('name'), returnsNormally);
      expect(notifyCount, 0);
    });

    test('释放后重新 bind 得到新实例，旧实例 dispose 不影响新实例的注册', () {
      final service = ParkBindingService(<String, dynamic>{'p': 1});
      final old = service.bind<int>('p');

      // 显式注销（release 但不 dispose），此时 old 不再是注册实例
      service.removeBindable('p');
      final fresh = service.bind<int>('p');
      expect(identical(old, fresh), isFalse);

      // 旧实例再 dispose：不得把同路径的新实例从池中摘掉
      old.dispose();

      expect(
        identical(service.bind<int>('p'), fresh),
        isTrue,
        reason: '旧实例的 dispose 不应注销新实例',
      );
      fresh.value = 5;
      expect(service.model['p'], 5);
    });

    test('service.dispose() 幂等且清理全部绑定', () {
      final service = ParkBindingService(<String, dynamic>{'a': 1, 'b': 2});
      final a = service.bind<int>('a');
      final b = service.bind<int>('b');

      service.dispose();
      expect(() => service.dispose(), returnsNormally);
      expect(service.model, <String, dynamic>{});
      // 已释放实例再次释放也不抛异常
      expect(() => a.dispose(), returnsNormally);
      expect(() => b.dispose(), returnsNormally);
    });
  });
}
