import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// Park 分页器尺寸
enum ParkPaginationSize {
  /// 小尺寸（按钮 24px，字号 12）
  small,

  /// 中尺寸（按钮 32px，字号 14，默认）
  medium,
}

/// Park 分页器
///
/// 提供页码导航，支持页码按钮、前后翻页、快速跳转、每页条数切换等功能。
/// 在 AntD / TDesign 中对应 Pagination 组件。
///
/// ```dart
/// ParkPagination(
///   total: 100,
///   current: 1,
///   pageSize: 10,
///   onChanged: (page, pageSize) {
///     setState(() => _page = page);
///   },
/// )
/// ```
class ParkPagination extends StatefulWidget {
  /// 数据总条数
  final int total;

  /// 当前页码（1-based，外部控制）
  final int current;

  /// 每页条数
  final int pageSize;

  /// 页码或每页条数变化时的回调
  ///
  /// 参数：(新页码, 新每页条数)
  @Deprecated('Use onChanged instead')
  final void Function(int page, int pageSize)? onChange;

  /// 页码或每页条数变化时的回调
  ///
  /// 参数：(新页码, 新每页条数)
  final void Function(int page, int pageSize)? onChanged;

  /// 内部使用的有效回调：优先使用 onChanged，回退到 onChange。
  void Function(int page, int pageSize)? get _effectiveOnChanged =>
      onChanged ?? onChange;

  /// 是否显示每页条数选择器
  final bool showSizeChanger;

  /// 可选的每页条数列表（为 null 时使用默认值 [10, 20, 50, 100]）
  final List<int>? pageSizeOptions;

  /// 是否显示快速跳转输入框
  final bool showQuickJumper;

  /// 每页条数变更回调（仅在 [showSizeChanger] 为 true 时生效）
  ///
  /// 参数：[currentPage] 为重置后的页码（1-based），[size] 为变更后的每页条数。
  /// 注意：[onChanged] 也会在每页条数变更时触发，[onShowSizeChange] 是额外的专有回调。
  final void Function(int currentPage, int size)? onShowSizeChange;

  /// 是否显示总条数信息（"共 X 条"）
  final bool showTotal;

  /// 简洁模式（仅显示上/下翻页和 当前页/总页数）
  final bool simple;

  /// 是否禁用整个分页器
  final bool disabled;

  /// 分页器尺寸
  final ParkPaginationSize size;

  /// 是否响应式布局（窄屏时自动隐藏部分功能）
  final bool responsive;

  /// 默认每页条数（用于非受控模式）
  final int defaultPageSize;

  /// 绑定键（点号分隔的路径，如 `'currentPage'`）
  final String? bindKey;

  /// 绑定服务实例
  final ParkBindingService? bindingService;

  const ParkPagination({
    super.key,
    required this.total,
    this.current = 1,
    this.pageSize = 10,
    // ignore: deprecated_member_use_from_same_package
    this.onChange,
    this.onChanged,
    this.showSizeChanger = false,
    this.pageSizeOptions,
    this.showQuickJumper = false,
    this.onShowSizeChange,
    this.showTotal = false,
    this.simple = false,
    this.disabled = false,
    this.size = ParkPaginationSize.medium,
    this.responsive = false,
    this.defaultPageSize = 10,
    this.bindKey,
    this.bindingService,
  });

  /// 获取有效的每页条数选项列表
  List<int> get effectivePageSizeOptions {
    final options = pageSizeOptions ?? const [10, 20, 50, 100];
    // 确保 defaultPageSize 在选项中
    if (!options.contains(defaultPageSize)) {
      return options.toList()..insert(0, defaultPageSize);
    }
    return options;
  }

  @override
  State<ParkPagination> createState() => _ParkPaginationState();
}

