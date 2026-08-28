import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/park_theme_data.dart';

/// Park 地图标记数据。
class ParkMapMarker {
  /// 标记唯一标识（用于列表联动与选中高亮）
  final String id;

  /// 标记所在坐标
  final LatLng point;

  /// 标记内容（自定义 Widget）
  final Widget child;

  /// 选中态内容（为空时复用 [child]）
  final Widget? selectedChild;

  /// 标记尺寸（宽高像素）
  final Size size;

  /// 创建地图标记。
  const ParkMapMarker({
    required this.id,
    required this.point,
    required this.child,
    this.selectedChild,
    this.size = const Size(36, 36),
  });
}

/// 聚合节点构建器：接收聚合内的标记数量，返回聚合展示 Widget。
typedef ParkMapClusterBuilder = Widget Function(BuildContext context, int count);

/// Park 地图
///
/// 基于 flutter_map 的跨平台地图组件（Android/iOS 纯 Dart 渲染），
/// 内置天地图 WMTS 底图，支持标记点、标记聚合、地图选点、距离圈与列表联动。
///
/// 天地图 key 通过 [tiandituKey] 传入，组件库不内置任何业务凭据。
///
/// ```dart
/// ParkMap(
///   tiandituKey: 'your_tianditu_key',
///   markers: [
///     ParkMapMarker(
///       id: '1',
///       point: const LatLng(39.9042, 116.4074),
///       child: Icon(Icons.home),
///     ),
///   ],
///   onMarkerTap: (m) => print('选中 ${m.id}'),
/// )
/// ```
class ParkMap extends StatefulWidget {
  /// 天地图服务 key（必填，官网申请；组件库不硬编码任何凭据）
  final String tiandituKey;

  /// 初始中心点
  final LatLng initialCenter;

  /// 初始缩放级别
  final double initialZoom;

  /// 标记点列表
  final List<ParkMapMarker> markers;

  /// 标记点点击回调（供列表联动）
  final ValueChanged<ParkMapMarker>? onMarkerTap;

  /// 受控选中的标记点 id（外部联动高亮，对应标记渲染 [ParkMapMarker.selectedChild]）
  final String? selectedMarkerId;

  /// 是否开启选点模式（点击地图回调 [onMapTap] 返回坐标）
  final bool selectionEnabled;

  /// 选点回调（仅 [selectionEnabled] 为 true 时触发，参数为点击处坐标）
  final ValueChanged<LatLng>? onMapTap;

  /// 距离圈中心（为空则不绘制）
  final LatLng? circleCenter;

  /// 距离圈半径（米，如 1000 / 3000）
  final double circleRadiusMeters;

  /// 是否启用标记聚合（标记数多于 1 时生效）
  final bool enableClustering;

  /// 聚合节点构建器（默认显示数量徽标，如「12」；业务侧可定制为「12 套」）
  final ParkMapClusterBuilder? clusterBuilder;

  const ParkMap({
    super.key,
    required this.tiandituKey,
    this.initialCenter = const LatLng(39.9042, 116.4074),
    this.initialZoom = 11,
    this.markers = const [],
    this.onMarkerTap,
    this.selectedMarkerId,
    this.selectionEnabled = false,
    this.onMapTap,
    this.circleCenter,
    this.circleRadiusMeters = 1000,
    this.enableClustering = true,
    this.clusterBuilder,
  });

  @override
  State<ParkMap> createState() => _ParkMapState();
}

class _ParkMapState extends State<ParkMap> {
  /// 天地图 WMTS 矢量底图 urlTemplate（tk 由构造参数注入，禁止硬编码）
  String get _urlTemplate =>
      'https://t{s}.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile'
      '&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles'
      '&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=${widget.tiandituKey}';

  List<Marker> _buildMarkers() {
    return widget.markers.map((ParkMapMarker m) {
      final selected = m.id == widget.selectedMarkerId;
      return Marker(
        point: m.point,
        width: m.size.width,
        height: m.size.height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onMarkerTap?.call(m),
          child: selected ? (m.selectedChild ?? m.child) : m.child,
        ),
      );
    }).toList();
  }

  /// 默认聚合节点：品牌色圆形数量徽标。
  Widget _defaultCluster(BuildContext context, int count) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: park.colors.brand,
        shape: BoxShape.circle,
        border: Border.all(color: park.colors.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: park.colors.textOnBrand,
          fontSize: park.typography.sizeBodySmall,
          fontWeight: park.typography.weightBold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    final markers = _buildMarkers();
    final useCluster = widget.enableClustering && widget.markers.length > 1;

    return FlutterMap(
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
        onTap: widget.selectionEnabled
            ? (TapPosition tapPosition, LatLng latLng) =>
                widget.onMapTap?.call(latLng)
            : null,
      ),
      children: [
        TileLayer(
          urlTemplate: _urlTemplate,
          subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
          maxNativeZoom: 18,
          userAgentPackageName: 'park_ui',
        ),
        if (widget.circleCenter != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: widget.circleCenter!,
                radius: widget.circleRadiusMeters,
                useRadiusInMeter: true,
                color: park.colors.brand.withValues(alpha: 0.08),
                borderColor: park.colors.brand,
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
        if (useCluster)
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              markers: markers,
              size: const Size(40, 40),
              maxClusterRadius: 80,
              zoomToBoundsOnClick: true,
              centerMarkerOnClick: false,
              markerChildBehavior: true,
              builder: (BuildContext ctx, List<Marker> clusterMarkers) =>
                  widget.clusterBuilder?.call(ctx, clusterMarkers.length) ??
                  _defaultCluster(ctx, clusterMarkers.length),
            ),
          )
        else
          MarkerLayer(markers: markers),
      ],
    );
  }
}
