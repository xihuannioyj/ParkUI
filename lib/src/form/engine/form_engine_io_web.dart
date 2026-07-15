// 文件序列化辅助 — Web 平台实现。
//
// Web 环境无 dart:io File 类型，直接返回 null。
// 经条件导入在 Web 平台覆盖 [form_engine_io_stub.dart] 的空实现（行为一致）。
String? trySerializeFilePath(dynamic value) => null;
