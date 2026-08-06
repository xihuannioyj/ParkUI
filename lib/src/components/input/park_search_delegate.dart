import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import '../../theme/tokens/park_spacing.dart';
import '../../theme/tokens/park_typography.dart';
import '../../l10n/park_localizations.dart';

/// Interface for search history persistence.
///
/// Implement this to provide custom storage (SharedPreferences, SQLite, etc.).
abstract class ParkSearchHistory {
  /// Returns recent search keywords for the given [scope].
  List<String> getHistory(String scope);

  /// Adds a keyword to history for the given [scope].
  void addHistory(String scope, String keyword);

  /// Removes a specific keyword from history.
  void removeHistory(String scope, String keyword);

  /// Clears all history for the given [scope].
  void clearHistory(String scope);
}

/// In-memory search history implementation (no persistence).
class ParkInMemorySearchHistory implements ParkSearchHistory {
  final Map<String, List<String>> _store = {};
  final int maxItems;

  ParkInMemorySearchHistory({this.maxItems = 10});

  @override
  List<String> getHistory(String scope) =>
      List.unmodifiable(_store[scope] ?? []);

  @override
  void addHistory(String scope, String keyword) {
    final list = _store.putIfAbsent(scope, () => []);
    list.remove(keyword);
    list.insert(0, keyword);
    if (list.length > maxItems) list.removeLast();
  }

  @override
  void removeHistory(String scope, String keyword) {
    _store[scope]?.remove(keyword);
  }

  @override
  void clearHistory(String scope) {
    _store.remove(scope);
  }
}

/// Shows a full-screen search page.
///
/// Returns the selected result value, or null if dismissed.
///
/// ```dart
/// final result = await showParkSearch<String>(
///   context: context,
///   hint: '搜索房源',
///   historyScope: 'housing',
///   onSearch: (keyword) async {
///     return await api.searchHousing(keyword);
///   },
///   suggestionBuilder: (keyword) {
///     return ['建议1', '建议2'];
///   },
///   resultBuilder: (context, keyword, results) {
///     return ListView(...);
///   },
/// );
/// ```
Future<T?> showParkSearch<T>({
  required BuildContext context,
  String? hint,
  String historyScope = 'default',
  ParkSearchHistory? history,
  Future<List<T>> Function(String keyword)? onSearch,
  List<String> Function(String keyword)? suggestionBuilder,
  Widget Function(BuildContext context, String keyword, List<T> results)?
      resultBuilder,
  Widget Function(BuildContext context, String keyword)? emptyBuilder,
  String? title,
  bool autofocus = true,
}) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      fullscreenDialog: true,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return _ParkSearchPage<T>(
          hint: hint,
          historyScope: historyScope,
          history: history ?? ParkInMemorySearchHistory(),
          onSearch: onSearch,
          suggestionBuilder: suggestionBuilder,
          resultBuilder: resultBuilder,
          emptyBuilder: emptyBuilder,
          title: title,
          autofocus: autofocus,
        );
      },
      transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    ),
  );
}

class _ParkSearchPage<T> extends StatefulWidget {
  final String? hint;
  final String historyScope;
  final ParkSearchHistory history;
  final Future<List<T>> Function(String keyword)? onSearch;
  final List<String> Function(String keyword)? suggestionBuilder;
  final Widget Function(BuildContext context, String keyword, List<T> results)?
      resultBuilder;
  final Widget Function(BuildContext context, String keyword)? emptyBuilder;
  final String? title;
  final bool autofocus;

  const _ParkSearchPage({
    this.hint,
    required this.historyScope,
    required this.history,
    this.onSearch,
    this.suggestionBuilder,
    this.resultBuilder,
    this.emptyBuilder,
    this.title,
    required this.autofocus,
  });

  @override
  State<_ParkSearchPage<T>> createState() => _ParkSearchPageState<T>();
}

