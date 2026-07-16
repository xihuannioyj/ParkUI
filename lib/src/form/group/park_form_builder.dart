import 'park_abstract_control.dart';
import 'park_form_group.dart';
import '../models/form_field_schema.dart';
import '../regex/park_regex_registry.dart';

/// Builds [ParkFormGroup] from [ParkFormSchema] or JSON.
///
/// This is the primary entry point for creating a runtime form group
/// from a declarative schema definition.
///
/// ```dart
/// final group = ParkFormBuilder.fromSchema(schema);
/// // or
/// final group = ParkFormBuilder.fromJson(jsonMap);
/// ```
class ParkFormBuilder {
  /// Build a [ParkFormGroup] from an existing [ParkFormSchema].
  ///
  /// [schema] The form schema defining fields, layout, etc.
  /// [initialData] Optional initial values to override schema defaults.
  static ParkFormGroup fromSchema(
    ParkFormSchema schema, {
    Map<String, dynamic>? initialData,
  }) {
    final Map<String, ParkAbstractControl> controls =
        <String, ParkAbstractControl>{};
    final Map<String, ParkFormField> fields = <String, ParkFormField>{};

    for (final ParkFormFieldSchema fieldSchema in schema.fields) {
      final String key = fieldSchema.fieldName;

      // Create FormControl with validators derived from schema.
      final dynamic initVal =
          initialData?[key] ?? fieldSchema.defaultValue;
      final List<ParkValidatorFunction> validators =
          _buildValidators(fieldSchema);
      final List<ParkAsyncValidatorFunction> asyncValidators =
          _buildAsyncValidators(fieldSchema);

      controls[key] = ParkFormControl(
        initVal,
        validators: validators,
        asyncValidators: asyncValidators,
      );

      // Create runtime field state.
      fields[key] = ParkFormField.fromSchema(fieldSchema);
    }

    return ParkFormGroup(
      schema: schema,
      controls: controls,
      fields: fields,
      layout: schema.layout,
    );
  }

  /// Build a [ParkFormGroup] from a JSON map.
  ///
  /// [json] The JSON object conforming to the ParkFormSchema protocol.
  /// [initialData] Optional initial values to override schema defaults.
  static ParkFormGroup fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? initialData,
  }) {
    return fromSchema(
      ParkFormSchema.fromJson(json),
      initialData: initialData,
    );
  }

  /// Build synchronous validators from field schema properties.
  static List<ParkValidatorFunction> _buildValidators(
    ParkFormFieldSchema schema,
  ) {
    final List<ParkValidatorFunction> validators = <ParkValidatorFunction>[];

    // Required validation.
    if (schema.isRequired) {
      validators.add((dynamic value) {
        if (value == null || (value is String && value.trim().isEmpty)) {
          return ParkFormError(
            'required',
            schema.validatorMessage ?? '${schema.labelName}不能为空',
          );
        }
        return null;
      });
    }

    // fieldLength validation (acts as maxLength shortcut).
    if (schema.fieldLength > 0) {
      validators.add((dynamic value) {
        if (value is String && value.length > schema.fieldLength) {
          return ParkFormError(
            'maxLength',
            '${schema.labelName}长度不能大于${schema.fieldLength}',
          );
        }
        return null;
      });
    }
    // maxLength validation (only when fieldLength is not already covering it).
    else if (schema.maxLength != null && schema.maxLength! > 0) {
      validators.add((dynamic value) {
        if (value is String && value.length > schema.maxLength!) {
          return ParkFormError(
            'maxLength',
            '${schema.labelName}长度不能大于${schema.maxLength}',
          );
        }
        return null;
      });
    }

    // minLength validation.
    if (schema.minLength != null && schema.minLength! > 0) {
      validators.add((dynamic value) {
        if (value is String && value.length < schema.minLength!) {
          return ParkFormError(
            'minLength',
            '${schema.labelName}长度不能小于${schema.minLength}',
          );
        }
        return null;
      });
    }

    // Regex validation: direct expression takes priority over regexTag.
    if (schema.regexExpression != null && schema.regexExpression!.isNotEmpty) {
      final RegExp regex = RegExp(schema.regexExpression!);
      validators.add((dynamic value) {
        if (value is String && value.isNotEmpty) {
          if (!regex.hasMatch(value)) {
            return ParkFormError(
              'pattern',
              schema.validatorMessage ?? '${schema.labelName}格式不正确',
            );
          }
        }
        return null;
      });
    } else if (schema.regexTag != null && schema.regexTag!.isNotEmpty) {
      final String? pattern = ParkRegexRegistry.get(schema.regexTag!);
      if (pattern != null) {
        final RegExp regex = RegExp(pattern);
        validators.add((dynamic value) {
          if (value is String && value.isNotEmpty) {
            if (!regex.hasMatch(value)) {
              return ParkFormError(
                'pattern',
                schema.validatorMessage ?? '${schema.labelName}格式不正确',
              );
            }
          }
          return null;
        });
      }
    }

    return validators;
  }

  /// Global registry of async validators keyed by [ParkFormFieldSchema.asyncValidatorKey].
  ///
  /// Register validators via [registerAsyncValidator] before building forms
  /// that reference them by key.
  static final Map<String, ParkAsyncValidatorFunction> _asyncValidatorRegistry =
      <String, ParkAsyncValidatorFunction>{};

  /// Register an async validator function under the given [key].
  ///
  /// Once registered, any field schema with `asyncValidatorKey == key`
  /// will automatically pick up this validator during form building.
  static void registerAsyncValidator(
    String key,
    ParkAsyncValidatorFunction validator,
  ) {
    _asyncValidatorRegistry[key] = validator;
  }

  /// Build async validators from field schema.
  ///
  /// Looks up [ParkFormFieldSchema.asyncValidatorKey] in the global
  /// [_asyncValidatorRegistry]. Returns an empty list when no key is set
  /// or the key has not been registered.
  static List<ParkAsyncValidatorFunction> _buildAsyncValidators(
    ParkFormFieldSchema schema,
  ) {
    if (schema.asyncValidatorKey != null &&
        _asyncValidatorRegistry.containsKey(schema.asyncValidatorKey)) {
      return <ParkAsyncValidatorFunction>[
        _asyncValidatorRegistry[schema.asyncValidatorKey]!,
      ];
    }
    return <ParkAsyncValidatorFunction>[];
  }
}
