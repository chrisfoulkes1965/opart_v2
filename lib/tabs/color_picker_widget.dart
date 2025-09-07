import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../model_opart.dart';
import '../opart_page.dart';
import 'palette_widget.dart';

class ColorPickerWidget extends StatefulWidget {
  final OpArt opArt;
  const ColorPickerWidget({required this.opArt});
  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  @override
  Widget build(BuildContext context) {
    Color oldColor = currentColor > 100
        ? widget.opArt.attributes[currentColor - 100].value as Color
        : widget.opArt.palette.colorList[currentColor];
    if (oldColor.red == oldColor.blue && oldColor.blue == oldColor.green) {
      if (oldColor.red < 255) {
        oldColor =
            Color.fromRGBO(oldColor.red + 1, oldColor.green, oldColor.blue, 1);
      } else {
        oldColor =
            Color.fromRGBO(oldColor.red - 1, oldColor.green, oldColor.blue, 1);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 80.0, bottom: 70, right: 10),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10)),
          child: ValueListenableBuilder<int>(
              valueListenable: rebuildColorPicker,
              builder: (context, value, child) {
                return SizedBox(
                  height: 190,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ColorPicker(
                                pickerAreaHeightPercent: 0.2,
                                displayThumbColor: true,
                                showLabel: false,
                                enableAlpha: false,
                                pickerColor: oldColor,
                                onColorChanged: (color) {
                                  oldColor = color;

                                  if (currentColor > 100) {
                                    widget.opArt.attributes[currentColor - 100].value =
                                        color;
                                  } else {
                                    widget.opArt.palette.colorList[currentColor] =
                                        color;
                                  }
                                  rebuildTab.value++;
                                  rebuildCanvas.value++;
                                  rebuildColorPicker.value++;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            currentOpArtPageState?.showCustomColorPicker = false;
                            widget.opArt.saveToCache();
                            rebuildOpArtPage.value++;
                          },
                        ),
                      )
                    ],
                  ),
                );
              })),
    );
  }
}
