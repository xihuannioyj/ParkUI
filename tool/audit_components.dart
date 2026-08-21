// Standalone audit helper: scans lib/src/components/**/*.dart and extracts,
// for every top-level class, the unnamed constructor's named/positional
// parameters (brace/paren/bracket/string/comment aware) and static method
// names. Writes tool/components_dump.json.
//
// Run: dart run tool/audit_components.dart  (from package root)

import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory('lib/src/components');
  final files = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final Map<String, dynamic> result = {};

  for (final file in files) {
    final src = file.readAsStringSync();
    final rel = file.path.replaceAll('\\', '/');
    final classes = scanClasses(src, rel);
    if (classes.isEmpty) continue;
    for (final cls in classes) {
      result['${rel}#${cls.name}'] = {
        'name': cls.name,
        'params': cls.params,
        'staticMethods': cls.staticMethods,
        'hasConstructor': cls.hasConstructor,
      };
    }
  }

  final outFile = File('tool/components_dump.json');
  outFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(result));
  stdout.writeln('COMPONENTS_DUMP_OK total=${result.length} file=${outFile.path}');
}

class _ClassInfo {
  final String name;
  final List<Map<String, dynamic>> params;
  final List<String> staticMethods;
  final bool hasConstructor;
  _ClassInfo(this.name, this.params, this.staticMethods, this.hasConstructor);
}

