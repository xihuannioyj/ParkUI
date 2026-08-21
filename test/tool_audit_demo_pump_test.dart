import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:park_ui/src/l10n/park_localizations.dart';
import 'package:park_ui/src/specs/park_base_specs.dart';
import 'package:park_ui/src/specs/park_binding_specs.dart';
import 'package:park_ui/src/specs/park_component_spec.dart';
import 'package:park_ui/src/specs/park_display_specs.dart';
import 'package:park_ui/src/specs/park_display_specs_extra.dart';
import 'package:park_ui/src/specs/park_feedback_specs.dart';
import 'package:park_ui/src/specs/park_feedback_specs_extra.dart';
import 'package:park_ui/src/specs/park_form_specs.dart';
import 'package:park_ui/src/specs/park_gap_specs.dart';
import 'package:park_ui/src/specs/park_input_specs.dart';
import 'package:park_ui/src/specs/park_input_specs_extra.dart';
import 'package:park_ui/src/specs/park_input_specs_group.dart';
import 'package:park_ui/src/specs/park_input_specs_p2.dart';
import 'package:park_ui/src/specs/park_nav_specs.dart';
import 'package:park_ui/src/specs/park_nav_specs_extra.dart';
import 'package:park_ui/src/specs/park_new_component_specs.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

void main() {
  testWidgets('pump every demo builder and record failures', (tester) async {
    final all = <String, ParkComponentSpec>{
      ...parkBaseSpecs,
      ...parkBindingSpecs,
      ...parkDisplaySpecs,
      ...parkDisplaySpecsExtra,
      ...parkFeedbackSpecs,
      ...parkFeedbackSpecsExtra,
      ...parkFormSpecs,
      ...parkGapSpecs,
      ...parkInputSpecs,
      ...parkInputSpecsExtra,
      ...parkInputGroupSpecs,
      ...parkInputSpecsPart2,
      ...parkNavSpecs,
      ...parkNavSpecsExtra,
      ...parkNewComponentSpecs,
    };

    final failures = <Map<String, dynamic>>[];

    Widget wrap(Widget child) {
      return MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        builder: (_, c) => ParkLocalizationsWidget(
          localizations: const ParkLocalizationsZh(),
          child: c!,
        ),
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: child,
            ),
          ),
        ),
      );
    }

    for (final spec in all.values) {
      for (final demo in spec.demos) {
        final errors = <String>[];
        try {
          await tester.pumpWidget(wrap(Container()));
          final ctx = tester.element(find.byType(MaterialApp));
          await tester.pumpWidget(wrap(demo.builder(ctx)));
        } catch (e, st) {
          errors.add('$e\n$st');
        }
        // Drain exceptions the framework recorded during pump/render.
        while (true) {
          final e = tester.takeException();
          if (e == null) break;
          errors.add(e.toString());
        }
        await tester.pump(const Duration(milliseconds: 50));
        while (true) {
          final e = tester.takeException();
          if (e == null) break;
          errors.add(e.toString());
        }
        await tester.pump(const Duration(milliseconds: 50));
        while (true) {
          final e = tester.takeException();
          if (e == null) break;
          errors.add(e.toString());
        }
        if (errors.isNotEmpty) {
          failures.add({
            'component': spec.name,
            'demo': demo.title,
            'error': errors.join('\n---\n'),
          });
        }
        await tester.pumpWidget(Container());
        while (tester.takeException() != null) {}
      }
    }

    final file = File(
      '${Directory.current.path}${Platform.pathSeparator}tool${Platform.pathSeparator}demo_failures.json',
    );
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(failures));
    // ignore: avoid_print
    print('DEMO_PUMP_DONE total=${all.values.fold<int>(0, (s, sp) => s + sp.demos.length)} failures=${failures.length}');
  });
}
