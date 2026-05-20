import 'package:flutter/material.dart';

/// Shared colours for settings overlay chrome (side panels, toolbar, FAB).
Color get opArtOverlayPanelBackground => Colors.white.withValues(alpha: 0.8);

const Color opArtOverlayAccent = Colors.cyan;

Color get opArtOverlayButtonBackground => Colors.grey.shade100;

Color get opArtOverlayButtonBackgroundInactive => Colors.grey.shade400;

const Color opArtOverlayIconDefault = Colors.cyan;

const Color opArtOverlayIconSelected = Colors.black;

const double opArtOverlayAccentBorderWidth = 4;

BoxDecoration opArtOverlayCircularButtonDecoration({required bool active}) {
  return BoxDecoration(
    color: active
        ? opArtOverlayButtonBackground
        : opArtOverlayButtonBackgroundInactive,
    shape: BoxShape.circle,
  );
}
