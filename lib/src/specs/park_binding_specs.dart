// Park 双向绑定引擎规格 — 展示页
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

/// 设计令牌（复用 ParkColors，避免裸字面量）。
final ParkColors _kColors = ParkColors.light();

/// 双向绑定引擎规格字典（1 个引擎）。
Map<String, ParkComponentSpec> get parkBindingSpecs =>
    <String, ParkComponentSpec>{
      'ParkBinding': _parkBindingSpec,
    };

// ---------------------------------------------------------------------------
// ParkBinding
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkBindingSpec = ParkComponentSpec(
  name: 'ParkBinding',
  title: '双向绑定',
  category: 'form',
  description:
      'ParkBindingEngine 基于 ValueNotifier + ValueListenableBuilder 实现了轻量级'
      '双向绑定引擎。支持点号分隔的嵌套路径、不可变模式设置、单例绑定实例管理，'
      '可零侵入集成到 ParkForm 和 ParkForm 中，无需任何三方依赖。',
  icon: Icons.link,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      description: '绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      description: '绑定服务实例。不设时尝试从 ParkBindingFormScope 获取。',
    ),
    ParkPropertyDef(
      name: 'model',
      type: 'Map<String, dynamic>?',
      description: 'ParkForm 的模型数据。传入后自动创建 ParkBindingService。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<T>',
      description: '值变化回调，由各组件（ParkInput/ParkSelect/ParkSwitch/ParkTextarea）'
          '直接提供。',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'service.bind<T>(path)',
      signature: 'ParkBindable<T> bind<T>(String path, {T? defaultValue})',
      description: '绑定路径，返回缓存或新建的 ParkBindable 实例。',
    ),
    ParkMethodDef(
      name: 'service.setValue<T>(path, value)',
      signature: 'void setValue<T>(String path, T value)',
      description: '快捷设置值，同时更新 ParkBindable 和模型。',
    ),
    ParkMethodDef(
      name: 'service.getValue<T>(path)',
      signature: 'T? getValue<T>(String path)',
      description: '快捷获取值，优先从 ParkBindable 获取。',
    ),
    ParkMethodDef(
      name: 'service.updateModel(newModel)',
      signature: 'void updateModel(Map<String, dynamic> newModel)',
      description: '批量更新模型，比对差异后仅通知变化的路径。',
    ),
    ParkMethodDef(
      name: 'service.dispose()',
      signature: 'void dispose()',
      description: '释放所有绑定和资源。',
    ),
    ParkMethodDef(
      name: 'service.watchEffect(fn)',
      signature: 'WatchEffectHandle watchEffect(void Function() fn)',
      description: '注册副作用函数，自动追踪其依赖的绑定路径；依赖变化自动重执行，返回停止句柄。',
    ),
    ParkMethodDef(
      name: 'service.batch(fn)',
      signature: 'void batch(void Function() fn)',
      description: '在批量作用域内执行 fn，将内部所有 setValue / updateModel 合并为单次通知。',
    ),
    ParkMethodDef(
      name: 'service.beginBatch() / endBatch()',
      signature: 'void beginBatch() / void endBatch()',
      description: '批量更新模式的底层开关（须成对使用），推荐使用 batch 高阶方法。',
    ),
    ParkMethodDef(
      name: 'service.nextTick()',
      signature: 'Future<void> nextTick()',
      description: '类似 Vue3 nextTick，等待所有待处理的批量更新完成以获取最新状态。',
    ),
    ParkMethodDef(
      name: 'service.disposeBindable(path)',
      signature: 'void disposeBindable(String path)',
      description: '释放指定路径的绑定并移除其注册引用。',
    ),
    ParkMethodDef(
      name: 'ParkBindable.value / update',
      signature: 'T get value / set value(T) / void update(T newValue)',
      description: '响应式值容器：value 读写（相等检测跳过重复通知），update 强制更新。',
    ),
    ParkMethodDef(
      name: 'ParkBindingPath.split(path)',
      signature: 'List<String> split(String path)',
      description: '将点号路径分割为键列表。',
    ),
    ParkMethodDef(
      name: 'ParkBindingPath.resolve(path, data)',
      signature: 'dynamic resolve(String path, Map data)',
      description: '沿路径从 data 中解析值。',
    ),
    ParkMethodDef(
      name: 'ParkBindingPath.set(path, data, value)',
      signature: 'Map set(String path, Map data, dynamic value)',
      description: '沿路径设置值（不可变模式，返回新 Map）。',
    ),
    ParkMethodDef(
      name: 'ParkBindingPath.hasPath(path, data)',
      signature: 'bool hasPath(String path, Map data)',
      description: '判断点号路径在 data 中是否存在（指南已提及，补全方法签名）。',
    ),
  ],
  basicUsageCode: '''
// 1. 创建绑定服务
final service = ParkBindingService({'name': '张三'});

// 2. 绑定字段 — 直接在组件上使用 bindKey
ParkInput(
  label: '姓名',
  bindKey: 'name',
  bindingService: service,
  hintText: '输入后下方实时显示',
)

// 3. 监听变化
final nameBindable = service.bind<String>('name');
nameBindable.addListener(() {
  print('新值: \${nameBindable.value}');
});''',
  guide: '''
## 快速开始
10 行代码体验核心用法：

```dart
final service = ParkBindingService({'name': '张三'});
final bindable = service.bind<String>('name');
bindable.addListener(() => print(bindable.value));
bindable.value = '李四'; // 触发通知
```

## ParkForm + bindingService 模式
传入外部绑定服务实现双向绑定：

```dart
final service = ParkBindingService({'name': '张三', 'age': 18});
ParkForm(
  bindingService: service,
  children: [
    ParkInput(label: '姓名', bindKey: 'name'),
    ParkInput(label: '年龄', bindKey: 'age'),
  ],
)
```
子组件通过 `ParkBindingFormScope.of(context)` 自动获取绑定服务，
不必手动传递 `bindingService` 参数。

## ParkForm + model 模式（快捷方式）
传入 Map 模型，ParkForm 自动创建绑定服务：

```dart
ParkForm(
  model: {'name': '张三', 'age': 18},
  children: [
    ParkInput(label: '姓名', bindKey: 'name'),
    ParkInput(label: '年龄', bindKey: 'age'),
  ],
)
```

## ParkForm + bindingService 模式
动态表单与服务集成：

```dart
final service = ParkBindingService();
ParkForm(
  schema: mySchema,
  bindingService: service,
  onSubmit: (values) => print(values),
)
```
表单字段值变化时自动同步到 `service`。

## 独立组件 bindKey
在任何输入组件上使用 bindKey：

```dart
ParkInput(
  label: '用户名',
  bindKey: 'user.name',
  bindingService: service,
  hintText: '请输入用户名',
)
```

## 嵌套路径
点号路径解析规则：
- `'user.name'` → `_model['user']['name']`
- `'address.province.city'` → `_model['address']['province']['city']`
- 不存在的路径返回 `null`，设置时自动创建中间节点

## API 参考

### ParkBindable<T>
- `path`: 绑定的路径
- `value`: 当前值（getter/setter，设置时触发通知）
- `update(T newValue)`: 类型安全的值更新
- `addListener/removeListener`: 监听值变化

### ParkBindingService
- `bind<T>(path, {defaultValue})`: 绑定路径，返回单例 ParkBindable
- `setValue<T>(path, value)`: 快捷设置值
- `getValue<T>(path)`: 快捷获取值
- `updateModel(newModel)`: 批量更新模型，差异通知
- `watchEffect(fn)`: 注册副作用，自动收集依赖路径，依赖变化自动重执行（类 Vue3 watchEffect）
- `batch(fn)` / `beginBatch()` + `endBatch()`: 批量更新，作用域内多次 setValue 合并为单次通知
- `nextTick()`: 等待所有待处理批量更新完成（类 Vue3 nextTick）
- `disposeBindable(path)` / `dispose()`: 释放指定路径或所有绑定与资源

### ParkBindingPath
- `split(path)`: 字符串路径 → 键列表
- `resolve(path, data)`: 解析值
- `set(path, data, value)`: 不可变模式设值
- `hasPath(path, data)`: 路径存在性判断

## 原理说明
引擎基于 Flutter SDK 内置的 ValueNotifier + ValueListenableBuilder 实现：

1. **ParkBindable<T> extends ValueNotifier<T>** — 每个字段独立的响应式容器
2. **ParkBindingService** — 管理实例池，维护模型镜像，同一路径单例复用
3. **ParkBindingPath** — 纯函数工具，不可变模式操作嵌套 Map
4. **ValueListenableBuilder** — Flutter 官方 Widget，自动订阅/解绑
5. **零侵入设计** — 不设 bindKey/bindingService 时不启用，不引入任何外部包
''',
  demos: <ParkDemoScenario>[
    // -----------------------------------------------------------------------
    // Demo 1: 基础字段绑定
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: '基础字段绑定',
      description:
          '一个文本输入框，输入内容实时在下方 Text 显示，演示 ParkInput + bindKey 基础用法。',
      code: '''
final service = ParkBindingService({'name': '张三'});

ParkInput(
  label: '姓名',
  bindKey: 'name',
  bindingService: service,
  hintText: '输入后下方实时显示',
)''',
      builder: (BuildContext context) => _BasicBindingDemo(),
    ),

    // -----------------------------------------------------------------------
    // Demo 2: 嵌套路径绑定
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: '嵌套路径绑定',
      description:
          'address.province / address.city / address.district 三级联动，'
          '演示嵌套路径解析。',
      code: '''
final service = ParkBindingService({
  'address': {'province': '广东', 'city': '深圳', 'district': '南山区'},
});

ParkInput(label: '省份', bindKey: 'address.province', bindingService: service)
ParkInput(label: '城市', bindKey: 'address.city', bindingService: service)
ParkInput(label: '区县', bindKey: 'address.district', bindingService: service)''',
      builder: (BuildContext context) => _NestedPathBindingDemo(),
    ),

    // -----------------------------------------------------------------------
    // Demo 3: 多字段表单
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: '多字段表单',
      description:
          'ParkForm 传入 bindingService，5 个字段（姓名/年龄/城市/介绍/通知）全部绑定，'
          '提交时打印数据。',
      code: '''
final service = ParkBindingService({
  'name': '张三', 'age': '28', 'city': '北京',
  'bio': 'Flutter 开发者', 'notify': true,
});

ParkForm(
  bindingService: service,
  onSubmit: (values) => print(values),
  children: [
    ParkInput(label: '姓名', bindKey: 'name'),
    ParkInput(label: '年龄', bindKey: 'age'),
    ParkSelect(
      label: '城市',
      bindKey: 'city',
      items: const <ParkSelectOption>[
        ParkSelectOption(label: '北京', value: '北京'),
        ParkSelectOption(label: '上海', value: '上海'),
        ParkSelectOption(label: '广州', value: '广州'),
        ParkSelectOption(label: '深圳', value: '深圳'),
      ],
    ),
    ParkTextarea(label: '介绍', bindKey: 'bio'),
    ParkSwitch(label: '接收通知', bindKey: 'notify'),
  ],
)''',
      builder: (BuildContext context) => _MultiFieldFormDemo(),
    ),

    // -----------------------------------------------------------------------
    // Demo 4: 动态表单绑定
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: '动态表单绑定',
      description:
          'ParkForm + bindingService，schema 驱动渲染，'
          '值变化自动同步到 service。',
      code: '''
final service = ParkBindingService();
ParkForm(
  schema: mySchema,
  bindingService: service,
  onSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => _DynamicFormBindingDemo(),
    ),

    // -----------------------------------------------------------------------
    // Demo 5: 绑定值响应式
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: '绑定值响应式',
      description:
          'service.bind 返回 ParkBindable，通过 value 修改后由 ValueListenableBuilder 自动刷新。',
      code: '''
