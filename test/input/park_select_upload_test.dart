import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  group('ParkSelect', () {
    testWidgets('应显示 loading 文案与加载指示器', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
          ),
          home: Scaffold(
            body: ParkSelect(
              items: const <ParkSelectOption>[
                ParkSelectOption(label: '北京', value: 'beijing'),
              ],
              loading: true,
              loadingText: '选项加载中…',
            ),
          ),
        ),
      );

      expect(find.text('选项加载中…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('搜索模式下应能展示空态', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
          ),
          home: Scaffold(
            body: ParkSelect(
              items: const <ParkSelectOption>[
                ParkSelectOption(label: '北京', value: 'beijing'),
              ],
              searchable: true,
              emptyText: '没有匹配项',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ParkSelect));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'shanghai');
      await tester.pumpAndSettle();

      expect(find.text('没有匹配项'), findsOneWidget);
    });
  });

  group('ParkUpload', () {
    test('应校验 imageOnly 约束', () {
      const ParkUpload upload = ParkUpload(
        files: <ParkUploadFile>[],
        imageOnly: true,
      );

      const ParkUploadFile file = ParkUploadFile(path: 'demo.pdf');
      expect(upload.validateFile(file), '仅支持上传图片文件');
    });

    test('应校验 accept 类型约束', () {
      const ParkUpload upload = ParkUpload(
        files: <ParkUploadFile>[],
        accept: <String>['jpg', 'png'],
      );

      const ParkUploadFile file = ParkUploadFile(path: 'demo.pdf');
      expect(upload.validateFile(file), '文件类型不支持');
    });

    test('应校验 maxSizeMB 约束', () {
      const ParkUpload upload = ParkUpload(
        files: <ParkUploadFile>[],
        maxSizeMB: 1,
      );

      const ParkUploadFile file = ParkUploadFile(
        path: 'demo.jpg',
        sizeBytes: 2 * 1024 * 1024,
      );
      expect(upload.validateFile(file), '文件大小不能超过 1MB');
    });
  });
}
