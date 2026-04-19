import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:opart_v2/model_opart.dart';

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

        return SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                    icon: Icon(MdiIcons.shape, color: Colors.cyan),
                    label: wide ? 'Random\nShape' : 'Shape',
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
                    icon: Icon(MdiIcons.autoFix, color: Colors.cyan, size: 28),
                    label: 'Go Wild!',
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
                    icon: const Icon(Icons.palette, color: Colors.cyan),
                    label: wide ? 'Random\nColors' : 'Colors',
                  ),
                ),
              ],
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
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
