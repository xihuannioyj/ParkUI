// sync_readme.dart — README 数字与代码实测一致性校验（B211 产物，Phase 65 补齐 B277）
//
// 用法（在 packages/park_ui 目录下）：
//   dart tool/sync_readme.dart          校验，不一致时退出码 1
//   dart tool/sync_readme.dart --fix    校验并自动回写 README 数字
//
// 仅依赖 dart:io，无三方包依赖。测试数不在本脚本校验范围（以 `flutter test` 实测为准）。

import 'dart:io';

void main(List<String> args) {
  final fix = args.contains('--fix');
  final root = _packageRoot();
  var readme = File('$root/README.md');
  if (!readme.existsSync()) {
    stderr.writeln('README.md 不存在: ${readme.path}');
    exit(2);
  }

  final componentCount = _countComponents(root);
  final demoCount = _countDemos(root);

  var content = readme.readAsStringSync();
  var drift = false;

  // 组件数：匹配 "提供 N 个开箱即用" 与 "**N 组件**"
  content = _check(content, RegExp(r'提供\s*(\d+)\s*个开箱即用'), componentCount,
      '组件总数（首句）', () => drift = true);
  content = _check(content, RegExp(r'\*\*(\d+)\s*组件\*\*'), componentCount,
      '组件总数（特性）', () => drift = true);
  // Demo 数：匹配 "N 个 Demo" 与 "N/186 组件" 覆盖率分子
  content = _check(content, RegExp(r'\*\*(\d+)\s*个 Demo\*\*'), demoCount,
      'Demo 总数', () => drift = true);
  content = _check(content, RegExp(r'（(\d+)/\d+\s*组件）'), demoCount,
      'Demo 覆盖率分子', () => drift = true);
  // 覆盖率分母对齐组件数
  content = _check(content, RegExp(r'（\d+/(\d+)\s*组件）'), componentCount,
      'Demo 覆盖率分母', () => drift = true);

  if (!drift) {
    stdout.writeln('README 数字与代码实测一致：组件 $componentCount / Demo $demoCount');
    return;
  }

  if (fix) {
    readme.writeAsStringSync(content);
    stdout.writeln('已回写 README：组件 $componentCount / Demo $demoCount');
  } else {
    stderr.writeln('README 数字与代码实测不一致（实测：组件 $componentCount / Demo $demoCount）。'
        '运行 `dart tool/sync_readme.dart --fix` 自动修正。');
    exit(1);
  }
}

/// 校验 [pattern] 捕获的数字是否等于 [actual]，不一致则替换并标记 drift。
String _check(String content, RegExp pattern, int actual, String label,
    void Function() onDrift) {
  return content.replaceAllMapped(pattern, (m) {
    final claimed = int.tryParse(m.group(1) ?? '');
    if (claimed == actual) return m.group(0)!;
    onDrift();
    stdout.writeln('  [$label] README=$claimed → 实测=$actual');
    return m.group(0)!.replaceFirst(m.group(1)!, '$actual');
  });
}

/// 统计 lib/src/components 下公开 `class Park*` 去重数量。
int _countComponents(String root) {
  final dir = Directory('$root/lib/src/components');
  final names = <String>{};
  final re = RegExp(r'class\s+(Park[A-Za-z0-9_]+)');
  for (final f in dir.listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    for (final m in re.allMatches(f.readAsStringSync())) {
      names.add(m.group(1)!);
    }
  }
  return names.length;
}

/// 统计 lib/src/specs 下 ParkDemoScenario 实例数（剔除类定义行）。
int _countDemos(String root) {
  final dir = Directory('$root/lib/src/specs');
  var count = 0;
  final re = RegExp(r'ParkDemoScenario\(');
  for (final f in dir.listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    count += re.allMatches(f.readAsStringSync()).length;
  }
  return count;
}

/// 定位包根（向上找含 pubspec.yaml 且名为 park_ui 的目录）。
String _packageRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    if (File('${dir.path}/pubspec.yaml').existsSync() &&
        dir.path.replaceAll('\\', '/').endsWith('park_ui')) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return Directory.current.path;
}