/// Removes `//` and `/* */` comments, string-aware.
String _stripComments(String s) {
  final out = StringBuffer();
  var i = 0;
  while (i < s.length) {
    final c = s[i];
    if (c == "'" || c == '"') {
      final end = _skipString(s, i);
      out.write(s.substring(i, end));
      i = end;
      continue;
    }
    if (c == '/' && i + 1 < s.length && s[i + 1] == '/') {
      final nl = s.indexOf('\n', i);
      i = nl < 0 ? s.length : nl + 1;
      continue;
    }
    if (c == '/' && i + 1 < s.length && s[i + 1] == '*') {
      final end = s.indexOf('*/', i + 2);
      i = end < 0 ? s.length : end + 2;
      continue;
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

List<_ClassInfo> scanClasses(String src, String rel) {
  final results = <_ClassInfo>[];
  final classRe = RegExp(r'\bclass\s+(\w+)');
  final matches = classRe.allMatches(src).toList();
  for (final m in matches) {
    final name = m.group(1)!;
    final start = m.start;
    // Find the opening brace of the class body.
    final bodyOpen = _findNext(src, start, '{');
    if (bodyOpen < 0) continue;
    final bodyEnd = _matchBrace(src, bodyOpen);
    if (bodyEnd < 0) continue;
    final body = src.substring(bodyOpen, bodyEnd + 1);

    // Find unnamed constructor: `Name(` (allow `const Name(`), not `Name.xxx(`.
    // Strip comments first so doc-comment occurrences of `Name(` don't match,
    // and do ALL index math on the stripped text.
    final bodyNoComments = _stripComments(body);
    final ctorRe = RegExp('(?<!\\w)${RegExp.escape(name)}\\s*\\(');
    final ctorMatch = ctorRe.firstMatch(bodyNoComments);
    List<Map<String, dynamic>> params = [];
    bool hasCtor = false;
    if (ctorMatch != null) {
      final openParen = ctorMatch.start + ctorMatch.group(0)!.indexOf('(');
      final closeParen = _matchParen(bodyNoComments, openParen);
      if (closeParen > 0) {
        hasCtor = true;
        final paramText = bodyNoComments.substring(openParen + 1, closeParen);
        params = _parseParams(paramText);
      }
    }

    final statics = _scanStaticMethods(bodyNoComments);
    results.add(_ClassInfo(name, params, statics, hasCtor));
  }
  return results;
}

/// Finds the index of [ch] at top nesting level starting from [from].
int _findNext(String s, int from, String ch) {
  var i = from;
  var depth = 0;
  while (i < s.length) {
    final c = s[i];
    if (c == '(' || c == '[') {
      depth++;
    } else if (c == ')' || c == ']') {
      depth--;
    } else if (c == ch && depth == 0) {
      return i;
    }
    i++;
  }
  return -1;
}

int _matchBrace(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    final c = s[i];
    if (c == '{') {
      depth++;
    } else if (c == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}

int _matchParen(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    final c = s[i];
    if (c == '(') {
      depth++;
    } else if (c == ')') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}

/// Split a constructor parameter list text into top-level segments.
List<String> _splitParams(String text) {
  final segments = <String>[];
  var depth = 0;
  var brace = 0;
  var angle = 0;
  var start = 0;
  var i = 0;
  while (i < text.length) {
    final c = text[i];
    if (c == "'" || c == '"') {
      i = _skipString(text, i);
      continue;
    }
    if (c == '/') {
      if (i + 1 < text.length && text[i + 1] == '/') {
        final nl = text.indexOf('\n', i);
        i = nl < 0 ? text.length : nl + 1;
        continue;
      }
      if (i + 1 < text.length && text[i + 1] == '*') {
        final end = text.indexOf('*/', i + 2);
        i = end < 0 ? text.length : end + 2;
        continue;
      }
    }
    if (c == '(' || c == '[') depth++;
    if (c == ')' || c == ']') depth--;
    if (c == '{') brace++;
    if (c == '}') brace--;
    if (c == '<' &&
        i + 1 < text.length &&
        RegExp(r'[A-Za-z_>]').hasMatch(text[i + 1])) {
      angle++;
    }
    if (c == '>' && angle > 0) angle--;
    if (c == ',' && depth == 0 && brace <= 1 && angle == 0) {
      segments.add(text.substring(start, i));
      start = i + 1;
    }
    i++;
  }
  if (start < text.length) {
    segments.add(text.substring(start));
  }
  return segments;
}

int _skipString(String s, int i) {
  final quote = s[i];
  var j = i + 1;
  var triple = false;
  if (j + 1 < s.length && s[j] == quote && s[j + 1] == quote) {
    triple = true;
    j += 2;
  }
  while (j < s.length) {
    if (s[j] == '\\') {
      j += 2;
      continue;
    }
    if (s[j] == quote) {
      if (triple) {
        if (j + 2 < s.length && s[j + 1] == quote && s[j + 2] == quote) {
          return j + 3;
        }
        j++;
        continue;
      }
      return j + 1;
    }
    if (s[j] == '\n' && !triple) return j + 1;
    j++;
  }
  return s.length;
}

List<Map<String, dynamic>> _parseParams(String text) {
  final segments = _splitParams(text);
  final params = <Map<String, dynamic>>[];
  var braceDepth = 0;
  for (final seg0 in segments) {
    var seg = seg0.trim();
    if (seg.isEmpty) continue;
    // Count braces in this segment (rough; ignores strings) to track whether
    // we are inside the named-param group.
    final opens = '{'.allMatches(seg).length;
    final closes = '}'.allMatches(seg).length;
    if (opens > 0) {
      seg = seg.replaceFirst('{', '').trim();
      braceDepth++;
    }
    if (seg.isEmpty) continue;
    if (closes > 0) {
      seg = seg.replaceFirst('}', '').trim();
      braceDepth--;
    }
    if (seg.isEmpty) continue;
    final isNamed = braceDepth > 0;
    final p = _parseOneParam(seg, isNamed);
    if (p != null) params.add(p);
  }
  return params;
}

Map<String, dynamic>? _parseOneParam(String seg, bool isNamed) {
  // Strip annotations like @Deprecated('...') — they contain identifiers/parens.
  var s = seg;
  final annotationRe = RegExp(r'@\w+(?:\([^)]*\))?\s*');
  s = s.replaceAll(annotationRe, '').trim();

  bool required = false;
  bool isSuper = false;
  String? name;

  var rest = s;
  if (rest.startsWith('required ')) {
    required = true;
    rest = rest.substring('required '.length).trim();
  }
  if (rest.startsWith('this.')) {
    var n = rest.substring('this.'.length);
    final eq = _topLevelEq(n);
    name = eq >= 0 ? n.substring(0, eq).trim() : n.trim();
    name = name.split(RegExp(r'\s+')).first;
    return {
      'name': name,
      'required': required,
      'isNamed': isNamed,
      'isSuper': false,
      'kind': 'this',
    };
  }
  if (rest.startsWith('super.')) {
    var n = rest.substring('super.'.length);
    final eq = _topLevelEq(n);
    name = eq >= 0 ? n.substring(0, eq).trim() : n.trim();
    name = name.split(RegExp(r'\s+')).first;
    return {
      'name': name,
      'required': required,
      'isNamed': isNamed,
      'isSuper': true,
      'kind': 'super',
    };
  }
  if (rest == 'super') {
    return {'name': 'super', 'required': false, 'isNamed': isNamed, 'isSuper': true, 'kind': 'super'};
  }
  // Typed parameter: `<type> <name>` or `<type> <name> = <default>`.
  // Find top-level '='.
  final eq = _topLevelEq(rest);
  if (eq >= 0) {
    final left = rest.substring(0, eq).trim();
    name = _lastIdentifier(left);
    final type = _typeOf(left, name!);
    return {
      'name': name,
      'required': required,
      'isNamed': isNamed,
      'isSuper': false,
      'kind': 'typed',
      'type': type,
    };
  } else {
    name = _lastIdentifier(rest);
    if (name == null) return null;
    final type = _typeOf(rest, name);
    return {
      'name': name,
      'required': required,
      'isNamed': isNamed,
      'isSuper': false,
      'kind': 'typed',
      'type': type,
    };
  }
}

/// Extracts the type expression before the parameter [name].
String _typeOf(String left, String name) {
  final idx = left.lastIndexOf(name);
  if (idx < 0) return '';
  return left.substring(0, idx).trim();
}

int _topLevelEq(String s) {
  var depth = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '(' || c == '[' || c == '{') depth++;
    if (c == ')' || c == ']' || c == '}') depth--;
    if (c == '=' && depth == 0) return i;
  }
  return -1;
}

String? _lastIdentifier(String s) {
  final re = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');
  final all = re.allMatches(s).toList();
  if (all.isEmpty) return null;
  return all.last.group(0);
}

List<String> _scanStaticMethods(String body) {
  final names = <String>[];
  final re = RegExp(r'\bstatic\b');
  for (final m in re.allMatches(body)) {
    // From after `static`, the next `(` before any `=`, `;` or `{` marks a
    // method; otherwise (field/getter/constructor call) skip.
    final after = body.substring(m.end);
    var parenIdx = -1;
    var skip = false;
    for (var i = 0; i < after.length; i++) {
      final c = after[i];
      if (c == '=' || c == ';' || c == '{') {
        skip = true;
        break;
      }
      if (c == '(') {
        parenIdx = i;
        break;
      }
    }
    if (skip || parenIdx < 0) continue;
    final before = after.substring(0, parenIdx).trim();
    final idRe = RegExp(r'[A-Za-z_][A-Za-z0-9_]*\s*$');
    final idMatch = idRe.firstMatch(before);
    if (idMatch == null) continue;
    final nm = idMatch.group(0)!.trim();
    if (nm == 'static') continue;
    if (nm.endsWith(')')) continue;
    names.add(nm);
  }
  return names.toSet().toList()..sort();
}
