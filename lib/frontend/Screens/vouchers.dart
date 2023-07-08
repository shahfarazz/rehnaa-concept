import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/landlord_tenants.dart';

class Voucher {
  final String url;
  final ImageProvider imageProvider;
  final firebase_storage.Reference ref;

  Voucher(this.url, this.ref, this.imageProvider);
}

class VouchersPage extends StatefulWidget {
  final bool isNewVoucher; // Add isNewVoucher parameter
  const VouchersPage({Key? key, this.isNewVoucher = false}) : super(key: key);

  @override
  _VouchersPageState createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Voucher>> _vouchersFuture;

  @override
  void initState() {
    super.initState();
    _vouchersFuture = _fetchVouchers();
  }

  @override
  bool get wantKeepAlive => true;

  Future<List<Voucher>> _fetchVouchers() async {
    try {
      // Fetch voucher document from Firestore
      DocumentSnapshot<Map<String, dynamic>> voucherSnapshot =
          await FirebaseFirestore.instance
              .collection('Vouchers')
              .doc('voucherkey')
              .get();

      Map<String, dynamic>? data = voucherSnapshot.data();
      List<dynamic> voucherUrls = data!['urls'] ?? [];

      List<Future<Voucher>> downloadTasks = [];

      for (String url in voucherUrls) {
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.refFromURL(url);
        downloadTasks.add(_fetchVoucher(ref));
      }

      List<Voucher> vouchersList = await Future.wait(downloadTasks);
      return vouchersList;
    } catch (error) {
      print('Error fetching vouchers: $error');
      return [];
    }
  }

  Future<Voucher> _fetchVoucher(firebase_storage.Reference ref) async {
    String url = await ref.getDownloadURL();
    final response = await http.get(Uri.parse(url));
    Uint8List imageData = await compressImage(response.bodyBytes);
    return Voucher(url, ref, MemoryImage(imageData));
  }

  Future<Uint8List> compressImage(Uint8List imageData) async {
    final compressedImage = await FlutterImageCompress.compressWithList(
      imageData,
      minHeight: 1920,
      minWidth: 1080,
      quality: 70,
    );
    return Uint8List.fromList(compressedImage!);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _buildAppBar(size, context),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        color: const Color.fromARGB(255, 235, 235, 235),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                "Vouchers",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFF33907C),
                                  fontWeight: FontWeight.bold,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 16),
                              buildRoundedImageCards(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRoundedImageCards(BuildContext context) {
    return FutureBuilder<List<Voucher>>(
      future: _vouchersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LandlordTenantSkeleton();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        List<Voucher> vouchersList = snapshot.data ?? [];

        Size size = MediaQuery.of(context).size;

        return SizedBox(
          height: size.height * 0.8,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: vouchersList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              Voucher voucher = vouchersList[index];
              return Padding(
                padding: const EdgeInsets.only(right: 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Card(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExpandedImageDialog(
                              imageProvider: voucher.imageProvider,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: CachedNetworkImage(
                          imageUrl: voucher.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SpinKitFadingCube(
                            color: Color.fromARGB(255, 30, 197, 83),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ExpandedImageDialog extends StatelessWidget {
  final ImageProvider imageProvider;

  const ExpandedImageDialog({Key? key, required this.imageProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            child: PhotoView(
              imageProvider: imageProvider,
              backgroundDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
              minScale: PhotoViewComputedScale.contained * 1.0,
              maxScale: PhotoViewComputedScale.covered * 2.0,
              initialScale: PhotoViewComputedScale.contained,
              basePosition: Alignment.center,
              heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
              customSize: MediaQuery.of(context).size,
            ),
          ),
          Positioned(
            top: 40.0,
            left: 10.0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF33907C),
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
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.white,
                ),
              ),
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
