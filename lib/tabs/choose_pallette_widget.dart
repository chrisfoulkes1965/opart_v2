import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/model_palette.dart';
import 'package:opart_v2/opart_page.dart' as opart_page;

int currentColor = 0;

Widget choosePaletteTabWidget() {
  // Animation<double> _animation;

  List<Widget> _circularPalette(int index) {
    final int _sizeOfPalette = defaultPalettes[index][3].length as int;

    final List<Widget> _list = [];
    if (_sizeOfPalette < 11) {
      for (int i = 0; i < _sizeOfPalette; i++) {
        _list.add(Transform.rotate(
            angle: i * 2 * pi / _sizeOfPalette,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.6),
                  shape: BoxShape.circle,
                  color:
                      Color(int.parse(defaultPalettes[index][3][i] as String)),
                ),
                height: 15,
                width: 15,
              ),
            )));
      }
    } else {
      for (int i = 0; i < _sizeOfPalette; i++) {
        if (i < 10) {
          _list.add(Transform.rotate(
              angle: i * 2 * pi / 10,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.6),
                    shape: BoxShape.circle,
                    color: Color(
                        int.parse(defaultPalettes[index][3][i] as String)),
                  ),
                  height: 15,
                  width: 15,
                ),
              )));
        } else {
          _list.add(Transform.rotate(
              angle: i * 2 * pi / (_sizeOfPalette - 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.6),
                      shape: BoxShape.circle,
                      color: Color(
                          int.parse(defaultPalettes[index][3][i] as String)),
                    ),
                    height: 15,
                    width: 15,
                  ),
                ),
              )));
        }
      }
    }
    return _list;
  }

  return ListView.builder(
      itemCount: defaultPalettes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            final List<String> newPalette =
                defaultPalettes[index][3] as List<String>;
            opart_page.currentOpArtPageState?.opArt.palette.colorList = [];
            opacity.value = 1.0;
            for (int i = 0; i < newPalette.length; i++) {
              opart_page.currentOpArtPageState?.opArt.palette.colorList
                  .add(Color(int.parse(newPalette[i])));
            }
            numberOfColors.value = newPalette.length;
            rebuildTab.value++;
            rebuildCanvas.value++;
            opart_page.currentOpArtPageState?.opArt.saveToCache();
          },
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Stack(
                        children: _circularPalette(index),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                defaultPalettes[index][0] as String,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      });
}
