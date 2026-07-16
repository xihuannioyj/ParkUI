import 'dart:async';

import 'package:flutter/material.dart';

import '../group/park_abstract_control.dart';

/// Widget that renders a dynamic list of form groups from a [ParkFormArray].
///
/// Supports add/remove with automatic UI updates. Listens to
/// [ParkFormArray.valueChanges] to rebuild when items are added or removed.
///
/// ```dart
/// ParkFormArrayWidget<ParkFormGroupControl>(
///   array: myFormArray,
///   itemBuilder: (context, item, index) {
///     return Text('Item $index: ${item.value}');
///   },
/// )
/// ```
class ParkFormArrayWidget extends StatefulWidget {
  /// The [ParkFormArray] that drives this widget's list of items.
  final ParkFormArray array;

  /// Builder for each item in the array.
  ///
  /// Receives the [BuildContext], the [ParkFormGroupControl] at [index],
  /// and the current [index].
  final Widget Function(
    BuildContext context,
    ParkFormGroupControl item,
    int index,
  ) itemBuilder;

  /// Optional custom widget for the "add" button label.
  ///
  /// When null, a default [Text] with '+ Add' is used.
  final Widget? addButtonText;

  /// Custom add handler.
  ///
  /// If null, a default empty [ParkFormGroupControl] is appended.
  final VoidCallback? onAdd;

  /// Predicate to determine whether the item at [index] can be removed.
  ///
  /// When null, all items show a remove button.
  final bool Function(int index)? canRemove;

  /// Create a [ParkFormArrayWidget].
  const ParkFormArrayWidget({
    super.key,
    required this.array,
    required this.itemBuilder,
    this.addButtonText,
    this.onAdd,
    this.canRemove,
  });

  @override
  State<ParkFormArrayWidget> createState() => _ParkFormArrayWidgetState();
}

class _ParkFormArrayWidgetState extends State<ParkFormArrayWidget> {
  StreamSubscription<dynamic>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.array.valueChanges.listen((dynamic _) {
      if (mounted) {
        setState(() {});
      }
    }, onError: (dynamic e) => debugPrint('Stream error: $e'));
  }

  @override
  void didUpdateWidget(ParkFormArrayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.array != widget.array) {
      _subscription?.cancel();
      _subscription = widget.array.valueChanges.listen((dynamic _) {
        if (mounted) {
          setState(() {});
        }
      }, onError: (dynamic e) => debugPrint('Stream error: $e'));
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleAdd() {
    if (widget.onAdd != null) {
      widget.onAdd!();
    } else {
      widget.array.add(ParkFormGroupControl(<String, ParkAbstractControl>{}));
    }
  }

  void _handleRemove(int index) {
    widget.array.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = widget.array.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: itemCount,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final ParkFormGroupControl item = widget.array.at(index);
              final bool canRemove =
                  widget.canRemove?.call(index) ?? true;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: widget.itemBuilder(context, item, index),
                    ),
                    if (canRemove)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        tooltip: 'Remove',
                        onPressed: () => _handleRemove(index),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: widget.addButtonText ?? const Text('Add'),
          onPressed: _handleAdd,
        ),
      ],
    );
  }
}
