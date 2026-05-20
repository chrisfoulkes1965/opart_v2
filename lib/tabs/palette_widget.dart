import 'package:flutter/material.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_palette.dart';
import 'package:opart_v2/model_settings.dart';
import 'package:opart_v2/opart_page.dart' as opart_page;

int currentColor = 0;

class PaletteTabWidget extends StatefulWidget {
  @override
  _PaletteTabWidgetState createState() => _PaletteTabWidgetState();
}

class _PaletteTabWidgetState extends State<PaletteTabWidget> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> listViewWidgets = [];
    // List<Widget> additionalColors = [];
    void additionalColors() {
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
            listViewWidgets.add(
              Padding(
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
                                (opart_page.currentOpArtPageState
                                        ?.showCustomColorPicker ??
                                    false)
                            ? 2
                            : 0,
                      ),
                      color: opart_page.currentOpArtPageState?.opArt
                          .attributes[i].colorValue,
                      shape: BoxShape.circle,
                    ),
                    height: 30,
                    width: 30,
                  ),
                ),
              ),
            );
          }
        }
      }
    }

    double height = MediaQuery.of(context).size.height;
    Widget opacityWidget() {
      return RotatedBox(
        quarterTurns: 1,
        child: Container(
          height: 40,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFffffff).withValues(alpha: 0.2),
                const Color(0xFF303030),
              ],
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.bottomRight,
              stops: const [0.0, 1.0],
            ),
          ),
          child: Slider(
            value: (opacity.value == null)
                ? 1
                : (opacity.doubleValue < 0 || opacity.doubleValue > 1)
                    ? 1
                    : opacity.doubleValue,
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
        opart_page.currentOpArtPageState?.opArt.palette.colorList.length ?? 0;

    return ValueListenableBuilder<int>(
      valueListenable: rebuildTab,
      builder: (context, value, child) {
        additionalColors();
        listViewWidgets.add(
          SizedBox(
            height: 30,
            child: IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (enableButton) {
                  enableButton = false;

                  if ((numberOfColors.intValue) > 1) {
                    numberOfColors.value = (numberOfColors.intValue) - 1;
                    opart_page.currentOpArtPageState?.opArt.palette.colorList
                        .removeLast();
                    if (numberOfColors.intValue > paletteLength) {
                      opart_page.currentOpArtPageState?.opArt.palette.randomize(
                        paletteType.value.toString(),
                        numberOfColors.intValue,
                      );
                    }
                    height = ((numberOfColors.doubleValue) + 2) * 30;
                    if (height > MediaQuery.of(context).size.height * 0.7) {
                      height = MediaQuery.of(context).size.height * 0.7;
                    }
                    opart_page.currentOpArtPageState?.opArt.saveToCache();
                    rebuildTab.value++;
                    rebuildCanvas.value++;
                  }
                }
              },
            ),
          ),
        );
        listViewWidgets.add(
          SizedBox(
            width: 30,
            child: Center(child: Text(numberOfColors.value.toString())),
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

                  numberOfColors.value = (numberOfColors.intValue) + 1;
                  opart_page.currentOpArtPageState?.opArt.attributes
                      .firstWhere((element) => element.name == 'numberOfColors')
                      .value = numberOfColors.value;
                  if (numberOfColors.intValue > paletteLength) {
                    final String paletteType =
                        opart_page.currentOpArtPageState?.opArt.attributes
                                .firstWhere(
                                  (element) => element.name == 'paletteType',
                                )
                                .value
                                .toString() ??
                            'random';
                    opart_page.currentOpArtPageState?.opArt.palette.randomize(
                      paletteType,
                      numberOfColors.intValue,
                    );
                  }
                  height = ((numberOfColors.doubleValue) + 2) * 30;
                  if (height > MediaQuery.of(context).size.height * 0.7) {
                    height = MediaQuery.of(context).size.height * 0.7;
                  }
                  opart_page.currentOpArtPageState?.opArt.saveToCache();
                  rebuildTab.value++;
                  rebuildCanvas.value++;
                }
              },
            ),
          ),
        );

        for (int i = 0; i < (numberOfColors.intValue); i++) {
          listViewWidgets.add(
            Padding(
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
                              (opart_page.currentOpArtPageState
                                      ?.showCustomColorPicker ??
                                  false)
                          ? 2
                          : 0,
                    ),
                    color: opart_page
                        .currentOpArtPageState?.opArt.palette.colorList[i],
                    shape: BoxShape.circle,
                  ),
                  height: 30,
                  width: 30,
                ),
              ),
            ),
          );
        }
        //  listViewWidgets.add(_opacityWidget());
        return Column(
          children: [
            Expanded(child: ListView(children: listViewWidgets)),
            SizedBox(height: 150, child: opacityWidget()),
          ],
        );
      },
    );
  }
}
