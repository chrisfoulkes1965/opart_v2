import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:opart_v2/information.dart';
import 'package:opart_v2/op_art_catalog.dart';
import 'package:opart_v2/opart_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'OpArt Lab',
                      style: TextStyle(
                        fontFamily: 'Righteous',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.cyan),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => InformationPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: kOpArtCatalog
                      .map(
                        (opArtType) => Container(
                          height: 120,
                          width: 120,
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => OpArtPage(
                                      opArtType.opArtType,
                                      animationValue: 0.0,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(
                                        alpha: 0.9,
                                      ),
                                      blurRadius: 5,
                                      offset: const Offset(5, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: GridTile(
                                    footer: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      width: double.infinity,
                                      child: Text(
                                        opArtType.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Righteous',
                                        ),
                                      ),
                                    ),
                                    child: Image.asset(opArtType.image),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
