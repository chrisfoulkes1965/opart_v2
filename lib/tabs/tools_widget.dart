import 'package:flutter/material.dart';
import 'package:opart_v2/opart_page.dart' as opart_page;

import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_settings.dart';
import 'package:opart_v2/tabs/general_tab.dart';

int slider = 100;
Widget toolBoxTab() {
  final List<SettingsModel> tools = opart_page
          .currentOpArtPageState?.opArt.attributes
          .where((element) => element.settingCategory == SettingCategory.tool)
          .toList() ??
      [];

  return StatefulBuilder(builder: (context, setState) {
    Widget sliderWidget(int toolSliderIndex) {
      if (toolSliderIndex == 100 ||
          toolSliderIndex < 0 ||
          toolSliderIndex >= tools.length) {
        return Container(color: Colors.orange);
      }
      final SettingsModel attribute = tools[toolSliderIndex];
      // Global [slider] can point at a stale index after switching op-art types.
      if (attribute.settingType != SettingType.double &&
          attribute.settingType != SettingType.int) {
        return Container(color: Colors.orange);
      }

      Widget buildDoubleSlider() {
        final double v = (attribute.value as num).toDouble();
        final double min = (attribute.min as num).toDouble();
        final double max = (attribute.max as num).toDouble();
        return Slider(
          activeColor: Colors.cyan,
          value: v.clamp(min, max),
          min: min,
          max: max,
          onChanged: (value) {
            setState(() {
              attribute.value = value;
              rebuildTab.value++;
              rebuildCanvas.value++;
            });
          },
          onChangeEnd: (value) {
            opart_page.currentOpArtPageState?.opArt.saveToCache();
          },
        );
      }

      Widget buildIntSlider() {
        final double min = (attribute.min as num).toDouble();
        final double max = (attribute.max as num).toDouble();
        final int span = (max - min).round();
        return Slider(
          activeColor: Colors.cyan,
          value: (attribute.value as num).toDouble().clamp(min, max),
          min: min,
          max: max,
          divisions: span > 0 ? span : null,
          onChanged: (value) {
            attribute.value = value.round();
            rebuildTab.value++;
            rebuildCanvas.value++;
          },
          onChangeEnd: (value) {
            opart_page.currentOpArtPageState?.opArt.saveToCache();
          },
        );
      }

      return RotatedBox(
        quarterTurns: 1,
        child: SizedBox(
          height: 40,
          child: attribute.settingType == SettingType.double
              ? buildDoubleSlider()
              : buildIntSlider(),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
            width: 80,
            //  height: MediaQuery.of(context).size.height - 70-60,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0),
              child: ListView.builder(
                  itemCount: tools.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: (tools[index].settingType !=
                                          SettingType.bool)
                                      ? Colors.grey[100] // if it's not a bool
                                      : (tools[index].value == true)
                                          ? Colors.grey[
                                              100] // if it is bool and == true
                                          : Colors.grey[400],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: index == slider
                                          ? Colors.black
                                          : Colors.cyan,
                                      width: 4)),
                              child: IconButton(
                                  icon:
                                      tools[index].icon ?? const Icon(Icons.settings),
                                  color: index == slider
                                      ? Colors.black
                                      : Colors.cyan,
                                  onPressed: () {
                                    setState(() {
                                      if (tools[index].settingType !=
                                              SettingType.double &&
                                          tools[index].settingType !=
                                              SettingType.int) {
                                        slider = 100;

                                        toolsTab.width = 80;

                                        rebuildTab.value++;
                                      }
                                      if (tools[index].silent == true) {
                                        if (tools[index].settingType ==
                                            SettingType.bool) {
                                          tools[index].value =
                                              !(tools[index].value as bool);
                                        }

                                        tools[index].onChange?.call();

                                        opart_page.currentOpArtPageState?.opArt
                                            .saveToCache();
                                        rebuildCanvas.value++;
                                      } else if (tools[index].settingType ==
                                              SettingType.double ||
                                          tools[index].settingType ==
                                              SettingType.int) {
                                        toolsTab.width = 120;
                                        rebuildTab.value++;
                                        slider = index;
                                      } else {
                                        if (tools[index].settingType ==
                                            SettingType.list) {
                                          final int currentValue = tools[index]
                                              .options
                                              .indexWhere((value) =>
                                                  value ==
                                                  tools[index].value) as int;

                                          tools[index].value = tools[index]
                                              .options[(currentValue ==
                                                  tools[index].options.length -
                                                      1)
                                              ? 0
                                              : currentValue + 1];
                                          rebuildCanvas.value++;
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor: Colors.white
                                                      .withOpacity(0.8),
                                                  duration: const Duration(
                                                      seconds: 2),
                                                  content: SizedBox(
                                                    height: 70,
                                                    child: Text(
                                                      tools[index].value
                                                          as String,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  )));
                                          opart_page
                                              .currentOpArtPageState?.opArt
                                              .saveToCache();
                                        }
                                      }
                                    });
                                  }),
                            ),
                          ),
                        ),
                        Text(tools[index].label, textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
            )),
        sliderWidget(slider)
      ],
    );
  });
}
