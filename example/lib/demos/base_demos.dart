import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Button Demo
// =============================================================================

class ButtonDemo extends StatelessWidget {
  const ButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Button 按钮', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('6 种变体 × 3 种尺寸，支持 loading / disabled / block 等状态。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        // --- 变体展示 ---
        ParkText('变体 Variants', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(variant: ParkButtonVariant.primary, onPressed: () {},
                child: const Text('Primary')),
            ParkButton(variant: ParkButtonVariant.secondary, onPressed: () {},
                child: const Text('Secondary')),
            ParkButton(variant: ParkButtonVariant.text, onPressed: () {},
                child: const Text('Text')),
            ParkButton(variant: ParkButtonVariant.link, onPressed: () {},
                child: const Text('Link')),
            ParkButton(variant: ParkButtonVariant.ghost, onPressed: () {},
                child: const Text('Ghost')),
            ParkButton(variant: ParkButtonVariant.danger, onPressed: () {},
                child: const Text('Danger')),
          ],
        ),
        const SizedBox(height: 24),

        // --- 尺寸展示 ---
        ParkText('尺寸 Sizes', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              size: ParkButtonSize.small,
              onPressed: () {},
              child: const Text('Small'),
            ),
            ParkButton(
              variant: ParkButtonVariant.primary,
              size: ParkButtonSize.medium,
              onPressed: () {},
              child: const Text('Medium'),
            ),
            ParkButton(
              variant: ParkButtonVariant.primary,
              size: ParkButtonSize.large,
              onPressed: () {},
              child: const Text('Large'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- 交互示例 ---
        ParkText('交互示例', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ParkButton(
                  variant: ParkButtonVariant.primary,
                  loading: _btnLoading,
                  onPressed: () {
                    setState(() => _btnLoading = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() => _btnLoading = false);
                    });
                  },
                  child: const Text('异步提交'),
                ),
                const SizedBox(height: 12),
                ParkButton(
                  variant: ParkButtonVariant.secondary,
                  onPressed: null,
                  child: const Text('禁用按钮'),
                ),
                const SizedBox(height: 12),
                ParkButton(
                  variant: ParkButtonVariant.primary,
                  block: true,
                  onPressed: () {},
                  child: const Text('Block 占满宽度'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

bool _btnLoading = false;

// =============================================================================
// Text Demo
// =============================================================================

class TextDemo extends StatelessWidget {
  const TextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Text 文本', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('预设标题/正文/辅助文字层级，支持语义色彩。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('Display (34px)', preset: ParkTextPreset.display),
        ParkText('H1 一级标题 (28px)', preset: ParkTextPreset.h1),
        ParkText('H2 二级标题 (22px)', preset: ParkTextPreset.h2),
        ParkText('H3 三级标题 (18px)', preset: ParkTextPreset.h3),
        ParkText('Body 正文 (16px)', preset: ParkTextPreset.body),
        ParkText('Body Small 小号正文 (14px)', preset: ParkTextPreset.bodySmall),
        ParkText('Caption 辅助文字 (13px)', preset: ParkTextPreset.caption),
        ParkText('Overline 超小文字 (11px)', preset: ParkTextPreset.overline),
        const SizedBox(height: 24),

        ParkText('语义色彩', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkText('成功文本', type: ParkTextType.success),
        ParkText('警告文本', type: ParkTextType.warning),
        ParkText('危险文本', type: ParkTextType.danger),
        ParkText('次要文本', type: ParkTextType.secondary),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Icon Demo
// =============================================================================

class IconDemo extends StatelessWidget {
  const IconDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Icon 图标', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('预设尺寸、容器背景、旋转动画、角标。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('尺寸预设', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ParkIcon(Icons.home, size: ParkIconSize.small),
            ParkIcon(Icons.home, size: ParkIconSize.medium),
            ParkIcon(Icons.home, size: ParkIconSize.large),
            ParkIcon(Icons.home, size: ParkIconSize.xlarge),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('容器背景', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ParkIcon(Icons.star, container: ParkIconContainer.circle),
            ParkIcon(Icons.settings, container: ParkIconContainer.rounded),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('角标 & 交互', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Wrap(
              spacing: 24,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const ParkIcon(Icons.mail, badge: 5),
                const ParkIcon(Icons.notifications, badge: 99),
                ParkIcon(Icons.refresh, spin: true),
                ParkIcon(
                  Icons.thumb_up,
                  onClick: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('图标被点击')),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Divider Demo
// =============================================================================

class DividerDemo extends StatelessWidget {
  const DividerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Divider 分割线', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('水平/垂直分割线、带文字、虚线样式。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础分割线', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkDivider(),
        const SizedBox(height: 12),
        ParkText('虚线分割线', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkDivider(dashed: true),
        const SizedBox(height: 12),
        ParkText('带文字分割线', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkDivider.withText('或者'),
        const SizedBox(height: 12),
        ParkDivider.withText('靠左', textAlign: ParkDividerTextAlign.left),
        const SizedBox(height: 12),
        ParkDivider.withText('靠右', textAlign: ParkDividerTextAlign.right),
        const SizedBox(height: 12),
        ParkText('自定义颜色与粗细', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkDivider(color: Color(0xFF1677FF), thickness: 3),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Fab Demo
// =============================================================================

class FabDemo extends StatelessWidget {
  const FabDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Fab 悬浮按钮', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('页面主操作悬浮按钮，支持多种形状和主题。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('形状 & 主题', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ParkFab(icon: Icons.add, onPressed: () {}),
            ParkFab(
              icon: Icons.edit,
              label: '编辑',
              shape: ParkFabShape.rounded,
              onPressed: () {},
            ),
            ParkFab(
              icon: Icons.delete,
              themeVariant: ParkFabTheme.danger,
              onPressed: () {},
            ),
            ParkFab(
              icon: Icons.star,
              size: ParkFabSize.small,
              themeVariant: ParkFabTheme.light,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('交互示例', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text('预览区域'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ParkFab(
                      icon: Icons.add,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('FAB 被点击')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Space Demo
// =============================================================================

class SpaceDemo extends StatelessWidget {
  const SpaceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Space 间距', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('统一控制子元素之间的间距，支持水平、垂直和自动换行。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('水平间距', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSpace(
          size: 16,
          children: [
            ParkTag(text: '标签 1', theme: ParkTagTheme.primary),
            ParkTag(text: '标签 2', theme: ParkTagTheme.success),
            ParkTag(text: '标签 3', theme: ParkTagTheme.warning),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('垂直间距', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSpace(
          direction: Axis.vertical,
          size: 8,
          children: [
            ParkTag(text: '第一行', theme: ParkTagTheme.primary),
            ParkTag(text: '第二行', theme: ParkTagTheme.success),
            ParkTag(text: '第三行', theme: ParkTagTheme.warning),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('自动换行', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSpace(
          wrap: true,
          size: 8,
          children: List.generate(
            12,
            (i) => ParkTag(
              text: 'Tag $i',
              theme: ParkTagTheme.primary,
              size: ParkTagSize.small,
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('预设间距', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSpace.md(
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('md (16px)'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ParkSpace.lg(
          children: [
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {},
              child: const Text('lg (24px)'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
