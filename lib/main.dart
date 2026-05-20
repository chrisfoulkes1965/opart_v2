import 'package:flutter/material.dart';
import 'package:opart_v2/bootstrap_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpArtLabApp());
}

class OpArtLabApp extends StatelessWidget {
  const OpArtLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
