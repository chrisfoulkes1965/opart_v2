import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:opart_v2/bootstrap_screen.dart';
import 'package:opart_v2/print/pages/print_flow_page.dart';
import 'package:opart_v2/services/supabase_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  _listenForCheckoutDeepLinks();
  runApp(const OpArtLabApp());
}

void _listenForCheckoutDeepLinks() {
  final appLinks = AppLinks();
  unawaited(
    appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleCheckoutUri(uri);
      }
    }),
  );
  appLinks.uriLinkStream.listen((Uri uri) => _handleCheckoutUri(uri));
}

void _handleCheckoutUri(Uri uri) {
  if (!uri.path.contains('checkout/success')) {
    return;
  }

  final orderId = uri.queryParameters['order_id'];
  if (orderId == null || orderId.isEmpty) {
    return;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) {
      return;
    }

    unawaited(
      PrintFlowPage.open(
        context,
        recipe: <String, dynamic>{},
        completedOrderId: orderId,
      ),
    );
  });
}

class OpArtLabApp extends StatelessWidget {
  const OpArtLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'OpArt Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BootstrapScreen(),
    );
  }
}
