import '../models/form_field_schema.dart';
import '../models/form_layout_schema.dart';

/// Park 动态表单 Schema 构建器
///
/// 链式 API 替代手写 JSON Schema，提供 IDE 补全和类型安全。
///
/// ```dart
/// final schema = ParkSchemaBuilder('my_form')
///   .addTextField('username', label: '用户名', required: true)
///   .addSelectField('role', label: '角色', options: [
///     {'label': '管理员', 'value': 'admin'},
///     {'label': '普通用户', 'value': 'user'},
///   ])
///   .addDateField('birthday', label: '出生日期')
///   .build();
/// ```
class ParkSchemaBuilder {
  final String formKey;
  final List<ParkFormFieldSchema> _fields = [];
  ParkFormLayout? _layout;

  /// 创建 Schema 构建器。
  ///
  /// [formKey] 表单唯一标识。
  ParkSchemaBuilder(this.formKey);

  /// 设置表单布局配置。
  ParkSchemaBuilder layout(ParkFormLayout layout) {
    _layout = layout;
    return this;
  }

  ParkFormFieldSchema _makeField({
    required String fieldId,
    required ParkFieldType fieldType,
    String? fieldName,
    String? labelName,
    dynamic defaultValue,
    String? placeholder,
    String? helpText,
    bool required = false,
    String? groupKey,
    List<Map<String, dynamic>> options = const [],
  }) {
    return ParkFormFieldSchema(
      fieldId: fieldId,
      fieldType: fieldType,
      fieldName: fieldName ?? fieldId,
      labelName: labelName ?? fieldId,
      fieldPrompt: placeholder ?? '',
      isRequired: required,
      helpText: helpText,
      defaultValue: defaultValue,
      groupKey: groupKey,
      options: options,
    );
  }

  /// 添加文本输入字段。
  ParkSchemaBuilder addTextField(
    String fieldId, {
    String? label,
    String? placeholder,
    bool required = false,
    String? helpText,
    String? groupKey,
  }) {
    _fields.add(_makeField(
      fieldId: fieldId,
      fieldType: ParkFieldType.text,
      labelName: label ?? fieldId,
      placeholder: placeholder ?? '请输入$label',
      required: required,
      helpText: helpText,
      groupKey: groupKey,
    ));
    return this;
  }

  /// 添加数字输入字段。
  ParkSchemaBuilder addNumberField(
    String fieldId, {
    String? label,
    bool required = false,
    double? min,
    double? max,
    String? helpText,
    String? groupKey,
  }) {
    _fields.add(_makeField(
      fieldId: fieldId,
      fieldType: ParkFieldType.number,
      labelName: label ?? fieldId,
      required: required,
      helpText: helpText,
      groupKey: groupKey,
    ));
    return this;
  }

  /// 添加选择器字段。
  ParkSchemaBuilder addSelectField(
    String fieldId, {
    String? label,
    required List<Map<String, dynamic>> options,
    bool required = false,
    bool multiple = false,
    String? placeholder,
    String? groupKey,
  }) {
    _fields.add(_makeField(
      fieldId: fieldId,
      fieldType: multiple ? ParkFieldType.checkbox : ParkFieldType.select,
      labelName: label ?? fieldId,
      placeholder: placeholder,
      required: required,
      options: options,
      groupKey: groupKey,
    ));
    return this;
  }

  /// 添加日期字段。
  ParkSchemaBuilder addDateField(
    String fieldId, {
    String? label,
    bool required = false,
    bool showTime = false,
    String? groupKey,
  }) {
    _fields.add(_makeField(
      fieldId: fieldId,
      fieldType: ParkFieldType.date,
      labelName: label ?? fieldId,
      required: required,
      groupKey: groupKey,
    ));
    return this;
  }

  /// 添加开关字段。
  ParkSchemaBuilder addSwitchField(
    String fieldId, {
    String? label,
    bool defaultValue = false,
    String? groupKey,
  }) {
    _fields.add(_makeField(
      fieldId: fieldId,
      fieldType: ParkFieldType.toggle,
      labelName: label ?? fieldId,
      defaultValue: defaultValue,
      groupKey: groupKey,
    ));
    return this;
  }

  /// 添加多行文本字段。
  ParkSchemaBuilder addTextareaField(
    String fieldId, {
    String? label,
    String? placeholder,
    bool required = false,
    String? groupKey,
  }) {
    _fields.add(_makeField(
      fieldId: fieldId,
      fieldType: ParkFieldType.textarea,
      labelName: label ?? fieldId,
      placeholder: placeholder,
      required: required,
      groupKey: groupKey,
    ));
    return this;
  }

  /// 添加级联选择器字段。
  ParkSchemaBuilder addCascaderField(
    String fieldId, {
    String? label,
    required List<Map<String, dynamic>> options,
    bool required = false,
    String? groupKey,
  }) {
    _fields.add(_makeField(
      fieldId: fieldId,
      fieldType: ParkFieldType.cascader,
      labelName: label ?? fieldId,
      required: required,
      options: options,
      groupKey: groupKey,
    ));
    return this;
  }

  /// 添加评分字段。
  ParkSchemaBuilder addRateField(
    String fieldId, {
    String? label,
    int max = 5,
    String? groupKey,
  }) {
    _fields.add(_makeField(
      fieldId: fieldId,
      fieldType: ParkFieldType.rate,
      labelName: label ?? fieldId,
      defaultValue: 0,
      groupKey: groupKey,
    ));
    return this;
  }

  /// 添加图片上传字段。
  ParkSchemaBuilder addImageField(
    String fieldId, {
    String? label,
    int maxCount = 9,
    String? groupKey,
  }) {
    _fields.add(_makeField(
      fieldId: fieldId,
      fieldType: ParkFieldType.image,
      labelName: label ?? fieldId,
      groupKey: groupKey,
    ));
    return this;
  }

  /// 构建 [ParkFormSchema]。
  ParkFormSchema build({
    List<ParkFormReactionSchema> reactions = const [],
  }) {
    return ParkFormSchema(
      formKey: formKey,
      fields: _fields,
      reactions: reactions,
      layout: _layout,
    );
  }

  /// 当前字段数量。
  int get fieldCount => _fields.length;
}
