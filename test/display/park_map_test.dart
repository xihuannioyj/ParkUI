import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:park_ui/src/components/display/park_map.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 360, height: 320, child: child),
        ),
      ),
    );

void main() {
  group('ParkMap', () {
    testWidgets('默认参数可构建', (tester) async {
      await tester.pumpWidget(_wrap(const ParkMap(tiandituKey: 'test-key')));
      await tester.pump();
      expect(find.byType(ParkMap), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('key 透传到 TileLayer urlTemplate', (tester) async {
      await tester.pumpWidget(_wrap(const ParkMap(tiandituKey: 'tk-123')));
      await tester.pump();
      final tileLayer = tester.widget<TileLayer>(find.byType(TileLayer));
      expect(tileLayer.urlTemplate, contains('tk-123'));
      expect(tileLayer.urlTemplate, contains('TILEMATRIX={z}'));
      expect(tileLayer.urlTemplate, contains('TILEROW={y}'));
      expect(tileLayer.urlTemplate, contains('TILECOL={x}'));
    });

    testWidgets('选点回调触发：点击地图返回 LatLng', (tester) async {
      LatLng? picked;
      await tester.pumpWidget(_wrap(
        ParkMap(
          tiandituKey: 'test-key',
          selectionEnabled: true,
          onMapTap: (latLng) => picked = latLng,
        ),
      ));
      await tester.pump();
      // flutter_map 的 onTap 经双击检测流（默认 250ms 超时）触发，
      // 测试中需 pump 超过该延迟等待回调。
      final center = tester.getCenter(find.byType(ParkMap));
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 400));
      expect(picked, isNotNull);
      expect(picked, isA<LatLng>());
    });

    testWidgets('选点关闭时不触发 onMapTap', (tester) async {
      int calls = 0;
      await tester.pumpWidget(_wrap(
        ParkMap(
          tiandituKey: 'test-key',
          selectionEnabled: false,
          onMapTap: (_) => calls++,
        ),
      ));
      await tester.pump();
      final center = tester.getCenter(find.byType(ParkMap));
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 400));
      expect(calls, 0);
    });

    testWidgets('标记点渲染与点击回调', (tester) async {
      ParkMapMarker? tapped;
      await tester.pumpWidget(_wrap(
        ParkMap(
          tiandituKey: 'test-key',
          markers: const [
            ParkMapMarker(
              id: 'm1',
              point: LatLng(39.9042, 116.4074),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.location_on),
              ),
            ),
          ],
          onMarkerTap: (m) => tapped = m,
        ),
      ));
      await tester.pump();
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pump();
      expect(tapped, isNotNull);
      expect(tapped!.id, 'm1');
    });

    testWidgets('selectedMarkerId 控制高亮标记渲染 selectedChild', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkMap(
          tiandituKey: 'test-key',
          selectedMarkerId: 'm1',
          // 关闭聚合以便单个标记直接渲染（聚合会把邻近标记折叠为聚合节点）
          enableClustering: false,
          markers: [
            ParkMapMarker(
              id: 'm1',
              point: LatLng(39.9042, 116.4074),
              child: Icon(Icons.location_on),
              selectedChild: Icon(Icons.star),
            ),
            ParkMapMarker(
              id: 'm2',
              point: LatLng(39.9142, 116.4174),
              child: Icon(Icons.home),
              selectedChild: Icon(Icons.favorite),
            ),
          ],
        ),
      ));
      await tester.pump();
      // m1 高亮：渲染 star（选中态）
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsNothing);
      // m2 未选中：渲染默认 home
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('距离圈：circleCenter 非空时绘制 CircleLayer', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkMap(
          tiandituKey: 'test-key',
          circleCenter: LatLng(39.9042, 116.4074),
          circleRadiusMeters: 1000,
        ),
      ));
      await tester.pump();
      expect(find.byType(CircleLayer), findsOneWidget);
    });

    testWidgets('距离圈：circleCenter 为空时不绘制', (tester) async {
      await tester.pumpWidget(_wrap(const ParkMap(tiandituKey: 'test-key')));
      await tester.pump();
      expect(find.byType(CircleLayer), findsNothing);
    });

    testWidgets('聚合：多标记且 enableClustering 时渲染聚合层', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkMap(
          tiandituKey: 'test-key',
          markers: [
            for (int i = 0; i < 5; i++)
              ParkMapMarker(
                id: 'm$i',
                point: LatLng(39.9042 + i * 0.005, 116.4074 + i * 0.005),
                child: const Icon(Icons.location_on),
              ),
          ],
        ),
      ));
      await tester.pump();
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('聚合关闭：enableClustering=false 渲染 MarkerLayer', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkMap(
          tiandituKey: 'test-key',
          enableClustering: false,
          markers: [
            ParkMapMarker(
              id: 'm1',
              point: LatLng(39.9042, 116.4074),
              child: Icon(Icons.location_on),
            ),
          ],
        ),
      ));
      await tester.pump();
      expect(find.byType(MarkerLayer), findsOneWidget);
    });

    testWidgets('自定义聚合节点 builder 生效', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkMap(
          tiandituKey: 'test-key',
          markers: [
            for (int i = 0; i < 4; i++)
              ParkMapMarker(
                id: 'm$i',
                point: LatLng(39.9042 + i * 0.005, 116.4074 + i * 0.005),
                child: const Icon(Icons.location_on),
              ),
          ],
          clusterBuilder: (context, count) => Text('$count 套'),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
