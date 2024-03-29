import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/Tenant/tenant_dashboard.dart';

import '../../../backend/models/tenantsmodel.dart';
import '../../../backend/services/helperfunctions.dart';
import '../../Screens/Landlord/landlord_dashboard.dart';

class TenantRentAccrualPage extends StatefulWidget {
  String uid;
  TenantRentAccrualPage({Key? key, required this.uid}) : super(key: key);
  @override
  _TenantRentAccrualPageState createState() => _TenantRentAccrualPageState();
}

class _TenantRentAccrualPageState extends State<TenantRentAccrualPage> {
  bool isApplied = false;
  Tenant? tenant;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIsApplied();
  }

  Future<void> checkIsApplied() async {
    var myTenant = await FirebaseFirestore.instance
        .collection('Tenants')
        .doc(widget.uid)
        .get();

    tenant = Tenant.fromJson(myTenant.data()!);
    // print('dateJoined is ${tenant!.dateJoined}');

    if (myTenant.data()?['isApplied'] == true) {
      // setState(() {
      isApplied = true;
      // });
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(size, context, widget.uid),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200], // Set the background color
          padding: EdgeInsets.symmetric(
            vertical: 100,
            horizontal: size.width * 0.05,
          ), // Updated padding
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Rent Accrual',
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
                          'After being a Rehnaa member for 6 months, tenants can accrue their rent for a particular month at a 3% interest rate per month.',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: GoogleFonts.montserrat().fontFamily),
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
                              colors: isApplied
                                  ? [Colors.grey, Colors.grey, Colors.grey]
                                  : [
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
                                Timestamp? joinDate = await FirebaseFirestore
                                    .instance
                                    .collection('Tenants')
                                    .doc(widget.uid)
                                    .get()
                                    .then((value) {
                                  return value.data()!['dateJoined'];
                                });

                                DateTime? joinDateTime = joinDate?.toDate();
                                DateTime? now = DateTime.now();

                                if (now.difference(joinDateTime!).inDays <
                                    180) {
                                  Fluttertoast.showToast(
                                    msg:
                                        'You must be a member for 6 months to apply for Rent Accrual.',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  return;
                                }
                                if (isApplied) {
                                  return;
                                }
                                // Handle button press
                                setState(() {
                                  isApplied = true;
                                });
                                FirebaseFirestore.instance
                                    .collection('Tenants')
                                    .doc(widget.uid)
                                    .set({
                                  'isApplied': true,
                                }, SetOptions(merge: true));

                                // Generate a random ID
                                final Random random = Random();
                                final String randomID = random
                                    .nextInt(999999)
                                    .toString()
                                    .padLeft(6, '0');

                                //send an AdminRequest for the tenant
                                FirebaseFirestore.instance
                                    .collection('AdminRequests')
                                    .doc(widget.uid)
                                    .set({
                                  'rentAccrualRequest': FieldValue.arrayUnion([
                                    {
                                      'fullname':
                                          '${tenant?.firstName} ${tenant?.lastName}',
                                      'uid': widget.uid,
                                      'requestID': randomID,
                                      'timestamp': Timestamp.now()
                                    }
                                  ]),
                                }, SetOptions(merge: true));

                                //send a notification to the tenant that the request has been sent
                                FirebaseFirestore.instance
                                    .collection('Notifications')
                                    .doc(widget.uid)
                                    .set({
                                  'notifications': FieldValue.arrayUnion([
                                    {
                                      'title':
                                          'Your request for rent accrual has been sent to the admin.',
                                    }
                                  ])
                                }, SetOptions(merge: true));

                                // show in green snackbar that the request has been sent
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      'Your request for rent accrual has been sent to the admin.',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: GoogleFonts.montserrat()
                                              .fontFamily),
                                    ),
                                  ),
                                );
                              },
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 32.0,
                                ),
                                child: Center(
                                  child: Text(
                                    isApplied! ? 'Applied' : 'Apply',
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
                Container(
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
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tenant?.dateJoined
                                      ?.toDate()
                                      .toString()
                                      .substring(0, 10) ??
                                  'Old User type datejoined not available',
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Date Joined',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily),
                            ),
                          ],
                        ),
                      ],
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
}

PreferredSizeWidget _buildAppBar(Size size, context, uid) {
  return AppBar(
    toolbarHeight: 70,
    title: Padding(
      padding: EdgeInsets.only(
        right:
            MediaQuery.of(context).size.width * 0.14, // 55% of the page width
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                // Add your desired logic here
                // print('tapped');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TenantDashboardPage(
                            uid: uid,
                          )),
                );
              },
              child: Stack(
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
              )),
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
