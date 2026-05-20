import 'package:flutter/material.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/opart_overlay_theme.dart';
import 'package:opart_v2/settings_overlay_layout.dart';
import 'package:opart_v2/tabs/general_tab.dart';

class TabWidget extends StatefulWidget {
  final GeneralTab tab;
  const TabWidget(this.tab);
  @override
  _TabWidgetState createState() => _TabWidgetState();
}

class _TabWidgetState extends State<TabWidget> {
  late GeneralTab tab;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: rebuildTab,
      builder: (context, value, child) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: tab.left ? tab.position : null,
          right: tab.left ? null : tab.position,
          top: 0,
          bottom: 0,
          child: Padding(
            padding: settingsOverlayPanelPadding(context),
            child: GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dx > 0) {
                  tab.left ? tab.openTab() : tab.closeTab();
                }
                if (details.delta.dx < 0) {
                  tab.left ? tab.closeTab() : tab.openTab();
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (tab.left) contentWidget(tab) else Container(),
                  tabWidget(tab),
                  if (!tab.left) contentWidget(tab) else Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget contentWidget(GeneralTab tab) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        color: opArtOverlayPanelBackground,
        width: tab.width,
        height: double.infinity,
        child: tab.content(),
      ),
    );
  }

  Widget tabWidget(GeneralTab tab) {
    return Align(
      alignment: Alignment(0, tab.tabHeight),
      child: GestureDetector(
        onTap: () {
          tab.open ? tab.closeTab() : tab.openTab();
        },
        child: RotatedBox(
          quarterTurns: tab.left ? 0 : 2,
          child: ClipPath(
            clipper: CustomMenuClipper(),
            child: Container(
              color: opArtOverlayPanelBackground,
              height: 100,
              width: 45,
              child: Icon(
                tab.icon,
                color: opArtOverlayIconDefault,
                size: 35,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    tab = widget.tab;
    super.initState();
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    final Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width + 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
