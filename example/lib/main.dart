import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  runApp(const MyApp());
}

/// Minimal example app demonstrating a few park_ui components across
/// the 基础 / 输入 / 展示 / 表单 categories.
///
/// All park_ui components fall back to [ParkThemeData.light()] when no
/// theme extension is injected, so this example runs with a plain
/// [ThemeData] and no external state management.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'park_ui Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('park_ui')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // 基础
          ParkButton(
            variant: ParkButtonVariant.primary,
            onPressed: () {},
            child: const Text('提交'),
          ),
          const SizedBox(height: 16),
          // 展示
          ParkCard(
            titleText: '卡片标题',
            child: const Text('这是一个 park_ui 卡片组件示例。'),
          ),
          const SizedBox(height: 16),
          // 栅格布局
          ParkGridRow(
            gutter: 16,
            vGutter: 8,
            children: [
              ParkGridCol(
                span: 8,
                child: Container(
                  height: 48,
                  color: Colors.blue.shade100,
                  alignment: Alignment.center,
                  child: const Text('8/24'),
                ),
              ),
              ParkGridCol(
                span: 8,
                child: Container(
                  height: 48,
                  color: Colors.green.shade100,
                  alignment: Alignment.center,
                  child: const Text('8/24'),
                ),
              ),
              ParkGridCol(
                span: 8,
                child: Container(
                  height: 48,
                  color: Colors.orange.shade100,
                  alignment: Alignment.center,
                  child: const Text('8/24'),
                ),
              ),
              ParkGridCol(
                span: 24,
                responsive: const ParkGridResponsive(md: 12, lg: 6),
                child: Container(
                  height: 48,
                  color: Colors.purple.shade100,
                  alignment: Alignment.center,
                  child: const Text('响应式'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              const ParkAvatar(text: 'PU'),
              const SizedBox(width: 12),
              const ParkTag(text: 'New', theme: ParkTagTheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          // 输入
          ParkInput(
            label: '用户名',
            hintText: '请输入用户名',
          ),
          const SizedBox(height: 16),
          // 表单 / 反馈
          ParkSwitch(
            value: true,
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }
}
