import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

class _FakeStorage implements ParkSearchHistoryStorage {
  final Map<String, List<String>> data = {};
  int loadCount = 0;
  int saveCount = 0;

  @override
  Future<List<String>> loadHistory(String scope) async {
    loadCount++;
    return List.of(data[scope] ?? const []);
  }

  @override
  Future<void> saveHistory(String scope, List<String> keywords) async {
    saveCount++;
    data[scope] = List.of(keywords);
  }
}

Future<void> _flush() => Future<void>.delayed(const Duration(milliseconds: 1));

void main() {
  group('ParkMemorySearchHistory', () {
    test('adds keywords to front with dedup', () {
      final history = ParkMemorySearchHistory();
      history.addHistory('home', '苹果');
      history.addHistory('home', '香蕉');
      history.addHistory('home', '苹果');
      expect(history.getHistory('home'), ['苹果', '香蕉']);
    });

    test('trims whitespace and ignores empty keywords', () {
      final history = ParkMemorySearchHistory();
      history.addHistory('home', '  苹果  ');
      history.addHistory('home', '   ');
      expect(history.getHistory('home'), ['苹果']);
    });

    test('caps at limit (default 10)', () {
      final history = ParkMemorySearchHistory();
      for (var i = 1; i <= 12; i++) {
        history.addHistory('home', 'kw$i');
      }
      final list = history.getHistory('home');
      expect(list.length, 10);
      expect(list.first, 'kw12');
      expect(list.last, 'kw3');
    });

    test('supports custom limit', () {
      final history = ParkMemorySearchHistory(limit: 3);
      history.addHistory('home', 'a');
      history.addHistory('home', 'b');
      history.addHistory('home', 'c');
      history.addHistory('home', 'd');
      expect(history.getHistory('home'), ['d', 'c', 'b']);
    });

    test('removes and clears per scope', () {
      final history = ParkMemorySearchHistory();
      history.addHistory('home', '苹果');
      history.addHistory('other', '香蕉');
      history.removeHistory('home', '苹果');
      expect(history.getHistory('home'), isEmpty);
      expect(history.getHistory('other'), ['香蕉']);
      history.clearHistory('other');
      expect(history.getHistory('other'), isEmpty);
    });

    test('returns unmodifiable list', () {
      final history = ParkMemorySearchHistory();
      history.addHistory('home', '苹果');
      expect(
        () => history.getHistory('home').add('x'),
        throwsUnsupportedError,
      );
    });
  });

  group('ParkStorageSearchHistory', () {
    test('addHistory persists asynchronously', () async {
      final storage = _FakeStorage();
      final history = ParkStorageSearchHistory(storage: storage);
      history.addHistory('home', '苹果');
      history.addHistory('home', '香蕉');
      history.addHistory('home', '苹果');
      expect(history.getHistory('home'), ['苹果', '香蕉']);
      await _flush();
      expect(storage.data['home'], ['苹果', '香蕉']);
    });

    test('lazy loads from storage on first access', () async {
      final storage = _FakeStorage()..data['home'] = ['旧词1', '旧词2'];
      final history = ParkStorageSearchHistory(storage: storage);
      // 首次同步访问返回空（尚未加载完成）
      expect(history.getHistory('home'), isEmpty);
      await _flush();
      expect(history.getHistory('home'), ['旧词1', '旧词2']);
      expect(storage.loadCount, 1);
    });

    test('preload fills cache for multiple scopes', () async {
      final storage = _FakeStorage()
        ..data['a'] = ['x1', 'x2']
        ..data['b'] = ['y1'];
      final history = ParkStorageSearchHistory(storage: storage);
      await history.preload(['a', 'b']);
      expect(history.getHistory('a'), ['x1', 'x2']);
      expect(history.getHistory('b'), ['y1']);
      expect(storage.loadCount, 2);
    });

    test('preload trims and filters empty entries', () async {
      final storage = _FakeStorage()..data['a'] = ['  x1 ', '', 'x2'];
      final history = ParkStorageSearchHistory(storage: storage);
      await history.preload(['a']);
      expect(history.getHistory('a'), ['x1', 'x2']);
    });

    test('removeHistory persists', () async {
      final storage = _FakeStorage();
      final history = ParkStorageSearchHistory(storage: storage);
      history.addHistory('home', '苹果');
      history.addHistory('home', '香蕉');
      history.removeHistory('home', '苹果');
      expect(history.getHistory('home'), ['香蕉']);
      await _flush();
      expect(storage.data['home'], ['香蕉']);
    });

    test('clearHistory persists empty list', () async {
      final storage = _FakeStorage();
      final history = ParkStorageSearchHistory(storage: storage);
      history.addHistory('home', '苹果');
      history.clearHistory('home');
      expect(history.getHistory('home'), isEmpty);
      await _flush();
      expect(storage.data['home'], isEmpty);
    });

    test('caps at limit and persists', () async {
      final storage = _FakeStorage();
      final history = ParkStorageSearchHistory(storage: storage, limit: 3);
      history.addHistory('home', 'a');
      history.addHistory('home', 'b');
      history.addHistory('home', 'c');
      history.addHistory('home', 'd');
      expect(history.getHistory('home'), ['d', 'c', 'b']);
      await _flush();
      expect(storage.data['home'], ['d', 'c', 'b']);
    });

    test('ignores empty keyword on add', () async {
      final storage = _FakeStorage();
      final history = ParkStorageSearchHistory(storage: storage);
      history.addHistory('home', '   ');
      expect(history.getHistory('home'), isEmpty);
      await _flush();
      expect(storage.saveCount, 0);
    });
  });
}
