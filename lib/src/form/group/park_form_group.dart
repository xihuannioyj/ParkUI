import 'dart:async';

import 'park_abstract_control.dart';
import '../models/form_field_schema.dart';
import '../models/form_layout_schema.dart';

/// Runtime mutable field state.
///
/// Created from [ParkFormFieldSchema] via [ParkFormField.fromSchema],
/// then freely modifiable at runtime (hide, disable, change options, etc.).
class ParkFormField {
  /// Unique field key (maps to [ParkFormFieldSchema.fieldName]).
  final String fieldKey;

  // ── Mutable runtime properties ──

  /// Whether the field is currently hidden.
  bool hidden;

  /// Whether the field is currently required.
  bool required;

  /// Whether the field is currently read-only.
  bool readonly;

  /// Whether the field is currently disabled.
  bool disabled;

  /// Current field type (can be changed at runtime).
  String fieldType;

  /// Current field control subtype.
  String? fieldControl;

  /// Current label text.
  String? label;

  /// Current placeholder text.
  String? placeholder;

  /// Current options list (for select / radio / checkbox etc.).
  List<Map<String, dynamic>>? options;

  /// Whether the field is in a loading state (e.g. fetching options).
  bool loading;

  /// Layout span (12-grid system).
  int span;

  /// Extension data for business-specific properties.
  Map<String, dynamic> ext;

  /// Reference to the original schema (read-only).
  final ParkFormFieldSchema schema;

  /// Create a runtime field state.
  ParkFormField({
    required this.fieldKey,
    required this.fieldType,
    required this.schema,
    this.hidden = false,
    this.required = false,
    this.readonly = false,
    this.disabled = false,
    this.fieldControl,
    this.label,
    this.placeholder,
    this.options,
    this.loading = false,
    this.span = 1,
    this.ext = const <String, dynamic>{},
  });

  /// Create from an existing [ParkFormFieldSchema].
  factory ParkFormField.fromSchema(ParkFormFieldSchema schema) {
    return ParkFormField(
      fieldKey: schema.fieldName,
      fieldType: schema.fieldType.name,
      schema: schema,
      hidden: schema.hidden,
      required: schema.isRequired,
      readonly: schema.isReadonly,
      fieldControl: schema.fieldControl,
      label: schema.labelName,
      placeholder: schema.fieldPrompt.isEmpty ? null : schema.fieldPrompt,
      options: schema.options
          .map(
            (Map<String, dynamic> o) => Map<String, dynamic>.from(o),
          )
          .toList(),
      span: schema.span,
      ext: Map<String, dynamic>.from(schema.ext),
    );
  }
}

/// Field change event emitted by [ParkFormGroup].
class ParkFormFieldChangeEvent {
  /// The field key that changed.
  final String fieldKey;

  /// The current value of the field.
  final dynamic value;

  /// The runtime field state.
  final ParkFormField field;

  /// Create a field change event.
  const ParkFormFieldChangeEvent({
    required this.fieldKey,
    this.value,
    required this.field,
  });
}

/// Runtime form group -- the single entry point for form operations at runtime.
///
/// Created via `ParkFormBuilder.fromSchema()` or `ParkFormBuilder.fromJson()`.
/// Provides value access, validation, batch operations, and change notification.
class ParkFormGroup {
  final Map<String, ParkAbstractControl> _controls;

  /// Runtime mutable field states keyed by field name.
  final Map<String, ParkFormField> fields;

  /// Form layout configuration (from schema).
  final ParkFormLayout? layout;

  /// The original form schema (read-only).
  final ParkFormSchema schema;

  // ── Change notification ──

  final StreamController<ParkFormFieldChangeEvent> _changesController =
      StreamController<ParkFormFieldChangeEvent>.broadcast();

  /// Stream of field change events (value or state changes).
  Stream<ParkFormFieldChangeEvent> get changes => _changesController.stream;

  /// Internal constructor used by [ParkFormBuilder].
  ParkFormGroup({
    required this.schema,
    required Map<String, ParkAbstractControl> controls,
    required this.fields,
    this.layout,
  }) : _controls = controls;

  // ═══ Value operations ═══

  /// Get all values (including hidden / disabled / readonly fields).
  Map<String, dynamic> get value => <String, dynamic>{
        for (final MapEntry<String, ParkAbstractControl> e in _controls.entries)
          e.key: e.value.value,
      };

