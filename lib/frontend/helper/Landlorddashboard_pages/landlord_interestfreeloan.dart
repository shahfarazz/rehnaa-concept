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

  // const InterestFreeLoanPage({Key? key}) : super(key: key);

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
    // try {
    // Fetch the landlord document from Firestore
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Landlords').doc(uid).get();
    if (kDebugMode) {
      print('Fetched snapshot: ${snapshot.data()}');
    }

    // Convert the snapshot to JSON
    Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;
    if (kDebugMode) {
      print('Landlord JSON: $json');
    }

    // Use the Landlord.fromJson method to create a Landlord instance
    Landlord landlord = await Landlord.fromJson(json);

    if (kDebugMode) {
      print('Created landlord: $landlord');
    }

    return landlord;
    // } catch (error) {
    //   if (kDebugMode) {
    //     print('Error fetching landlord: $error');
    //   }
    //   rethrow;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 65.0,
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
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Image.asset(
                  'assets/mainlogo.png',
                  // fit: BoxFit.cover,
                ),
              ),
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
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                "Interest Free Loan",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff33907c),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              buildTextCard(),
                              const SizedBox(height: 16),
                              buildTextCard2(),
                              const SizedBox(height: 330),
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

  Widget buildTextCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SelectableText.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                text:
                    'You can apply for one month worth rent as an interest free loan after being a Rehnaa member for six months.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),

          textAlign: TextAlign.justify, // Justify the text
        ),
      ),
    );
  }

  Widget buildTextCard2() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _landlordStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LandlordDashboardContentSkeleton();
        } else if (snapshot.hasError) {
          // Handle any error that occurred while fetching the data
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // Convert the snapshot to JSON
          // print('Snapshot: ${snapshot.data!.data()}');
          Map<String, dynamic> json =
              snapshot.data!.data() as Map<String, dynamic>;
          if (kDebugMode) {
            // print('Landlord JSON: $json');
          }
          // Use the Landlord.fromJson method to create a Landlord instance
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
              padding: const EdgeInsets.all(20.0),
              child: SelectableText.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          ' ${DateFormat('dd MMMMyyyy').format(landlord.dateJoined!.toDate())} \n\n  Date Joined',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                textAlign: TextAlign.justify, // Justify the text
              ),
            ),
          );
        }

        // By default, return an empty container if no data is available
        return Container();
      },
    );
  }
}
