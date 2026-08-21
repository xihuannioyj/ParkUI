// Audit comparison: joins tool/specs_dump.json with tool/components_dump.json
// and prints, per spec, missing constructor params / events / methods and
// doc-completeness flags. Run: dart run tool/audit_compare.dart

import 'dart:convert';
import 'dart:io';

void main() {
  final specs = jsonDecode(File('tool/specs_dump.json').readAsStringSync())
      as Map<String, dynamic>;
  final comps = jsonDecode(File('tool/components_dump.json').readAsStringSync())
      as Map<String, dynamic>;

  final classByName = <String, List<Map<String, dynamic>>>{};
  comps.forEach((key, val) {
    final m = val as Map<String, dynamic>;
    final name = m['name'] as String;
    classByName.putIfAbsent(name, () => []).add(m);
  });

  final rows = <Map<String, dynamic>>[];

  specs.forEach((specName, specRaw) {
    final spec = specRaw as Map<String, dynamic>;
    final classes = classByName[specName] ?? <Map<String, dynamic>>[];

    // Union of constructor params across matching classes.
    final ctorParams = <String, Map<String, dynamic>>{};
    for (final c in classes) {
      for (final p in (c['params'] as List<dynamic>)) {
        final pm = p as Map<String, dynamic>;
        final n = pm['name'] as String;
        ctorParams.putIfAbsent(n, () => pm);
      }
    }
    final staticMethods = <String>{};
    for (final c in classes) {
      staticMethods.addAll((c['staticMethods'] as List<dynamic>).cast<String>());
    }

    final propNames = (spec['properties'] as List<dynamic>)
        .map((p) => (p as Map<String, dynamic>)['name'] as String)
        .toSet();
    final eventNames = (spec['events'] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .toSet();
    final methodNames = (spec['methods'] as List<dynamic>)
        .map((m) => (m as Map<String, dynamic>)['name'] as String)
        .toSet();

    // Missing params: public named params not registered anywhere
    // (properties, events, or methods).
    final documentedNames = {...propNames, ...eventNames, ...methodNames};
    final missingParams = <String>[];
    final missingKey = <String>[];
    for (final entry in ctorParams.entries) {
      final n = entry.key;
      final p = entry.value;
      if (p['isSuper'] == true) continue;
      if (n == 'super') continue;
      if (!documentedNames.contains(n)) {
        if (n == 'key') {
          missingKey.add(n);
        } else {
          missingParams.add(n);
        }
      }
    }
    missingParams.sort();
    missingKey.sort();

    // Missing events: callback params (on* or Function-typed) not registered.
    final missingEvents = <String>[];
    for (final entry in ctorParams.entries) {
      final n = entry.key;
      final p = entry.value;
      if (p['isSuper'] == true) continue;
      final type = (p['type'] as String?) ?? '';
      final onPrefix = n.length > 2 &&
          n.startsWith('on') &&
          RegExp(r'[A-Z]').hasMatch(n[2]);
      final isCallback = onPrefix ||
          (type.isNotEmpty &&
              (type.contains('Function') ||
                  type.contains('Callback') ||
                  type.contains('Builder') ||
                  type.contains('Validator')));
      if (!isCallback) continue;
      if (documentedNames.contains(n)) continue;
      missingEvents.add(n);
    }
    missingEvents.sort();

    // Missing methods: public static methods not registered.
    final missingMethods = <String>[];
    for (final sm in staticMethods) {
      if (sm.startsWith('_')) continue;
      if (!methodNames.contains(sm)) missingMethods.add(sm);
    }
    missingMethods.sort();

    final demos = spec['demos'] as List<dynamic>;
    final demoCount = demos.length;
    final demoText = demos.map((d) {
      final m = d as Map<String, dynamic>;
      return '${m['title']} ${m['description']}';
    }).join(' ');

    final basicUsage = (spec['basicUsageCode'] as String).trim();
    final guide = (spec['guide'] as String).trim();
    final schemaDoc = (spec['schemaDoc'] as String).trim();
    final dynDoc = (spec['dynamicFormSchemaDoc'] as String).trim();

    rows.add({
      'name': specName,
      'title': spec['title'],
      'source': spec['source'],
      'demoCount': demoCount,
      'demos': demos.map((d) => (d as Map<String, dynamic>)['title']).toList(),
      'demoText': demoText,
      'missingParams': missingParams,
      'missingKeyOnly': missingKey,
      'missingEvents': missingEvents,
      'missingMethods': missingMethods,
      'basicUsageEmpty': basicUsage.isEmpty,
      'basicUsageLen': basicUsage.length,
      'guideEmpty': guide.isEmpty,
      'guideLen': guide.length,
      'schemaDocEmpty': schemaDoc.isEmpty,
      'schemaDocLen': schemaDoc.length,
      'dynDocEmpty': dynDoc.isEmpty,
      'componentClasses': classes.map((c) => c['name']).toList(),
      'staticMethods': staticMethods.toList()..sort(),
      'registeredProperties': propNames.toList()..sort(),
      'registeredEvents': eventNames.toList()..sort(),
    });
  });

  rows.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  File('tool/audit_report.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(rows),
  );

  // Summary table.
  final sb = StringBuffer();
  sb.writeln('NAME | demos | basicUsage | guide | schemaDoc | dynDoc | missingParams | missingEvents | missingMethods');
  for (final r in rows) {
    final mp = (r['missingParams'] as List).join(',');
    final me = (r['missingEvents'] as List).join(',');
    final mm = (r['missingMethods'] as List).join(',');
    sb.writeln(
        '${r['name']} | ${r['demoCount']} | ${r['basicUsageEmpty'] ? 'EMPTY' : 'ok(${r['basicUsageLen']})'} | '
        '${r['guideEmpty'] ? 'EMPTY' : 'ok(${r['guideLen']})'} | ${r['schemaDocEmpty'] ? 'EMPTY' : 'ok(${r['schemaDocLen']})'} | '
        '${r['dynDocEmpty'] ? '-' : 'ok'} | ${mp.isEmpty ? '-' : mp} | ${me.isEmpty ? '-' : me} | ${mm.isEmpty ? '-' : mm}');
  }
  File('tool/audit_report_table.txt').writeAsStringSync(sb.toString());
  stdout.writeln('REPORT_OK rows=${rows.length}');
  stdout.writeln(sb.toString());
}

String _typeOfParam(Map<String, dynamic> p) {
  // For 'typed' params we didn't store the type; reconstruct from kind is not
  // possible. Instead we rely on name heuristics for callbacks. To capture
  // builder/validator-style callbacks, extend heuristic in caller.
  return '';
}