  /// Batch set multiple field values.
  void patchValue(Map<String, dynamic> values) {
    _batchStart();
    for (final MapEntry<String, dynamic> e in values.entries) {
      _controls[e.key]?.setValue(e.value);
    }
    _batchEnd();
  }

  /// Get a control by dot-separated path.
  ParkAbstractControl? get(String path) {
    final List<String> parts = path.split('.');
    ParkAbstractControl? cur = _controls[parts.first];
    for (int i = 1; i < parts.length; i++) {
      if (cur is ParkFormGroupControl) {
        cur = cur.control(parts[i]);
      } else {
        return null;
      }
    }
    return cur;
  }

  // ═══ Validation ═══

  /// Whether all controls pass validation.
  bool get valid => _controls.values.every(
        (ParkAbstractControl c) => c.valid,
      );

  /// Whether any control fails validation.
  bool get invalid => !valid;

  /// Collect errors from all invalid controls.
  Map<String, List<ParkFormError>> get errors {
    return <String, List<ParkFormError>>{
      for (final MapEntry<String, ParkAbstractControl> e in _controls.entries)
        if (!e.value.valid) e.key: e.value.errors,
    };
  }

  /// Run all validators (sync + async) on all controls.
  Future<bool> validate() async {
    final List<bool> results = await Future.wait<bool>(
      _controls.values.map(
        (ParkAbstractControl c) => c.validate(),
      ),
    );
    return results.every((bool r) => r);
  }

  // ═══ Reset ═══

  /// Reset all controls and field states to their schema defaults.
  ///
  /// Optionally provide [defaults] to override initial values.
  void reset([Map<String, dynamic>? defaults]) {
    _batchStart();
    for (final MapEntry<String, ParkAbstractControl> e in _controls.entries) {
      e.value.reset(defaults?[e.key]);
    }
    // Also reset field runtime states to schema defaults.
    for (final ParkFormField field in fields.values) {
      final ParkFormFieldSchema s = field.schema;
      field.hidden = s.hidden;
      field.required = s.isRequired;
      field.readonly = s.isReadonly;
      field.disabled = false;
      field.fieldType = s.fieldType.name;
      field.fieldControl = s.fieldControl;
      field.label = s.labelName;
      field.placeholder = s.fieldPrompt.isEmpty ? null : s.fieldPrompt;
      field.loading = false;
    }
    _batchEnd();
  }

  // ═══ Batch operations ═══

  bool _batching = false;
  final List<ParkFormFieldChangeEvent> _pendingEvents =
      <ParkFormFieldChangeEvent>[];

  /// Execute [fn] in batch mode.
  ///
  /// All change notifications are deferred until [fn] completes,
  /// then emitted as a single batch. This is useful when setting multiple
  /// field values at once and you want listeners to receive a single
  /// consolidated update rather than one event per field.
  ///
  /// ## Sync-only limitation
  ///
  /// **[fn] must be synchronous.** The batch boundary (`_batchStart` /
  /// `_batchEnd`) wraps the call synchronously, so:
  ///
  /// - If [fn] contains `await`, notifications are flushed as soon as
  ///   `_batchEnd()` returns — *before* the awaited work completes.
  /// - Any mutations performed in the async continuation after `await`
  ///   will emit events immediately (outside the batch window).
  ///
  /// For async workflows, either:
  /// 1. Call [patchValue] / [reset] individually, or
  /// 2. Wrap each synchronous segment in its own [batch] call.
  ///
  /// ```dart
  /// // Correct: synchronous batch
  /// formGroup.batch(() {
  ///   formGroup.patchValue({'a': 1, 'b': 2});
  ///   formGroup.notifyFieldStateChanged('a');
  /// });
  ///
  /// // Incorrect: async work inside batch — events flush too early
  /// formGroup.batch(() async {
  ///   formGroup.patchValue({'a': 1});
  ///   await someAsyncOperation(); // notifications already emitted!
  ///   formGroup.patchValue({'b': 2}); // emitted immediately, not batched
  /// });
  /// ```
  void batch(void Function() fn) {
    _batchStart();
    fn();
    _batchEnd();
  }

  void _batchStart() {
    _batching = true;
    _pendingEvents.clear();
  }

