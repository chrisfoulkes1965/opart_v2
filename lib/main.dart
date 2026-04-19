import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opart_v2/database_helper.dart';
import 'package:opart_v2/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpArtLabApp());
}

class OpArtLabApp extends StatefulWidget {
  const OpArtLabApp({super.key});

  @override
  State<OpArtLabApp> createState() => _OpArtLabAppState();
}

class _OpArtLabAppState extends State<OpArtLabApp> {
  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await DatabaseHelper.instance.getUserDb();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OpArt Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Op Art Studio'),
    );
  }
}
