import 'dart:math';

import 'package:flutter/material.dart';

const double kMinPaletteContrastRatio = 2.5;

const int _maxLightnessSteps = 20;
const double _lightnessStep = 0.06;

double contrastRatio(Color a, Color b) {
  final double lumA = a.computeLuminance();
  final double lumB = b.computeLuminance();
  final double lighter = max(lumA, lumB);
  final double darker = min(lumA, lumB);
  return (lighter + 0.05) / (darker + 0.05);
}

Color alphaBlended(Color foreground, Color background, double alpha) {
  final double clampedAlpha = alpha.clamp(0.0, 1.0);
  return Color.alphaBlend(
    foreground.withValues(alpha: clampedAlpha),
    background,
  );
}

double effectiveMinContrastRatio(double minRatio, double alpha) {
  final double clampedAlpha = alpha.clamp(0.0, 1.0);
  return 1.0 + (minRatio - 1.0) * clampedAlpha;
}

Color ensureContrastAgainstBackground({
  required Color color,
  required Color background,
  double alpha = 1.0,
  double minRatio = kMinPaletteContrastRatio,
}) {
  final double clampedAlpha = alpha.clamp(0.0, 1.0);
  final double targetRatio = effectiveMinContrastRatio(minRatio, clampedAlpha);
  final Color effective = alphaBlended(color, background, clampedAlpha);
  if (contrastRatio(effective, background) >= targetRatio) {
    return color;
  }

  final HSLColor hsl = HSLColor.fromColor(color);
  final double backgroundLuminance = background.computeLuminance();
  final double effectiveLuminance = effective.computeLuminance();
  final bool pushLighter = backgroundLuminance < effectiveLuminance;

  HSLColor adjusted = hsl;
  for (int step = 0; step < _maxLightnessSteps; step++) {
    final double nextLightness =
        (adjusted.lightness + (pushLighter ? _lightnessStep : -_lightnessStep))
            .clamp(0.0, 1.0);
    if (nextLightness == adjusted.lightness) {
      break;
    }

    adjusted = adjusted.withLightness(nextLightness);
    final Color candidate = adjusted.toColor();
    if (contrastRatio(
          alphaBlended(candidate, background, clampedAlpha),
          background,
        ) >=
        targetRatio) {
      return candidate;
    }
  }

  final Color lightFallback = adjusted.withLightness(1.0).toColor();
  final Color darkFallback = adjusted.withLightness(0.0).toColor();
  final double lightContrast = contrastRatio(
    alphaBlended(lightFallback, background, clampedAlpha),
    background,
  );
  final double darkContrast = contrastRatio(
    alphaBlended(darkFallback, background, clampedAlpha),
    background,
  );

  return lightContrast >= darkContrast ? lightFallback : darkFallback;
}
