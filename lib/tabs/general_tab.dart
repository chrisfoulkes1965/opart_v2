import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:opart_v2/tabs/tools_widget.dart';

import '../model_opart.dart';
import '../opart_page.dart' as opart_page;
import 'choose_pallette_widget.dart';
import 'palette_widget.dart';

abstract class GeneralTab {
  bool open = false;
  double position = 0.0;
  double width = 0.0;
  double tabHeight = 0.0;
  bool left = true;
  late IconData icon;
  bool hidden = false;

  void closeTab() {
    paletteTab.position = -paletteTab.width;
    paletteTab.open = false;
    toolsTab.position = -toolsTab.width;
    toolsTab.open = false;
    choosePaletteTab.position = -choosePaletteTab.width;
    choosePaletteTab.open = false;
    position = -width;
    opart_page.currentOpArtPageState?.showCustomColorPicker = false;
    rebuildOpArtPage.value++;
    rebuildTab.value++;
  }

  void openTab() {
    opart_page.currentOpArtPageState?.showCustomColorPicker = false;
    rebuildOpArtPage.value++;
    paletteTab.position = -paletteTab.width;
    paletteTab.open = false;
    toolsTab.position = -toolsTab.width;
    toolsTab.open = false;
    choosePaletteTab.position = -choosePaletteTab.width;
    choosePaletteTab.open = false;
    open = true;
    position = 0;
    opart_page.currentOpArtPageState?.showCustomColorPicker = false;
    rebuildOpArtPage.value++;
    rebuildTab.value++;
  }

  void hideTab() {
    open = false;
    position = -width - 45;
    rebuildTab.value++;
  }

  Widget content() {
    return Container();
  }
}

late ToolsTab toolsTab;
late PaletteTab paletteTab;
late ChoosePaletteTab choosePaletteTab;

class ToolsTab implements GeneralTab {
  @override
  bool open = false;
  @override
  IconData icon = MdiIcons.tools;

  @override
  bool left = false;

  @override
  double tabHeight = -0.5;

  @override
  double position = -80;

  @override
  double width = 80;

  void showSlider() {
    position = 80;
    rebuildTab.value++;
  }

  @override
  Widget content() {
    return toolBoxTab();
  }

  @override
  bool hidden = false;

  @override
  void closeTab() {
    paletteTab.position = -paletteTab.width;
    paletteTab.open = false;
    toolsTab.position = -toolsTab.width;
    toolsTab.open = false;
    choosePaletteTab.position = -choosePaletteTab.width;
    choosePaletteTab.open = false;
    position = -width;
    opart_page.currentOpArtPageState?.showCustomColorPicker = false;
    rebuildOpArtPage.value++;
    rebuildTab.value++;
  }

  @override
  void hideTab() {
    open = false;
    position = -width - 45;
    rebuildTab.value++;
  }

  @override
  void openTab() {
    opart_page.currentOpArtPageState?.showCustomColorPicker = false;
    rebuildOpArtPage.value++;
    paletteTab.position = -paletteTab.width;
    paletteTab.open = false;
    toolsTab.position = -toolsTab.width;
    toolsTab.open = false;
    choosePaletteTab.position = -choosePaletteTab.width;
    choosePaletteTab.open = false;
    open = true;
    position = 0;
    opart_page.currentOpArtPageState?.showCustomColorPicker = false;
    rebuildOpArtPage.value++;
    rebuildTab.value++;
  }
}

class PaletteTab implements GeneralTab {
  @override
  bool open = false;
  final BuildContext context;
  PaletteTab(this.context);
  @override
  IconData icon = Icons.palette;

  @override
  bool left = true;
  @override
  void openTab() {
    toolsTab.position = -toolsTab.width;
    toolsTab.open = false;
    choosePaletteTab.position = -choosePaletteTab.width - 45;
    choosePaletteTab.open = false;
    open = true;
    position = 0;
    rebuildTab.value++;
  }

  @override
  double tabHeight = -0.5;

  @override
  double width = 50;

  @override
  Widget content() {
    return PaletteTabWidget();
  }

  @override
  double position = -50;

  @override
  bool hidden = false;

  @override
  void closeTab() {
    paletteTab.position = -paletteTab.width;
    paletteTab.open = false;
    toolsTab.position = -toolsTab.width;
    toolsTab.open = false;
    choosePaletteTab.position = -choosePaletteTab.width;
    choosePaletteTab.open = false;
    position = -width;
    opart_page.currentOpArtPageState?.showCustomColorPicker = false;
    rebuildOpArtPage.value++;
    rebuildTab.value++;
  }

  @override
  void hideTab() {
    open = false;
    position = -width - 45;
    rebuildTab.value++;
  }
}

class ChoosePaletteTab implements GeneralTab {
  @override
  bool open = false;
  @override
  IconData icon = Icons.palette_outlined;

  @override
  bool left = true;

  @override
  double tabHeight = 0.3;

  @override
  double width = 80;
  @override
  void openTab() {
    paletteTab.position = -paletteTab.width - 45;
    paletteTab.open = false;
    toolsTab.position = -toolsTab.width;
    toolsTab.open = false;
    open = true;
    position = 0;
    rebuildTab.value++;
  }

  @override
  Widget content() {
    return choosePaletteTabWidget();
  }

  @override
  double position = -80;

  @override
  bool hidden = false;

  @override
  void closeTab() {
    paletteTab.position = -paletteTab.width;
    paletteTab.open = false;
    toolsTab.position = -toolsTab.width;
    toolsTab.open = false;
    choosePaletteTab.position = -choosePaletteTab.width;
    choosePaletteTab.open = false;
    position = -width;
    opart_page.currentOpArtPageState?.showCustomColorPicker = false;
    rebuildOpArtPage.value++;
    rebuildTab.value++;
  }

  @override
  void hideTab() {
    open = false;
    position = -width - 45;
    rebuildTab.value++;
  }
}
