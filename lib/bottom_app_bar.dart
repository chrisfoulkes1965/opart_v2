import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/opart_overlay_theme.dart';
import 'package:opart_v2/settings_overlay_layout.dart';

/// Bottom toolbar: three equal-width actions so nothing wraps off-screen.
/// Uses debounced [OpArt.saveToCache] so history thumbnails are captured
/// after the canvas has updated, without blocking toolbar taps.
Widget customBottomAppBar({
  required BuildContext context,
  required OpArt opArt,
}) {
  return SafeArea(
    top: false,
    child: LayoutBuilder(
      builder: (context, constraints) {
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
                        opArt.randomizeSettings();
                        rebuildCanvas.value++;
                        opArt.saveToCache();
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
                        opArt.randomizeSettings();
                        opArt.randomizePalette();
                        rebuildCanvas.value++;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          rebuildTab.value++;
                        });
                        opArt.saveToCache();
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
                        opArt.randomizePalette();
                        rebuildCanvas.value++;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          rebuildTab.value++;
                        });
                        opArt.saveToCache();
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
        message: 'Tap to $label',
        waitDuration: const Duration(milliseconds: 350),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
