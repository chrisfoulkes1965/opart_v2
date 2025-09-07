import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'main.dart';
import 'model_opart.dart';
import 'opart_page.dart';

CarouselSliderController buttonCarouselController = CarouselSliderController();

class MyGallery extends StatefulWidget {
  final int currentImage;
  final bool paid;
  const MyGallery(this.currentImage, this.paid);
  @override
  _MyGalleryState createState() => _MyGalleryState();
}

class _MyGalleryState extends State<MyGallery> {
  bool carouselView = true;
  int currentIndex = 0;
  String currentSize = "8' x 10'";
  Color frameColor = Colors.black;

  final _rebuildDelete = ValueNotifier(0);
  bool showDelete = false;
  @override
  Widget build(BuildContext context) {
    if (widget.paid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        buttonCarouselController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        rebuildGallery.value++;
        buttonCarouselController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }

    return ValueListenableBuilder<int>(
        valueListenable: rebuildGallery,
        builder: (context, value, child) {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                  centerTitle: true,
                  title: const Text('My Gallery',
                      style: TextStyle(
                          fontFamily: 'Righteous',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black)),
                  leading: IconButton(
                      icon: const Icon(
                        Icons.home,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        // Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MyHomePage(title: 'OpArt Lab')));
                      }),
                  actions: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            carouselView = !carouselView;
                          });
                        },
                        icon: Icon(
                            carouselView
                                ? Icons.view_comfortable
                                : Icons.view_carousel_rounded,
                            color: Colors.black))
                  ]),
              body: savedOpArt.isEmpty
                  ? const Center(
                      child: Text(
                          'You have not yet saved any opArt to your gallery'))
                  : carouselView
                      ? Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Center(
                            child: CarouselSlider.builder(
                                carouselController: buttonCarouselController,
                                options: CarouselOptions(
                                    viewportFraction:
                                        MediaQuery.of(context).orientation ==
                                                Orientation.portrait
                                            ? 0.8
                                            : 0.3,
                                    enableInfiniteScroll: false,
                                    height: MediaQuery.of(context).size.height,
                                    enlargeCenterPage: true,
                                    initialPage: widget.currentImage - 1),
                                itemCount: savedOpArt.length,
                                itemBuilder: (BuildContext context, int index,
                                    int realIndex) {
                                  currentIndex = index;
                                  return GestureDetector(
                                    onLongPress: () {
                                      showDelete = !showDelete;
                                      _rebuildDelete.value++;
                                    },
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => OpArtPage(
                                                    savedOpArt[index]['type']
                                                        as OpArtType,
                                                    downloadNow: false,
                                                    opArtSettings:
                                                        savedOpArt[index],
                                                    animationValue: savedOpArt[
                                                                index][
                                                            'animationControllerValue']
                                                        as double,
                                                  )));
                                    },
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                color: Colors.black,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Container(
                                                    color: Colors.white,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Image.memory(
                                                        base64Decode(
                                                            savedOpArt[index]
                                                                    ['image']
                                                                as String),
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (savedOpArt[index]['paid'] ==
                                                null)
                                              Container(height: 12)
                                            else
                                              savedOpArt[index]['paid'] as bool
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text('purchased'),
                                                        IconButton(
                                                            icon: const Icon(Icons
                                                                .file_download),
                                                            onPressed: () {
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => OpArtPage(
                                                                            savedOpArt[index]['type']
                                                                                as OpArtType,
                                                                            downloadNow:
                                                                                true,
                                                                            opArtSettings:
                                                                                savedOpArt[index],
                                                                            animationValue:
                                                                                0.0,
                                                                          )));
                                                            })
                                                      ],
                                                    )
                                                  : Container(height: 12)
                                          ],
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
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: Center(
                                                          child:
                                                              FloatingActionButton(
                                                            onPressed: () {
                                                              if (savedOpArt[
                                                                          index]
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
                                                                              const Text('You have paid for this image. If you delete it you will not be able to download it again.'),
                                                                          actions: [
                                                                            ElevatedButton(
                                                                              onPressed: () {
                                                                                final DatabaseHelper helper = DatabaseHelper.instance;
                                                                                helper.delete(savedOpArt[index]['id'] as int);
                                                                                savedOpArt.removeAt(index);
                                                                                showDelete = false;
                                                                                rebuildGallery.value++;
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: const Text('Delete'),
                                                                            ),
                                                                            ElevatedButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: const Text('Cancel'),
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
                                                                            [
                                                                            'id']
                                                                        as int);
                                                                savedOpArt
                                                                    .removeAt(
                                                                        index);
                                                                showDelete =
                                                                    false;
                                                                rebuildGallery
                                                                    .value++;
                                                              }
                                                            },
                                                            backgroundColor:
                                                                Colors.white,
                                                            child: const Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ),
                                                      ))
                                                  : Container();
                                            }),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        )
                      : Center(
                          child: GridView.builder(
                              scrollDirection: MediaQuery.of(context)
                                          .orientation ==
                                      Orientation.portrait
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: MediaQuery.of(context)
                                                  .orientation ==
                                              Orientation.portrait
                                          ? MediaQuery.of(context).size.width /
                                              (MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  60)
                                          : 2 *
                                              MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  60)),
                              itemCount: savedOpArt.length,
                              itemBuilder: (BuildContext context, int index) {
                                currentIndex = index;
                                return Center(
                                  child: GestureDetector(
                                    onLongPress: () {
                                      showDelete = true;
                                      _rebuildDelete.value++;
                                    },
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => OpArtPage(
                                                    savedOpArt[index]['type']
                                                        as OpArtType,
                                                    downloadNow: false,
                                                    opArtSettings:
                                                        savedOpArt[index],
                                                    animationValue: 0.0,
                                                  )));
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                              color: Colors.black,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  color: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.memory(
                                                      base64Decode(
                                                          savedOpArt[index]
                                                                  ['image']
                                                              as String),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  ),
                                                ),
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
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: Center(
                                                          child:
                                                              FloatingActionButton(
                                                            onPressed: () {
                                                              final DatabaseHelper
                                                                  helper =
                                                                  DatabaseHelper
                                                                      .instance;
                                                              helper.delete(
                                                                  savedOpArt[index]
                                                                          ['id']
                                                                      as int);
                                                              savedOpArt
                                                                  .removeAt(
                                                                      index);
                                                              showDelete =
                                                                  false;
                                                              rebuildGallery
                                                                  .value++;
                                                            },
                                                            backgroundColor:
                                                                Colors.white,
                                                            child: const Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ),
                                                      ))
                                                  : Container();
                                            }),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ));
        });
  }

  @override
  void initState() {
    currentIndex = widget.currentImage;
    super.initState();
  }
}
