import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 搜索框尺寸枚举
enum ParkSearchSize {
  /// 小尺寸 — 高度 32px
  small,

  /// 中尺寸（默认）— 高度 40px
  medium,

  /// 大尺寸 — 高度 48px
  large,
}

/// 搜索框形状枚举
enum ParkSearchShape {
  /// 胶囊形（默认）
  capsule,

  /// 方形（小圆角）
  square,
}

/// 搜索缓存服务接口。
///
/// 实现此接口以提供搜索历史持久化能力。
/// park_ui 不内置存储实现，由外部按需注入。
abstract class ParkSearchCache {
  /// 加载历史记录（按时间倒序，最近在前）
  Future<List<String>> loadHistory(String scope);

  /// 保存一条搜索关键词（去重、前置、截断）
  Future<void> saveHistory(String scope, String keyword);

  /// 删除单条历史记录
  Future<void> removeHistory(String scope, String keyword);

  /// 清空所有历史记录
  Future<void> clearHistory(String scope);
}

/// Park UI 搜索框
///
/// 胶囊形搜索输入框，支持搜索图标前缀、清除按钮、取消按钮等功能。
/// 通过 [cacheService] 接入外部搜索历史缓存（需实现 [ParkSearchCache] 接口），
/// 注入后自动显示搜索历史建议面板。
///
/// ```dart
/// ParkSearch(
///   hintText: '搜索',
///   onChanged: (v) => print(v),
///   showCancel: true,
///   cacheService: MySearchCache(),
///   cacheScope: 'home',
/// )
/// ```
class ParkSearch extends StatefulWidget {
  const ParkSearch({
    super.key,
    this.controller,
    this.hintText = '搜索',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.showCancel = false,
    this.loading = false,
    this.disabled = false,
    this.size = ParkSearchSize.medium,
    this.shape = ParkSearchShape.capsule,
    this.actionText,
    this.onSearch,
    this.maxLength,
    this.clearable = true,
    this.bindKey,
    this.bindingService,
    this.cacheService,
    this.cacheScope = 'default',
    this.suggestionBuilder,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool showCancel;

  /// 是否处于加载状态。为 true 时搜索图标替换为加载指示器。
  /// 默认 false。
  final bool loading;

  /// 是否禁用。为 true 时渲染禁用样式，不可交互。
  /// 默认 false。
  final bool disabled;

  /// 搜索框尺寸，控制高度。默认 [ParkSearchSize.medium]。
  final ParkSearchSize size;

  /// 搜索框形状。默认 [ParkSearchShape.capsule]（胶囊形）。
  final ParkSearchShape shape;

  /// 搜索按钮自定义文字。设置后在搜索框右侧显示文字按钮。
  final String? actionText;

  /// 搜索回调（与 onSubmitted 等价，兼容 AntD 命名）
  final ValueChanged<String>? onSearch;

  /// 最大输入长度
  final int? maxLength;

  /// 是否显示清除按钮。默认 true。
  final bool clearable;

  /// 绑定键（点号分隔的路径，如 `'searchText'`）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  /// 搜索缓存服务（实现 [ParkSearchCache] 接口）。
  /// 设置后自动加载/保存搜索历史并显示建议面板。
  /// 不设置时无历史功能。
  final ParkSearchCache? cacheService;

  /// 缓存作用域（用于隔离不同搜索场景的历史记录）。
  /// 默认 `'default'`。
  final String cacheScope;

  /// 自定义建议面板构建器（覆盖默认的历史面板 UI）。
  final Widget Function(BuildContext context, List<String> suggestions, String query, ValueChanged<String> onTap)? suggestionBuilder;

  @override
  State<ParkSearch> createState() => _ParkSearchState();
}

class _ParkSearchState extends State<ParkSearch>
    with BindableWidgetMixin<String, ParkSearch> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showCancel = false;
  OverlayEntry? _suggestionOverlay;
  final LayerLink _layerLink = LayerLink();
  List<String> _historyList = [];
  bool _historyLoaded = false;
  VoidCallback? _bindingSyncListener;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _loadHistory();
    // 从 bindable 读取初始值
    final initialValue = boundValue;
    if (initialValue != null) {
      _controller.text = initialValue;
    }
    // 监听外部绑定值变化，同步到 TextEditingController
    _bindingSyncListener = () {
      if (mounted) {
        final newValue = boundValue;
        if (newValue != null && _controller.text != newValue) {
          _controller.text = newValue;
        }
      }
    };
    boundListenable.addListener(_bindingSyncListener!);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    if (widget.autofocus && !widget.disabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _hideSuggestionOverlay();
    if (_bindingSyncListener != null) {
      boundListenable.removeListener(_bindingSyncListener!);
      _bindingSyncListener = null;
    }
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showCancel = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus && widget.cacheService != null) {
      if (!_historyLoaded) {
        _loadHistory();
      }
      if (_historyList.isNotEmpty) {
        _showSuggestionOverlay();
      }
    } else {
      _hideSuggestionOverlay();
    }
  }

