import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

void main() {
  group('ParkThemeData', () {
    test('light() creates non-null theme', () {
      final theme = ParkThemeData.light();
      expect(theme, isNotNull);
      expect(theme.colors.brand, isNotNull);
      expect(theme.spacing.base, greaterThan(0));
    });

    test('dark() creates non-null theme', () {
      final theme = ParkThemeData.dark();
      expect(theme, isNotNull);
      expect(theme.colors.brand, isNotNull);
      expect(theme.shadows, isNotNull);
    });

    test('light and dark have different surface colors', () {
      final light = ParkThemeData.light();
      final dark = ParkThemeData.dark();
      expect(light.colors.surface, isNot(equals(dark.colors.surface)));
    });

    test('copyWith overrides specific fields', () {
      final base = ParkThemeData.light();
      final modified = base.copyWith(
        surfaceStyle: ParkSurfaceStyle.flat,
      );
      expect(modified.surfaceStyle, ParkSurfaceStyle.flat);
      // Other fields unchanged
      expect(modified.colors.brand, equals(base.colors.brand));
      expect(modified.spacing.base, equals(base.spacing.base));
    });

    test('copyWith preserves all fields when no args', () {
      final base = ParkThemeData.light();
      final copy = base.copyWith();
      expect(copy, equals(base));
    });

    test('lerp at t=0 returns start theme', () {
      final a = ParkThemeData.light();
      final b = ParkThemeData.dark();
      final result = a.lerp(b, 0.0);
      expect(result.colors.surface, equals(a.colors.surface));
    });

    test('lerp at t=1 returns end theme', () {
      final a = ParkThemeData.light();
      final b = ParkThemeData.dark();
      final result = a.lerp(b, 1.0);
      expect(result.colors.surface, equals(b.colors.surface));
    });

    test('lerp at t=0.5 interpolates colors', () {
      final a = ParkThemeData.light();
      final b = ParkThemeData.dark();
      final result = a.lerp(b, 0.5);
      // Surface color should be between light and dark
      expect(result.colors.surface, isNot(equals(a.colors.surface)));
      expect(result.colors.surface, isNot(equals(b.colors.surface)));
    });

    test('lerp surfaceStyle switches at midpoint', () {
      final a = ParkThemeData.light().copyWith(surfaceStyle: ParkSurfaceStyle.stripe);
      final b = ParkThemeData.light().copyWith(surfaceStyle: ParkSurfaceStyle.flat);
      final before = a.lerp(b, 0.3);
      final after = a.lerp(b, 0.7);
      expect(before.surfaceStyle, ParkSurfaceStyle.stripe);
      expect(after.surfaceStyle, ParkSurfaceStyle.flat);
    });

    test('equality works correctly', () {
      final a = ParkThemeData.light();
      final b = ParkThemeData.light();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality on different values', () {
      final a = ParkThemeData.light();
      final b = ParkThemeData.dark();
      expect(a, isNot(equals(b)));
    });
  });

  group('ParkSurfaceStyle', () {
    test('has 5 values', () {
      expect(ParkSurfaceStyle.values.length, 5);
    });
  });
}
