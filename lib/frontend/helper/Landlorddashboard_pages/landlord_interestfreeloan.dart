import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/frontend/Screens/faq.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/landlordinvoice.dart';
import 'landlord_dashboard_content.dart';
import 'skeleton.dart';

class InterestFreeLoanPage extends StatefulWidget {
  final String uid;

  InterestFreeLoanPage({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _InterestFreeLoanPageState createState() => _InterestFreeLoanPageState();
}

class _InterestFreeLoanPageState extends State<InterestFreeLoanPage>
    with AutomaticKeepAliveClientMixin<InterestFreeLoanPage> {
  // late Future<Landlord> _landlordFuture;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _landlordStream;

  @override
  bool get wantKeepAlive => true;
  bool isWithdraw = false;

  @override
  void initState() {
    super.initState();
    // Fetch landlord data from Firestore
    // _landlordFuture = getLandlordFromFirestore(widget.uid);
    // Establish the Firestore stream for the landlord document
    print('widget.uid is ${widget.uid}');
    _landlordStream = FirebaseFirestore.instance
        .collection('Landlords')
        .doc(widget.uid)
        .snapshots();
  }

  Future<Landlord> getLandlordFromFirestore(String uid) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Landlords').doc(uid).get();
    if (kDebugMode) {
      print('Fetched snapshot: ${snapshot.data()}');
    }

    Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;
    if (kDebugMode) {
      print('Landlord JSON: $json');
    }

    Landlord landlord = await Landlord.fromJson(json);

    if (kDebugMode) {
      print('Created landlord: $landlord');
    }

    return landlord;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _buildAppBar(size, context),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200], // Set the background color
          padding: const EdgeInsets.symmetric(
            vertical: 100.0,
            horizontal: 16.0,
          ), // Updated padding
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Interest Free Loan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          color: Color(0xff45BF7A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Colors.grey, width: 0.1),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'You can apply for one month worth rent as an interest free loan after being a Rehnaa member for 6 months.',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30.0),
                              onTap: () {
                                //TODO in the future
                              },
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 32.0,
                                ),
                                child: Center(
                                  child: Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily:
                                          GoogleFonts.montserrat().fontFamily,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: buildTextCard2(
                    BoxConstraints(
                      maxWidth: size.width * 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextCard2(BoxConstraints constraints) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _landlordStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LandlordDashboardContentSkeleton();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          Map<String, dynamic> json =
              snapshot.data!.data() as Map<String, dynamic>;
          if (kDebugMode) {
            // print('Landlord JSON: $json');
          }
          Landlord landlord = Landlord.fromJson(json);

          if (json['isWithdraw'] != null && json['isWithdraw'] == true) {
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  isWithdraw = true;
                });
              }
            });
          }
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(constraints.maxWidth * 0.05),
              child: SelectableText.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          ' ${DateFormat('dd MMMM yyyy').format(landlord.dateJoined!.toDate())}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    TextSpan(
                      text: '\n\n  Date Joined',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: GoogleFonts.montserrat().fontFamily,

                        // color: Colors.green,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}

PreferredSizeWidget _buildAppBar(Size size, context) {
  return AppBar(
    toolbarHeight: 70,
    title: Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02, // 2% of the page height
        right:
            MediaQuery.of(context).size.width * 0.14, // 55% of the page width
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
            Color(0xff0FA697),
            Color(0xff45BF7A),
            Color(0xff0DF205),
          ],
        ),
      ),
    ),
  );
}