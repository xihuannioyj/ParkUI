import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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

void main() {
  test('dump all specs to tool/specs_dump.json', () {
    final Map<String, Map<String, ParkComponentSpec>> sources = {
      'park_base_specs': parkBaseSpecs,
      'park_binding_specs': parkBindingSpecs,
      'park_display_specs': parkDisplaySpecs,
      'park_display_specs_extra': parkDisplaySpecsExtra,
      'park_feedback_specs': parkFeedbackSpecs,
      'park_feedback_specs_extra': parkFeedbackSpecsExtra,
      'park_form_specs': parkFormSpecs,
      'park_gap_specs': parkGapSpecs,
      'park_input_specs': parkInputSpecs,
      'park_input_specs_extra': parkInputSpecsExtra,
      'park_input_specs_group': parkInputGroupSpecs,
      'park_input_specs_p2': parkInputSpecsPart2,
      'park_nav_specs': parkNavSpecs,
      'park_nav_specs_extra': parkNavSpecsExtra,
      'park_new_component_specs': parkNewComponentSpecs,
    };

    final Map<String, dynamic> out = {};
    for (final entry in sources.entries) {
      for (final spec in entry.value.values) {
        out[spec.name] = {
          'source': entry.key,
          'name': spec.name,
          'title': spec.title,
          'category': spec.category,
          'description': spec.description,
          'demos': spec.demos
              .map((d) => {
                    'title': d.title,
                    'description': d.description,
                    'code': d.code,
                  })
              .toList(),
          'basicUsageCode': spec.basicUsageCode,
          'properties': spec.properties
              .map((p) => {
                    'name': p.name,
                    'type': p.type,
                    'defaultVal': p.defaultVal,
                    'required': p.required,
                    'description': p.description,
                  })
              .toList(),
          'events': spec.events
              .map((e) => {
                    'name': e.name,
                    'signature': e.signature,
                    'description': e.description,
                  })
              .toList(),
          'methods': spec.methods
              .map((m) => {
                    'name': m.name,
                    'signature': m.signature,
                    'description': m.description,
                  })
              .toList(),
          'guide': spec.guide,
          'schemaDoc': spec.schemaDoc,
          'dynamicFormSchemaDoc': spec.dynamicFormSchemaDoc,
          'relatedComponents': spec.relatedComponents,
        };
      }
    }

    final file = File(
      '${Directory.current.path}${Platform.pathSeparator}tool${Platform.pathSeparator}specs_dump.json',
    );
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(out),
    );
    // ignore: avoid_print
    print('DUMP_OK total=${out.length} file=${file.path}');
  });
}
