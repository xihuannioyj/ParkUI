import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Form Demo
// =============================================================================

class FormDemo extends StatelessWidget {
  const FormDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Form 表单', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('表单容器，支持校验、提交、重置，配合 FormItem / FormSection 使用。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础表单', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkForm(
          onSubmit: (values) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Submitted: $values')),
            );
          },
          showReset: true,
          children: [
            ParkFormItem(
              label: '用户名',
              required: true,
              rules: const [
                ParkFormRule(required: true, message: '请输入用户名'),
              ],
              child: ParkInput(hintText: '请输入用户名'),
            ),
            ParkFormItem(
              label: '邮箱',
              rules: const [
                ParkFormRule(
                    required: true, type: ParkRuleType.email, message: '请输入有效邮箱'),
              ],
              child: ParkInput(hintText: '请输入邮箱'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('分组表单', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkForm(
          onSubmit: (_) {},
          showReset: false,
          children: [
            ParkFormSection(
              title: '基本信息',
              description: '请填写您的基本信息',
              children: [
                ParkFormItem(
                  label: '姓名',
                  child: ParkInput(hintText: '请输入姓名'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ParkFormSection(
              title: '联系方式',
              collapsible: true,
              children: [
                ParkFormItem(
                  label: '手机号',
                  child: ParkInput(hintText: '请输入手机号'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// DynamicForm Demo
// =============================================================================

class DynamicFormDemo extends StatelessWidget {
  const DynamicFormDemo({super.key});

  static final ParkFormSchema _basicSchema = ParkFormSchema(
    formKey: 'demo_basic',
    fields: [
      ParkFormFieldSchema(
        fieldId: 'f1',
        fieldName: 'username',
        labelName: '用户名',
        fieldType: ParkFieldType.text,
        isRequired: true,
        fieldPrompt: '请输入用户名',
      ),
      ParkFormFieldSchema(
        fieldId: 'f2',
        fieldName: 'email',
        labelName: '邮箱',
        fieldType: ParkFieldType.text,
        fieldPrompt: '请输入邮箱',
        regexTag: 'email',
        validatorMessage: '请输入有效的邮箱地址',
      ),
      ParkFormFieldSchema(
        fieldId: 'f3',
        fieldName: 'role',
        labelName: '角色',
        fieldType: ParkFieldType.select,
        fieldPrompt: '请选择角色',
        dataSourceType: ParkDataSourceType.staticOptions,
        options: const [
          {'label': '管理员', 'value': 'admin'},
          {'label': '编辑者', 'value': 'editor'},
          {'label': '访客', 'value': 'guest'},
        ],
      ),
      ParkFormFieldSchema(
        fieldId: 'f4',
        fieldName: 'active',
        labelName: '启用',
        fieldType: ParkFieldType.toggle,
        defaultValue: true,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('DynamicForm 动态表单', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('通过 JSON Schema 驱动表单渲染，支持校验、联动、分组。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础动态表单', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkForm(
          schema: _basicSchema,
          onSchemaSubmit: (values) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Submitted: $values')),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('分组 + 可折叠', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkForm(
          schema: ParkFormSchema(
            formKey: 'demo_grouped',
            fields: [
              ParkFormFieldSchema(
                fieldId: 'g1',
                fieldName: 'name',
                labelName: '姓名',
                fieldType: ParkFieldType.text,
                isRequired: true,
                fieldPrompt: '请输入姓名',
                groupKey: 'basic',
                groupName: '基本信息',
              ),
              ParkFormFieldSchema(
                fieldId: 'g2',
                fieldName: 'age',
                labelName: '年龄',
                fieldType: ParkFieldType.number,
                fieldPrompt: '请输入年龄',
                groupKey: 'basic',
              ),
              ParkFormFieldSchema(
                fieldId: 'g3',
                fieldName: 'bio',
                labelName: '简介',
                fieldType: ParkFieldType.textarea,
                fieldPrompt: '请输入个人简介',
                groupKey: 'extra',
                groupName: '详细信息',
              ),
            ],
          ),
          showReset: false,
          onSchemaSubmit: (values) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Submitted: $values')),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// FormBuilder Demo
// =============================================================================

class FormBuilderDemo extends StatelessWidget {
  const FormBuilderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('FormBuilder 表单构建器', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('使用 ParkFormBuilder 从 Schema 创建响应式表单组，编程式控制表单值与状态。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('编程式表单', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        _FormBuilderExample(),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

class _FormBuilderExample extends StatefulWidget {
  @override
  State<_FormBuilderExample> createState() => _FormBuilderExampleState();
}

class _FormBuilderExampleState extends State<_FormBuilderExample> {
  late final ParkFormGroup _group;

  @override
  void initState() {
    super.initState();
    final schema = ParkFormSchema(
      formKey: 'demo_builder',
      fields: [
        ParkFormFieldSchema(
          fieldId: 'fb1',
          fieldName: 'city',
          labelName: '城市',
          fieldType: ParkFieldType.text,
          fieldPrompt: '请输入城市',
        ),
        ParkFormFieldSchema(
          fieldId: 'fb2',
          fieldName: 'district',
          labelName: '区域',
          fieldType: ParkFieldType.text,
          fieldPrompt: '请输入区域',
        ),
      ],
    );
    _group = ParkFormBuilder.fromSchema(
      schema,
      initialData: {'city': '北京', 'district': '朝阳区'},
    );
  }

  @override
  void dispose() {
    _group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkForm(
          schema: ParkFormSchema(
            formKey: 'demo_builder_ui',
            fields: [
              ParkFormFieldSchema(
                fieldId: 'fb1',
                fieldName: 'city',
                labelName: '城市',
                fieldType: ParkFieldType.text,
                fieldPrompt: '请输入城市',
              ),
              ParkFormFieldSchema(
                fieldId: 'fb2',
                fieldName: 'district',
                labelName: '区域',
                fieldType: ParkFieldType.text,
                fieldPrompt: '请输入区域',
              ),
            ],
          ),
          formGroup: _group,
          showReset: false,
          onSchemaSubmit: (_) {},
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () async {
                await _group.validate();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Values: ${_group.value}')),
                );
              },
              child: const Text('获取值'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                _group.patchValue({'city': '上海', 'district': '浦东'});
              },
              child: const Text('填充数据'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                _group.reset();
              },
              child: const Text('重置'),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// FormArray Demo
// =============================================================================

class FormArrayDemo extends StatelessWidget {
  const FormArrayDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('FormArray 表单数组', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('动态增减表单项列表，支持嵌套表单组。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('动态列表', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        _FormArrayExample(),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

class _FormArrayExample extends StatefulWidget {
  @override
  State<_FormArrayExample> createState() => _FormArrayExampleState();
}

class _FormArrayExampleState extends State<_FormArrayExample> {
  late final ParkFormArray _array;

  @override
  void initState() {
    super.initState();
    _array = ParkFormArray([
      ParkFormGroupControl({
        'name': ParkFormControl('张三'),
        'score': ParkFormControl(90),
      }),
      ParkFormGroupControl({
        'name': ParkFormControl('李四'),
        'score': ParkFormControl(85),
      }),
    ]);
  }

  @override
  void dispose() {
    _array.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _array.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('#${index + 1}  ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(
                    child: ParkInput(
                      label: '姓名',
                      initialValue:
                          item.control('name')?.value as String? ?? '',
                      hintText: '请输入姓名',
                      onChanged: (String? v) {
                        item.control('name')?.setValue(v ?? '');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: ParkInput(
                      label: '分数',
                      initialValue:
                          (item.control('score')?.value ?? '').toString(),
                      hintText: '分数',
                      onChanged: (String? v) {
                        item.control('score')?.setValue(int.tryParse(v ?? '') ?? 0);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      _array.removeAt(index);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                _array.add(ParkFormGroupControl({
                  'name': ParkFormControl(''),
                  'score': ParkFormControl(0),
                }));
                setState(() {});
              },
              child: const Text('+ 添加'),
            ),
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Array values: ${_array.value}')),
                );
              },
              child: const Text('获取所有值'),
            ),
          ],
        ),
      ],
    );
  }
}
