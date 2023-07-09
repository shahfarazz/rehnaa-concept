import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/frontend/Screens/faq.dart';
// import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/landlordinvoice.dart';
import 'landlord_dashboard_content.dart';
// import 'skeleton.dart';

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
  bool isAppliedInterestLoan = false;

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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: //isApplied
                          // ? [Colors.grey, Colors.grey, Colors.grey]
                          [
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
                      onTap: () async {
                        Timestamp? joinDate = await FirebaseFirestore.instance
                            .collection('Landlords')
                            .doc(widget.uid)
                            .get()
                            .then((value) {
                          return value.data()!['dateJoined'];
                        });

                        DateTime? joinDateTime = joinDate?.toDate();
                        DateTime? now = DateTime.now();

                        if (now.difference(joinDateTime!).inDays < 180) {
                          Fluttertoast.showToast(
                            msg:
                                'You must be a member for 6 months to apply for an interest free loan.',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          final Random random = Random();
                          final String randomID =
                              random.nextInt(999999).toString().padLeft(6, '0');
                          FirebaseFirestore.instance
                              .collection('Landlords')
                              .doc(widget.uid)
                              .get()
                              .then((value) {
                            Landlord landlord =
                                Landlord.fromJson(value.data()!);
                            if (isAppliedInterestLoan == false) {
                              FirebaseFirestore.instance
                                  .collection('AdminRequests')
                                  .doc(widget.uid)
                                  .set({
                                'interestFreeLoanRequest':
                                    FieldValue.arrayUnion([
                                  {
                                    'fullname':
                                        '${landlord?.firstName} ${landlord?.lastName}',
                                    'uid': widget.uid,
                                    'timestamp': Timestamp.now(),
                                    'requestID': randomID,
                                  }
                                ]),
                                'timestamp': Timestamp.now()
                              }, SetOptions(merge: true));
                              setState(() {
                                isAppliedInterestLoan = true;
                              });
                              FirebaseFirestore.instance
                                  .collection('Landlords')
                                  .doc(widget.uid)
                                  .update({
                                'isAppliedInterestLoan': true,
                              });
                              Fluttertoast.showToast(
                                msg:
                                    'You have successfully applied for an interest free loan.',
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg:
                                    'You have already applied for an interest free loan.',
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          });
                        }

                        // if (isApplied) {
                        //   return;
                        // }
                        // // Handle button press
                        // setState(() {
                        //   isApplied = true;
                        // });
                        // FirebaseFirestore.instance
                        //     .collection('Landlords')
                        //     .doc(widget.uid)
                        //     .set({
                        //   'isApplied': true,
                        // }, SetOptions(merge: true));

                        // //send an AdminRequest for the tenant
                        // // FirebaseFirestore.instance
                        // //     .collection('AdminRequests')
                        // //     .doc(widget.uid)
                        // //     .set({
                        // //   'rentAccrualRequest': FieldValue.arrayUnion([
                        // //     {
                        // //       'fullname':
                        // //           '${landlord?.firstName} ${landlord?.lastName}',
                        // //       'uid': widget.uid,
                        // //     }
                        // //   ]),
                        // //   'timestamp': Timestamp.now()
                        // // }, SetOptions(merge: true)); //TODO implement this call

                        // //send a notification to the tenant that the request has been sent
                        // FirebaseFirestore.instance
                        //     .collection('Notifications')
                        //     .doc(widget.uid)
                        //     .set({
                        //   'notifications': FieldValue.arrayUnion([
                        //     {
                        //       'title':
                        //           'Your request for rent advance has been sent to the admin.',
                        //     }
                        //   ])
                        // }, SetOptions(merge: true));

                        // // show in green snackbar that the request has been sent
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     backgroundColor: Colors.green,
                        //     content: Text(
                        //       'Your request for rent advance has been sent to the admin.\nRehnaa team will contact you shortly. Thanks',
                        //       style: TextStyle(
                        //         fontSize: 18,
                        //         fontFamily: GoogleFonts.montserrat().fontFamily,
                        //       ),
                        //     ),
                        //   ),
                        // );
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
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: buildTextCard2(
                    BoxConstraints(
                      maxWidth: size.width * 1,
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
    final Size size = MediaQuery.of(context).size;

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

          if (json['isAppliedInterestLoan'] != null &&
              json['isAppliedInterestLoan'] == true) {
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  isAppliedInterestLoan = true;
                });
              }
            });
          }
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Align contents vertically in the center
                children: [
                  Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: size.width * 0.27)),
                      Text(
                        DateFormat('dd MMMM yyyy').format(
                            landlord?.dateJoined?.toDate() ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          color: Color(0xff45BF7A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: size.width * 0.27)),
                      Text(
                        'Date Joined',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
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
