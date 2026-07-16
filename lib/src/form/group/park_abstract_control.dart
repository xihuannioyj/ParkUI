import 'dart:async';

/// Base error class for form validation.
class ParkFormError {
  /// Error key (e.g. 'required', 'maxLength', 'pattern').
  final String key;

  /// Human-readable error message.
  final String message;

  /// Create a form error.
  const ParkFormError(this.key, this.message);

  @override
  String toString() => 'ParkFormError($key: $message)';
}

/// Synchronous validator function type.
///
/// Returns null when the value is valid, or a [ParkFormError] when invalid.
typedef ParkValidatorFunction = ParkFormError? Function(dynamic value);

/// Asynchronous validator function type.
///
/// Returns null when the value is valid, or a [ParkFormError] when invalid.
typedef ParkAsyncValidatorFunction = Future<ParkFormError?> Function(
  dynamic value,
);

/// Change event emitted by form controls.
class ParkFormFieldChange {
  /// The field key that changed.
  final String fieldKey;

  /// The new value.
  final dynamic value;

  /// Whether the field is dirty (user-modified).
  final bool isDirty;

  /// Create a field change event.
  const ParkFormFieldChange({
    required this.fieldKey,
    this.value,
    this.isDirty = false,
  });
}

/// Abstract base class for all form controls.
///
/// Provides value management, validation (sync + async),
/// state tracking (pristine/dirty, touched/untouched, pending),
/// and reactive streams (valueChanges, statusChanges).
abstract class ParkAbstractControl {
  dynamic _value;

  /// Current value of this control.
  dynamic get value => _value;

  final List<ParkValidatorFunction> _validators;
  final List<ParkAsyncValidatorFunction> _asyncValidators;

  List<ParkFormError> _errors = <ParkFormError>[];

  /// Current validation errors (unmodifiable).
  List<ParkFormError> get errors => List<ParkFormError>.unmodifiable(_errors);

  /// Whether this control passes all validators.
  bool get valid => _errors.isEmpty;

  /// Whether this control fails any validator.
  bool get invalid => !valid;

  // ── State tracking ──

  bool _pristine = true;

  /// Whether the user has NOT yet modified the value.
  bool get pristine => _pristine;

  /// Whether the user has modified the value.
  bool get dirty => !_pristine;

  bool _touched = false;

  /// Whether the user has triggered a blur / focus-out.
  bool get touched => _touched;

  /// Whether the user has NOT yet triggered a blur.
  bool get untouched => !_touched;

  bool _pending = false;

  /// Whether an async validation is in progress.
  bool get pending => _pending;

  bool _enabled = true;

  /// Whether this control is enabled.
  bool get enabled => _enabled;

  /// Whether this control is disabled.
  bool get disabled => !_enabled;

  /// Enable this control.
  void enable() {
    _enabled = true;
    _statusController.add(status);
  }

  /// Disable this control.
  void disable() {
    _enabled = false;
    _statusController.add(status);
  }

  // ── Status ──

  /// Computed status string: 'VALID', 'INVALID', or 'PENDING'.
  String get status {
    if (_pending) return 'PENDING';
    if (!valid) return 'INVALID';
    return 'VALID';
  }

  // ── Streams ──

  final StreamController<dynamic> _valueController =
      StreamController<dynamic>.broadcast();

  /// Emits whenever the value changes.
  Stream<dynamic> get valueChanges => _valueController.stream;

  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  /// Emits whenever the status changes.
  Stream<String> get statusChanges => _statusController.stream;

  /// Create a control with an initial value and optional validators.
  ParkAbstractControl(
    dynamic initialValue, {
    List<ParkValidatorFunction>? validators,
    List<ParkAsyncValidatorFunction>? asyncValidators,
  })  : _value = initialValue,
        _validators = validators ?? <ParkValidatorFunction>[],
        _asyncValidators = asyncValidators ?? <ParkAsyncValidatorFunction>[];

  /// Set a new value.
  ///
  /// Marks the control as dirty and touched by default.
  /// Set [markDirty] to false to update the value without marking dirty/touched.
  /// Runs synchronous validation immediately.
  void setValue(
    dynamic v, {
    bool updateParent = true,
    bool emitEvent = true,
    bool markDirty = true,
  }) {
    _value = v;
    if (markDirty) {
      _pristine = false;
      _touched = true;
    }
    if (emitEvent) {
      _valueController.add(v);
    }
    _runValidation();
  }

