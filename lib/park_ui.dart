/// Park UI — 独立、可插拔的 Flutter UI 组件集
///
/// 提供完整的设计令牌系统和 85+ 个自定义控件。
/// 所有组件独立工作，不依赖 GetX / Provider 等全局状态管理。
///
/// 快速开始：
/// ```dart
/// import 'package:park_ui/park_ui.dart';
///
/// // 1. 在 MaterialApp 中注入主题
/// MaterialApp(
///   theme: ThemeData(extensions: [ParkThemeData.light()]),
///   darkTheme: ThemeData(extensions: [ParkThemeData.dark()]),
/// )
///
/// // 2. 使用组件
/// ParkButton(
///   variant: ParkButtonVariant.primary,
///   onPressed: () {},
///   child: Text('提交'),
/// )
/// ```
library;

// ============================================================================
// 主题系统
// ============================================================================

export 'src/theme/park_theme.dart';
export 'src/theme/park_theme_data.dart';

// ============================================================================
// 本地化
// ============================================================================

export 'src/l10n/park_localizations.dart';
export 'src/theme/tokens/park_colors.dart';
export 'src/theme/tokens/park_typography.dart';
export 'src/theme/tokens/park_spacing.dart';
export 'src/theme/tokens/park_radius.dart';
export 'src/theme/tokens/park_shadows.dart';
export 'src/theme/tokens/park_motion.dart';

// ============================================================================
// 基础组件
// ============================================================================

export 'src/components/base/park_button.dart';
export 'src/components/base/park_button_style.dart';
export 'src/components/base/park_text.dart';
export 'src/components/base/park_icon.dart';
export 'src/components/base/park_divider.dart';
export 'src/components/base/park_fab.dart';
export 'src/components/base/park_link.dart';
export 'src/components/base/park_space.dart';
export 'src/components/base/park_ink_well.dart';

// ============================================================================
// 输入组件
// ============================================================================

export 'src/components/input/park_input.dart';
export 'src/components/input/park_textarea.dart';
export 'src/components/input/park_search.dart';
export 'src/components/input/park_switch.dart';
export 'src/components/input/park_stepper.dart';
export 'src/components/input/park_slider.dart';
export 'src/components/input/park_rate.dart';
export 'src/components/input/park_checkbox.dart';
export 'src/components/input/park_radio.dart';
export 'src/components/input/park_picker.dart';
export 'src/components/input/park_date_picker.dart';
export 'src/components/input/park_date_range_picker.dart';
export 'src/components/input/park_select.dart';
export 'src/components/input/park_cascader.dart';
export 'src/components/input/park_tree_select.dart';
export 'src/components/input/park_upload.dart';
export 'src/components/input/park_auto_complete.dart';
export 'src/components/input/park_color_picker.dart';
export 'src/components/input/park_input_number.dart';
export 'src/components/input/park_time_picker.dart';
export 'src/components/input/park_transfer.dart';
export 'src/components/input/park_form.dart';
export 'src/components/input/park_form_item.dart';
export 'src/components/input/park_form_section.dart';
export 'src/components/input/park_segmented.dart';
export 'src/components/input/park_input_group.dart';
export 'src/components/input/park_calendar.dart';

// ============================================================================
// 导航组件
// ============================================================================

export 'src/components/navigation/park_tabs.dart';
export 'src/components/navigation/park_tab_bar.dart';
export 'src/components/navigation/park_nav_bar.dart';
export 'src/components/navigation/park_side_bar.dart';
export 'src/components/navigation/park_steps.dart';
export 'src/components/navigation/park_drawer.dart';
export 'src/components/navigation/park_back_top.dart';
export 'src/components/navigation/park_indexes.dart';
export 'src/components/navigation/park_breadcrumb.dart';
export 'src/components/navigation/park_pagination.dart';
export 'src/components/navigation/park_layout.dart';
export 'src/components/navigation/park_anchor.dart';
export 'src/components/navigation/park_menu.dart';

