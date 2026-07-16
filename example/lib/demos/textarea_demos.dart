import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Textarea Demo
// =============================================================================

class TextareaDemo extends StatelessWidget {
  const TextareaDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Textarea 多行输入', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('多行文本输入，支持字数统计、自动扩展高度、清除按钮。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTextarea(
          hintText: '请输入备注信息',
          label: '备注',
        ),
        const SizedBox(height: 24),

        ParkText('字数统计', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTextarea(
          hintText: '请输入评论内容',
          label: '评论',
          maxLength: 200,
          showCount: true,
        ),
        const SizedBox(height: 24),

        ParkText('只读模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTextarea(
          initialValue: '这是一段只读的文本内容，不可编辑。',
          readOnly: true,
          label: '描述',
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
