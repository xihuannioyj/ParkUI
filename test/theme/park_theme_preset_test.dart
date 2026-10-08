/// 主题预设（`ParkThemePreset`，7 值）与渐变令牌（`ParkGradient` /
/// `ParkGradients`）的测试，含 `_lerpColors` 漏项的回归锁定。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  group('ParkThemePreset · 7 值全部可构造', () {
    test('枚举恰为 7 个值且含新增的 aurora / candy', () {
      expect(ParkThemePreset.values.length, equals(7));
      expect(ParkThemePreset.values, contains(ParkThemePreset.aurora));
      expect(ParkThemePreset.values, contains(ParkThemePreset.candy));
    });

    test('parkThemePresets 列表覆盖全部 7 个值且以 stripe 开头', () {
      expect(parkThemePresets.length, equals(ParkThemePreset.values.length));
      expect(parkThemePresets.first, equals(ParkThemePreset.stripe));
      for (final ParkThemePreset p in ParkThemePreset.values) {
        expect(parkThemePresets, contains(p));
      }
    });

    test('每个预设在明/暗两套下都能构建且不抛异常', () {
      for (final ParkThemePreset preset in ParkThemePreset.values) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = ParkThemeData.preset(preset, brightness: b);

          expect(park.surfaceStyle, equals(preset.surfaceStyle));
          expect(park.radius, equals(preset.radius));
          expect(park.shadows, equals(preset.shadowsFor(b)));
          expect(park.blur, equals(preset.blur));
          expect(park.gradients.brand.colors, isNotEmpty);
          expect(park.colors.brand.a, equals(1.0), reason: '预设不得污染品牌色');
        }
      }
    });

    test('每个预想的 label / description 非空且互不重复', () {
      final Set<String> labels = <String>{};
      final Set<String> descs = <String>{};
      for (final ParkThemePreset p in ParkThemePreset.values) {
        expect(p.label, isNotEmpty);
        expect(p.description, isNotEmpty);
        labels.add(p.label);
        descs.add(p.description);
      }
      expect(labels.length, equals(ParkThemePreset.values.length));
      expect(descs.length, equals(ParkThemePreset.values.length));
    });

    test('findParkThemePreset 按名称查找，未知名称回退 stripe', () {
      expect(
        findParkThemePreset('aurora'),
        equals(ParkThemePreset.aurora),
      );
      expect(
        findParkThemePreset('candy'),
        equals(ParkThemePreset.candy),
      );
      expect(
        findParkThemePreset('不存在的风格'),
        equals(ParkThemePreset.stripe),
      );
    });

    test('neon / aurora 倾向深色，其余不倾向', () {
      expect(ParkThemePreset.neon.prefersDark, isTrue);
      expect(ParkThemePreset.aurora.prefersDark, isTrue);
      expect(ParkThemePreset.stripe.prefersDark, isFalse);
      expect(ParkThemePreset.flat.prefersDark, isFalse);
      expect(ParkThemePreset.glass.prefersDark, isFalse);
      expect(ParkThemePreset.neo.prefersDark, isFalse);
      expect(ParkThemePreset.candy.prefersDark, isFalse);
    });

    test('preset 可叠加在已有主题上并保留品牌色', () {
      final ParkThemeData branded = ParkThemeData.light().copyWith(
        colors: ParkColors.light().copyWith(brand: const Color(0xFF00AA00)),
      );
      final ParkThemeData themed = ParkThemeData.preset(
        ParkThemePreset.candy,
        base: branded,
      );

      expect(themed.colors.brand, equals(const Color(0xFF00AA00)));
      expect(themed.surfaceStyle, equals(ParkSurfaceStyle.flat));
    });

    test('backgroundDecoration 仅 glass / aurora / neon 非空', () {
      for (final ParkThemePreset p in ParkThemePreset.values) {
        final BoxDecoration? d = p.backgroundDecoration(
          ParkThemeData.preset(p),
        );
        final bool expectNull = p == ParkThemePreset.stripe ||
            p == ParkThemePreset.flat ||
            p == ParkThemePreset.neo ||
            p == ParkThemePreset.candy;
        if (expectNull) {
          expect(d, isNull, reason: '$p 不应有渐变背景');
        } else {
          expect(d, isNotNull, reason: '$p 应有渐变背景');
          expect(d!.gradient, isNotNull);
        }
      }
    });

    test('aurora / candy 确实覆盖了渐变令牌（否则预设无辨识度）', () {
      final ParkThemeData base = ParkThemeData.light();
      final ParkThemeData aurora = ParkThemeData.preset(ParkThemePreset.aurora);
      final ParkThemeData candy = ParkThemeData.preset(ParkThemePreset.candy);

      expect(aurora.gradients, isNot(equals(base.gradients)));
      expect(candy.gradients, isNot(equals(base.gradients)));
      expect(candy.gradients.brand.colors.first, equals(base.colors.warning));
    });

    test('stripe / flat / neo / neon 不覆盖渐变（保持零回归）', () {
      final ParkThemeData base = ParkThemeData.light();
      for (final ParkThemePreset p in <ParkThemePreset>[
        ParkThemePreset.stripe,
        ParkThemePreset.flat,
        ParkThemePreset.neo,
        ParkThemePreset.neon,
        ParkThemePreset.glass,
      ]) {
        expect(
          ParkThemeData.preset(p).gradients,
          equals(base.gradients),
          reason: '$p 不应改动渐变令牌',
        );
      }
    });
  });

  group('ParkGradient 值类型与 lerp', () {
    const ParkGradient a = ParkGradient.linear(
      colors: <Color>[Color(0xFF000000), Color(0xFFFFFFFF)],
    );
    const ParkGradient b = ParkGradient.linear(
      colors: <Color>[Color(0xFFFF0000), Color(0xFF0000FF)],
      begin: Alignment.center,
    );

    test('copyWith / == / hashCode 四件套自洽', () {
      expect(a.copyWith(), equals(a));
      expect(a.copyWith().hashCode, equals(a.hashCode));
      expect(a.copyWith(begin: Alignment.bottomRight), isNot(equals(a)));
    });

    test('lerp t=0 返回 a，t=1 返回 b', () {
      expect(ParkGradient.lerp(a, b, 0), equals(a));
      expect(ParkGradient.lerp(a, b, 1), equals(b));
    });

    test('lerp t=0.5 逐色插值到中点', () {
      final ParkGradient mid = ParkGradient.lerp(a, b, 0.5);
      expect(
        mid.colors[0],
        equals(Color.lerp(const Color(0xFF000000), const Color(0xFFFF0000), 0.5)),
      );
      expect(
        mid.colors[1],
        equals(Color.lerp(const Color(0xFFFFFFFF), const Color(0xFF0000FF), 0.5)),
      );
    });

    test('lerp 长度不等时按中点切换', () {
      const ParkGradient one = ParkGradient.linear(
        colors: <Color>[Color(0xFF000000)],
      );
      final ParkGradient lo = ParkGradient.lerp(a, one, 0.4);
      final ParkGradient hi = ParkGradient.lerp(a, one, 0.6);

      expect(lo.colors.length, equals(2));
      expect(hi.colors.length, equals(1));
    });

    test('lerp 保留 stops 长度一致性（避免长度不匹配导致断言失败）', () {
      const ParkGradient withStops = ParkGradient.linear(
        colors: <Color>[Color(0xFF000000), Color(0xFFFFFFFF)],
        stops: <double>[0.0, 1.0],
      );
      final ParkGradient mid = ParkGradient.lerp(a, withStops, 0.5);

      // a.stops 为 null，withStops.stops 有 2 项 → 按中点切到 withStops
      expect(mid.stops, equals(<double>[0.0, 1.0]));
      expect(mid.stops!.length, equals(mid.colors.length));

      final ParkGradient bothStops = ParkGradient.lerp(withStops, withStops, 0.5);
      expect(bothStops.stops, equals(<double>[0.0, 1.0]));
    });

    test('lerp 离散字段按中点切换', () {
      final ParkGradient lo = ParkGradient.lerp(a, b, 0.4);
      final ParkGradient hi = ParkGradient.lerp(a, b, 0.6);

      expect(lo.begin, equals(a.begin));
      expect(hi.begin, equals(b.begin));
    });

    test('asFlutter 按 type 正确分派', () {
      expect(a.asFlutter, isA<LinearGradient>());
      expect(
        const ParkGradient.radial(colors: <Color>[Color(0xFF000000)]).asFlutter,
        isA<RadialGradient>(),
      );
      expect(
        const ParkGradient.sweep(colors: <Color>[Color(0xFF000000)]).asFlutter,
        isA<SweepGradient>(),
      );
    });

    test('createShader 返回有效 Shader', () {
      expect(
        a.createShader(const Rect.fromLTWH(0, 0, 10, 10)),
        isA<Shader>(),
      );
    });
  });

  group('ParkGradients 令牌组', () {
    test('fromColors 派生 6 条语义渐变且全部非空', () {
      final ParkGradients g = ParkGradients.fromColors(ParkColors.light());

      for (final ParkGradient grad in <ParkGradient>[
        g.brand,
        g.accent,
        g.neonGlow,
        g.aurora,
        g.glassSheen,
        g.sweep,
      ]) {
        expect(grad.colors.length, greaterThanOrEqualTo(2));
      }
      expect(g.sweep.type, equals(ParkGradientType.sweep));
    });

    test('brand 渐变端点取自 ParkColors（无硬编码色值）', () {
      final ParkColors c = ParkColors.light();
      final ParkGradients g = ParkGradients.fromColors(c);

      expect(g.brand.colors.first, equals(c.brand));
      expect(g.brand.colors.last, equals(c.brandAt(7)));
    });

    test('ParkThemeData.gradients 未显式指定时从 colors 自动派生', () {
      final ParkThemeData a = ParkThemeData.light();
      final ParkThemeData b = ParkThemeData.light().copyWith(
        colors: ParkColors.light().copyWith(brand: const Color(0xFF00AA00)),
      );

      // 品牌色变了，渐变应自动跟随，无需每个构造点手动传 gradients。
      expect(
        b.gradients.brand.colors.first,
        equals(const Color(0xFF00AA00)),
      );
      expect(a.gradients.brand.colors.first, isNot(equals(const Color(0xFF00AA00))));
    });

    test('lerp / copyWith / == / hashCode 自洽', () {
      final ParkGradients x = ParkGradients.fromColors(ParkColors.light());
      final ParkGradients y = ParkGradients.fromColors(ParkColors.dark());

      expect(ParkGradients.lerp(x, y, 0), equals(x));
      expect(ParkGradients.lerp(x, y, 1), equals(y));
      expect(x.copyWith(), equals(x));
      expect(x.copyWith().hashCode, equals(x.hashCode));
      expect(x.hashCode, equals(ParkGradients.fromColors(ParkColors.light()).hashCode));
    });
  });

  group('ParkThemeData.gradients 已接入 copyWith / lerp / == / hashCode', () {
    test('仅 gradients 不同 → == 必须为 false（否则主题不重建）', () {
      final ParkThemeData a = ParkThemeData.light();
      final ParkThemeData b = a.copyWith(
        gradients: ParkGradients.fromColors(ParkColors.dark()),
      );

      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });

    test('lerp 后 gradients 被正确插值而非重置', () {
      final ParkThemeData light = ParkThemeData.light();
      final ParkThemeData dark = ParkThemeData.dark();
      final ParkThemeData mid = light.lerp(dark, 0.5);

      expect(mid.gradients, isNot(equals(light.gradients)));
      expect(mid.gradients, isNot(equals(dark.gradients)));
    });

    test('surfaceStyle 在 lerp 中按中点硬跳变（材质无中间态）', () {
      final ParkThemeData stripe = ParkThemeData.light();
      final ParkThemeData glass = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.glass,
      );

      expect(stripe.lerp(glass, 0.4).surfaceStyle, ParkSurfaceStyle.stripe);
      expect(stripe.lerp(glass, 0.6).surfaceStyle, ParkSurfaceStyle.glass);
    });
  });

  group('ParkColors 漏项修复回归锁定', () {
    test('_lerpColors 现在会插值 inverseSurface / onInverseSurface', () {
      final ParkThemeData light = ParkThemeData.light();
      final ParkThemeData dark = ParkThemeData.dark();
      final ParkThemeData mid = light.lerp(dark, 0.5);

      // 修复前这两个字段会被重置为 const 默认值（浅色板的值），
      // 导致暗色主题过渡时 Toast 反色胶囊跳变。
      expect(
        mid.colors.inverseSurface,
        equals(
          Color.lerp(light.colors.inverseSurface, dark.colors.inverseSurface, 0.5),
        ),
      );
      expect(
        mid.colors.onInverseSurface,
        equals(
          Color.lerp(
            light.colors.onInverseSurface,
            dark.colors.onInverseSurface,
            0.5,
          ),
        ),
      );
      // 端点也必须正确
      expect(light.lerp(dark, 0).colors.inverseSurface, equals(light.colors.inverseSurface));
      expect(light.lerp(dark, 1).colors.inverseSurface, equals(dark.colors.inverseSurface));
    });

    test('copyWith 能覆盖 inverseSurface / onInverseSurface', () {
      final ParkColors base = ParkColors.light();
      final ParkColors next = base.copyWith(
        inverseSurface: const Color(0xFF111111),
        onInverseSurface: const Color(0xFF222222),
      );

      expect(next.inverseSurface, equals(const Color(0xFF111111)));
      expect(next.onInverseSurface, equals(const Color(0xFF222222)));
      expect(base.inverseSurface, isNot(equals(const Color(0xFF111111))));
    });

    test('仅 inverseSurface 不同 → == 必须为 false（修复前漏判相等）', () {
      final ParkColors a = ParkColors.light();
      final ParkColors b = a.copyWith(inverseSurface: const Color(0xFF111111));
      final ParkColors c = a.copyWith(onInverseSurface: const Color(0xFF222222));

      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
      expect(a.hashCode, isNot(equals(c.hashCode)));
    });

    test('light / dark 两个色板本身仍不相等', () {
      expect(ParkColors.light(), isNot(equals(ParkColors.dark())));
      expect(ParkThemeData.light(), isNot(equals(ParkThemeData.dark())));
    });
  });
}
