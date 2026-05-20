import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opart_v2/app_warmup.dart';
import 'package:opart_v2/home_page.dart';

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_finishBootstrap());
    });
  }

  Future<void> _finishBootstrap() async {
    await warmUpOpArtLab(context);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const MyHomePage(title: 'Op Art Studio'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 16),
            Text(
              'Loading OpArt Lab…',
              style: TextStyle(
                fontFamily: 'Righteous',
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
