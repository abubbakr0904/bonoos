import 'dart:math';

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //this project specific
  static const primaryGreen = Color(0xff39B981);
  static const primaryGreenLight = Color(0xffEBFFFF);
  static const primaryBlue = Color(0xff1D9DF2);
  static const primaryBlueLight = Color(0xffE8F4FF);
  static const primaryBlueLightest = Color(0xffF0F5F9);
  static const textColorBlack = Color(0xff0A1E56);
  static const textColorDark = Color(0xff4A586C);
  static const scaffoldBackgroundColor = Color(0xffF0F5F9);
  static const red = Color(0xffE53E3E);
  static const redOpacity10 = Color(0x1AE53E3E);
  static const redOpacity20 = Color(0x33E53E3E);
  static const grey100 = Color(0xFFF7F7F7);

  ///
  static const polygonColor = Color(0xFF04CFD9);
  static const scaffoldBackground = Color(0xFFF5F6F8);
  static const primaryOpacity = Color(0xffFFEBD3);
  static const textSecondary = Color(0xFF8C919E);
  static const tertiary = Color(0xFFF3F3F3);
  static const darkCardColor = Color(0xFF242424);
  static const textBrand = Color(0xFF343434);
  static const brandElectric = Color(0xFF04CFD9);
  static const blueAccent = Color(0xFF94DCCA);
  static const textPrimaryDark = Color(0xFFF4F4F4);
  static const textPrimaryLight = Color(0xFFF4F4F4);
  static const c404040 = Color(0xFF404040);
  static const c909090 = Color(0xFF909090);
  static const darkBottomSheetBgColor = Color(0xff151515);

  static const white = Colors.white;
  static const black = Colors.black;
  static const scaffoldDarkBg = Color(0xff151515);
  static const transparent = Colors.transparent;
  static const grey3 = Color(0xFF898E96);
  static const grey600 = Color(0xFF8C919E);
  static const grey5 = Color(0xFF374957);
  static const grey2 = Color(0xFFCCCDCE);
  static const grey200 = Color(0xFFF1F1F1);
  static const grey808080 = Color(0xFF808080);
  static const grey1 = Color(0xFFE7E9EC);
  static const c343434 = Color(0xFF343434);
  static const grey500 = Color(0xFFB7B7B7);
  static const grey400 = Color(0xFFF1F5F7);
  static const gray = Color(0xffA6ADB9);
  static const cEEEE = Color(0xffEEEEEE);
  static const green = Color(0xff2AD43B);
  static const c185935 = Color(0xff185935);
  static const c096A34 = Color(0xff096A34);
  static const orange = Color(0xffFFA600);
  static const shimmerColor = Color(0xffF0F0F0);
  static const hintColor = Color(0xff888888);

  static const c30215A = Color(0xff30215A);
  static const grey4 = Color(0xFF393F48);
  static const dividerColor = Color(0xFFD7D8DD);
  static const secondary = Color(0xFFF1F1F1);
  static const borderSecondary = Color(0xFF8C919E);
  static const secondary2 = Color(0xFFF8F8FA);
  static const cff8989 = Color(0xFFFF8989);
  static const c964A4A = Color(0xFF964A4A);
  static const c065155 = Color(0xFF065155);
  static const c0F1A07 = Color(0xFF0F1A07);
  static const cE4FFCE = Color(0xFFE4FFCE);
  static const cF4F4F4 = Color(0xFFF4F4F4);
  static const c9D9D9D = Color(0xFF9D9D9D);
  static const c475569 = Color(0xFF475569);
  static const cB5B5B5 = Color(0xFFB5B5B5);
  static const cF0F1F2 = Color(0xFFF0F1F2);
  static const borderColor = Color(0xFFE4E6E8);
  static const deepYellow = Color(0xFFE8B200);
  static const secondRed = Color(0xFFE06363);

  //static const red = Color(0xFFFD4D00);
  static const violet = Color(0xFF8F00FF);
  static const x0A1E56 = Color(0xff0A1E56);
  static const x616161 = Color(0xff616161);
  static const xF0F1F2 = Color(0xffF0F1F2);




  static const c55004D = Color(0xff55004D);
  static const c842D5F = Color(0xff842D5F);

  static const _nearBlack = Color(0xFF080410);

  static const _softDark = Color(0xFF12081E);

  /// Asosiy uchlik + yengil oq/qorong‘i aralashma — sezilarli farq, lekin palitra bir xil oilada.
  static Color _varyBrandTone(Color base, Random rnd) {
    final towardLight = rnd.nextDouble() * 0.14;
    final towardDark = rnd.nextDouble() * 0.18;
    final step1 = Color.lerp(base, Colors.white, towardLight)!;
    return Color.lerp(step1, _softDark, towardDark)!;
  }

  /// Faqat `c55004D`, `c842D5F`, `c30215A` asosida — har safar boshqacha ko‘rinadi.
  /// [seed] — har kirishda boshqacha variant.
  static LinearGradient randomBrandScreenGradient([int? seed]) {
    final r = seed != null ? Random(seed) : Random();

    final bases = <Color>[c55004D, c842D5F, c30215A];
    final colors = <Color>[
      _varyBrandTone(bases[r.nextInt(3)], r),
      _varyBrandTone(bases[r.nextInt(3)], r),
      _varyBrandTone(bases[r.nextInt(3)], r),
    ];

    // Ba’zan 4-chi nuqta — gradient yanada boy
    if (r.nextBool()) {
      colors.add(_varyBrandTone(bases[r.nextInt(3)], r));
    }

    final dirs = <(Alignment, Alignment)>[
      (Alignment.topCenter, Alignment.bottomCenter),
      (Alignment.topLeft, Alignment.bottomRight),
      (Alignment.topRight, Alignment.bottomLeft),
      (const Alignment(-0.85, -1.0), const Alignment(0.85, 1.0)),
      (const Alignment(0.85, -1.0), const Alignment(-0.85, 1.0)),
      (Alignment.centerLeft, Alignment.centerRight),
      (const Alignment(-0.5, -1.0), const Alignment(0.5, 1.0)),
    ];
    final d = dirs[r.nextInt(dirs.length)];

    final n = colors.length;
    final stops = List<double>.generate(n, (i) {
      if (n == 3) {
        final s0 = 0.0;
        final s1 = 0.28 + r.nextDouble() * 0.22;
        final s2 = 1.0;
        return [s0, s1, s2][i];
      }
      return i / (n - 1);
    });

    return LinearGradient(
      begin: d.$1,
      end: d.$2,
      colors: colors,
      stops: stops,
    );
  }

  static Color _blendTowardsDark(Color c, double t) => Color.lerp(c, _nearBlack, t)!;

  /// Home / auth fon: xuddi shu uchta asosiy rang, qorong‘iroq (primary dan chiqmaydi).
  static HomeStackGradients randomHomeStackGradients() {
    final r = Random();
    final da = 0.40 + r.nextDouble() * 0.12;
    final db = 0.43 + r.nextDouble() * 0.12;
    final dc = 0.36 + r.nextDouble() * 0.12;
    final a = _blendTowardsDark(c55004D, da);
    final b = _blendTowardsDark(c842D5F, db);
    final c = _blendTowardsDark(c30215A, dc);
    final orders = <List<Color>>[
      [a, b, c],
      [c, b, a],
      [b, a, c],
      [a, c, b],
      [b, c, a],
      [c, a, b],
    ];
    final colors = orders[r.nextInt(orders.length)];
    final dirs = <(Alignment, Alignment)>[
      (Alignment.topCenter, Alignment.bottomCenter),
      (Alignment.topLeft, Alignment.bottomRight),
      (Alignment.topRight, Alignment.bottomLeft),
    ];
    final d = dirs[r.nextInt(dirs.length)];
    final base = LinearGradient(begin: d.$1, end: d.$2, colors: colors);

    final topA = 0.18 + r.nextDouble() * 0.12;
    final botA = 0.14 + r.nextDouble() * 0.10;

    final radialTopRight = RadialGradient(
      colors: [
        c842D5F.withValues(alpha: topA),
        c842D5F.withValues(alpha: 0),
      ],
    );
    final radialBottomLeft = RadialGradient(
      colors: [
        c55004D.withValues(alpha: botA),
        c55004D.withValues(alpha: 0),
      ],
    );

    const overlay = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x0AFFFFFF),
        Color(0x00FFFFFF),
        Color(0x1A000000),
      ],
    );

    return HomeStackGradients(
      baseLinear: base,
      radialTopRight: radialTopRight,
      radialBottomLeft: radialBottomLeft,
      overlayLinear: overlay,
      glowTop: -70 + r.nextInt(21) - 10,
      glowRight: -40 + r.nextInt(21) - 10,
      glowLeft: -55 + r.nextInt(21) - 10,
      glowMidTop: 170 + r.nextInt(25) - 12,
    );
  }


  static ColorFilter colorFilter(Color? color) => ColorFilter.mode(color ?? AppColors.white, BlendMode.srcIn);
}

/// [HomeGradientBackground] uchun tasodifiy tanlangan gradientlar to‘plami.
class HomeStackGradients {
  const HomeStackGradients({
    required this.baseLinear,
    required this.radialTopRight,
    required this.radialBottomLeft,
    required this.overlayLinear,
    required this.glowTop,
    required this.glowRight,
    required this.glowLeft,
    required this.glowMidTop,
  });

  final LinearGradient baseLinear;
  final RadialGradient radialTopRight;
  final RadialGradient radialBottomLeft;
  final LinearGradient overlayLinear;
  final double glowTop;
  final double glowRight;
  final double glowLeft;
  final double glowMidTop;
}
