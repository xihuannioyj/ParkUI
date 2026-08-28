import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Map Demo — ParkMap 地图组件
//
// 天地图 key 通过 --dart-define=TIANDITU_KEY=xxx 注入（组件库不硬编码业务凭据）。
// 未配置 key 时底图瓦片无法加载，但标记/聚合/选点/距离圈等交互仍可演示。
// =============================================================================

/// 构建时通过 --dart-define=TIANDITU_KEY 注入天地图 key
const String _kTiandituKey = String.fromEnvironment('TIANDITU_KEY');

/// 演示用的房源标记数据（北京国贸附近）
const List<(String, double, double)> _kHousePoints = [
  ('朝阳区·国贸 1 居', 39.9087, 116.4615),
  ('朝阳区·双井 2 居', 39.8939, 116.4612),
  ('朝阳区·呼家楼 1 居', 39.9219, 116.4623),
  ('朝阳区·大望路 2 居', 39.9070, 116.4796),
  ('朝阳区·劲松 3 居', 39.8871, 116.4513),
  ('东城区·东直门 1 居', 39.9410, 116.4346),
  ('东城区·王府井 2 居', 39.9073, 116.4118),
  ('西城区·西单 1 居', 39.9078, 116.3744),
  ('西城区·金融街 3 居', 39.9130, 116.3593),
  ('海淀区·中关村 2 居', 39.9841, 116.3153),
  ('海淀区·五道口 1 居', 39.9927, 116.3379),
  ('丰台区·丽泽 2 居', 39.8627, 116.3346),
];

class MapDemo extends StatefulWidget {
  const MapDemo({super.key});

  @override
  State<MapDemo> createState() => _MapDemoState();
}

class _MapDemoState extends State<MapDemo> {
  bool _selectionEnabled = false;
  bool _showCircle = false;
  double _circleRadiusMeters = 1000;
  String? _selectedId;
  String? _pickedInfo;

  Widget _pin({required bool selected}) {
    final park = ParkThemeData.light();
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: selected ? park.colors.brand : park.colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? park.colors.brand : park.colors.brandLight,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.home,
        size: 16,
        color: selected ? park.colors.textOnBrand : park.colors.brand,
      ),
    );
  }

  List<ParkMapMarker> get _markers => [
        for (final (title, lat, lng) in _kHousePoints)
          ParkMapMarker(
            id: title,
            point: LatLng(lat, lng),
            child: _pin(selected: false),
            selectedChild: _pin(selected: true),
          ),
      ];

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ParkText('Map 地图', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        const ParkText(
            'flutter_map + 天地图 WMTS：标记、聚合、选点、距离圈、列表联动。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        // 工具条：选点模式 / 距离圈
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            ParkSwitch(
              value: _selectionEnabled,
              onChanged: (v) => setState(() => _selectionEnabled = v),
              checkedLabel: '选点模式',
              uncheckedLabel: '选点模式',
            ),
            ParkSwitch(
              value: _showCircle,
              onChanged: (v) => setState(() => _showCircle = v),
              checkedLabel: '距离圈',
              uncheckedLabel: '距离圈',
            ),
            if (_showCircle)
              ParkSegmented(
                items: const [
                  ParkSegmentedItem(value: '1km', label: '1km'),
                  ParkSegmentedItem(value: '3km', label: '3km'),
                ],
                value: _circleRadiusMeters == 1000 ? '1km' : '3km',
                onChanged: (v) => setState(() {
                  _circleRadiusMeters = v == '1km' ? 1000 : 3000;
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // 地图
        SizedBox(
          height: 320,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(park.radius.md),
            child: ParkMap(
              tiandituKey: _kTiandituKey,
              initialCenter: const LatLng(39.9087, 116.4615),
              initialZoom: 11,
              markers: _markers,
              selectedMarkerId: _selectedId,
              selectionEnabled: _selectionEnabled,
              circleCenter: _showCircle
                  ? (_selectedId != null
                      ? _markers
                          .firstWhere((m) => m.id == _selectedId)
                          .point
                      : const LatLng(39.9087, 116.4615))
                  : null,
              circleRadiusMeters: _circleRadiusMeters,
              onMarkerTap: (m) => setState(() => _selectedId = m.id),
              onMapTap: (latLng) => setState(() {
                _pickedInfo =
                    '选点: ${latLng.latitude.toStringAsFixed(6)}, '
                    '${latLng.longitude.toStringAsFixed(6)}';
              }),
              clusterBuilder: (context, count) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: park.colors.brand,
                  shape: BoxShape.circle,
                  border: Border.all(color: park.colors.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count 套',
                  style: TextStyle(
                    color: park.colors.textOnBrand,
                    fontSize: park.typography.sizeCaption,
                    fontWeight: park.typography.weightBold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 状态提示
        if (_pickedInfo != null)
          ParkText(_pickedInfo!, preset: ParkTextPreset.caption),
        if (_kTiandituKey.isEmpty)
          const ParkText(
            '提示：未配置天地图 key，底图瓦片不加载。'
            '运行示例时加 --dart-define=TIANDITU_KEY=你的key 即可显示底图。',
            preset: ParkTextPreset.caption,
          ),
        const SizedBox(height: 16),

        // 列表联动：点击房源项高亮地图标记
        const ParkText('房源列表（点击联动地图高亮）', preset: ParkTextPreset.h3),
        const SizedBox(height: 8),
        for (final (title, lat, lng) in _kHousePoints)
          ParkCell(
            titleText: title,
            note: '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
            leftIcon: const Icon(Icons.home, size: 18),
            onPressed: () => setState(() => _selectedId = title),
            extra: _selectedId == title
                ? Icon(Icons.check_circle, color: park.colors.brand, size: 18)
                : null,
          ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
