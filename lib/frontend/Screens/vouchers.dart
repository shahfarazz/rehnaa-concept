import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:photo_view/photo_view.dart';
import 'package:rehnaa/frontend/Screens/splash.dart';

class Voucher {
  final String url;
  final ImageProvider imageProvider;
  final firebase_storage.Reference ref;

  Voucher(this.url, this.ref, this.imageProvider);
}

class VouchersPage extends StatefulWidget {
  const VouchersPage({Key? key}) : super(key: key);

  @override
  _VouchersPageState createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  Stream<List<Voucher>>? _vouchersStream;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _vouchersStream = _fetchVouchers().asStream();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<List<Voucher>> _fetchVouchers() async {
    try {
      firebase_storage.ListResult listResult = await firebase_storage
          .FirebaseStorage.instance
          .ref('images/vouchers/')
          .listAll();
      List<Voucher> vouchersList = [];
      for (var ref in listResult.items) {
        String url = await ref.getDownloadURL();
        final response = await http.get(Uri.parse(url));
        Uint8List imageData = response.bodyBytes;
        vouchersList.add(Voucher(url, ref, MemoryImage(imageData)));
      }
      return vouchersList;
    } catch (error) {
      print('Error fetching vouchers: $error');
      return [];
    }
  }

  void _debounceFetchVouchers() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _vouchersStream = _fetchVouchers().asStream();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
      final Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: _buildAppBar(size, context),

      body: Stack(
        children: [
          
          Column(
            children: [
              const SizedBox(height: 30),
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.1,
              //   child: Image.asset(
              //     'assets/mainlogo.png',
              //   ),
              // ),
              const SizedBox(height: 20),
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
                              const Text(
                                "Vouchers",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFF33907C),
                                  fontWeight: FontWeight.bold,
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
    return StreamBuilder<List<Voucher>>(
      stream: _vouchersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF45BF7A)),
          );
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
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: progress == null
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF45BF7A)),
                                  )
                                : LinearProgressIndicator(
                                    value: progress.progress,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF45BF7A)),
                                  ),
                          ),
                          imageUrl: voucher.url,
                          fit: BoxFit.cover,
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
        // top: MediaQuery.of(context).size.height * 0.02, // 2% of the page height
        right: MediaQuery.of(context).size.width * 0.14, // 55% of the page width
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
            // const SizedBox(width: 8),
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Stack(
            children: [
              
              
            ],
          ),
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff0FA697),
              Color(0xff45BF7A),
              Color(0xff0DF205),
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

