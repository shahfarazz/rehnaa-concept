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
  late Future<Landlord> _landlordFuture;
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              Positioned(
                top: constraints.maxHeight * 0.04,
                left: constraints.maxWidth * 0.02,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: constraints.maxWidth * 0.1,
                    height: constraints.maxWidth * 0.1,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF33907C),
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
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.06),
                  SizedBox(
                    height: constraints.maxHeight * 0.1,
                    child: Image.asset(
                      'assets/mainlogo.png',
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.04),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                          child: Card(
                            color: const Color.fromARGB(255, 235, 235, 235),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                              child: Column(
                                children: [
                                  SizedBox(height: constraints.maxHeight * 0.02),
                                  Text(
                                    "Interest Free Loan",
                                    style: TextStyle(
                                      fontSize: constraints.maxWidth * 0.06,
                                      color: Color(0xff33907c),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: constraints.maxHeight * 0.03),
                                  buildTextCard(constraints),
                                  SizedBox(height: constraints.maxHeight * 0.03),
                                  buildTextCard2(constraints),
                                  SizedBox(height: constraints.maxHeight * 0.3),
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
          );
        },
      ),
    );
  }

  Widget buildTextCard(BoxConstraints constraints) {
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
                    'You can apply for one month worth rent as an interest free loan after being a Rehnaa member for six months.',
                style: TextStyle(fontSize: constraints.maxWidth * 0.04),
              ),
            ],
          ),
          textAlign: TextAlign.justify,
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
                          ' ${DateFormat('dd MMMMyyyy').format(landlord.dateJoined!.toDate())} \n\n  Date Joined',
                      style: TextStyle(fontSize: constraints.maxWidth * 0.04),
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