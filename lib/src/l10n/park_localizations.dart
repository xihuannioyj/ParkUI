import 'package:flutter/material.dart';

// =============================================================================
// ParkLocalizations — park_ui 全局国际化字符串
// =============================================================================

/// park_ui 本地化字符串抽象接口。
///
/// 所有组件中用户可见的文字都可由此接口统一管理。
/// 通过 [ParkLocalizationsWidget] 注入 Widget 树，
/// 组件内通过 `ParkLocalizations.of(context)` 获取。
///
/// 内置 [ParkLocalizationsZh]（中文默认）和 [ParkLocalizationsEn]（英文）两种实现。
/// 调用方可实现此接口并注入自定义本地化。
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ParkLocalizationsWidget(
///     localizations: ParkLocalizationsEn(),
///     child: child!,
///   ),
/// )
/// ```
abstract class ParkLocalizations {
  // ── 按钮 ──
  String get confirmText;
  String get cancelText;
  String get clearText;
  String get searchText;
  String get submitText;
  String get saveText;
  String get deleteText;
  String get closeText;
  String get doneText;
  String get resetText;

  // ── 占位 ──
  String get selectPlaceholder;
  String get inputPlaceholder;
  String get searchPlaceholder;

  // ── 状态 ──
  String get noData;
  String get loading;
  String get loadFailed;
  String get retry;
  String get success;
  String get warning;
  String get error;

  // ── 步骤 ──
  String get previousStep;
  String get nextStep;

  // ── 其他 ──
  String get noMore;
  String get pullToRefresh;
  String get releaseToRefresh;
  String get refreshing;
  String get confirmDelete;

  /// 从 [BuildContext] 获取当前 [ParkLocalizations]。
  /// 未注入时返回 [ParkLocalizationsZh] 默认值。
  static ParkLocalizations of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_ParkLocalizationsInherited>();
    if (inherited != null) return inherited.localizations;
    return const ParkLocalizationsZh();
  }
}

// =============================================================================
// ParkLocalizationsWidget — 注入本地化的 InheritedWidget 封装
// =============================================================================

/// 向 Widget 树注入 [ParkLocalizations]。
///
/// 通常放在 [MaterialApp] 的 builder 中：
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ParkLocalizationsWidget(
///     localizations: ParkLocalizationsEn(),
///     child: child!,
///   ),
/// )
/// ```
class ParkLocalizationsWidget extends StatefulWidget {
  /// 本地化实现。
  final ParkLocalizations localizations;

  /// 子组件。
  final Widget child;

  const ParkLocalizationsWidget({
    super.key,
    required this.localizations,
    required this.child,
  });

  @override
  State<ParkLocalizationsWidget> createState() =>
      _ParkLocalizationsWidgetState();
}

class _ParkLocalizationsWidgetState extends State<ParkLocalizationsWidget> {
  @override
  Widget build(BuildContext context) {
    return _ParkLocalizationsInherited(
      localizations: widget.localizations,
      child: widget.child,
    );
  }
}

class _ParkLocalizationsInherited extends InheritedWidget {
  final ParkLocalizations localizations;

  const _ParkLocalizationsInherited({
    required this.localizations,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ParkLocalizationsInherited oldWidget) =>
      oldWidget.localizations != localizations;
}

// =============================================================================
// 中文（默认）
// =============================================================================

/// park_ui 中文本地化（默认实现）。
class ParkLocalizationsZh implements ParkLocalizations {
  const ParkLocalizationsZh();

  @override
  String get confirmText => '确定';
  @override
  String get cancelText => '取消';
  @override
  String get clearText => '清空';
  @override
  String get searchText => '搜索';
  @override
  String get submitText => '提交';
  @override
  String get saveText => '保存';
  @override
  String get deleteText => '删除';
  @override
  String get closeText => '关闭';
  @override
  String get doneText => '完成';
  @override
  String get resetText => '重置';
  @override
  String get selectPlaceholder => '请选择';
  @override
  String get inputPlaceholder => '请输入';
  @override
  String get searchPlaceholder => '搜索';
  @override
  String get noData => '暂无数据';
  @override
  String get loading => '加载中...';
  @override
  String get loadFailed => '加载失败';
  @override
  String get retry => '重试';
  @override
  String get success => '成功';
  @override
  String get warning => '警告';
  @override
  String get error => '错误';
  @override
  String get previousStep => '上一步';
  @override
  String get nextStep => '下一步';
  @override
  String get noMore => '没有更多';
  @override
  String get pullToRefresh => '下拉刷新';
  @override
  String get releaseToRefresh => '释放刷新';
  @override
  String get refreshing => '刷新中...';
  @override
  String get confirmDelete => '确认删除？';
}

// =============================================================================
// 英文
// =============================================================================

/// park_ui 英文本地化。
class ParkLocalizationsEn implements ParkLocalizations {
  const ParkLocalizationsEn();

  @override
  String get confirmText => 'OK';
  @override
  String get cancelText => 'Cancel';
  @override
  String get clearText => 'Clear';
  @override
  String get searchText => 'Search';
  @override
  String get submitText => 'Submit';
  @override
  String get saveText => 'Save';
  @override
  String get deleteText => 'Delete';
  @override
  String get closeText => 'Close';
  @override
  String get doneText => 'Done';
  @override
  String get resetText => 'Reset';
  @override
  String get selectPlaceholder => 'Please select';
  @override
  String get inputPlaceholder => 'Please enter';
  @override
  String get searchPlaceholder => 'Search';
  @override
  String get noData => 'No data';
  @override
  String get loading => 'Loading...';
  @override
  String get loadFailed => 'Load failed';
  @override
  String get retry => 'Retry';
  @override
  String get success => 'Success';
  @override
  String get warning => 'Warning';
  @override
  String get error => 'Error';
  @override
  String get previousStep => 'Previous';
  @override
  String get nextStep => 'Next';
  @override
  String get noMore => 'No more';
  @override
  String get pullToRefresh => 'Pull to refresh';
  @override
  String get releaseToRefresh => 'Release to refresh';
  @override
  String get refreshing => 'Refreshing...';
  @override
  String get confirmDelete => 'Confirm delete?';
}

// =============================================================================
// 日语
// =============================================================================

/// park_ui 日文本地化。
class ParkLocalizationsJa implements ParkLocalizations {
  const ParkLocalizationsJa();

  @override
  String get confirmText => '確認';
  @override
  String get cancelText => 'キャンセル';
  @override
  String get clearText => 'クリア';
  @override
  String get searchText => '検索';
  @override
  String get submitText => '送信';
  @override
  String get saveText => '保存';
  @override
  String get deleteText => '削除';
  @override
  String get closeText => '閉じる';
  @override
  String get doneText => '完了';
  @override
  String get resetText => 'リセット';
  @override
  String get selectPlaceholder => '選択してください';
  @override
  String get inputPlaceholder => '入力してください';
  @override
  String get searchPlaceholder => '検索';
  @override
  String get noData => 'データがありません';
  @override
  String get loading => '読み込み中...';
  @override
  String get loadFailed => '読み込み失敗';
  @override
  String get retry => '再試行';
  @override
  String get success => '成功';
  @override
  String get warning => '警告';
  @override
  String get error => 'エラー';
  @override
  String get previousStep => '前へ';
  @override
  String get nextStep => '次へ';
  @override
  String get noMore => 'これ以上ありません';
  @override
  String get pullToRefresh => '下に引っ張って更新';
  @override
  String get releaseToRefresh => '離して更新';
  @override
  String get refreshing => '更新中...';
  @override
  String get confirmDelete => '削除してもよろしいですか？';
}
