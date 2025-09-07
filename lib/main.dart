import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:opart_v2/loading.dart';
import 'package:opart_v2/database_helper.dart';
import 'package:opart_v2/information.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/mygallery.dart';
import 'package:opart_v2/opart_page.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

bool showDelete = false;
bool proVersion = true;
Random rnd = Random();
int seed = DateTime.now().millisecond;
double aspectRatio = 2 / 3;

Offerings? offerings;

void main() {
  runApp(MaterialApp(
    theme: ThemeData(primaryColor: Colors.cyan),
    initialRoute: '/menu',
    routes: {
      // '/': (context) => Loading(),
      '/menu': (context) => MyApp(),
    },
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OpArt Lab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Op Art Studio'),
    );
  }

  Future<void> initPlatformState() async {
    proVersion = false;

    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup('dZAXkioWKFdOESaEtJMQkRsrETmZbFUK');

    try {
      offerings = await Purchases.getOfferings();
      print(offerings);
      if (offerings?.current != null &&
          offerings!.current!.availablePackages.isNotEmpty) {
        // Display packages for sale
      }
    } on PlatformException catch (e) {
      print('offerings errors');

      // optional error handling
    }
  }

  @override
  void initState() {
    final DatabaseHelper helper = DatabaseHelper.instance;
    // helper.deleteDB();
    initPlatformState();
    helper.getUserDb();

    super.initState();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _rebuildDelete = ValueNotifier(0);
  List<OpArtTypes> opArtTypes = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('OpArt Lab',
                        style: TextStyle(
                            fontFamily: 'Righteous',
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.info, color: Colors.cyan),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InformationPage()));
                    })
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: opArtTypes
                      .map(
                        (opArtType) => Container(
                          height: 120,
                          width: 120,
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OpArtPage(
                                        opArtType.opArtType,
                                        downloadNow: false,
                                        animationValue: 0.0)),
                              );
                            },
                            child: Hero(
                              tag: opArtType.name,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.9),
                                      blurRadius: 5,
                                      offset: const Offset(5, 5),
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: GridTile(
                                    footer: Container(
                                      color: Colors.white.withOpacity(0.7),
                                      width: double.infinity,
                                      child: Text(
                                        opArtType.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Righteous',
                                          // fontWeight: FontWeight.bold,
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyGallery(savedOpArt.length - 1, false)));
              },
              child: const Text('My Gallery',
                  style: TextStyle(
                      fontFamily: 'Righteous',
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ValueListenableBuilder<int>(
                  valueListenable: rebuildMain,
                  builder: (context, value, child) {
                    if (savedOpArt.isEmpty) {
                      return const Text(
                          'Curate your own gallery of stunning OpArt here.');
                    }
                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                          itemCount: savedOpArt.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MyGallery(index + 1, false)));
                              },
                              onLongPress: () {
                                showDelete = !showDelete;
                                _rebuildDelete.value++;
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Image.memory(
                                          base64Decode(savedOpArt[index]
                                              ['image'] as String),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ValueListenableBuilder<int>(
                                      valueListenable: _rebuildDelete,
                                      builder: (context, value, child) {
                                        return showDelete
                                            ? Positioned(
                                                right: 0,
                                                top: 0,
                                                child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle),
                                                  child: Center(
                                                    child: FloatingActionButton(
                                                        onPressed: () {
                                                          if (savedOpArt[index]
                                                                  ['paid']
                                                              as bool) {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                      title: const Text(
                                                                          ' Are you sure you want to delete?'),
                                                                      content:
                                                                          const Text(
                                                                              'You have paid for this image. If you delete it you will not be able to download it again.'),
                                                                      actions: [
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            final DatabaseHelper
                                                                                helper =
                                                                                DatabaseHelper.instance;
                                                                            helper.delete(savedOpArt[index]['id']
                                                                                as int);
                                                                            savedOpArt.removeAt(index);
                                                                            showDelete =
                                                                                false;
                                                                            rebuildMain.value++;
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              const Text('Delete'),
                                                                        ),
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              const Text('Cancel'),
                                                                        )
                                                                      ]);
                                                                });
                                                          } else {
                                                            final DatabaseHelper
                                                                helper =
                                                                DatabaseHelper
                                                                    .instance;
                                                            helper.delete(
                                                                savedOpArt[index]
                                                                        ['id']
                                                                    as int);
                                                            savedOpArt.removeAt(
                                                                index);
                                                            showDelete = false;
                                                            rebuildMain.value++;
                                                          }
                                                        },
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: const Icon(
                                                            Icons.delete,
                                                            color:
                                                                Colors.grey)),
                                                  ),
                                                ))
                                            : Container();
                                      }),
                                ],
                              ),
                            );
                          }),
                    );
                  }),
            ),
          ],
        ),
      )),
    );
  }

  @override
  void initState() {
    // InAppPurchaseConnection.enablePendingPurchases();

    opArtTypes = [
      OpArtTypes('Flow', OpArtType.Flow, 'lib/assets/flow_200.png'),
      OpArtTypes(
          'Wallpaper', OpArtType.Wallpaper, 'lib/assets/wallpaper_200.png'),
      OpArtTypes('Diagonal', OpArtType.Diagonal, 'lib/assets/diagonal_200.png'),
      OpArtTypes('Shapes', OpArtType.Shapes, 'lib/assets/shapes_200.png'),
      OpArtTypes('Trees', OpArtType.Tree, 'lib/assets/tree_200.png'),
      OpArtTypes('Maze', OpArtType.Maze, 'lib/assets/maze_200.png'),
      OpArtTypes('Quads', OpArtType.Quads, 'lib/assets/quads_200.png'),
      // OpArtTypes('Plasma', OpArtType.Plasma, 'lib/assets/plasma.png'),
      OpArtTypes('String', OpArtType.String, 'lib/assets/string_200.png'),
      OpArtTypes('Rhombus', OpArtType.Rhombus, 'lib/assets/rhombus_200.png'),
      OpArtTypes(
          'Triangles', OpArtType.Triangles, 'lib/assets/triangles_200.png'),
      OpArtTypes('Squares', OpArtType.Squares, 'lib/assets/squares_200.png'),
      // OpArtTypes('Life', OpArtType.Life, 'lib/assets/squares.png'),
      OpArtTypes(
          'Spirals', OpArtType.Fibonacci, 'lib/assets/fibonacci_200.png'),
      OpArtTypes('Eye', OpArtType.Eye, 'lib/assets/eye_200.png'),
      OpArtTypes('Hexagons', OpArtType.Hexagons, 'lib/assets/hexagons_200.png'),
      OpArtTypes('Waves', OpArtType.Wave, 'lib/assets/wave_200.png'),
      OpArtTypes('Riley', OpArtType.Riley, 'lib/assets/riley_200.png'),
      OpArtTypes(
          'Neighbour', OpArtType.Neighbour, 'lib/assets/neighbour_200.png'),
    ];
    super.initState();
  }
}