final service = ParkBindingService({'count': 0});
final bindable = service.bind<int>('count', defaultValue: 0);

// 修改 value，监听者自动刷新
bindable.value = bindable.value + 1;''',
      builder: (BuildContext context) => _BindableValueDemo(),
    ),

    // -----------------------------------------------------------------------
    // Demo 6: watchEffect 自动依赖追踪
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: 'watchEffect 自动追踪',
      description:
          'watchEffect 注册副作用，自动收集依赖路径，任意依赖变化自动重执行。',
      code: '''
final service = ParkBindingService({'name': '张三', 'age': 18});
service.watchEffect(() {
  final name = service.getValue<String>('name');
  final age = service.getValue<int>('age');
  print('name=\$name, age=\$age'); // 任意依赖变化自动重执行
});''',
      builder: (BuildContext context) => _WatchEffectBindingDemo(),
    ),

    // -----------------------------------------------------------------------
    // Demo 7: batch 批量更新
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: 'batch 批量更新',
      description:
          'batch 作用域内多次 setValue 合并为单次通知；逐条 setValue 则各自通知。',
      code: '''
service.batch(() {
  service.setValue('name', '李四');
  service.setValue('city', '上海');
  service.setValue('hobby', '音乐');
}); // 合并为单次通知''',
      builder: (BuildContext context) => _BatchBindingDemo(),
    ),

    // -----------------------------------------------------------------------
    // Demo 8: nextTick 获取最新值
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: 'nextTick 获取最新值',
      description:
          'batch 更新后 await nextTick() 确保拿到最新值（类似 Vue3 nextTick）。',
      code: '''
service.batch(() {
  service.setValue('name', '李四');
});
await service.nextTick(); // 等待批量更新完成
print(service.getValue('name')); // '李四''',
      builder: (BuildContext context) => _NextTickBindingDemo(),
    ),
  ],
);

