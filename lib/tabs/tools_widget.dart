import 'package:flutter/material.dart';
import 'package:opart_v2/opart_page.dart' as opart_page;

import '../model_opart.dart';
import '../model_settings.dart';
import 'general_tab.dart';

int slider = 100;
Widget toolBoxTab() {
  final List<SettingsModel> tools = opart_page
          .currentOpArtPageState?.opArt.attributes
          .where((element) => element.settingCategory == SettingCategory.tool)
          .toList() ??
      [];

  return StatefulBuilder(builder: (context, setState) {
    Widget sliderWidget(int slider) {
      if (slider == 100) {
        return Container(color: Colors.orange);
      } else {
        final SettingsModel attribute = tools[slider];
        return RotatedBox(
          quarterTurns: 1,
          child: SizedBox(
            height: 40,
            child: attribute.settingType == SettingType.double
                ? Slider(
                    activeColor: Colors.cyan,
                    value: attribute.value as double,
                    min: attribute.min as double,
                    max: attribute.max as double,
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
                  )
                : Slider(
                    activeColor: Colors.cyan,
                    value: attribute.value.toDouble() as double,
                    min: attribute.min.toDouble() as double,
                    max: attribute.max.toDouble() as double,
                    onChanged: (value) {
                      attribute.value = value.toInt();
                      rebuildTab.value++;
                      rebuildCanvas.value++;
                    },
                    onChangeEnd: (value) {
                      opart_page.currentOpArtPageState?.opArt.saveToCache();
                    },
                    divisions: attribute.max - attribute.min as int,
                  ),
          ),
        );
      }
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
                                      tools[index].icon ?? Icon(Icons.settings),
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
