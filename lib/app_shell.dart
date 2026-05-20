import 'package:flutter/material.dart';
import 'package:opart_v2/home_page.dart';
import 'package:opart_v2/mygallery.dart';
import 'package:opart_v2/shop_page.dart';

enum AppTab { home, gallery, shop }

class AppShell extends StatefulWidget {
  AppShell() : super(key: shellKey);

  static final GlobalKey<_AppShellState> shellKey = GlobalKey<_AppShellState>();

  static void navigateToTab(AppTab tab, {int? galleryIndex}) {
    shellKey.currentState?.selectTab(tab, galleryIndex: galleryIndex);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _selectedTab = AppTab.home;
  int _galleryIndex = 0;

  void selectTab(AppTab tab, {int? galleryIndex}) {
    setState(() {
      _selectedTab = tab;
      if (galleryIndex != null) {
        _galleryIndex = galleryIndex;
      }
    });
  }

  int get _selectedIndex => _selectedTab.index;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const MyHomePage(title: 'OpArt Lab'),
            MyGallery(
              key: ValueKey(_galleryIndex),
              _galleryIndex,
              showHomeButton: false,
            ),
            ShopPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedTab = AppTab.values[index];
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Gallery',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Shop',
            ),
          ],
        ),
      ),
    );
  }
}
