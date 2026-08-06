import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// ParkSearchHistory Demo
// =============================================================================

/// 内存版假存储：模拟 SharedPreferences / 数据库等持久化实现。
class _FakeStorage implements ParkSearchHistoryStorage {
  final Map<String, List<String>> _store = {};

  @override
  Future<List<String>> loadHistory(String scope) async {
    // 模拟异步读取延迟
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_store[scope] ?? const []);
  }

  @override
  Future<void> saveHistory(String scope, List<String> keywords) async {
    _store[scope] = List.of(keywords);
  }
}

class SearchHistoryDemo extends StatefulWidget {
  const SearchHistoryDemo({super.key});

  @override
  State<SearchHistoryDemo> createState() => _SearchHistoryDemoState();
}

class _SearchHistoryDemoState extends State<SearchHistoryDemo> {
  final TextEditingController _controller = TextEditingController();
  final ParkMemorySearchHistory _memoryHistory =
      ParkMemorySearchHistory(limit: 8);
  final ParkStorageSearchHistory _storageHistory = ParkStorageSearchHistory(
    storage: _FakeStorage(),
    limit: 8,
  );

  static const String _scope = 'demo_home_search';
  late List<String> _memoryItems;
  late List<String> _storageItems;

  @override
  void initState() {
    super.initState();
    // 演示预置几条历史
    _memoryHistory.addHistory(_scope, '一居室');
    _memoryHistory.addHistory(_scope, '朝阳区 整租');
    _memoryHistory.addHistory(_scope, '近地铁');
    _storageHistory.addHistory(_scope, '月租 2000 以下');
    _storageHistory.addHistory(_scope, '短租');
    _memoryItems = _memoryHistory.getHistory(_scope);
    _storageItems = _storageHistory.getHistory(_scope);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _memoryItems = _memoryHistory.getHistory(_scope);
      _storageItems = _storageHistory.getHistory(_scope);
    });
  }

  void _addMemory(String keyword) {
    _memoryHistory.addHistory(_scope, keyword);
    _refresh();
  }

  void _removeMemory(String keyword) {
    _memoryHistory.removeHistory(_scope, keyword);
    _refresh();
  }

  void _clearMemory() {
    _memoryHistory.clearHistory(_scope);
    _refresh();
  }

  void _addStorage(String keyword) {
    _storageHistory.addHistory(_scope, keyword);
    _refresh();
  }

  void _removeStorage(String keyword) {
    _storageHistory.removeHistory(_scope, keyword);
    _refresh();
  }

  void _clearStorage() {
    _storageHistory.clearHistory(_scope);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('SearchHistory 搜索历史', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('搜索历史存储：内存实现与存储实现（去重/前置/截断语义一致）。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('ParkMemorySearchHistory 内存版', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        _buildHistorySection(
          items: _memoryItems,
          onAdd: _addMemory,
          onRemove: _removeMemory,
          onClear: _clearMemory,
          hintText: '输入关键词后点击添加',
        ),
        const SizedBox(height: 24),

        ParkText('ParkStorageSearchHistory 存储版', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        _buildHistorySection(
          items: _storageItems,
          onAdd: _addStorage,
          onRemove: _removeStorage,
          onClear: _clearStorage,
          hintText: '通过 ParkSearchHistoryStorage 持久化',
        ),
        const SizedBox(height: 12),
        ParkText(
            '存储版实现：同步访问缓存，异步写入存储；实现 [ParkSearchHistoryStorage] '
            '即可桥接 SharedPreferences / 数据库。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }

  Widget _buildHistorySection({
    required List<String> items,
    required void Function(String keyword) onAdd,
    required void Function(String keyword) onRemove,
    required VoidCallback onClear,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ParkInput(
                controller: _controller,
                hintText: hintText,
                onSubmitted: (value) {
                  final keyword = value.trim();
                  if (keyword.isNotEmpty) {
                    onAdd(keyword);
                    _controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {
                final keyword = _controller.text.trim();
                if (keyword.isNotEmpty) {
                  onAdd(keyword);
                  _controller.clear();
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          ParkText('暂无搜索历史', preset: ParkTextPreset.caption)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                ParkTag(
                  text: item,
                  size: ParkTagSize.medium,
                  theme: ParkTagTheme.primary,
                  variant: ParkTagVariant.outline,
                  closable: true,
                  onClose: () => onRemove(item),
                ),
            ],
          ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: onClear,
              child: const Text('清空历史'),
            ),
          ),
        ],
      ],
    );
  }
}
