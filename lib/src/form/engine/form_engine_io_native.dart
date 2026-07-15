// 文件序列化辅助 — 原生平台实现。
//
// 使用 dart:io 的 File 类型提取本地文件路径。
// 经条件导入在原生平台覆盖 [form_engine_io_stub.dart] 的空实现，
// 使 park_ui 的动态表单在导出值时可将 File 正确序列化为路径。
import 'dart:io';

/// 将 [value] 中的 [File] 提取为本地文件路径；非 File 时返回 null。
String? trySerializeFilePath(dynamic value) {
  if (value is File) {
    return value.path;
  }
  return null;
}