  /// Reset the control to its initial state.
  ///
  /// Optionally provide a [defaultValue] to reset to.
  void reset([dynamic defaultValue]) {
    _value = defaultValue;
    _errors = <ParkFormError>[];
    _pristine = true;
    _touched = false;
    _pending = false;
    _valueController.add(_value);
    _statusController.add(status);
  }

  /// Mark this control as touched.
  void markAsTouched() {
    _touched = true;
  }

  /// Mark this control as untouched.
  void markAsUntouched() {
    _touched = false;
  }

  /// Mark this control as dirty (user-modified).
  void markAsDirty() {
    _pristine = false;
  }

  /// Mark this control as pristine (unmodified).
  void markAsPristine() {
    _pristine = true;
  }

  /// Run synchronous validators and update errors.
  void _runValidation() {
    _errors = <ParkFormError>[];
    for (final ParkValidatorFunction v in _validators) {
      final ParkFormError? err = v(_value);
      if (err != null) _errors.add(err);
    }
    _statusController.add(status);
  }

  /// Run all validators (sync + async) and return whether the control is valid.
  Future<bool> validate() async {
    _runValidation();
    if (_errors.isNotEmpty) return false;

    if (_asyncValidators.isNotEmpty) {
      _pending = true;
      _statusController.add(status);
      try {
        for (final ParkAsyncValidatorFunction v in _asyncValidators) {
          final ParkFormError? err = await v(_value);
          if (err != null) _errors.add(err);
        }
      } catch (e) {
        _errors.add(ParkFormError('validationException', e.toString()));
      } finally {
        _pending = false;
        _statusController.add(status);
      }
    }

    return valid;
  }

  /// Replace the synchronous validators.
  void setValidators(List<ParkValidatorFunction> validators) {
    _validators.clear();
    _validators.addAll(validators);
    _runValidation();
  }

  /// Replace the asynchronous validators.
  void setAsyncValidators(List<ParkAsyncValidatorFunction> validators) {
    _asyncValidators.clear();
    _asyncValidators.addAll(validators);
  }

  /// Release resources (close streams).
  void dispose() {
    _valueController.close();
    _statusController.close();
  }
}

/// Leaf control -- holds a single scalar value.
class ParkFormControl extends ParkAbstractControl {
  /// The default value used when [reset] is called without arguments.
  final dynamic defaultValue;

  /// Create a leaf form control.
  ParkFormControl(
    super.value, {
    this.defaultValue,
    super.validators,
    super.asyncValidators,
  });

  @override
  void reset([dynamic defaultValue]) {
    super.reset(defaultValue ?? this.defaultValue);
  }
}

/// Group control -- holds named child controls (like a nested form).
class ParkFormGroupControl extends ParkAbstractControl {
  final Map<String, ParkAbstractControl> _controls;

  /// Create a group control from a map of named child controls.
  ParkFormGroupControl(this._controls) : super(null);

  /// Unmodifiable view of child controls.
  Map<String, ParkAbstractControl> get controls =>
      Map<String, ParkAbstractControl>.unmodifiable(_controls);

