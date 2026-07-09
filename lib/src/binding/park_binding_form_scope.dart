import 'package:flutter/widgets.dart';
import 'park_binding_service.dart';

/// 表单绑定 InheritedWidget。
///
/// 向子树注入 [ParkBindingService]。
/// 子组件可通过 [ParkBindingFormScope.of(context)] 获取绑定服务。
///
/// ```dart
/// final service = ParkBindingFormScope.of(context)?.service;
/// ```
class ParkBindingFormScope extends InheritedWidget {
  /// 绑定服务实例。
  final ParkBindingService service;

  /// 创建 [ParkBindingFormScope]。
  const ParkBindingFormScope({
    super.key,
    required this.service,
    required super.child,
  });

  /// 获取最近的 [ParkBindingFormScope]。
  ///
  /// 如果上下文中不存在，返回 `null`。
  static ParkBindingFormScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ParkBindingFormScope>();
  }

  @override
  bool updateShouldNotify(ParkBindingFormScope oldWidget) {
    return service != oldWidget.service;
  }
}
