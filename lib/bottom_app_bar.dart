import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'model_opart.dart';

Widget customBottomAppBar(
    {required BuildContext context, required OpArt opArt, required bool enableButton}) {
  final double width = MediaQuery.of(context).size.width;

  return SizedBox(
      //  color: Colors.white.withOpacity(0.8),
      height: 70,
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(
            height: 70,
            width: (width > 400) ? 111 : 50,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                if (enableButton) {
                  opArt.randomizeSettings();
                  // opArt.randomizePalette();
                  opArt.saveToCache();
                  enableButton = false;
                  //
                  //   opArt.randomizeSettings();
                  //   opArt.saveToCache();
                  //   enableButton = false;
                  rebuildCanvas.value++;
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  Icon(
                    MdiIcons.shape,
                    color: Colors.cyan,
                  ),
                  if (width > 400) const SizedBox(width: 3),
                  if (width > 400)
                    const Text(
                      'Random\nShape',
                      style: TextStyle(color: Colors.black),
                    ),
                ],
              ),
            ),
          ),
          // ignore: sized_box_for_whitespace
          Container(
            height: 70,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () async {
                if (enableButton) {
                  opArt.randomizeSettings();
                  opArt.randomizePalette();
                  opArt.saveToCache();
                  enableButton = false;
                  rebuildCanvas.value++;
                  rebuildTab.value++;
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(
                    MdiIcons.autoFix,
                    color: Colors.cyan,
                    size: 30,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Go Wild!',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 70,
            width: (width > 400) ? 111 : 50,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                if (enableButton) {
                  opArt.randomizePalette();

                  opArt.saveToCache();
                  enableButton = false;
                  rebuildCanvas.value++;
                  rebuildTab.value++;
                }
                // BottomSheetPalette(context);
                // if (animationController != null) {
                //   animationController.stop();
                // }
                // PaletteToolBox(
                //   context,
                //   opArt,
                // );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  const Icon(
                    Icons.palette,
                    color: Colors.cyan,
                  ),
                  if (width > 400) const SizedBox(width: 3),
                  if (width > 400)
                    const Text(
                      'Random\nColors',
                      style: TextStyle(color: Colors.black),
                    )
                  else
                    Container(),
                ],
              ),
            ),
          ),
          // RaisedButton.icon(
          //   splashColor: Colors.red,
          //   animationDuration: Duration(milliseconds: 10),
          //   onPressed: () {
          //     randomize();
          //   },
          //   icon: Icon(Icons.refresh),
          //   label: Text(
          //     'randomize',
          //     textAlign: TextAlign.center,
          //   ),
          // ),

          // IconButton(
          //   onPressed: () {
          //     randomize();
          //
          //   },
          //  // icon: Icon(Icons.refresh),
          //   // child: Row(
          //   //   children: <Widget>[
          //   //     Icon(Icons.refresh),
          //   //     Padding(
          //   //       padding: const EdgeInsets.all(8.0),
          //   //       child: Text(
          //   //         'Go Wild!',
          //   //         textAlign: TextAlign.center,
          //   //       ),
          //   //     )
          //   //   ],
          //   // ),
          // ),
          // OutlineButton(
          //     onPressed: () {
          //       showBottomSheet();
          //     },
          //     child: Row(
          //       children: <Widget>[
          //         Icon(Icons.blur_circular),
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Text(
          //             'Tools',
          //             textAlign: TextAlign.center,
          //           ),
          //         )
          //       ],
          //     )),
          // GestureDetector(
          //   onTap: () {
          //     randomizePalette();
          //   },
          //   child: Row(
          //     children: <Widget>[
          //       Icon(Icons.palette),
          //       Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Text(
          //           'new palette',
          //           textAlign: TextAlign.center,
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          // IconButton(
          //   onPressed: () {
          //     randomizePalette();
          //
          //   },
          //   icon: Icon(Icons.palette),
          // child: Row(
          //   children: <Widget>[
          //     Icon(Icons.palette),
          //     Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Text(
          //         'randomize \nPalette',
          //         textAlign: TextAlign.center,
          //       ),
          //     )
          //   ],
          // ),
          // )
        ],
      ));
}