  void _batchEnd() {
    _batching = false;
    for (final ParkFormFieldChangeEvent event in _pendingEvents) {
      _changesController.add(event);
    }
    _pendingEvents.clear();
  }

  void _notify(ParkFormFieldChangeEvent event) {
    if (_changesController.isClosed) return;
    if (_batching) {
      _pendingEvents.add(event);
    } else {
      _changesController.add(event);
    }
  }

  /// Notify listeners that a field's runtime state changed
  /// (hidden, required, etc.).
  void notifyFieldStateChanged(String fieldKey) {
    final ParkFormField? field = fields[fieldKey];
    if (field != null) {
      _notify(ParkFormFieldChangeEvent(
        fieldKey: fieldKey,
        value: _controls[fieldKey]?.value,
        field: field,
      ));
    }
  }

  /// Notify listeners that a field's value changed.
  void notifyValueChanged(String fieldKey) {
    final ParkFormField? field = fields[fieldKey];
    if (field != null) {
      _notify(ParkFormFieldChangeEvent(
        fieldKey: fieldKey,
        value: _controls[fieldKey]?.value,
        field: field,
      ));
    }
  }

  // ═══ Public controls accessor ═══

  /// Unmodifiable view of all controls keyed by field name.
  Map<String, ParkAbstractControl> get controls =>
      Map<String, ParkAbstractControl>.unmodifiable(_controls);

  // ═══ Snapshot / Restore ═══

  /// Create a snapshot of current form state (values + field states).
  Map<String, dynamic> snapshot() {
    return <String, dynamic>{
      'values': Map<String, dynamic>.from(value),
      'fields': <String, dynamic>{
        for (final MapEntry<String, ParkFormField> e in fields.entries)
          e.key: <String, dynamic>{
            'hidden': e.value.hidden,
            'required': e.value.required,
            'readonly': e.value.readonly,
            'disabled': e.value.disabled,
          },
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Restore from a previously captured [snapshot].
  void restore(Map<String, dynamic> snapshot) {
    final Map<String, dynamic>? values =
        snapshot['values'] as Map<String, dynamic>?;
    if (values != null) patchValue(values);

    final Map<String, dynamic>? fieldStates =
        snapshot['fields'] as Map<String, dynamic>?;
    if (fieldStates != null) {
      batch(() {
        for (final MapEntry<String, dynamic> e in fieldStates.entries) {
          final ParkFormField? field = fields[e.key];
          final Map<String, dynamic>? state =
              e.value as Map<String, dynamic>?;
          if (field != null && state != null) {
            field.hidden = state['hidden'] as bool? ?? false;
            field.required = state['required'] as bool? ?? false;
            field.readonly = state['readonly'] as bool? ?? false;
            field.disabled = state['disabled'] as bool? ?? false;
          }
        }
      });
    }
  }

  // ═══ Export / Query helpers ═══

  /// Export form values for JSON serialization.
  ///
  /// Converts [DateTime] values to ISO-8601 strings.
  Map<String, dynamic> exportValues() {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<String, dynamic> e in value.entries) {
      final dynamic v = e.value;
      if (v is DateTime) {
        result[e.key] = v.toIso8601String();
      } else {
        result[e.key] = v;
      }
    }
    return result;
  }

  /// Flat map of all errors: fieldKey -> first error message.
  Map<String, String> get flatErrors {
    final Map<String, String> result = <String, String>{};
    for (final MapEntry<String, List<ParkFormError>> e in errors.entries) {
      if (e.value.isNotEmpty) {
        result[e.key] = e.value.first.message;
      }
    }
    return result;
  }

  /// Mark all controls as touched (for showing all errors before submit).
  void markAllAsTouched() {
    for (final ParkAbstractControl c in _controls.values) {
      c.markAsTouched();
    }
  }

  /// Get only visible field values (excludes hidden fields).
  Map<String, dynamic> get visibleValues {
    return <String, dynamic>{
      for (final MapEntry<String, ParkAbstractControl> e in _controls.entries)
        if (fields[e.key]?.hidden != true) e.key: e.value.value,
    };
  }

  // ═══ Cleanup ═══

  /// Release all resources (streams, child controls).
  void dispose() {
    for (final ParkAbstractControl c in _controls.values) {
      c.dispose();
    }
    _changesController.close();
  }
}
