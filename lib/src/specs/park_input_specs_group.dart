// Park 输入组件补充规格 — ParkInputGroup（Batch 2 完善版）
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

// ===========================================================================
// 命名令牌常量
// ===========================================================================
final ParkSpacing _kSpacing = ParkSpacing.defaults();

/// 组合输入组件规格字典（1 个组件）。
Map<String, ParkComponentSpec> get parkInputGroupSpecs =>
    <String, ParkComponentSpec>{
      'ParkInputGroup': _parkInputGroupSpec,
    };

// ---------------------------------------------------------------------------
// ParkInputGroup
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkInputGroupSpec = ParkComponentSpec(
  name: 'ParkInputGroup',
  title: '组合输入',
  category: 'input',
  description:
      '将多个输入类控件（ParkInput / ParkSelect / ParkButton 等）组合成一个'
      '视觉一体的紧凑容器。compact 模式下外层单一圆角边框 + 裁剪 + 相邻 1px 分隔线，'
      '子项需设置 bordered: false 去除中间边框；组高由 size 统一控制，'
      '与 ParkInput / ParkSelect 高度映射一致。',
  icon: Icons.view_module_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: '子组件列表，通常为 ParkInput / ParkSelect / ParkButton / Text 等。'
          ' / Child widget list, usually ParkInput / ParkSelect / ParkButton / Text etc.',
    ),
    ParkPropertyDef(
      name: 'compact',
      type: 'bool',
      defaultVal: 'true',
      description: '紧凑模式：外层单一圆角边框 + 裁剪 + 相邻 1px 分隔线，视觉一体。'
          ' / Compact mode: single rounded border + clip + adjacent 1px dividers, visually unified.',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkInputSize',
      defaultVal: 'ParkInputSize.medium',
      description: '统一组高：small(32) / medium(48) / large(56)。'
          ' / Unified group height: small(32) / medium(48) / large(56).',
    ),
    ParkPropertyDef(
      name: 'divider',
      type: 'bool',
      defaultVal: 'true',
      description: '紧凑模式下是否在相邻子项之间显示 1px 分隔线。'
          ' / Whether to show a 1px divider between adjacent children in compact mode.',
    ),
    ParkPropertyDef(
      name: 'spacing',
      type: 'double',
      defaultVal: '8',
      description: '非紧凑模式下的子项间距。'
          ' / Spacing between children in non-compact mode.',
    ),
    ParkPropertyDef(
      name: 'mainAxisAlignment',
      type: 'MainAxisAlignment',
      defaultVal: 'MainAxisAlignment.start',
      description: '非紧凑模式下的主轴对齐方式。'
          ' / Main axis alignment in non-compact mode.',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否整体禁用（置灰背景）。'
          ' / Whether the whole group is disabled (greyed background).',
    ),
  ],
  // 注意：ParkInputGroup 本身是纯 StatelessWidget 布局容器，不持有任何回调
  // （已核对 park_input_group.dart 构造参数：仅 children / compact / size / divider /
  // spacing / mainAxisAlignment / disabled）。事件由各子组件自身负责
  // （如 ParkInput.onChanged、ParkSelect 的 onChanged 等），因此本组件 events = 0 为
  // 符合实现的正确值，并非遗漏。
  // NOTE: ParkInputGroup is a pure StatelessWidget layout container and exposes no
  // callbacks of its own. Events are delegated to child components
  // (e.g. ParkInput.onChanged, ParkSelect.onChanged). Hence events = 0 is correct.
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkInputGroup(
  children: [
    ParkInput(hintText: '姓名', bordered: false),
    ParkSelect(
      items: [ParkSelectOption(label: '男', value: 'm')],
      hintText: '性别',
      bordered: false,
    ),
    ParkButton(height: 48, child: Text('确定')),
  ],
)
''',
  guide: '''
## 何时使用
- 需要将「输入框 + 下拉选择 + 按钮」等控件在一行紧凑成体时
- 搜索栏、筛选条件行、注册表单的「区号 + 手机号」等组合场景

