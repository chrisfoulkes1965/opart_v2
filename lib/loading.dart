import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> waitSome() async {
    await Navigator.pushReplacementNamed(
      context,
      '/menu',
      arguments: {'location': 'OpArt Menu'},
    );
  }

  @override
  void initState() {
    super.initState();
    waitSome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: const Center(
        child: SpinKitFadingCube(color: Colors.white, size: 200.0),
      ),
    );
  }
}