// ============================================================================
// 数据展示组件
// ============================================================================

export 'src/components/display/park_avatar.dart';
export 'src/components/display/park_badge.dart';
export 'src/components/display/park_cell.dart';
export 'src/components/display/park_collapse.dart';
export 'src/components/display/park_descriptions.dart';
export 'src/components/display/park_empty.dart';
export 'src/components/display/park_image.dart';
export 'src/components/display/park_image_viewer.dart';
export 'src/components/display/park_progress.dart';
export 'src/components/display/park_result.dart';
export 'src/components/display/park_skeleton.dart';
export 'src/components/display/park_swiper.dart';
export 'src/components/display/park_table.dart';
export 'src/components/display/park_tag.dart';
export 'src/components/display/park_counter.dart';
export 'src/components/display/park_footer.dart';
export 'src/components/display/park_grid.dart';
export 'src/components/display/park_sticky.dart';
export 'src/components/display/park_card.dart';
export 'src/components/display/park_countdown.dart';
export 'src/components/display/park_qrcode.dart';
export 'src/components/display/park_list.dart';
export 'src/components/display/park_ellipsis.dart';
export 'src/components/display/park_timeline.dart';
export 'src/components/display/park_tooltip.dart';
export 'src/components/display/park_watermark.dart';
export 'src/components/display/park_tree.dart';

// ============================================================================
// 反馈组件
// ============================================================================

export 'src/components/feedback/park_dialog.dart';
export 'src/components/feedback/park_toast.dart';
export 'src/components/feedback/park_loading.dart';
export 'src/components/feedback/park_alert.dart';
export 'src/components/feedback/park_action_sheet.dart';
export 'src/components/feedback/park_popup.dart';
export 'src/components/feedback/park_dropdown_menu.dart';
export 'src/components/feedback/park_dropdown_sheet.dart';
export 'src/components/feedback/park_dropdown_filter.dart';
export 'src/components/feedback/park_notice_bar.dart';
export 'src/components/feedback/park_message.dart';
export 'src/components/feedback/park_popover.dart';
export 'src/components/feedback/park_refresh.dart';
export 'src/components/feedback/park_swipe_cell.dart';
export 'src/components/feedback/park_notification.dart';
export 'src/components/feedback/park_overlay.dart';
export 'src/components/feedback/park_popconfirm.dart';

// ============================================================================
// 动态表单
// ============================================================================
export 'src/form/models/form_field_schema.dart';
export 'src/form/models/form_formatter_schema.dart';
export 'src/form/models/form_layout_schema.dart' hide ParkFormLayout;
export 'src/form/engine/form_engine.dart';
export 'src/form/engine/form_reaction_engine.dart';
export 'src/form/engine/form_formatter_engine.dart';
export 'src/form/engine/form_runtime_state.dart';
export 'src/form/engine/form_engine_io_stub.dart';
export 'src/form/validators/form_validator.dart';
export 'src/form/validators/form_validator_result.dart';
export 'src/form/validators/async_validators.dart';
export 'src/form/validators/async_validator_config.dart';
export 'src/form/regex/park_regex_registry.dart';
export 'src/form/data_source/park_data_source_resolver.dart';
export 'src/form/widgets/park_dynamic_form.dart';
export 'src/form/widgets/park_form_field_widget.dart';
export 'src/form/widgets/park_form_field_helpers.dart';
export 'src/form/widgets/park_schema_builder.dart';
export 'src/form/platform/park_form_image_service.dart';

// ============================================================================
// 双向绑定
// ============================================================================
export 'src/binding/park_bindable.dart';
export 'src/binding/park_binding_service.dart';
export 'src/binding/park_binding_path.dart';
export 'src/binding/park_binding_scheduler.dart';
export 'src/binding/park_binding_form_field_mixin.dart';
export 'src/binding/park_binding_form_scope.dart';
export 'src/binding/park_binding_mixin.dart';