// ============================================================================
// Demo 1: 基础字段绑定
// ============================================================================

class _BasicBindingDemo extends StatefulWidget {
  @override
  State<_BasicBindingDemo> createState() => _BasicBindingDemoState();
}

class _BasicBindingDemoState extends State<_BasicBindingDemo> {
  late final ParkBindingService _service;
  late final ParkBindable<String> _bindable;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'name': '张三'});
    _bindable = _service.bind<String>('name', defaultValue: '');
    _bindable.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bindable.removeListener(_onChanged);
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkInput(
            label: '姓名',
            bindKey: 'name',
            bindingService: _service,
            hintText: '输入后下方实时显示',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.sync, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '实时值: ${_bindable.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Demo 2: 嵌套路径绑定
// ============================================================================

class _NestedPathBindingDemo extends StatefulWidget {
  @override
  State<_NestedPathBindingDemo> createState() => _NestedPathBindingDemoState();
}

class _NestedPathBindingDemoState extends State<_NestedPathBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'address': <String, dynamic>{
        'province': '广东',
        'city': '深圳',
        'district': '南山区',
      },
    });
    // 订阅嵌套路径变化，让下方 model 展示实时刷新
    _service.watchEffect(() {
      _service.getValue<String>('address.province');
      _service.getValue<String>('address.city');
      _service.getValue<String>('address.district');
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkInput(
            label: '省份',
            bindKey: 'address.province',
            bindingService: _service,
          ),
          const SizedBox(height: 12),
          ParkInput(
            label: '城市',
            bindKey: 'address.city',
            bindingService: _service,
          ),
          const SizedBox(height: 12),
          ParkInput(
            label: '区县',
            bindKey: 'address.district',
            bindingService: _service,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '当前模型数据:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _service.model.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Demo 3: 多字段表单
// ============================================================================

class _MultiFieldFormDemo extends StatefulWidget {
  @override
  State<_MultiFieldFormDemo> createState() => _MultiFieldFormDemoState();
}

class _MultiFieldFormDemoState extends State<_MultiFieldFormDemo> {
  late final ParkBindingService _service;
  String _lastSubmitted = '';

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'name': '张三',
      'age': '28',
      'city': '北京',
      'bio': 'Flutter 开发者',
      'notify': true,
    });
    // 订阅所有表单字段，实时刷新下方提交结果展示
    _service.watchEffect(() {
      _service.getValue<String>('name');
      _service.getValue<String>('age');
      _service.getValue<String>('city');
      _service.getValue<String>('bio');
      _service.getValue<bool>('notify');
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkForm(
            bindingService: _service,
            onSubmit: (Map<String, dynamic> values) {
              setState(() {
                _lastSubmitted = values.toString();
              });
            },
            submitLabel: '提交表单',
            showReset: true,
            resetLabel: '重置',
            children: <Widget>[
              ParkInput(
                label: '姓名',
                bindKey: 'name',
                hintText: '请输入姓名',
              ),
              const SizedBox(height: 12),
              ParkInput(
                label: '年龄',
                bindKey: 'age',
                hintText: '请输入年龄',
              ),
              const SizedBox(height: 12),
              ParkSelect(
                label: '城市',
                bindKey: 'city',
                items: const <ParkSelectOption>[
                  ParkSelectOption(label: '北京', value: '北京'),
                  ParkSelectOption(label: '上海', value: '上海'),
                  ParkSelectOption(label: '广州', value: '广州'),
                  ParkSelectOption(label: '深圳', value: '深圳'),
                ],
              ),
              const SizedBox(height: 12),
              ParkTextarea(
                label: '介绍',
                bindKey: 'bio',
                hintText: '请输入个人介绍',
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              ParkSwitch(
                label: '接收通知',
                bindKey: 'notify',
                value: true,
              ),
            ],
          ),
          if (_lastSubmitted.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '提交: $_lastSubmitted',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// Demo 4: 动态表单绑定
// ============================================================================

final ParkFormSchema _bindingFormSchema = ParkFormSchema(
  formKey: 'demo_binding',
  fields: <ParkFormFieldSchema>[
    ParkFormFieldSchema(
      fieldId: 'bf_name',
      fieldType: ParkFieldType.text,
      labelName: '姓名',
      fieldName: 'name',
      isRequired: true,
      fieldPrompt: '请输入姓名',
      fieldLength: 20,
    ),
    ParkFormFieldSchema(
      fieldId: 'bf_city',
      fieldType: ParkFieldType.select,
      labelName: '城市',
      fieldName: 'city',
      fieldPrompt: '请选择城市',
      options: <Map<String, dynamic>>[
        <String, dynamic>{'label': '北京', 'value': 'bj'},
        <String, dynamic>{'label': '上海', 'value': 'sh'},
        <String, dynamic>{'label': '广州', 'value': 'gz'},
        <String, dynamic>{'label': '深圳', 'value': 'sz'},
      ],
    ),
    ParkFormFieldSchema(
      fieldId: 'bf_member',
      fieldType: ParkFieldType.toggle,
      labelName: '是否会员',
      fieldName: 'member',
      defaultValue: false,
    ),
  ],
);

class _DynamicFormBindingDemo extends StatefulWidget {
  @override
  State<_DynamicFormBindingDemo> createState() =>
      _DynamicFormBindingDemoState();
}

class _DynamicFormBindingDemoState extends State<_DynamicFormBindingDemo> {
  late final ParkBindingService _service;
  String _lastSyncValue = '';

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService();
    // 订阅动态表单字段，让 service.model 展示实时刷新
    _service.watchEffect(() {
      _service.getValue<String>('name');
      _service.getValue<String>('city');
      _service.getValue<bool>('member');
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkForm(
            schema: _bindingFormSchema,
            bindingService: _service,
            onSubmit: (Map<String, dynamic> values) {
              setState(() {
                _lastSyncValue = values.toString();
              });
            },
            submitLabel: '提交',
            showReset: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'BindingService 同步状态:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _service.model.isEmpty ? '（尚未输入）' : _service.model.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          if (_lastSyncValue.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '提交: $_lastSyncValue',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// Demo 5: 绑定值响应式
// ============================================================================

class _BindableValueDemo extends StatefulWidget {
  @override
  State<_BindableValueDemo> createState() => _BindableValueDemoState();
}

class _BindableValueDemoState extends State<_BindableValueDemo> {
  late final ParkBindingService _service;
  late final ParkBindable<int> _bindable;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'count': 0});
    _bindable = _service.bind<int>('count', defaultValue: 0);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ValueListenableBuilder<int>(
            valueListenable: _bindable,
            builder: (BuildContext ctx, int value, Widget? child) {
              return ParkText('当前计数: $value', preset: ParkTextPreset.body);
            },
          ),
          const SizedBox(height: 12),
          ParkButton(
            onPressed: () {
              _bindable.value = _bindable.value + 1;
            },
            child: const ParkText('+1'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Demo 6: watchEffect 自动依赖追踪
// ============================================================================

class _WatchEffectBindingDemo extends StatefulWidget {
  @override
  State<_WatchEffectBindingDemo> createState() =>
      _WatchEffectBindingDemoState();
}

class _WatchEffectBindingDemoState extends State<_WatchEffectBindingDemo> {
  late final ParkBindingService _service;
  String _log = '';

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'name': '张三',
      'age': 18,
    });
    _service.watchEffect(() {
      final String name = _service.getValue<String>('name') ?? '';
      final int age = _service.getValue<int>('age') ?? 0;
      if (mounted) {
        setState(() {
          _log = 'name=$name, age=$age';
        });
      }
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kColors.brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _kColors.brand.withValues(alpha: 0.2),
              ),
            ),
            child: ParkText('watchEffect: $_log',
                preset: ParkTextPreset.bodySmall),
          ),
          const SizedBox(height: 12),
          ParkButton(
            onPressed: () {
              _service.setValue<String>('name', '李四');
            },
            child: const ParkText('改名 李四'),
          ),
          const SizedBox(height: 8),
          ParkButton(
            onPressed: () {
              _service.setValue<int>('age', 20);
            },
            child: const ParkText('改年龄 20'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Demo 7: batch 批量更新
// ============================================================================

class _BatchBindingDemo extends StatefulWidget {
  @override
  State<_BatchBindingDemo> createState() => _BatchBindingDemoState();
}

class _BatchBindingDemoState extends State<_BatchBindingDemo> {
  late final ParkBindingService _service;
  int _notifyCount = 0;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'name': '张三',
      'city': '北京',
      'hobby': '阅读',
    });
    _service.watchEffect(() {
      _service.getValue<String>('name');
      _service.getValue<String>('city');
      _service.getValue<String>('hobby');
      if (mounted) {
        setState(() {
          _notifyCount++;
        });
      }
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkText('副作用执行次数: $_notifyCount',
              preset: ParkTextPreset.body),
          const SizedBox(height: 12),
          ParkButton(
            block: true,
            onPressed: () {
              _service.batch(() {
                _service.setValue<String>('name', '李四');
                _service.setValue<String>('city', '上海');
                _service.setValue<String>('hobby', '音乐');
              });
            },
            child: const ParkText('batch 更新（1 次通知）'),
          ),
          const SizedBox(height: 8),
          ParkButton(
            block: true,
            onPressed: () {
              _service.setValue<String>('name', '王五');
              _service.setValue<String>('city', '广州');
              _service.setValue<String>('hobby', '运动');
            },
            child: const ParkText('逐条更新（3 次通知）'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Demo 8: nextTick 获取最新值
// ============================================================================

class _NextTickBindingDemo extends StatefulWidget {
  @override
  State<_NextTickBindingDemo> createState() => _NextTickBindingDemoState();
}

class _NextTickBindingDemoState extends State<_NextTickBindingDemo> {
  late final ParkBindingService _service;
  String _status = '等待点击';

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'name': '张三'});
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    _service.batch(() {
      _service.setValue<String>('name', '李四');
    });
    await _service.nextTick();
    if (mounted) {
      setState(() {
        _status =
            'nextTick 后读取值: ${_service.getValue<String>('name')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkText(_status, preset: ParkTextPreset.body),
          const SizedBox(height: 12),
          ParkButton(
            onPressed: _run,
            child: const ParkText('batch 后 nextTick'),
          ),
        ],
      ),
    );
  }
}
