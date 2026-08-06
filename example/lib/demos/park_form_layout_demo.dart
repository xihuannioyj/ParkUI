import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// ParkFormLayout Demo
// =============================================================================

class FormLayoutDemo extends StatelessWidget {
  const FormLayoutDemo({super.key});

  void _showModalForm(BuildContext context) {
    ParkPopup.showBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ParkFormModalScaffold(
        title: '添加联系人',
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () {
          Navigator.of(ctx).pop();
          ParkToast.show(context, '已保存联系人');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ParkFormRow(
                label: '姓名',
                required: true,
                child: ParkInput(hintText: '请输入姓名'),
              ),
              ParkFormRow(
                label: '手机号',
                child: ParkInput(hintText: '请输入手机号'),
              ),
              ParkFormRow(
                label: '备注',
                child: ParkInput(hintText: '选填'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ParkFormPageBody(
      sections: [
        ParkText('FormLayout 表单布局', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('通用表单页面组件：介绍区、分区卡片、提交按钮、分步操作、弹层。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('ParkFormIntro 表单介绍区', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkFormIntro(
          title: '完善认证信息',
          description: '请填写真实有效的信息，提交后将进入人工审核，通常 1-2 个工作日完成。',
          badgeText: '第1步 / 3',
        ),
        const SizedBox(height: 24),

        ParkText('ParkFormSectionCard 分区卡片', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkFormSectionCard(
          title: '基本信息',
          description: '以下信息用于身份核验',
          extensionWidget: ParkText('必填',
              fontSize: 12, color: Theme.of(context).colorScheme.error),
          children: [
            ParkFormRow(
              label: '姓名',
              required: true,
              child: ParkInput(hintText: '请输入姓名'),
            ),
            ParkFormRow(
              label: '手机号',
              child: ParkInput(hintText: '请输入手机号'),
            ),
            ParkFormRow(
              label: '邮箱',
              child: ParkInput(hintText: '请输入邮箱'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('ParkFormSubmitButton 提交按钮', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkFormSubmitButton(
          text: '提交认证',
          onPressed: () => ParkToast.show(context, '提交成功'),
        ),
        const SizedBox(height: 24),

        ParkText('ParkFormStepActions 分步操作', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkFormStepActions(
          canGoBack: true,
          nextText: '下一步',
          onBack: () => ParkToast.show(context, '返回上一步'),
          onNext: () => ParkToast.show(context, '进入下一步'),
        ),
        ParkFormStepActions(
          canGoBack: false,
          nextText: '完成',
          onBack: null,
          onNext: () => ParkToast.show(context, '流程完成'),
        ),
        const SizedBox(height: 24),

        ParkText('ParkFormModalHeader / Scaffold 弹层', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () => _showModalForm(context),
          child: const Text('打开表单弹层'),
        ),
        const SizedBox(height: 12),
        ParkText(
            '弹层由 ParkFormModalHeader（取消/标题/确认头部）+ 内容区组合，'
            '可通过 ParkPopup.showBottomSheet 承载。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
