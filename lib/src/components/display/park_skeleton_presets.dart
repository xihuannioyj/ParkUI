import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import 'park_skeleton.dart';

/// 通用骨架屏卡片 — 基于 [ParkSkeleton] 封装。
///
/// 列表加载时替代全屏 Loading，使用 park_ui 统一 shimmer 动画。
class ParkShimmerCard extends StatelessWidget {
  /// 内容文本行数
  final int lines;

  /// 是否显示头像占位
  final bool hasAvatar;

  /// 头像尺寸（直径），默认 40
  final double? avatarSize;

  const ParkShimmerCard({
    super.key,
    this.lines = 3,
    this.hasAvatar = false,
    this.avatarSize,
  });

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final size = avatarSize ?? 40;

    return Container(
      margin: EdgeInsets.only(bottom: park.spacing.base),
      padding: EdgeInsets.all(park.spacing.base),
      decoration: BoxDecoration(
        color: park.colors.surface,
        borderRadius: park.radius.brLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasAvatar) ...[
            ParkSkeleton.avatar(size: size),
            SizedBox(width: park.spacing.md),
          ],
          Expanded(
            child: ParkSkeleton.text(
              lines: lines,
              lineHeight: 14,
              spacing: 12,
              lastLineWidthFraction: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// 租赁类列表首屏骨架。
///
/// 用于租赁、短租等列表首次进入时的骨架屏占位。
class ParkLeaseListSkeleton extends StatelessWidget {
  /// 是否展示顶部汇总卡片占位。
  final bool showSummary;

  /// 骨架列表项数量。
  final int itemCount;

  const ParkLeaseListSkeleton({
    super.key,
    this.showSummary = false,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      children: <Widget>[
        if (showSummary) _buildSummarySkeleton(context),
        ...List<Widget>.generate(
          itemCount,
          (_) => const ParkShimmerCard(lines: 4, hasAvatar: false),
        ),
      ],
    );
  }

  Widget _buildSummarySkeleton(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(park.spacing.base),
      decoration: BoxDecoration(
        color: park.colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ParkSkeleton.text(lines: 2, lineHeight: 14, spacing: 10),
          const SizedBox(height: 14),
          Row(
            children: List<Widget>.generate(
              3,
              (int index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: index == 2 ? 0 : park.spacing.sm),
                  child: Container(
                    padding: EdgeInsets.all(park.spacing.md),
                    decoration: BoxDecoration(
                      color: park.colors.background,
                      borderRadius: park.radius.brMd,
                    ),
                    child: ParkSkeleton.text(
                      lines: 2,
                      lineHeight: 12,
                      spacing: 8,
                      lastLineWidthFraction: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 房间类列表首屏骨架。
///
/// 对齐首页房间卡片的视觉密度，避免首次加载时整页空白。
class ParkRoomListSkeleton extends StatelessWidget {
  /// 骨架列表项数量。
  final int itemCount;

  const ParkRoomListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: itemCount,
      itemBuilder: (_, _) => _buildRoomCardSkeleton(context),
    );
  }

  Widget _buildRoomCardSkeleton(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Container(
      margin: EdgeInsets.only(bottom: park.spacing.md),
      padding: EdgeInsets.all(park.spacing.base),
      decoration: BoxDecoration(
        color: park.colors.surface,
        borderRadius: park.radius.brLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ParkSkeleton.text(
            lines: 2,
            lineHeight: 14,
            spacing: 10,
            lastLineWidthFraction: 0.35,
          ),
          const SizedBox(height: 14),
          Row(
            children: List<Widget>.generate(
              4,
              (int index) => Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : 10),
                child: ParkSkeleton.avatar(size: 22),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ParkSkeleton.text(
            lines: 2,
            lineHeight: 12,
            spacing: 8,
            lastLineWidthFraction: 0.65,
          ),
        ],
      ),
    );
  }
}

/// 通用详情页骨架。
///
/// 适用于详情/展示页首次加载时的基础占位，保持卡片式信息结构的过渡体验。
class ParkDetailPageSkeleton extends StatelessWidget {
  /// 骨架卡片数量。
  final int sectionCount;

  const ParkDetailPageSkeleton({super.key, this.sectionCount = 3});

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
        child: Column(
          children: List<Widget>.generate(
            sectionCount,
            (int index) => Container(
              margin: EdgeInsets.only(
                  bottom: index == sectionCount - 1 ? 0 : park.spacing.md),
              padding: EdgeInsets.all(park.spacing.base),
              decoration: BoxDecoration(
                color: park.colors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ParkSkeleton.text(
                lines: 4,
                lineHeight: 14,
                spacing: 12,
                lastLineWidthFraction: 0.55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
