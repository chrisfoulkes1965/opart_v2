import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/opart_overlay_theme.dart';
import 'package:opart_v2/settings_overlay_layout.dart';

/// Bottom toolbar: three equal-width actions so nothing wraps off-screen.
/// Uses top-level `enableButton` in `model_opart.dart` so taps stay in sync
/// with [OpArt.saveToCache] (which sets the flag back when capture finishes).
Widget customBottomAppBar({
  required BuildContext context,
  required OpArt opArt,
}) {
  return SafeArea(
    top: false,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final bool wide = w > 400;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: kOpArtBottomToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _BottomToolButton(
                      onPressed: () {
                        if (!enableButton) return;
                        enableButton = false;
                        opArt.randomizeSettings();
                        opArt.saveToCache();
                        rebuildCanvas.value++;
                      },
                      icon: Icon(
                        MdiIcons.shape,
                        color: opArtOverlayIconDefault,
                        size: 22,
                      ),
                      label: 'Change shape',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _BottomToolButton(
                      onPressed: () {
                        if (!enableButton) return;
                        enableButton = false;
                        opArt.randomizeSettings();
                        opArt.randomizePalette();
                        opArt.saveToCache();
                        rebuildCanvas.value++;
                        rebuildTab.value++;
                      },
                      icon: Icon(
                        MdiIcons.autoFix,
                        color: opArtOverlayIconDefault,
                        size: 24,
                      ),
                      label: 'Go wild',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _BottomToolButton(
                      onPressed: () {
                        if (!enableButton) return;
                        enableButton = false;
                        opArt.randomizePalette();
                        opArt.saveToCache();
                        rebuildCanvas.value++;
                        rebuildTab.value++;
                      },
                      icon: const Icon(
                        Icons.palette,
                        color: opArtOverlayIconDefault,
                        size: 22,
                      ),
                      label: 'Change colors',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _BottomToolButton extends StatelessWidget {
  const _BottomToolButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: opArtOverlayButtonBackground,
      borderRadius: BorderRadius.circular(10),
      child: Tooltip(
        message: 'Tap to $label', // Customize this as appropriate
        waitDuration: const Duration(milliseconds: 350),
        child: GestureDetector(
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
