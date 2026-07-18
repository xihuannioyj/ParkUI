import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_tree.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 300, height: 400, child: child),
        ),
      ),
    );

void main() {
  group('ParkTree - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTree(
          data: const [
            ParkTreeNode(key: '1', label: 'Node 1'),
            ParkTreeNode(key: '2', label: 'Node 2'),
          ],
        ),
      ));
      expect(find.text('Node 1'), findsOneWidget);
      expect(find.text('Node 2'), findsOneWidget);
    });

    testWidgets('renders nested children when expanded', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTree(
          data: const [
            ParkTreeNode(key: '1', label: 'Parent', children: [
              ParkTreeNode(key: '1-1', label: 'Child A'),
              ParkTreeNode(key: '1-2', label: 'Child B'),
            ]),
          ],
          defaultExpandedKeys: {'1'},
        ),
      ));
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Child A'), findsOneWidget);
      expect(find.text('Child B'), findsOneWidget);
    });

    testWidgets('children hidden when not expanded', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTree(
          data: const [
            ParkTreeNode(key: '1', label: 'Parent', children: [
              ParkTreeNode(key: '1-1', label: 'Child'),
            ]),
          ],
        ),
      ));
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Child'), findsNothing);
    });
  });

  group('ParkTree - interaction', () {
    testWidgets('tapping expand icon reveals children', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTree(
          data: const [
            ParkTreeNode(key: '1', label: 'Parent', children: [
              ParkTreeNode(key: '1-1', label: 'Child'),
            ]),
          ],
        ),
      ));
      expect(find.text('Child'), findsNothing);

      // Tap the expand icon (arrow_right)
      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pump();
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('onSelect fires when tapping a node', (tester) async {
      String? selectedKey;
      await tester.pumpWidget(_wrap(
        ParkTree(
          data: const [
            ParkTreeNode(key: '1', label: 'Node 1'),
            ParkTreeNode(key: '2', label: 'Node 2'),
          ],
          onSelect: (key) => selectedKey = key,
        ),
      ));
      await tester.tap(find.text('Node 2'));
      await tester.pump();
      expect(selectedKey, '2');
    });

    testWidgets('node with icon renders icon', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTree(
          data: const [
            ParkTreeNode(key: '1', label: 'File', icon: Icons.insert_drive_file),
          ],
        ),
      ));
      expect(find.byIcon(Icons.insert_drive_file), findsOneWidget);
    });
  });

  group('ParkTreeNode - model', () {
    test('hasChildren returns true for parent nodes', () {
      const node = ParkTreeNode(key: '1', label: 'Parent', children: [
        ParkTreeNode(key: '1-1', label: 'Child'),
      ]);
      expect(node.hasChildren, true);
      expect(node.isLeaf, false);
    });

    test('isLeaf returns true for nodes without children', () {
      const node = ParkTreeNode(key: '1', label: 'Leaf');
      expect(node.hasChildren, false);
      expect(node.isLeaf, true);
    });

    test('defaultExpanded flag works', () {
      const node = ParkTreeNode(key: '1', label: 'Node', defaultExpanded: true);
      expect(node.defaultExpanded, true);
    });

    test('disabled flag defaults to false', () {
      const node = ParkTreeNode(key: '1', label: 'Node');
      expect(node.disabled, false);
    });
  });
}
