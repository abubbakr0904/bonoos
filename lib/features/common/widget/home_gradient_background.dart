import 'package:bonoos/core/values/app_colors.dart';
import 'package:flutter/material.dart';

/// Qatlamli gradient — har ochilishda [AppColors.randomHomeStackGradients] bilan biroz boshqacha,
/// lekin doim marka siyoh/magenta palitrada.
class HomeGradientBackground extends StatefulWidget {
  const HomeGradientBackground({super.key});

  @override
  State<HomeGradientBackground> createState() => _HomeGradientBackgroundState();
}

class _HomeGradientBackgroundState extends State<HomeGradientBackground> {
  late final HomeStackGradients _g;

  @override
  void initState() {
    super.initState();
    _g = AppColors.randomHomeStackGradients();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: _g.baseLinear),
        ),
        Positioned(
          top: _g.glowTop,
          right: _g.glowRight,
          child: Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _g.radialTopRight,
            ),
          ),
        ),
        Positioned(
          top: _g.glowMidTop,
          left: _g.glowLeft,
          child: Container(
            height: 190,
            width: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _g.radialBottomLeft,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: _g.overlayLinear),
          ),
        ),
      ],
    );
  }
}
