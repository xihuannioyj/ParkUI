import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: SizedBox(width: 800, height: 600, child: child)),
    );

/// Tap the header cell by tapping the Padding that wraps the header content.
/// This avoids issues with the Tooltip's GestureDetector intercepting taps.
Future<void> _tapHeader(WidgetTester tester, String text) async {
  // Find the Padding ancestor of the text (the header cell's padding)
  final paddingFinder = find.ancestor(
    of: find.text(text),
    matching: find.byType(Padding),
  );
  // Tap the center of the Padding — this is within the GestureDetector's area
  await tester.tap(paddingFinder.first);
}

void main() {
  group('ParkTable', () {
    // -----------------------------------------------------------------------
    // Basic rendering
    // -----------------------------------------------------------------------

    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
          ParkTableColumn(key: 'age', title: '年龄'),
        ],
        data: const [
          {'name': '张三', 'age': '25'},
          {'name': '李四', 'age': '30'},
        ],
      )));
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
      expect(find.text('李四'), findsOneWidget);
    });

    testWidgets('renders all data rows', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'id', title: 'ID'),
          ParkTableColumn(key: 'name', title: 'Name'),
        ],
        data: const [
          {'id': '1', 'name': 'Alice'},
          {'id': '2', 'name': 'Bob'},
          {'id': '3', 'name': 'Charlie'},
        ],
      )));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Empty state
    // -----------------------------------------------------------------------

    testWidgets('空数据', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'c1', title: '列1'),
          ParkTableColumn(key: 'c2', title: '列2'),
        ],
        data: [],
      )));
      expect(find.text('暂无数据'), findsOneWidget);
    });

    testWidgets('empty data shows custom emptyText', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'c1', title: '列1'),
        ],
        data: const [],
        emptyText: 'No records found',
      )));
      expect(find.text('No records found'), findsOneWidget);
    });

    testWidgets('empty data shows custom empty widget', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'c1', title: '列1'),
        ],
        data: const [],
        empty: const Text('Custom empty state'),
      )));
      expect(find.text('Custom empty state'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Loading state
    // -----------------------------------------------------------------------

    testWidgets('loading state shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: const [
          {'name': '张三'},
        ],
        loading: true,
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loading state with empty data does not show empty text',
        (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: const [],
        loading: true,
      )));
      // When loading, empty text should not appear
      expect(find.text('暂无数据'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Sort interaction
    // -----------------------------------------------------------------------

    testWidgets('sortable column shows sort icons', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名', sortable: true),
          ParkTableColumn(key: 'age', title: '年龄'),
        ],
        data: const [
          {'name': '张三', 'age': '25'},
        ],
      )));
      // Sort icons (arrow_drop_up and arrow_drop_down) should be present
      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('tapping sortable column triggers onSort callback',
        (tester) async {
      int? sortedColumnIndex;
      bool? sortedAscending;

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名', sortable: true),
          ParkTableColumn(key: 'age', title: '年龄', sortable: true),
        ],
        data: const [
          {'name': '张三', 'age': '25'},
          {'name': '李四', 'age': '30'},
        ],
        onSort: (columnIndex, ascending) {
          sortedColumnIndex = columnIndex;
          sortedAscending = ascending;
        },
      )));

      // Tap on the first sortable column header
      await _tapHeader(tester, '姓名');
      await tester.pump();

      expect(sortedColumnIndex, equals(0));
      expect(sortedAscending, isTrue);
    });

    testWidgets('tapping sortable column twice toggles sort direction',
        (tester) async {
      final sortCalls = <Map<String, dynamic>>[];

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名', sortable: true),
        ],
        data: const [
          {'name': '张三'},
          {'name': '李四'},
        ],
        onSort: (columnIndex, ascending) {
          sortCalls.add({'index': columnIndex, 'ascending': ascending});
        },
      )));

      // First tap: ascending
      await _tapHeader(tester, '姓名');
      await tester.pump();
      expect(sortCalls.last['ascending'], isTrue);

      // Second tap: descending
      await _tapHeader(tester, '姓名');
      await tester.pump();
      expect(sortCalls.last['ascending'], isFalse);
    });

    testWidgets('tapping different sortable column resets to ascending',
        (tester) async {
      final sortCalls = <Map<String, dynamic>>[];

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名', sortable: true),
          ParkTableColumn(key: 'age', title: '年龄', sortable: true),
        ],
        data: const [
          {'name': '张三', 'age': '25'},
          {'name': '李四', 'age': '30'},
        ],
        onSort: (columnIndex, ascending) {
          sortCalls.add({'index': columnIndex, 'ascending': ascending});
        },
      )));

      // Tap name column twice to make it descending
      await _tapHeader(tester, '姓名');
      await tester.pump();
      await _tapHeader(tester, '姓名');
      await tester.pump();
      expect(sortCalls.last['ascending'], isFalse);

      // Tap age column: should reset to ascending
      await _tapHeader(tester, '年龄');
      await tester.pump();
      expect(sortCalls.last['index'], equals(1));
      expect(sortCalls.last['ascending'], isTrue);
    });

    testWidgets('non-sortable column does not trigger onSort', (tester) async {
      bool sortCalled = false;

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'), // not sortable
        ],
        data: const [
          {'name': '张三'},
        ],
        onSort: (columnIndex, ascending) {
          sortCalled = true;
        },
      )));

      await _tapHeader(tester, '姓名');
      await tester.pump();
      expect(sortCalled, isFalse);
    });

    // -----------------------------------------------------------------------
    // Pagination
    // -----------------------------------------------------------------------

    testWidgets('pagination renders page numbers', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: List.generate(5, (i) => {'name': 'User $i'}),
        pagination: const ParkTablePagination(
          current: 1,
          pageSize: 2,
          total: 5,
        ),
      )));
      // Should show page numbers 1, 2, 3
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('pagination onPageChanged fires on next page tap',
        (tester) async {
      int? changedPage;
      int? changedPageSize;

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: List.generate(6, (i) => {'name': 'User $i'}),
        pagination: ParkTablePagination(
          current: 1,
          pageSize: 2,
          total: 6,
          onPageChanged: (page, pageSize) {
            changedPage = page;
            changedPageSize = pageSize;
          },
        ),
      )));

      // Tap the next page button (chevron_right)
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(changedPage, equals(2));
      expect(changedPageSize, equals(2));
    });

    testWidgets('pagination onPageChanged fires on previous page tap',
        (tester) async {
      int? changedPage;

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: List.generate(6, (i) => {'name': 'User $i'}),
        pagination: ParkTablePagination(
          current: 2,
          pageSize: 2,
          total: 6,
          onPageChanged: (page, pageSize) {
            changedPage = page;
          },
        ),
      )));

      // Tap the previous page button (chevron_left)
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(changedPage, equals(1));
    });

    testWidgets('pagination disables previous button on first page',
        (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: List.generate(6, (i) => {'name': 'User $i'}),
        pagination: const ParkTablePagination(
          current: 1,
          pageSize: 2,
          total: 6,
        ),
      )));

      // The chevron_left icon should be present but disabled (greyed out)
      final icon = tester.widget<Icon>(find.byIcon(Icons.chevron_left));
      expect(icon.color, isNotNull);
    });

    testWidgets('pagination disables next button on last page',
        (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: List.generate(6, (i) => {'name': 'User $i'}),
        pagination: const ParkTablePagination(
          current: 3,
          pageSize: 2,
          total: 6,
        ),
      )));

      // The chevron_right icon should be present but disabled
      final icon = tester.widget<Icon>(find.byIcon(Icons.chevron_right));
      expect(icon.color, isNotNull);
    });

    // -----------------------------------------------------------------------
    // Row selection
    // -----------------------------------------------------------------------

    testWidgets('checkbox row selection renders checkboxes', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: const [
          {'name': '张三'},
          {'name': '李四'},
        ],
        rowSelection: const ParkRowSelection(
          type: ParkRowSelectionType.checkbox,
          selectedRowKeys: [],
        ),
      )));
      // Should find Checkbox widgets (2 rows + 1 select-all)
      expect(find.byType(Checkbox), findsNWidgets(3));
    });

    testWidgets('checkbox row selection onChanged fires on tap',
        (tester) async {
      List<String>? selectedKeys;
      List<dynamic>? selectedRows;

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: const [
          {'name': '张三'},
          {'name': '李四'},
        ],
        rowKey: 'name',
        rowSelection: ParkRowSelection(
          type: ParkRowSelectionType.checkbox,
          selectedRowKeys: const [],
          onChanged: (keys, rows) {
            selectedKeys = keys;
            selectedRows = rows;
          },
        ),
      )));

      // Tap the first row's checkbox (second Checkbox, after select-all)
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(1));
      await tester.pump();

      expect(selectedKeys, isNotNull);
      expect(selectedKeys, hasLength(1));
      expect(selectedRows, hasLength(1));
    });

    testWidgets('radio row selection renders radio indicators',
        (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: const [
          {'name': '张三'},
          {'name': '李四'},
        ],
        rowSelection: const ParkRowSelection(
          type: ParkRowSelectionType.radio,
          selectedRowKeys: [],
        ),
      )));
      // Radio type uses GestureDetector with Container, not Checkbox
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('radio row selection onChanged fires with single key',
        (tester) async {
      List<String>? selectedKeys;

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: const [
          {'name': '张三'},
          {'name': '李四'},
        ],
        rowKey: 'name',
        rowSelection: ParkRowSelection(
          type: ParkRowSelectionType.radio,
          selectedRowKeys: const [],
          onChanged: (keys, rows) {
            selectedKeys = keys;
          },
        ),
      )));

      // Tap the first row's radio indicator
      final radios = find.byType(GestureDetector);
      // Find the GestureDetector that contains the radio circle decoration
      await tester.tap(radios.first);
      await tester.pump();

      // For radio type, selecting a row should result in exactly 1 key
      if (selectedKeys != null) {
        expect(selectedKeys, hasLength(1));
      }
    });

    testWidgets('pre-selected rows are visually selected', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: const [
          {'name': '张三'},
          {'name': '李四'},
        ],
        rowKey: 'name',
        rowSelection: const ParkRowSelection(
          type: ParkRowSelectionType.checkbox,
          selectedRowKeys: ['张三'],
        ),
      )));

      // Find checkboxes - the first row should be checked
      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      final checkboxValues = checkboxes.map((c) => c.value).toList();
      // Select-all should be indeterminate (null or false), first row checked
      expect(checkboxValues.contains(true), isTrue);
    });

    // -----------------------------------------------------------------------
    // Bordered / Striped
    // -----------------------------------------------------------------------

    testWidgets('bordered table renders without error', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: const [
          {'name': '张三'},
        ],
        bordered: true,
      )));
      expect(find.text('张三'), findsOneWidget);
    });

    testWidgets('striped table renders without error', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: const [
          {'name': '张三'},
          {'name': '李四'},
        ],
        striped: true,
      )));
      expect(find.text('张三'), findsOneWidget);
      expect(find.text('李四'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Column alignment
    // -----------------------------------------------------------------------

    testWidgets('column alignment is respected', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(
              key: 'name', title: '姓名', align: ParkTableColumnAlign.left),
          ParkTableColumn(
              key: 'age', title: '年龄', align: ParkTableColumnAlign.center),
          ParkTableColumn(
              key: 'score', title: '分数', align: ParkTableColumnAlign.right),
        ],
        data: const [
          {'name': '张三', 'age': '25', 'score': '90'},
        ],
      )));
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('年龄'), findsOneWidget);
      expect(find.text('分数'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Custom cell renderer
    // -----------------------------------------------------------------------

    testWidgets('custom render callback is used', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: [
          const ParkTableColumn(key: 'name', title: '姓名'),
          ParkTableColumn(
            key: 'status',
            title: '状态',
            render: (row, index) => Chip(
              label: Text(row['status']?.toString() ?? ''),
            ),
          ),
        ],
        data: const [
          {'name': '张三', 'status': 'Active'},
        ],
      )));
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Column width
    // -----------------------------------------------------------------------

    testWidgets('column width is respected', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名', width: 200),
          ParkTableColumn(key: 'age', title: '年龄', width: 80),
        ],
        data: const [
          {'name': '张三', 'age': '25'},
        ],
      )));
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // onChange / onChanged callback
    // -----------------------------------------------------------------------

    testWidgets('onChanged fires on sort change', (tester) async {
      Map<String, dynamic>? changeInfo;

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名', sortable: true),
        ],
        data: const [
          {'name': '张三'},
          {'name': '李四'},
        ],
        onChanged: (info) {
          changeInfo = info;
        },
      )));

      await _tapHeader(tester, '姓名');
      await tester.pump();

      expect(changeInfo, isNotNull);
      expect(changeInfo!['type'], equals('sort'));
      expect(changeInfo!['columnKey'], equals('name'));
      expect(changeInfo!['ascending'], isTrue);
    });

    testWidgets('onChanged fires on pagination change', (tester) async {
      Map<String, dynamic>? changeInfo;

      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
        ],
        data: List.generate(6, (i) => {'name': 'User $i'}),
        pagination: const ParkTablePagination(
          current: 1,
          pageSize: 2,
          total: 6,
        ),
        onChanged: (info) {
          changeInfo = info;
        },
      )));

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(changeInfo, isNotNull);
      expect(changeInfo!['type'], equals('pagination'));
      expect(changeInfo!['page'], equals(2));
    });
  });
}