class _ParkPaginationState extends State<ParkPagination>
    with BindableWidgetMixin<int, ParkPagination> {
  late TextEditingController _jumperController;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    _jumperController = TextEditingController();

    // 从 bindable 读取初始值
    final initialValue = boundValue;
    if (initialValue != null && initialValue != widget.current) {
      final int clamped = initialValue.clamp(1, _totalPages);
      if (clamped != widget.current) {
        widget._effectiveOnChanged?.call(clamped, widget.pageSize);
      }
    }
  }

  @override
  void dispose() {
    _jumperController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 计算属性
  // ==========================================================================

  int get _totalPages {
    if (widget.pageSize <= 0) return 1;
    return (widget.total / widget.pageSize).ceil().clamp(1, 99999);
  }

  double get _buttonSize {
    return widget.size == ParkPaginationSize.small ? 24.0 : 32.0;
  }

  double get _fontSize {
    return widget.size == ParkPaginationSize.small ? 12.0 : 14.0;
  }

  double get _iconSize {
    return widget.size == ParkPaginationSize.small ? 14.0 : 16.0;
  }

  // ==========================================================================
  // 页码范围算法
  // ==========================================================================

  /// 计算应该显示的页码序列（含省略号占位符 null）
  List<int?> _buildPageRange() {
    final total = _totalPages;
    final current = widget.current;

    if (total <= 7) {
      return List.generate(total, (i) => i + 1);
    }

    final pages = <int?>[];

    // 始终显示第一页
    pages.add(1);

    // 当前页附近范围（左右各1个邻居）
    final int rangeStart = (current - 1).clamp(2, total - 1);
    final int rangeEnd = (current + 1).clamp(2, total - 1);

    // 左省略号
    if (rangeStart > 2) {
      pages.add(null); // 省略号
    }

    // 中间页码
    for (int i = rangeStart; i <= rangeEnd; i++) {
      pages.add(i);
    }

    // 右省略号
    if (rangeEnd < total - 1) {
      pages.add(null); // 省略号
    }

    // 始终显示最后一页
    if (total > 1) {
      pages.add(total);
    }

    return pages;
  }

  // ==========================================================================
  // 回调
  // ==========================================================================

  void _goToPage(int page) {
    if (widget.disabled) return;
    final clamped = page.clamp(1, _totalPages);
    if (clamped == widget.current) return;
    widget._effectiveOnChanged?.call(clamped, widget.pageSize);
    boundValue = clamped;
  }

  void _onPageSizeChanged(int newSize) {
    if (widget.disabled) return;
    // 切换每页条数时重置当前页为 1，避免超出新总数范围
    const newCurrent = 1;
    widget._effectiveOnChanged?.call(newCurrent, newSize);
    widget.onShowSizeChange?.call(newCurrent, newSize);
    boundValue = newCurrent;
  }

  void _onJumperSubmitted(String value) {
    final page = int.tryParse(value.trim());
    if (page != null) {
      _goToPage(page);
    }
    _jumperController.clear();
  }

  // ==========================================================================
  // Build
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

    if (widget.simple) {
      return _buildSimple(park);
    }

    final children = <Widget>[];

    // 总条数
    if (widget.showTotal) {
      children.add(_buildTotalInfo(park));
      children.add(SizedBox(width: park.spacing.sm));
    }

    // 上一页
    children.add(_buildPrevButton(park));

    // 页码按钮
    if (!widget.simple) {
      final range = _buildPageRange();
      for (final page in range) {
        if (page == null) {
          children.add(_buildEllipsis(park));
        } else {
          children.add(_buildPageButton(park, page));
        }
      }
    }

    // 下一页
    children.add(_buildNextButton(park));

    // 响应式布局：窄屏时隐藏每页条数选择器和快速跳转
    final bool hideSecondary = widget.responsive && _isNarrowScreen(context);

    // 每页条数选择器
    if (widget.showSizeChanger && !hideSecondary) {
      children.add(SizedBox(width: park.spacing.sm));
      children.add(_buildSizeChanger(park));
    }

    // 快速跳转
    if (widget.showQuickJumper && !hideSecondary) {
      children.add(SizedBox(width: park.spacing.sm));
      children.add(_buildQuickJumper(park));
    }

    return Semantics(
      label: l10n.paginationSemantics(_totalPages, widget.current),
      child: Opacity(
        opacity: widget.disabled ? 0.45 : 1.0,
        child: IgnorePointer(
          ignoring: widget.disabled,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }

  bool _isNarrowScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 480;
  }

  // ==========================================================================
  // 简洁模式
  // ==========================================================================

  Widget _buildSimple(ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    return Semantics(
      label: l10n.paginationSemantics(_totalPages, widget.current),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPrevButton(park),
          SizedBox(width: park.spacing.sm),
          Text(
            '${widget.current} / $_totalPages',
            style: TextStyle(
              color: park.colors.textPrimary,
              fontSize: _fontSize,
              fontWeight: park.typography.weightMedium,
            ),
          ),
          SizedBox(width: park.spacing.sm),
          _buildNextButton(park),
        ],
      ),
    );
  }

  // ==========================================================================
  // 总条数
  // ==========================================================================

  Widget _buildTotalInfo(ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    return Semantics(
      label: l10n.totalInfo(widget.total),
      child: Text(
        l10n.totalInfo(widget.total),
        style: TextStyle(
          color: park.colors.textSecondary,
          fontSize: _fontSize,
        ),
      ),
    );
  }

  // ==========================================================================
  // 上一页 / 下一页按钮
  // ==========================================================================

  Widget _buildPrevButton(ParkThemeData park) {
    final isDisabled = widget.current <= 1;
    return _buildArrowButton(
      park: park,
      icon: Icons.chevron_left,
      isDisabled: isDisabled,
      semanticLabel: ParkLocalizations.of(context).previousPage,
      onTap: () => _goToPage(widget.current - 1),
    );
  }

  Widget _buildNextButton(ParkThemeData park) {
    final isDisabled = widget.current >= _totalPages;
    return _buildArrowButton(
      park: park,
      icon: Icons.chevron_right,
      isDisabled: isDisabled,
      semanticLabel: ParkLocalizations.of(context).nextPage,
      onTap: () => _goToPage(widget.current + 1),
    );
  }

  Widget _buildArrowButton({
    required ParkThemeData park,
    required IconData icon,
    required bool isDisabled,
    required String semanticLabel,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: !isDisabled,
      child: _ParkPageButtonBase(
        size: _buttonSize,
        fontSize: _fontSize,
        disabled: isDisabled,
        isActive: false,
        onTap: isDisabled ? null : onTap,
        child: Icon(
          icon,
          size: _iconSize,
          color: isDisabled
              ? park.colors.textDisabled
              : park.colors.textPrimary,
        ),
      ),
    );
  }

  // ==========================================================================
  // 页码按钮
  // ==========================================================================

  Widget _buildPageButton(ParkThemeData park, int page) {
    final isActive = page == widget.current;
    final l10n = ParkLocalizations.of(context);
    return Semantics(
      label: l10n.pageButtonSemantics(page),
      selected: isActive,
      button: true,
      child: _ParkPageButtonBase(
        size: _buttonSize,
        fontSize: _fontSize,
        disabled: false,
        isActive: isActive,
        onTap: () => _goToPage(page),
        child: Text(
          '$page',
          style: TextStyle(
            color: isActive
                ? park.colors.textOnBrand
                : park.colors.textPrimary,
            fontSize: _fontSize,
            fontWeight: isActive
                ? park.typography.weightMedium
                : park.typography.weightRegular,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 省略号
  // ==========================================================================

  Widget _buildEllipsis(ParkThemeData park) {
    return Semantics(
      label: '...',
      child: SizedBox(
        width: _buttonSize,
        height: _buttonSize,
        child: Center(
          child: Text(
            '...',
            style: TextStyle(
              color: park.colors.textSecondary,
              fontSize: _fontSize,
              fontWeight: park.typography.weightBold,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 每页条数选择器
  // ==========================================================================

  Widget _buildSizeChanger(ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    final options = widget.effectivePageSizeOptions;
    return Semantics(
      label: l10n.pageSizeSemantics(widget.pageSize),
      child: Container(
        height: _buttonSize,
        padding: EdgeInsets.symmetric(horizontal: park.spacing.sm),
        decoration: BoxDecoration(
          color: park.colors.surface,
          border: Border.all(color: park.colors.border, width: 1),
          borderRadius: park.radius.brSm,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: options.contains(widget.pageSize)
                ? widget.pageSize
                : options.first,
            isDense: true,
            icon: Icon(
              Icons.arrow_drop_down,
              size: _iconSize,
              color: park.colors.textSecondary,
            ),
            style: TextStyle(
              color: park.colors.textPrimary,
              fontSize: _fontSize,
            ),
            dropdownColor: park.colors.surface,
            borderRadius: park.radius.brMd,
            items: options.map((size) {
              return DropdownMenuItem<int>(
                value: size,
                child: Semantics(
                  label: l10n.pageSizeOption(size),
                  child: Text(
                    l10n.pageSizeOption(size),
                    style: TextStyle(
                      color: park.colors.textPrimary,
                      fontSize: _fontSize,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: widget.disabled ? null : (val) {
              if (val != null) _onPageSizeChanged(val);
            },
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 快速跳转
  // ==========================================================================

  Widget _buildQuickJumper(ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    return Semantics(
      label: l10n.jumpTo,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.jumpTo,
            style: TextStyle(
              color: park.colors.textSecondary,
              fontSize: _fontSize,
            ),
          ),
          SizedBox(width: park.spacing.xs),
          SizedBox(
            width: _buttonSize * 1.5,
            height: _buttonSize,
            child: Semantics(
              textField: true,
              label: l10n.jumpTo,
              child: TextField(
                controller: _jumperController,
                enabled: !widget.disabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  color: park.colors.textPrimary,
                  fontSize: _fontSize,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: park.spacing.xs,
                    vertical: park.spacing.xs,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: park.radius.brSm,
                    borderSide: BorderSide(color: park.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: park.radius.brSm,
                    borderSide: BorderSide(color: park.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: park.radius.brSm,
                    borderSide: BorderSide(color: park.colors.brand, width: 1.5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: park.radius.brSm,
                    borderSide: BorderSide(color: park.colors.borderLight),
                  ),
                  filled: true,
                  fillColor: widget.disabled
                      ? park.colors.disabledBg
                      : park.colors.surface,
                ),
                onSubmitted: _onJumperSubmitted,
              ),
            ),
          ),
          SizedBox(width: park.spacing.xs),
          Text(
            l10n.page,
            style: TextStyle(
              color: park.colors.textSecondary,
              fontSize: _fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 内部基础按钮（处理 hover / active / disabled 状态）
// ============================================================================

class _ParkPageButtonBase extends StatefulWidget {
  final double size;
  final double fontSize;
  final bool disabled;
  final bool isActive;
  final VoidCallback? onTap;
  final Widget child;

  const _ParkPageButtonBase({
    required this.size,
    required this.fontSize,
    required this.disabled,
    required this.isActive,
    required this.onTap,
    required this.child,
  });

  @override
  State<_ParkPageButtonBase> createState() => _ParkPageButtonBaseState();
}

class _ParkPageButtonBaseState extends State<_ParkPageButtonBase> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // 计算背景色和边框色
    Color bgColor;
    Color borderColor;

    if (widget.isActive) {
      bgColor = park.colors.brand;
      borderColor = park.colors.brand;
    } else if (widget.disabled) {
      bgColor = park.colors.surface;
      borderColor = park.colors.borderLight;
    } else if (_isHovered) {
      bgColor = park.colors.brand.withValues(alpha: 0.06);
      borderColor = park.colors.brand;
    } else {
      bgColor = park.colors.surface;
      borderColor = park.colors.border;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: MouseRegion(
        cursor: widget.disabled || widget.onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) {
          if (!widget.disabled) setState(() => _isHovered = true);
        },
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.disabled ? null : widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(park.radius.sm),
            ),
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