  Future<void> _loadHistory() async {
    if (widget.cacheService == null) return;
    try {
      final list = await widget.cacheService!.loadHistory(widget.cacheScope);
      if (mounted) {
        setState(() {
          _historyList = list;
          _historyLoaded = true;
        });
      }
    } catch (_) {}
  }

  List<String> get _filteredSuggestions {
    if (_historyList.isEmpty) return const [];
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return _historyList;
    return _historyList
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  void _showSuggestionOverlay() {
    _hideSuggestionOverlay();
    final suggestions = _filteredSuggestions;
    if (suggestions.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final searchBarWidth = renderBox.size.width;

    _suggestionOverlay = OverlayEntry(
      builder: (overlayContext) {
        final park = Theme.of(overlayContext).extension<ParkThemeData>() ??
            ParkThemeData.light();
        return CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: searchBarWidth,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(park.radius.sm),
                color: park.colors.surface,
                surfaceTintColor: park.colors.surface,
                shadowColor: park.colors.textPrimary.withValues(alpha: 0.12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  decoration: BoxDecoration(
                    border: Border.all(color: park.colors.divider),
                    borderRadius: BorderRadius.circular(park.radius.sm),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(park.radius.sm),
                    child: _buildSuggestionsPanel(park),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_suggestionOverlay!);
  }

  void _hideSuggestionOverlay() {
    _suggestionOverlay?.remove();
    _suggestionOverlay = null;
  }

  Widget _buildSuggestionsPanel(ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    final suggestions = _filteredSuggestions;
    final query = _controller.text.trim();

    if (widget.suggestionBuilder != null) {
      return widget.suggestionBuilder!(
        context, suggestions, query, _onSuggestionTap,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(
            park.spacing.md, park.spacing.sm,
            park.spacing.sm, park.spacing.xs,
          ),
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 16, color: park.colors.textPlaceholder),
              SizedBox(width: park.spacing.xs),
              Text(
                query.isEmpty ? l10n.searchHistory : l10n.matchedHistory,
                style: park.typography.caption.copyWith(
                  color: park.colors.textPlaceholder,
                ),
              ),
              const Spacer(),
              if (widget.cacheService != null)
                GestureDetector(
                  onTap: () {
                    widget.cacheService!.clearHistory(widget.cacheScope);
                    setState(() {
                      _historyList.clear();
                    });
                    _hideSuggestionOverlay();
                  },
                  child: Semantics(
                    button: true,
                    label: l10n.clearText,
                    child: Text(
                      l10n.clearText,
                      style: park.typography.caption.copyWith(
                        color: park.colors.brand,
                        fontWeight: park.typography.weightMedium,
                      ),
                    ),
                  ),
                ),
              ],
          ),
        ),
        // Items
        if (suggestions.isEmpty)
          Padding(
            padding: EdgeInsets.all(park.spacing.md),
            child: Center(
              child: Text(
                l10n.noSearchHistory,
                style: park.typography.caption.copyWith(
                  color: park.colors.textPlaceholder,
                ),
              ),
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => Divider(
                height: 1, thickness: 0.5,
                color: park.colors.divider.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final item = suggestions[index];
                return _buildHistoryItem(item, park);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryItem(String item, ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    return Semantics(
      button: true,
      label: item,
      child: InkWell(
      onTap: () => _onSuggestionTap(item),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.md,
          vertical: park.spacing.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: park.colors.textPlaceholder),
            SizedBox(width: park.spacing.sm),
            Expanded(
              child: Text(
                item,
                style: park.typography.body.copyWith(
                  color: park.colors.textPrimary,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ),
            if (widget.cacheService != null)
              Semantics(
                button: true,
                label: '${l10n.deleteText} $item',
                child: GestureDetector(
                  onTap: () {
                    widget.cacheService!.removeHistory(widget.cacheScope, item);
                    setState(() {
                      _historyList.remove(item);
                      if (_historyList.isEmpty) {
                        _hideSuggestionOverlay();
                      }
                    });
                  },
                  child: Icon(
                    Icons.close_rounded, size: 16,
                    color: park.colors.textPlaceholder,
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  void _onSuggestionTap(String value) {
    _controller.text = value;
    // 保存到缓存
    if (widget.cacheService != null) {
      widget.cacheService!.saveHistory(widget.cacheScope, value);
    }
    widget.onChanged?.call(value);
    widget.onSubmitted?.call(value);
    widget.onSearch?.call(value);
    _hideSuggestionOverlay();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    boundValue = '';
    _hideSuggestionOverlay();
  }

  void _cancel() {
    _clear();
    _focusNode.unfocus();
    _hideSuggestionOverlay();
  }

  void _onActionTap() {
    if (widget.disabled || widget.loading) return;
    widget.onSubmitted?.call(_controller.text);
    widget.onSearch?.call(_controller.text);
    boundValue = _controller.text;
  }

  double get _height {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    switch (widget.size) {
      case ParkSearchSize.small:
        return park.sizing.inputHeightSm;
      case ParkSearchSize.medium:
        return 40;
      case ParkSearchSize.large:
        return park.sizing.inputHeightMd;
    }
  }

  double get _fontSize {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    switch (widget.size) {
      case ParkSearchSize.small:
        return park.typography.sizeBodySmall;
      case ParkSearchSize.medium:
        return park.typography.sizeBody;
      case ParkSearchSize.large:
        return park.typography.sizeH3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParkLocalizations.of(context);
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final isDisabled = widget.disabled;

    final borderRadius = widget.shape == ParkSearchShape.capsule
        ? park.radius.brFull
        : park.radius.brSm;

    final bgColor =
        isDisabled ? park.colors.disabledBg : park.colors.surface;
    final textColor =
        isDisabled ? park.colors.textDisabled : park.colors.textPrimary;
    final placeholderColor =
        isDisabled ? park.colors.textDisabled : park.colors.textPlaceholder;

    // Leading icon: loading spinner or search icon
    Widget leadingIcon;
    if (widget.loading) {
      leadingIcon = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(park.colors.brand),
        ),
      );
    } else {
      leadingIcon = Icon(
        CupertinoIcons.search,
        size: 18,
        color: isDisabled ? park.colors.textDisabled : park.colors.textPlaceholder,
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: IgnorePointer(
      ignoring: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: park.motion.standard,
                height: _height,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: borderRadius,
                ),
                child: Row(
                  children: [
                    SizedBox(width: park.spacing.md),
                    leadingIcon,
                    SizedBox(width: park.spacing.xs),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: widget.autofocus && !isDisabled,
                        enabled: !isDisabled,
                        maxLength: widget.maxLength,
                        style: park.typography.body.copyWith(
                          fontSize: _fontSize,
                          color: textColor,
                        ),
                        cursorColor: park.colors.brand,
                        onChanged: (v) {
                          widget.onChanged?.call(v);
                          boundValue = v;
                        },
                        onSubmitted: (v) {
                          widget.onSubmitted?.call(v);
                          widget.onSearch?.call(v);
                          boundValue = v;
                        },
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: park.typography.body.copyWith(
                            fontSize: _fontSize,
                            color: placeholderColor,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: park.spacing.xs,
                            vertical: 0,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (widget.clearable && _controller.text.isNotEmpty && !isDisabled)
                      Semantics(
                        button: true,
                        label: l10n.clearText,
                        child: GestureDetector(
                          onTap: _clear,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: park.spacing.sm,
                            ),
                            child: Icon(
                              CupertinoIcons.clear_circled_solid,
                              size: 18,
                              color: park.colors.textPlaceholder,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Action text button
            if (widget.actionText != null) ...[
              SizedBox(width: park.spacing.sm),
              Semantics(
                button: true,
                label: widget.actionText,
                enabled: !widget.loading,
                child: GestureDetector(
                  onTap: widget.loading ? null : _onActionTap,
                  child: Container(
                    height: _height,
                    padding: EdgeInsets.symmetric(horizontal: park.spacing.base),
                    decoration: BoxDecoration(
                      color: park.colors.brand,
                      borderRadius: borderRadius,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.actionText!,
                      style: park.typography.body.copyWith(
                        fontSize: _fontSize,
                        color: park.colors.textOnBrand,
                        fontWeight: park.typography.weightMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            // Cancel button
            if (widget.showCancel && _showCancel && !isDisabled) ...[
              SizedBox(width: park.spacing.sm),
              Semantics(
                button: true,
                label: l10n.cancelText,
                child: GestureDetector(
                  onTap: _cancel,
                  child: Text(
                    l10n.cancelText,
                    style: park.typography.body.copyWith(
                      color: park.colors.brand,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}
