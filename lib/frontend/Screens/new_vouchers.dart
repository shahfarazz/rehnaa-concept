import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:easy_image_viewer/easy_image_viewer.dart';

import '../helper/Tenantdashboard_pages/tenant_propertyinfo.dart';

class NewVouchersPage extends StatefulWidget {
  const NewVouchersPage({super.key});

  @override
  State<NewVouchersPage> createState() => _NewVouchersPageState();
}

class _NewVouchersPageState extends State<NewVouchersPage> {
  //no matter who calls the page we have to fetch the data from
  // firebase storage and display it here
  // I want to load the images as fast as possible

  var images = [];
  var imageNames = [];
  double loadingProgress = 0.0;
  bool isLoading = true;
  // Timer? loadingTimer;
  String? searchQuery = '';

  void _loadImages() {
    FirebaseFirestore.instance
        .collection('Vouchers')
        .doc('voucherkey')
        .get()
        .then((value) {
      setState(() {
        images = value.data()?['urls'] ?? [];
        imageNames = value.data()?['names'] ?? [];
        isLoading = false;
      });
    });

    // Start the loading timer
    // loadingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
    //   setState(() {
    //     loadingProgress += 0.1;
    //   });
    // });
  }

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void dispose() {
    // loadingTimer
    // ?.cancel(); // Cancel the loading timer when the widget is disposed
    super.dispose();
  }

  @override
  //return a list of images fetched using the url in images, wrapped in a card with a listview
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(size, context),
      body: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(top: size.height * 0.3)),
                const SpinKitFadingCube(
                  color: Color.fromARGB(255, 30, 197, 83),
                ),
              ],
            )
          : images.length == 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(top: size.height * 0.1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48.0,
                                  color: Color(0xff33907c),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'No Vouchers available yet',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20.0,
                                    color: const Color(0xff33907c),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        cursorColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.green,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.green),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        addAutomaticKeepAlives: true,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          int reversedIndex = images.length - 1 - index;
                          String imageName = imageNames[reversedIndex];

                          if (searchQuery != null &&
                              imageName.toLowerCase().contains(searchQuery!)) {
                            return Column(
                              children: [
                                SizedBox(height: size.height * 0.02),
                                Text(
                                  '$imageName',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                  ),
                                ),
                                Card(
                                  child: GestureDetector(
                                    onTap: () async {
                                      // FullScreenImagePage
                                      var reversedImages = images.reversed;
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return FullScreenImagePage(
                                          currentIndex: index,
                                          imagePaths: reversedImages
                                              .map((image) => image.toString())
                                              .toList(),
                                        );
                                      }));
                                    },
                                    child: SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: CachedNetworkImage(
                                        imageUrl: images[reversedIndex],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(
                                          child: const SpinKitFadingCube(
                                            color: Color.fromARGB(
                                                255, 30, 197, 83),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

PreferredSizeWidget _buildAppBar(Size size, context) {
  return AppBar(
    toolbarHeight: 70,
    title: Padding(
      padding: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: [
              ClipPath(
                clipper: HexagonClipper(),
                child: Transform.scale(
                  scale: 0.87,
                  child: Container(
                    color: Colors.white,
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
              ClipPath(
                clipper: HexagonClipper(),
                child: Image.asset(
                  'assets/mainlogo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Stack(
          children: [],
        ),
      ),
    ],
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0FA697),
            Color(0xFF45BF7A),
            Color(0xFF0DF205),
          ],
        ),
      ),
    ),
  );
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double controlPointOffset = size.height / 6;

    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2 - controlPointOffset);
    path.lineTo(size.width, size.height / 2 + controlPointOffset);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2 + controlPointOffset);
    path.lineTo(0, size.height / 2 - controlPointOffset);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
