import 'package:flutter/material.dart';
import 'package:opart_v2/model_settings.dart';
import 'package:opart_v2/opart_page.dart' as opart_page;

import '../model_opart.dart';
import '../model_palette.dart';

int currentColor = 0;

class PaletteTabWidget extends StatefulWidget {
  @override
  _PaletteTabWidgetState createState() => _PaletteTabWidgetState();
}

class _PaletteTabWidgetState extends State<PaletteTabWidget> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> listViewWidgets = [];
    int lengthOfAdditionalColors = 0;
    // List<Widget> additionalColors = [];
    void _additionalColors() {
      for (int i = 0;
          i < (opart_page.currentOpArtPageState?.opArt.attributes.length ?? 0);
          i++) {
        if (opart_page.currentOpArtPageState?.opArt.attributes[i].settingType ==
            SettingType.color) {
          if (opart_page.currentOpArtPageState?.opArt.attributes[i].name ==
                  'lineColor' &&
              opart_page.currentOpArtPageState?.opArt.attributes
                      .firstWhere((element) => element.name == 'lineWidth')
                      .value ==
                  0) {
            //???
          } else {
            listViewWidgets.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: GestureDetector(
                onTap: () {
                  currentColor = i + 100;
                  opart_page.currentOpArtPageState?.showCustomColorPicker =
                      true;
                  rebuildColorPicker.value++;
                  rebuildOpArtPage.value++;
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: i == currentColor &&
                                  (opart_page.currentOpArtPageState?.showCustomColorPicker ?? false)
                              ? 2
                              : 0),
                      color: opart_page.currentOpArtPageState?.opArt
                          .attributes[i].value as Color,
                      shape: BoxShape.circle),
                  height: 30,
                  width: 30,
                ),
              ),
            ));
            lengthOfAdditionalColors++;
          }
        }
      }
    }

    double height = MediaQuery.of(context).size.height;
    Widget _opacityWidget() {
      return RotatedBox(
        quarterTurns: 1,
        child: Container(
          height: 40,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            ),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFffffff).withOpacity(0.2),
                const Color(0xFF303030),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.00),
              stops: const [0.0, 1.0],
            ),
          ),
          child: Slider(
            value: (opacity.value == null)
                ? 1
                : (opacity.value as double < 0 || opacity.value as double > 1)
                    ? 1
                    : opacity.value as double,
            min: 0.2,
            onChanged: (value) {
              opacity.value = value;
              rebuildTab.value++;
              rebuildCanvas.value++;
            },
            onChangeEnd: (value) {
              opart_page.currentOpArtPageState?.opArt.saveToCache();
            },
          ),
        ),
      );
    }

    final int paletteLength =
        (opart_page.currentOpArtPageState?.opArt.palette.colorList.length ?? 0);

    return ValueListenableBuilder<int>(
        valueListenable: rebuildTab,
        builder: (context, value, child) {
          _additionalColors();
          listViewWidgets.add(
            SizedBox(
              height: 30,
              child: IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (enableButton) {
                      enableButton = false;

                      if (numberOfColors.value as int > 1) {
                        numberOfColors.value--;
                        opart_page
                            .currentOpArtPageState?.opArt.palette.colorList
                            .removeLast();
                        if (numberOfColors.value as int > paletteLength) {
                          opart_page.currentOpArtPageState?.opArt.palette
                              .randomize(paletteType.value.toString(),
                                  numberOfColors.value as int);
                        }
                        height =
                            ((numberOfColors.value.toDouble() as double) + 2) *
                                30;
                        if (height > MediaQuery.of(context).size.height * 0.7) {
                          height = MediaQuery.of(context).size.height * 0.7;
                        }
                        opart_page.currentOpArtPageState?.opArt.saveToCache();
                        rebuildTab.value++;
                        rebuildCanvas.value++;
                      }
                    }
                  }),
            ),
          );
          listViewWidgets.add(
            SizedBox(
              width: 30,
              child: Center(
                child: Text(
                  numberOfColors.value.toString(),
                ),
              ),
            ),
          );

          listViewWidgets.add(
            SizedBox(
              height: 30,
              child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (enableButton) {
                      enableButton = false;

                      numberOfColors.value++;
                      opart_page.currentOpArtPageState?.opArt.attributes
                          .firstWhere(
                              (element) => element.name == 'numberOfColors')
                          .value = numberOfColors.value;
                      if (numberOfColors.value as int > paletteLength) {
                        final String paletteType = (opart_page
                            .currentOpArtPageState?.opArt.attributes
                            .firstWhere(
                                (element) => element.name == 'paletteType')
                            .value
                            .toString()) ?? 'random';
                        opart_page.currentOpArtPageState?.opArt.palette
                            .randomize(
                                paletteType, numberOfColors.value as int);
                      }
                      height =
                          ((numberOfColors.value.toDouble() as double) + 2) *
                              30;
                      if (height > MediaQuery.of(context).size.height * 0.7) {
                        height = MediaQuery.of(context).size.height * 0.7;
                      }
                      opart_page.currentOpArtPageState?.opArt.saveToCache();
                      rebuildTab.value++;
                      rebuildCanvas.value++;
                    }
                  }),
            ),
          );

          for (int i = 0; i < (numberOfColors.value as int); i++) {
            listViewWidgets.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: GestureDetector(
                onTap: () {
                  currentColor = i;
                  opart_page.currentOpArtPageState?.showCustomColorPicker =
                      true;
                  rebuildColorPicker.value++;
                  rebuildOpArtPage.value++;
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: i == currentColor &&
                                  (opart_page.currentOpArtPageState?.showCustomColorPicker ?? false)
                              ? 2
                              : 0),
                      color: opart_page
                          .currentOpArtPageState?.opArt.palette.colorList[i],
                      shape: BoxShape.circle),
                  height: 30,
                  width: 30,
                ),
              ),
            ));
          }
          //  listViewWidgets.add(_opacityWidget());
          return SizedBox(
              height: MediaQuery.of(context).size.height - 60 - 60 - 70,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(children: listViewWidgets),
                  ),
                  SizedBox(height: 150, child: _opacityWidget())
                ],
              ));
        });
  }
}