  /// Get a child control by name.
  ///
  /// Supports dot-separated paths for nested groups
  /// (e.g. `'address.city'`).
  ParkAbstractControl? control(String name) {
    final List<String> parts = name.split('.');
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

  /// Whether a child control with the given [name] exists.
  bool contains(String name) => _controls.containsKey(name);

  /// Add a new child control.
  ///
  /// Automatically subscribes to the child's valueChanges and forwards
  /// emissions to this group's value stream.
  void addControl(String name, ParkAbstractControl control) {
    _controls[name] = control;
    control.valueChanges.listen((dynamic _) {
      if (!_valueController.isClosed) {
        _valueController.add(value);
      }
    });
    _valueController.add(value);
  }

  /// Remove and dispose a child control.
  void removeControl(String name) {
    final ParkAbstractControl? removed = _controls.remove(name);
    removed?.dispose();
    _valueController.add(value);
  }

  @override
  Map<String, dynamic> get value => <String, dynamic>{
        for (final MapEntry<String, ParkAbstractControl> e in _controls.entries)
          e.key: e.value.value,
      };

  /// Raw value including disabled controls.
  Map<String, dynamic> get rawValue => value;

  /// Get values of only enabled (non-disabled) controls.
  Map<String, dynamic> getEnabledValues() {
    return Map<String, dynamic>.fromEntries(
      _controls.entries
          .where((MapEntry<String, ParkAbstractControl> e) => !e.value.disabled)
          .map(
              (MapEntry<String, ParkAbstractControl> e) =>
                  MapEntry<String, dynamic>(e.key, e.value.value),
          ),
    );
  }

  /// Patch multiple child values at once.
  void patchValue(Map<String, dynamic> values) {
    for (final MapEntry<String, dynamic> e in values.entries) {
      _controls[e.key]?.setValue(e.value);
    }
  }

  @override
  bool get valid => _controls.values.every(
        (ParkAbstractControl c) => c.valid,
      );

  @override
  List<ParkFormError> get errors {
    final List<ParkFormError> allErrors = <ParkFormError>[];
    for (final MapEntry<String, ParkAbstractControl> e in _controls.entries) {
      if (!e.value.valid) {
        allErrors.addAll(e.value.errors);
      }
    }
    return allErrors;
  }

  @override
  Future<bool> validate() async {
    final List<bool> results = await Future.wait<bool>(
      _controls.values.map(
        (ParkAbstractControl c) => c.validate(),
      ),
    );
    return results.every((bool r) => r);
  }

  @override
  void reset([dynamic defaultValue]) {
    for (final ParkAbstractControl c in _controls.values) {
      c.reset();
    }
  }

  @override
  void dispose() {
    for (final ParkAbstractControl c in _controls.values) {
      c.dispose();
    }
    super.dispose();
  }
}

/// Array control -- holds an ordered list of group controls.
class ParkFormArray extends ParkAbstractControl {
  final List<ParkFormGroupControl> _items;

  /// The number of items present at construction time.
  ///
  /// Used by [reset] to remove dynamically added items beyond this count.
  final int _initialItemCount;

  /// Create an array control from a list of group controls.
  ParkFormArray(this._items)
      : _initialItemCount = _items.length,
        super(null);

  /// Unmodifiable view of the items.
  List<ParkFormGroupControl> get items =>
      List<ParkFormGroupControl>.unmodifiable(_items);

  @override
  List<Map<String, dynamic>> get value =>
      _items.map((ParkFormGroupControl g) => g.value).toList();

  /// Append a group control.
  void add(ParkFormGroupControl item) {
    _items.add(item);
    _valueController.add(value);
  }

  /// Insert a group control at [index].
  void addAt(int index, ParkFormGroupControl item) {
    _items.insert(index, item);
    _valueController.add(value);
  }

  /// Remove and dispose the group control at [index].
  ///
  /// Silently returns if [index] is out of bounds.
  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index].dispose();
    _items.removeAt(index);
    _valueController.add(value);
  }

  /// Remove and dispose all group controls.
  void clear() {
    for (final ParkFormGroupControl item in _items) {
      item.dispose();
    }
    _items.clear();
    _valueController.add(value);
  }

  /// Get the group control at [index].
  ParkFormGroupControl at(int index) => _items[index];

  /// Number of items.
  int get length => _items.length;

  @override
  bool get valid => _items.every(
        (ParkFormGroupControl c) => c.valid,
      );

  @override
  Future<bool> validate() async {
    final List<bool> results = await Future.wait<bool>(
      _items.map(
        (ParkFormGroupControl c) => c.validate(),
      ),
    );
    return results.every((bool r) => r);
  }

  @override
  void reset([dynamic defaultValue]) {
    // Reset all existing items.
    for (final ParkFormGroupControl item in _items) {
      item.reset();
    }
    // Remove any items that were dynamically added beyond the initial count.
    while (_items.length > _initialItemCount) {
      final ParkFormGroupControl removed = _items.removeLast();
      removed.dispose();
    }
    _valueController.add(value);
  }

  @override
  void dispose() {
    for (final ParkFormGroupControl item in _items) {
      item.dispose();
    }
    super.dispose();
  }
}
