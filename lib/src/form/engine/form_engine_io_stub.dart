// 文件序列化辅助 — 空实现（Web 回退）。
//
// 通过条件导入，在原生平台使用 dart:io 实现，
// 在 Web 平台使用本空实现。
String? trySerializeFilePath(dynamic value) => null;
