// Spec 完整性守护测试
//
// 确保所有已注册的 ParkComponentSpec 满足最低完整性要求：
//   1. demos 非空
//   2. properties 非空（纯展示/布局组件允许例外）
//   3. basicUsageCode 或 guide 至少有一个非空
//   4. 每个 demo 的 code 字段非空
//   5. 每个 demo 的 builder 可调用并返回非空 Widget
//   6. 总 spec 数量 >= 阈值，防止 spec 意外丢失
//   7. 关键核心组件 spec 必须存在

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

// ---------------------------------------------------------------------------
// 聚合所有 spec map
// ---------------------------------------------------------------------------

/// 合并所有 spec 文件导出的 Map<String, ParkComponentSpec>。
///
/// 注意：同名 key 后者覆盖前者（如 'ParkForm' 同时出现在
/// parkInputSpecsPart2 与 parkFormSpecs 中），最终 map 保留最后写入的版本。
Map<String, ParkComponentSpec> _allSpecs() {
  return <String, ParkComponentSpec>{
    ...parkBaseSpecs,
    ...parkInputSpecs,
    ...parkInputSpecsPart2,
    ...parkInputSpecsExtra,
    ...parkInputGroupSpecs,
    ...parkNavSpecs,
    ...parkNavSpecsExtra,
    ...parkDisplaySpecs,
    ...parkDisplaySpecsExtra,
    ...parkFeedbackSpecs,
    ...parkFeedbackSpecsExtra,
    ...parkFormSpecs,
    ...parkBindingSpecs,
    ...parkNewComponentSpecs,
  };
}

/// 纯展示 / 布局类组件，允许 properties 为空。
///
/// 这些组件通常没有构造参数或仅有极少量参数，
/// 在 spec 中省略 properties 是合理的。
const Set<String> _kPropertiesExempt = <String>{
  // 如有确实无属性的组件，在此添加 name（与 spec.name 一致）。
  // 示例：'ParkDivider',
};

/// 总 spec 数量下限。
///
/// 当前合并后约有 110 个 spec（去重后）。
/// 如果新增或删除 spec，请同步更新此阈值。
const int _kMinSpecCount = 95;

/// 核心组件 name 列表 — 必须存在于 spec map 中。
const List<String> _kCoreComponents = <String>[
  'ParkButton',
  'ParkInput',
  'ParkForm',
  'ParkTable',
  'ParkSelect',
  'ParkDialog',
  'ParkTabs',
  'ParkToast',
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final Map<String, ParkComponentSpec> allSpecs = _allSpecs();

  group('Spec 完整性守护', () {
    // -----------------------------------------------------------------------
    // 1. spec 数量守护
    // -----------------------------------------------------------------------
    test('已注册 spec 总数 >= $_kMinSpecCount（防止 spec 意外丢失）', () {
      expect(
        allSpecs.length,
        greaterThanOrEqualTo(_kMinSpecCount),
        reason: '当前已注册 ${allSpecs.length} 个 spec，'
            '低于阈值 $_kMinSpecCount。'
            '如果确实删除了 spec，请同步下调 _kMinSpecCount；'
            '如果是意外丢失，请恢复。',
      );
    });

    // -----------------------------------------------------------------------
    // 2. 关键组件 spec 存在
    // -----------------------------------------------------------------------
    test('核心组件 spec 必须存在', () {
      final List<String> missing = <String>[
        for (final String name in _kCoreComponents)
          if (!allSpecs.containsKey(name)) name,
      ];
      expect(
        missing,
        isEmpty,
        reason: '以下核心组件缺少 spec: $missing',
      );
    });

    // -----------------------------------------------------------------------
    // 3. 所有 spec 的 demos 非空
    // -----------------------------------------------------------------------
    test('所有 spec 的 demos 非空', () {
      final List<String> emptyDemos = <String>[
        for (final MapEntry<String, ParkComponentSpec> e in allSpecs.entries)
          if (e.value.demos.isEmpty) e.key,
      ];
      expect(
        emptyDemos,
        isEmpty,
        reason: '以下 spec 的 demos 为空: $emptyDemos',
      );
    });

    // -----------------------------------------------------------------------
    // 4. 所有 spec 的 properties 非空（纯展示组件例外）
    // -----------------------------------------------------------------------
    test('所有 spec 的 properties 非空（纯展示组件例外）', () {
      final List<String> emptyProps = <String>[
        for (final MapEntry<String, ParkComponentSpec> e in allSpecs.entries)
          if (e.value.properties.isEmpty &&
              !_kPropertiesExempt.contains(e.key))
            e.key,
      ];
      expect(
        emptyProps,
        isEmpty,
        reason: '以下 spec 的 properties 为空（如确实无属性，'
            '请将 name 加入 _kPropertiesExempt）: $emptyProps',
      );
    });

    // -----------------------------------------------------------------------
    // 5. 所有 spec 有 basicUsageCode 或 guide
    // -----------------------------------------------------------------------
    test('所有 spec 至少有 basicUsageCode 或 guide', () {
      final List<String> noUsage = <String>[
        for (final MapEntry<String, ParkComponentSpec> e in allSpecs.entries)
          if (e.value.basicUsageCode.isEmpty && e.value.guide.isEmpty)
            e.key,
      ];
      expect(
        noUsage,
        isEmpty,
        reason: '以下 spec 既无 basicUsageCode 也无 guide: $noUsage',
      );
    });

    // -----------------------------------------------------------------------
    // 6. 每个 demo 的 code 字段非空
    // -----------------------------------------------------------------------
    test('所有 demo 的 code 字段非空', () {
      final List<String> emptyCode = <String>[];
      for (final MapEntry<String, ParkComponentSpec> e in allSpecs.entries) {
        for (int i = 0; i < e.value.demos.length; i++) {
          if (e.value.demos[i].code.isEmpty) {
            emptyCode.add('${e.key}#$i (${e.value.demos[i].title})');
          }
        }
      }
      expect(
        emptyCode,
        isEmpty,
        reason: '以下 demo 的 code 为空: $emptyCode',
      );
    });

    // -----------------------------------------------------------------------
    // 7. 每个 demo 的 builder 可调用并返回非空 Widget
    // -----------------------------------------------------------------------
    testWidgets('所有 demo builder 可调用并返回非空 Widget',
        (WidgetTester tester) async {
      // 先渲染一个最小 MaterialApp，获取合法 BuildContext
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SizedBox.shrink()),
        ),
      );
      final BuildContext ctx =
          tester.element(find.byType(Scaffold));

      final List<String> failedBuilders = <String>[];

      for (final MapEntry<String, ParkComponentSpec> e in allSpecs.entries) {
        for (int i = 0; i < e.value.demos.length; i++) {
          final ParkDemoScenario demo = e.value.demos[i];
          try {
            demo.builder(ctx);
          } catch (err) {
            failedBuilders.add(
              '${e.key}#${i} (${demo.title}): $err',
            );
          }
        }
      }

      expect(
        failedBuilders,
        isEmpty,
        reason: '以下 demo builder 失败: $failedBuilders',
      );
    });
  });
}
