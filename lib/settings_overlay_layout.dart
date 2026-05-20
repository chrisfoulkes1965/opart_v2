import 'package:flutter/material.dart';

/// History strip height in [OpArtPage] settings mode (excluding [SafeArea] top).
const double kOpArtHistoryBarHeight = 60;

/// Toolbar body height in [customBottomAppBar] (excluding [SafeArea] bottom).
const double kOpArtBottomToolbarHeight = 48;

/// Bottom inset for play/pause controls sitting just above the toolbar.
double settingsOverlayPlaybackBottom(BuildContext context) {
  return settingsOverlayPanelPadding(context).bottom + 6;
}

/// Padding that keeps side panels below the history strip and above the toolbar.
EdgeInsets settingsOverlayPanelPadding(BuildContext context) {
  final padding = MediaQuery.paddingOf(context);
  return EdgeInsets.only(
    top: padding.top + kOpArtHistoryBarHeight,
    bottom: padding.bottom + kOpArtBottomToolbarHeight,
  );
}

/// Vertical space available for panel content between history and toolbar.
double settingsOverlayContentHeight(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final insets = settingsOverlayPanelPadding(context);
  return size.height - insets.top - insets.bottom;
}
