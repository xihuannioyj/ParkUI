/// 组件数量断言测试
/// 确保 Park UI 组件库的组件数量保持稳定，防止意外增减

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParkComponentRegistry - 组件数量断言', () {
    test('lib/src/components 目录下导出的组件文件数量稳定', () {
      // 扫描 lib/src/components 目录下的所有 .dart 文件
      final componentsDir = Directory('lib/src/components');
      expect(componentsDir.existsSync(), isTrue,
          reason: 'lib/src/components 目录应存在');

      final dartFiles = componentsDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      // 当前实际组件文件数量
      // 如果新增或删除组件，需同步更新此断言值
      expect(dartFiles.length, equals(111),
          reason: '组件文件数量应为 111，如有变更请更新此断言值');
    });

    test('park_ui.dart 导出的组件文件数量稳定', () {
      final barrelFile = File('lib/park_ui.dart');
      expect(barrelFile.existsSync(), isTrue,
          reason: 'lib/park_ui.dart 应存在');

      final content = barrelFile.readAsStringSync();
      final lines = content.split('\n');
      final componentExports = lines
          .where((line) => line.trimLeft().startsWith("export 'src/components/"))
          .toList();

      // 当前 barrel 文件中导出的组件数量
      // 如果新增或删除组件导出，需同步更新此断言值
      expect(componentExports.length, equals(99),
          reason: 'barrel 文件中组件导出数量应为 99，如有变更请更新此断言值');
    });

    test('各子目录组件分布合理', () {
      final componentsDir = Directory('lib/src/components');
      final subdirs = componentsDir
          .listSync()
          .whereType<Directory>()
          .toList();

      // 至少有 base, input, navigation, display, feedback 五个子目录
      expect(subdirs.length, greaterThanOrEqualTo(5),
          reason: '组件库应至少包含 5 个子目录');

      final dirNames = subdirs.map((d) => d.path.split(Platform.pathSeparator).last).toSet();
      expect(dirNames, containsAll(['base', 'input', 'navigation', 'display', 'feedback']));
    });
  });
}