class _ParkSearchPageState<T> extends State<_ParkSearchPage<T>> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _keyword = '';
  List<T> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    if (text != _keyword) {
      setState(() {
        _keyword = text;
        _hasSearched = false;
        _results = [];
      });
    }
  }

  Future<void> _doSearch(String keyword) async {
    if (keyword.isEmpty) return;

    widget.history.addHistory(widget.historyScope, keyword);

    if (widget.onSearch == null) return;

    setState(() => _isSearching = true);
    try {
      final results = await widget.onSearch!(keyword);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      debugPrint('showParkSearch error: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;
    final l10n = ParkLocalizations.of(context);

    final historyItems = widget.history.getHistory(widget.historyScope);
    final suggestions = _keyword.isNotEmpty && widget.suggestionBuilder != null
        ? widget.suggestionBuilder!(_keyword)
        : <String>[];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.base,
                vertical: spacing.sm,
              ),
              child: Row(
                children: [
                  // Back button
                  Semantics(
                    button: true,
                    label: l10n.cancelText,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.only(right: spacing.sm),
                        child: Icon(
                          Icons.arrow_back,
                          size: 22,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Search input
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: spacing.md),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(park.radius.full),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              size: 18, color: colors.textPlaceholder),
                          SizedBox(width: spacing.xs),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: widget.autofocus,
                              textInputAction: TextInputAction.search,
                              onSubmitted: _doSearch,
                              style: TextStyle(
                                fontSize: typo.sizeBody,
                                color: colors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: widget.hint ?? l10n.searchPlaceholder,
                                hintStyle: TextStyle(
                                  fontSize: typo.sizeBody,
                                  color: colors.textPlaceholder,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            Semantics(
                              button: true,
                              label: 'Clear',
                              child: GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  _focusNode.requestFocus();
                                },
                                child: Icon(Icons.close_rounded,
                                    size: 16, color: colors.textSecondary),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Search button
                  Semantics(
                    button: true,
                    label: l10n.searchText,
                    child: GestureDetector(
                      onTap: () => _doSearch(_keyword),
                      child: Padding(
                        padding: EdgeInsets.only(left: spacing.sm),
                        child: Text(
                          l10n.searchText,
                          style: TextStyle(
                            fontSize: typo.sizeBody,
                            color: colors.brand,
                            fontWeight: typo.weightMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: colors.divider),

            // Body
            Expanded(
              child: _isSearching
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(spacing.xl),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.brand,
                        ),
                      ),
                    )
                  : _hasSearched && _results.isEmpty
                      ? widget.emptyBuilder != null
                          ? widget.emptyBuilder!(context, _keyword)
                          : Center(
                              child: Text(
                                l10n.noSearchResults,
                                style: TextStyle(
                                  fontSize: typo.sizeBody,
                                  color: colors.textSecondary,
                                ),
                              ),
                            )
                      : _hasSearched && widget.resultBuilder != null
                          ? widget.resultBuilder!(context, _keyword, _results)
                          : _keyword.isEmpty && historyItems.isNotEmpty
                              ? _buildHistory(historyItems, park, colors, typo, spacing, l10n)
                              : suggestions.isNotEmpty
                                  ? _buildSuggestions(suggestions, colors, typo, spacing)
                                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(
    List<String> items,
    ParkThemeData park,
    ParkColors colors,
    ParkTypography typo,
    ParkSpacing spacing,
    ParkLocalizations l10n,
  ) {
    return ListView(
      padding: EdgeInsets.all(spacing.base),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.searchHistory,
              style: TextStyle(
                fontSize: typo.sizeBodySmall,
                fontWeight: typo.weightMedium,
                color: colors.textSecondary,
              ),
            ),
            Semantics(
              button: true,
              label: l10n.searchHistory,
              child: GestureDetector(
                onTap: () {
                  widget.history.clearHistory(widget.historyScope);
                  setState(() {});
                },
                child: Icon(Icons.delete_outline,
                    size: 18, color: colors.textPlaceholder),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.xs,
          children: items.map((item) {
            return Semantics(
              button: true,
              label: item,
              child: GestureDetector(
                onTap: () {
                  _controller.text = item;
                  _doSearch(item);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(park.radius.full),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: typo.sizeBodySmall,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestions(
    List<String> suggestions,
    ParkColors colors,
    ParkTypography typo,
    ParkSpacing spacing,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          dense: true,
          leading: Icon(Icons.search, size: 18, color: colors.textPlaceholder),
          title: Text(
            suggestion,
            style: TextStyle(
              fontSize: typo.sizeBody,
              color: colors.textPrimary,
            ),
          ),
          onTap: () {
            _controller.text = suggestion;
            _doSearch(suggestion);
          },
        );
      },
    );
  }
}
