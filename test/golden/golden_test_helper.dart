/// Golden test helper — wraps widgets with ParkConfigProvider + MaterialApp
/// for consistent theming across all golden tests.

import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

/// Wraps [child] with the standard Park UI theme for golden tests.
///
/// Uses [ParkConfigProvider] + [MaterialApp] + [Scaffold] to ensure
/// all theme-dependent widgets render consistently.
Widget goldenWrap(Widget child, {ParkThemeData? theme}) {
  final ParkThemeData effectiveTheme = theme ?? ParkThemeData.light();
  return ParkConfigProvider(
    theme: effectiveTheme,
    child: MaterialApp(
      theme: ThemeData(extensions: [effectiveTheme]),
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

/// Wraps [child] with a fixed-size container for deterministic golden rendering.
Widget goldenWrapSized(Widget child, {double width = 400, double height = 300, ParkThemeData? theme}) {
  final ParkThemeData effectiveTheme = theme ?? ParkThemeData.light();
  return ParkConfigProvider(
    theme: effectiveTheme,
    child: MaterialApp(
      theme: ThemeData(extensions: [effectiveTheme]),
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: Center(child: child),
        ),
      ),
    ),
  );
}

/// Wraps [child] in a column layout for rendering multiple variants
/// vertically in a single golden file.
Widget goldenWrapColumn(List<Widget> children, {ParkThemeData? theme}) {
  final ParkThemeData effectiveTheme = theme ?? ParkThemeData.light();
  return ParkConfigProvider(
    theme: effectiveTheme,
    child: MaterialApp(
      theme: ThemeData(extensions: [effectiveTheme]),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ),
    ),
  );
}