## 使用建议
- 紧凑模式下，子项务必设置 `bordered: false` 以去掉中间边框，由组提供唯一边框
- 组高由 `size` 统一（small:32 / medium:48 / large:56），与 ParkInput / ParkSelect 一致
- 组内的 ParkButton 必须传入 `height: <组高>` 覆盖默认高度，做到严格等高
- 非紧凑模式（compact: false）下子项各自保留边框，按 spacing 间距排列

## 搭配推荐
- 搭配 ParkInput 做关键词输入
- 搭配 ParkSelect 做类型 / 分类筛选
- 搭配 ParkButton 做搜索 / 提交操作

## 事件说明 / Events note
- ParkInputGroup 是纯布局容器（StatelessWidget），自身**不持有** onChanged 等回调；
  事件由各子组件负责（如 ParkInput.onChanged、ParkSelect 的 onChanged）。因此本组件
  events = 0 是核对实现后的正确值，并非遗漏。
- ParkInputGroup is a pure layout container (StatelessWidget) and exposes **no** callbacks
  of its own; events are delegated to the child components. Hence events = 0 is correct.
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础组合',
      description: '两个输入框组合成一体，中间以 1px 分隔线隔开。',
      code: '''
ParkInputGroup(
  children: [
    ParkInput(hintText: '姓', bordered: false),
    ParkInput(hintText: '名', bordered: false),
  ],
)
''',
      builder: (BuildContext context) => ParkInputGroup(
        children: <Widget>[
          ParkInput(hintText: '姓', bordered: false),
          ParkInput(hintText: '名', bordered: false),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '输入框 + 选择器',
      description: '输入框与下拉选择器组合，二者均设 bordered: false 去中间边框。',
      code: '''
ParkInputGroup(
  children: [
    ParkInput(hintText: '城市', bordered: false),
    ParkSelect(
      items: [
        ParkSelectOption(label: '北京', value: 'bj'),
        ParkSelectOption(label: '上海', value: 'sh'),
      ],
      hintText: '请选择',
      bordered: false,
    ),
  ],
)
''',
      builder: (BuildContext context) => ParkInputGroup(
        children: <Widget>[
          ParkInput(hintText: '城市', bordered: false),
          ParkSelect(
            items: <ParkSelectOption>[
              ParkSelectOption(label: '北京', value: 'bj'),
              ParkSelectOption(label: '上海', value: 'sh'),
            ],
            hintText: '请选择',
            bordered: false,
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '输入框 + 选择器 + 按钮',
      description: '标准搜索栏：输入框 + 选择器 + 按钮，按钮通过 height 与组高严格对齐。',
      code: '''
ParkInputGroup(
  children: [
    ParkInput(hintText: '关键词', bordered: false),
    ParkSelect(
      items: [ParkSelectOption(label: '文章', value: 'article')],
      hintText: '类型',
      bordered: false,
    ),
    ParkButton(height: 48, child: Text('搜索')),
  ],
)
''',
      builder: (BuildContext context) => ParkInputGroup(
        children: <Widget>[
          ParkInput(hintText: '关键词', bordered: false),
          ParkSelect(
            items: <ParkSelectOption>[
              ParkSelectOption(label: '文章', value: 'article'),
              ParkSelectOption(label: '视频', value: 'video'),
            ],
            hintText: '类型',
            bordered: false,
          ),
          ParkButton(height: 48, child: const Text('搜索')),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '尺寸',
      description: '通过 size 切换 small(32) / medium(48) / large(56) 组高。',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkInputGroup(size: ParkInputSize.small, children: [
      ParkInput(hintText: '小', size: ParkInputSize.small, bordered: false),
      ParkButton(height: 32, child: Text('Go')),
    ]),
    SizedBox(height: _kSpacing.sm),
    ParkInputGroup(size: ParkInputSize.medium, children: [
      ParkInput(hintText: '中', size: ParkInputSize.medium, bordered: false),
      ParkButton(height: 48, child: Text('Go')),
    ]),
    SizedBox(height: _kSpacing.sm),
    ParkInputGroup(size: ParkInputSize.large, children: [
      ParkInput(hintText: '大', size: ParkInputSize.large, bordered: false),
      ParkButton(height: 56, child: Text('Go')),
    ]),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkInputGroup(
            size: ParkInputSize.small,
            children: <Widget>[
              ParkInput(
                hintText: '小',
                size: ParkInputSize.small,
                bordered: false,
              ),
              ParkButton(height: 32, child: const Text('Go')),
            ],
          ),
          SizedBox(height: _kSpacing.sm),
          ParkInputGroup(
            size: ParkInputSize.medium,
            children: <Widget>[
              ParkInput(
                hintText: '中',
                size: ParkInputSize.medium,
                bordered: false,
              ),
              ParkButton(height: 48, child: const Text('Go')),
            ],
          ),
          SizedBox(height: _kSpacing.sm),
          ParkInputGroup(
            size: ParkInputSize.large,
            children: <Widget>[
              ParkInput(
                hintText: '大',
                size: ParkInputSize.large,
                bordered: false,
              ),
              ParkButton(height: 56, child: const Text('Go')),
            ],
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '非紧凑模式',
      description: 'compact: false 时子项各自保留边框，按间距排列。',
      code: '''
ParkInputGroup(
  compact: false,
  children: [
    SizedBox(width: 140, child: ParkInput(hintText: '邮箱')),
    ParkButton(child: Text('订阅')),
  ],
)
''',
      builder: (BuildContext context) => ParkInputGroup(
        compact: false,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: ParkInput(hintText: '邮箱'),
          ),
          ParkButton(child: const Text('订阅')),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '禁用状态',
      description: 'disabled: true 整体禁用，所有子项置灰。',
      code: '''
ParkInputGroup(
  disabled: true,
  children: [
    ParkInput(hintText: '已禁用', bordered: false),
    ParkButton(height: 48, child: Text('确定')),
  ],
)
''',
      builder: (BuildContext context) => ParkInputGroup(
        disabled: true,
        children: <Widget>[
          ParkInput(hintText: '已禁用', bordered: false),
          ParkButton(height: 48, child: const Text('确定')),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '组合输入 + onChanged',
      description:
          'ParkInputGroup 自身无回调，事件由子组件负责。下方输入框的 onChanged '
          '通过 StatefulBuilder 实时回显到外部文本，演示「组合输入 + 子组件 onChanged」用法。'
          ' / ParkInputGroup has no callback of its own; the inner ParkInput.onChanged is '
          'wired via StatefulBuilder to echo the typed text live.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String value = '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkInputGroup(
          children: [
            ParkInput(
              hintText: '关键词',
              bordered: false,
              onChanged: (v) => setState(() => value = v),
            ),
            ParkSelect(
              items: [ParkSelectOption(label: '文章', value: 'article')],
              hintText: '类型',
              bordered: false,
            ),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('已输入：\$value', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String value = '';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkInputGroup(
                  children: <Widget>[
                    ParkInput(
                      hintText: '关键词',
                      bordered: false,
                      onChanged: (String v) => setState(() => value = v),
                    ),
                    ParkSelect(
                      items: const <ParkSelectOption>[
                        ParkSelectOption(label: '文章', value: 'article'),
                        ParkSelectOption(label: '视频', value: 'video'),
                      ],
                      hintText: '类型',
                      bordered: false,
                    ),
                  ],
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('已输入：$value', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '可交互：InputGroup 组合',
      description: '通过 StatefulBuilder 管理三个子项的控制器：前缀（区号）+ 主输入（手机号）+'
          ' 后缀按钮（发送验证码），演示 ParkInputGroup 在真实场景下的完整实时交互。'
          '下方回显输入内容和按钮点击状态。'
          ' / StatefulBuilder manages three controllers: prefix (area code) + main (phone) + '
          'suffix button (send code), demonstrating real-world ParkInputGroup interaction.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    final prefixCtrl = TextEditingController();
    final mainCtrl = TextEditingController();
    String btnMsg = '发送验证码';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkInputGroup(
          children: [
            SizedBox(
              width: 80,
              child: ParkInput(
                hintText: '+86',
                bordered: false,
                controller: prefixCtrl,
                onChanged: (_) => setState(() {}),
              ),
            ),
            ParkInput(
              hintText: '手机号',
              bordered: false,
              controller: mainCtrl,
              onChanged: (_) => setState(() {}),
            ),
            ParkButton(
              height: 48,
              onPressed: () =>
                  setState(() => btnMsg = '已发送 !'),
              child: Text(btnMsg),
            ),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText(
          '区号: \${prefixCtrl.text} | 手机号: \${mainCtrl.text}',
          preset: ParkTextPreset.bodySmall,
        ),
        ParkText('按钮状态: \$btnMsg',
            preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        final prefixCtrl = TextEditingController();
        final mainCtrl = TextEditingController();
        String btnMsg = '发送验证码';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkInputGroup(
                  children: <Widget>[
                    SizedBox(
                      width: 80,
                      child: ParkInput(
                        hintText: '+86',
                        bordered: false,
                        controller: prefixCtrl,
                        onChanged: (String _) => setState(() {}),
                      ),
                    ),
                    ParkInput(
                      hintText: '手机号',
                      bordered: false,
                      controller: mainCtrl,
                      onChanged: (String _) => setState(() {}),
                    ),
                    ParkButton(
                      height: 48,
                      onPressed: () =>
                          setState(() => btnMsg = '已发送 !'),
                      child: Text(btnMsg),
                    ),
                  ],
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText(
                  '区号: ${prefixCtrl.text} | 手机号: ${mainCtrl.text}',
                  preset: ParkTextPreset.bodySmall,
                ),
                ParkText('按钮状态: $btnMsg',
                    preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '绑定模式：绑定引擎 + 手动 onChanged',
      description: 'ParkInputGroup 是纯布局容器，无 bindKey 支持。本 demo 展示手动绑定模式：'
          '使用 ParkBindingService + ParkBindingFormScope，通过子输入框的 onChanged 手动'
          '将值写入绑定引擎，下方 model 实时回显当前模型数据。'
          ' / ParkInputGroup is a pure layout container without bindKey. This demo shows manual '
          'binding: ParkBindingService + ParkBindingFormScope, manually pushing values via onChanged, '
          'with live model echo below.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    final prefixCtrl = TextEditingController();
    final mainCtrl = TextEditingController();
    final ParkBindingService service =
        ParkBindingService({'prefix': '', 'phone': ''});
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkBindingFormScope(
          service: service,
          child: ParkInputGroup(
            children: [
              SizedBox(
                width: 80,
                child: ParkInput(
                  hintText: '+86',
                  bordered: false,
                  controller: prefixCtrl,
                  onChanged: (v) {
                    service.setValue('prefix', v);
                    setState(() {});
                  },
                ),
              ),
              ParkInput(
                hintText: '手机号',
                bordered: false,
                controller: mainCtrl,
                onChanged: (v) {
                  service.setValue('phone', v);
                  setState(() {});
                },
              ),
              ParkButton(
                height: 48,
                onPressed: () {
                  service.batch(() {
                    service.setValue('prefix', '+86');
                    service.setValue('phone', '13800138000');
                  });
                  prefixCtrl.text = '+86';
                  mainCtrl.text = '13800138000';
                  setState(() {});
                },
                child: const Text('填充示例'),
              ),
            ],
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('model: \${service.model}',
            preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        final prefixCtrl = TextEditingController();
        final mainCtrl = TextEditingController();
        final ParkBindingService service =
            ParkBindingService(<String, dynamic>{'prefix': '', 'phone': ''});
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkBindingFormScope(
                  service: service,
                  child: ParkInputGroup(
                    children: <Widget>[
                      SizedBox(
                        width: 80,
                        child: ParkInput(
                          hintText: '+86',
                          bordered: false,
                          controller: prefixCtrl,
                          onChanged: (String v) {
                            service.setValue('prefix', v);
                            setState(() {});
                          },
                        ),
                      ),
                      ParkInput(
                        hintText: '手机号',
                        bordered: false,
                        controller: mainCtrl,
                        onChanged: (String v) {
                          service.setValue('phone', v);
                          setState(() {});
                        },
                      ),
                      ParkButton(
                        height: 48,
                        onPressed: () {
                          service.batch(() {
                            service.setValue('prefix', '+86');
                            service.setValue('phone', '13800138000');
                          });
                          prefixCtrl.text = '+86';
                          mainCtrl.text = '13800138000';
                          setState(() {});
                        },
                        child: const Text('填充示例'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('model: ${service.model}',
                    preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '交互式组合输入 + 双向绑定',
      description: '在 ParkInputGroup 中使用绑定的 ParkInput，输入内容实时同步到模型。'
          '/ Using ParkInput with bindKey inside ParkInputGroup for live two-way binding.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    final service = ParkBindingService({
      'name': '张三',
      'email': 'zhangsan@example.com',
    });
    VoidCallback? stopEffect;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkBindingFormScope(
          service: service,
          child: ParkInputGroup(
            children: [
              ParkInput(
                hintText: '姓名',
                bindKey: 'name',
                bordered: false,
              ),
              ParkInput(
                hintText: '邮箱',
                bindKey: 'email',
                bordered: false,
              ),
              ParkButton(
                height: 48,
                onPressed: () {
                  service.batch(() {
                    service.setValue('name', '李四');
                    service.setValue('email', 'lisi@example.com');
                  });
                  setState(() {});
                },
                child: Text('重置'),
              ),
            ],
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('model: \$service.model',
            preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        final service = ParkBindingService(<String, dynamic>{
          'name': '张三',
          'email': 'zhangsan@example.com',
        });
        VoidCallback? stopEffect;
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            // 使用 watchEffect 自动追踪依赖，值变化时触发 setState 刷新 model 回显
            stopEffect ??= service.watchEffect(() {
              service.getValue<String>('name');
              service.getValue<String>('email');
              setState(() {});
            });
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkBindingFormScope(
                  service: service,
                  child: ParkInputGroup(
                    children: <Widget>[
                      ParkInput(
                        hintText: '姓名',
                        bindKey: 'name',
                        bordered: false,
                      ),
                      ParkInput(
                        hintText: '邮箱',
                        bindKey: 'email',
                        bordered: false,
                      ),
                      ParkButton(
                        height: 48,
                        onPressed: () {
                          service.batch(() {
                            service.setValue('name', '李四');
                            service.setValue('email', 'lisi@example.com');
                          });
                          setState(() {});
                        },
                        child: const Text('重置'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('model: ${service.model}',
                    preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    // ── ParkInputGroup: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm）',
      description: 'ParkInputGroup 组合内的字段可通过 ParkForm schema 等效表达。'
          ' / ParkForm demo: equivalent schema for grouped fields.',
      code: '''
ParkForm(
  schema: ParkFormSchema(
    formKey: 'group_demo',
    fields: [
      ParkFormFieldSchema(
        fieldId: 'f_name',
        fieldType: ParkFieldType.text,
        labelName: '姓名',
        fieldName: 'name',
        isRequired: true,
        fieldPrompt: '请输入姓名',
      ),
      ParkFormFieldSchema(
        fieldId: 'f_email',
        fieldType: ParkFieldType.text,
        labelName: '邮箱',
        fieldName: 'email',
        fieldPrompt: '请输入邮箱',
      ),
    ],
  ),
  onSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkForm(
          schema: ParkFormSchema(
            formKey: 'group_demo',
            fields: <ParkFormFieldSchema>[
              ParkFormFieldSchema(
                fieldId: 'f_name',
                fieldType: ParkFieldType.text,
                labelName: '姓名',
                fieldName: 'name',
                isRequired: true,
                fieldPrompt: '请输入姓名',
              ),
              ParkFormFieldSchema(
                fieldId: 'f_email',
                fieldType: ParkFieldType.text,
                labelName: '邮箱',
                fieldName: 'email',
                fieldPrompt: '请输入邮箱',
              ),
            ],
          ),
          onSubmit: (_) {},
        ),
      ),
    ),
  ],
);
