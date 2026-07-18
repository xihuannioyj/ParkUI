import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Link Demo
// =============================================================================

class LinkDemo extends StatelessWidget {
  const LinkDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Link 链接', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('文字超链接，支持多种样式、图标、禁用和加载状态。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        // --- 基础用法 ---
        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            ParkLink('默认链接', onTap: () {}),
            ParkLink('下划线链接',
                variant: ParkLinkVariant.underline, onTap: () {}),
          ],
        ),
        const SizedBox(height: 24),

        // --- 语义样式 ---
        ParkText('语义样式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            ParkLink('Primary', linkStyle: ParkLinkStyle.primary,
                onTap: () {}),
            ParkLink('Danger', linkStyle: ParkLinkStyle.danger,
                onTap: () {}),
            ParkLink('Warning', linkStyle: ParkLinkStyle.warning,
                onTap: () {}),
            ParkLink('Success', linkStyle: ParkLinkStyle.success,
                onTap: () {}),
          ],
        ),
        const SizedBox(height: 24),

        // --- 带图标 ---
        ParkText('带图标', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            ParkLink('前置图标',
                icon: const Icon(Icons.link, size: 16),
                onTap: () {}),
            ParkLink('后置图标',
                trailingIcon: const Icon(Icons.open_in_new, size: 16),
                onTap: () {}),
          ],
        ),
        const SizedBox(height: 24),

        // --- 尺寸 ---
        ParkText('尺寸', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ParkLink('Small', linkSize: ParkLinkSize.small, onTap: () {}),
            ParkLink('Medium', linkSize: ParkLinkSize.medium, onTap: () {}),
            ParkLink('Large', linkSize: ParkLinkSize.large, onTap: () {}),
          ],
        ),
        const SizedBox(height: 24),

        // --- 禁用 & 加载 ---
        ParkText('禁用 & 加载', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            ParkLink('禁用链接', disabled: true, onTap: () {}),
            ParkLink('加载中', loading: true, onTap: () {}),
            ParkLink('已访问', visited: true, onTap: () {}),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
