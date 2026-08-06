import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// ParkSkeletonPresets Demo
// =============================================================================

class SkeletonPresetsDemo extends StatelessWidget {
  const SkeletonPresetsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('SkeletonPresets 骨架屏预设', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('业务级骨架屏预设：通用卡片、租赁列表、房间列表、详情页。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('ParkShimmerCard 通用卡片', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkShimmerCard(lines: 3),
        const ParkShimmerCard(lines: 2, hasAvatar: true),
        const ParkShimmerCard(lines: 4, hasAvatar: true, avatarSize: 48),
        const SizedBox(height: 24),

        ParkText('ParkLeaseListSkeleton 租赁列表', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 420,
          child: ParkLeaseListSkeleton(showSummary: true, itemCount: 3),
        ),
        const SizedBox(height: 24),

        ParkText('ParkRoomListSkeleton 房间列表', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const SizedBox(
          height: 420,
          child: ParkRoomListSkeleton(itemCount: 3),
        ),
        const SizedBox(height: 24),

        ParkText('ParkDetailPageSkeleton 详情页', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const SizedBox(
          height: 420,
          child: ParkDetailPageSkeleton(sectionCount: 3),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
