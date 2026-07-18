import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// QRCode Demo
// =============================================================================

class QRCodeDemo extends StatelessWidget {
  const QRCodeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('QRCode 二维码', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('基于 qr_flutter 生成可扫描的二维码，支持纠错等级、自定义颜色和 Logo。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkQRCode(data: 'https://parkui.example.com'),
        const SizedBox(height: 24),

        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ParkQRCode(data: 'https://parkui.example.com', size: 80),
            ParkQRCode(data: 'https://parkui.example.com', size: 120),
            ParkQRCode(data: 'https://parkui.example.com', size: 200),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('自定义颜色', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ParkQRCode(
              data: 'https://parkui.example.com',
              size: 120,
              foregroundColor: Color(0xFF1677FF),
            ),
            ParkQRCode(
              data: 'https://parkui.example.com',
              size: 120,
              foregroundColor: Color(0xFF52C41A),
              backgroundColor: Color(0xFFF6FFED),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('纠错等级 & Logo', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const ParkQRCode(
              data: 'https://parkui.example.com',
              size: 140,
              errorCorrectionLevel: ParkQRErrorCorrectionLevel.high,
              logo: Icon(Icons.star, size: 36, color: Colors.orange),
            ),
            ParkQRCode(
              data: 'https://parkui.example.com',
              size: 140,
              errorCorrectionLevel: ParkQRErrorCorrectionLevel.high,
              logo: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF1677FF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('P',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
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
// Watermark Demo
// =============================================================================

class WatermarkDemo extends StatelessWidget {
  const WatermarkDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Watermark 水印', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('在内容区域叠加半透明文字水印，用于版权保护和敏感信息标识。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础文字水印', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ParkWatermark(
            text: 'Park UI',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('内容区域',
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('自定义样式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ParkWatermark(
            text: '机密文件',
            color: const Color(0xFF1677FF).withAlpha(30),
            fontSize: 18,
            rotate: -30,
            gapX: 100,
            gapY: 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('敏感数据区域',
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('密集水印', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ParkWatermark(
            text: 'CONFIDENTIAL',
            color: Colors.red.withAlpha(20),
            fontSize: 12,
            rotate: -45,
            gapX: 80,
            gapY: 60,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('文档内容',
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// List Demo
// =============================================================================

class ListDemo extends StatelessWidget {
  const ListDemo({super.key});

  static const List<Map<String, dynamic>> _items = [
    {'title': '用户管理', 'desc': '管理系统用户的增删改查'},
    {'title': '权限配置', 'desc': '配置角色权限和访问控制'},
    {'title': '日志审计', 'desc': '查看操作日志和安全审计'},
    {'title': '数据备份', 'desc': '定期备份和恢复数据'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('List 列表', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('通用列表，支持分割线、头部/底部、加载态和加载更多。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础列表', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ParkList<Map<String, dynamic>>(
            items: _items,
            split: true,
            itemBuilder: (context, item, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item['title'] as String),
                subtitle: Text(item['desc'] as String),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        ParkText('带头部和底部', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ParkList<Map<String, dynamic>>(
            items: _items.take(3).toList(),
            split: true,
            header: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              color: Colors.grey.shade100,
              child: const Text('系统设置',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            footer: Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: const Text('共 4 项',
                  style: TextStyle(color: Colors.grey)),
            ),
            itemBuilder: (context, item, index) {
              return ListTile(
                title: Text(item['title'] as String),
                subtitle: Text(item['desc'] as String),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        ParkText('加载状态', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ParkList<Map<String, dynamic>>(
            items: const [],
            loading: true,
            loadingItemCount: 3,
            itemBuilder: (context, item, index) {
              return ListTile(title: Text(item['title'] as String));
            },
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Masonry Demo
// =============================================================================

class MasonryDemo extends StatelessWidget {
  const MasonryDemo({super.key});

  static const List<_MasonryItem> _items = [
    _MasonryItem(title: '山川', color: 0xFFE3F2FD, height: 120),
    _MasonryItem(title: '河流', color: 0xFFE8F5E9, height: 160),
    _MasonryItem(title: '森林', color: 0xFFFFF3E0, height: 100),
    _MasonryItem(title: '沙漠', color: 0xFFFCE4EC, height: 180),
    _MasonryItem(title: '海洋', color: 0xFFE0F7FA, height: 140),
    _MasonryItem(title: '湖泊', color: 0xFFF3E5F5, height: 110),
    _MasonryItem(title: '草原', color: 0xFFE8F5E9, height: 150),
    _MasonryItem(title: '冰川', color: 0xFFE1F5FE, height: 130),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Masonry 瀑布流', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('以最短列优先算法将列表项分配到多列中，形成 Pinterest 风格布局。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('两列瀑布流', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 500,
          child: ParkMasonry<_MasonryItem>(
            items: _items,
            columns: 2,
            spacing: 12,
            itemBuilder: (context, item, index) {
              return Container(
                height: item.height.toDouble(),
                decoration: BoxDecoration(
                  color: Color(item.color),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(item.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        ParkText('三列瀑布流', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 400,
          child: ParkMasonry<_MasonryItem>(
            items: _items.sublist(0, 6),
            columns: 3,
            spacing: 8,
            itemBuilder: (context, item, index) {
              return Container(
                height: item.height.toDouble() * 0.8,
                decoration: BoxDecoration(
                  color: Color(item.color),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(item.title,
                      style: const TextStyle(fontSize: 14)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

class _MasonryItem {
  final String title;
  final int color;
  final int height;

  const _MasonryItem({
    required this.title,
    required this.color,
    required this.height,
  });
}

// =============================================================================
// Tooltip Demo
// =============================================================================

class TooltipDemo extends StatelessWidget {
  const TooltipDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Tooltip 文字提示', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('鼠标悬浮或点击时显示文字提示，支持 8 个方向和自定义内容。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法（悬浮触发）', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: const [
            ParkTooltip(
              message: '顶部提示',
              placement: ParkTooltipPlacement.top,
              child: Icon(Icons.info_outline, size: 28),
            ),
            ParkTooltip(
              message: '底部提示',
              placement: ParkTooltipPlacement.bottom,
              child: Icon(Icons.info, size: 28),
            ),
            ParkTooltip(
              message: '左侧提示',
              placement: ParkTooltipPlacement.left,
              child: Icon(Icons.arrow_back, size: 28),
            ),
            ParkTooltip(
              message: '右侧提示',
              placement: ParkTooltipPlacement.right,
              child: Icon(Icons.arrow_forward, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('点击触发', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: const [
            ParkTooltip(
              message: '点击显示的提示',
              trigger: ParkTooltipTrigger.tap,
              placement: ParkTooltipPlacement.top,
              child: ParkButton(
                variant: ParkButtonVariant.secondary,
                child: Text('点击我'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('无箭头 & 自定义颜色', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: const [
            ParkTooltip(
              message: '无箭头的提示',
              showArrow: false,
              child: ParkButton(
                variant: ParkButtonVariant.secondary,
                child: Text('无箭头'),
              ),
            ),
            ParkTooltip(
              message: '自定义颜色',
              color: Color(0xFF1677FF),
              textColor: Colors.white,
              child: ParkButton(
                variant: ParkButtonVariant.secondary,
                child: Text('品牌色'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
