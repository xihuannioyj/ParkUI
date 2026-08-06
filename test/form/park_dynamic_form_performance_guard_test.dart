import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget buildDynamicFormTestApp(Widget child) {
  final ParkThemeData theme = ParkThemeData.light();
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[theme]),
    home: Scaffold(body: child),
  );
}

ParkFormSchema buildStaticDataSourceSchema() {
  return const ParkFormSchema(
    formKey: 'perf_static_schema',
    fields: <ParkFormFieldSchema>[
      ParkFormFieldSchema(
        fieldId: 'f_type',
        fieldName: 'type',
        labelName: '类型',
        fieldType: ParkFieldType.select,
        dataSourceType: ParkDataSourceType.enumSource,
        dataSourceKey: 'type_enum',
        fieldPrompt: '请选择类型',
      ),
      ParkFormFieldSchema(
        fieldId: 'f_status',
        fieldName: 'status',
        labelName: '状态',
        fieldType: ParkFieldType.select,
        dataSourceType: ParkDataSourceType.dict,
        dataSourceKey: 'status_dict',
        fieldPrompt: '请选择状态',
      ),
    ],
  );
}

void main() {
  testWidgets('静态数据源字段可稳定渲染且无异常', (WidgetTester tester) async {
    final ParkFormSchema schema = buildStaticDataSourceSchema();

    await tester.pumpWidget(
      buildDynamicFormTestApp(
        ParkDynamicForm(
          schema: schema,
          onSubmit: (_) {},
          configureEngine: (ParkFormEngine engine) {
            engine.dataSourceResolver.registerEnum(
              'type_enum',
              <Map<String, dynamic>>[
                <String, dynamic>{'label': '长租', 'value': 'long'},
                <String, dynamic>{'label': '商业', 'value': 'business'},
              ],
            );
            engine.dataSourceResolver.registerDict(
              'status_dict',
              <Map<String, dynamic>>[
                <String, dynamic>{'label': '启用', 'value': 'enabled'},
                <String, dynamic>{'label': '停用', 'value': 'disabled'},
              ],
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('类型'), findsOneWidget);
    expect(find.text('状态'), findsOneWidget);
    expect(find.byType(ParkSelect), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('静态数据源加载后不依赖整页 setState 也能正常显示字段与选项壳', (
    WidgetTester tester,
  ) async {
    final ParkFormSchema schema = buildStaticDataSourceSchema();

    await tester.pumpWidget(
      buildDynamicFormTestApp(
        ParkDynamicForm(
          schema: schema,
          onSubmit: (_) {},
          configureEngine: (ParkFormEngine engine) {
            engine.dataSourceResolver.registerEnum(
              'type_enum',
              <Map<String, dynamic>>[
                <String, dynamic>{'label': '长租', 'value': 'long'},
                <String, dynamic>{'label': '商业', 'value': 'business'},
              ],
            );
            engine.dataSourceResolver.registerDict(
              'status_dict',
              <Map<String, dynamic>>[
                <String, dynamic>{'label': '启用', 'value': 'enabled'},
                <String, dynamic>{'label': '停用', 'value': 'disabled'},
              ],
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('请选择类型'), findsOneWidget);
    expect(find.text('请选择状态'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('依赖映射缓存不改变显隐与动态选项联动行为', (WidgetTester tester) async {
    int fetchCount = 0;
    const ParkFormSchema schema = ParkFormSchema(
      formKey: 'dependency_cache_guard',
      fields: <ParkFormFieldSchema>[
        ParkFormFieldSchema(
          fieldId: 'f_keyword',
          fieldName: 'keyword',
          labelName: '关键字',
          fieldType: ParkFieldType.text,
          fieldPrompt: '请输入关键字',
        ),
        ParkFormFieldSchema(
          fieldId: 'f_extra',
          fieldName: 'extra',
          labelName: '附加说明',
          fieldType: ParkFieldType.text,
          fieldPrompt: '请输入附加说明',
          ext: <String, dynamic>{'visible_when_expr': 'keyword == "hz"'},
          dependencies: <String>['keyword'],
        ),
        ParkFormFieldSchema(
          fieldId: 'f_city',
          fieldName: 'city',
          labelName: '城市',
          fieldType: ParkFieldType.select,
          fieldPrompt: '请选择城市',
          dataSourceType: ParkDataSourceType.api,
          dataSourceKey: 'city_fetcher',
          dataSourceParams: <String, dynamic>{'keyword': r'$form.keyword'},
        ),
      ],
    );

    await tester.pumpWidget(
      buildDynamicFormTestApp(
        ParkDynamicForm(
          schema: schema,
          onSubmit: (_) {},
          configureEngine: (ParkFormEngine engine) {
            engine.dataSourceResolver.registerFetcher(
              'city_fetcher',
              (ParkFormFieldSchema field, Map<String, dynamic> params) async {
                fetchCount++;
                final String keyword = params['keyword'] as String? ?? '';
                if (keyword == 'hz') {
                  return <Map<String, dynamic>>[
                    <String, dynamic>{'label': '杭州', 'value': 'hangzhou'},
                  ];
                }
                return <Map<String, dynamic>>[
                  <String, dynamic>{'label': '上海', 'value': 'shanghai'},
                ];
              },
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(fetchCount, 1);
    expect(find.text('附加说明'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'hz');
    await tester.pump();
    await tester.pumpAndSettle();

    expect(fetchCount, 2);
    expect(find.text('附加说明'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'sh');
    await tester.pump();
    await tester.pumpAndSettle();

    expect(fetchCount, 3);
    expect(find.text('附加说明'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
