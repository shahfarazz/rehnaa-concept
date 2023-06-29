import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../backend/models/tenantsmodel.dart';
import '../../Screens/Landlord/landlord_dashboard.dart';

class TenantSecurityDepositPage extends StatefulWidget {
  final String uid;
  const TenantSecurityDepositPage({super.key, required this.uid});

  @override
  State<TenantSecurityDepositPage> createState() =>
      _TenantSecurityDepositPageState();
}

class _TenantSecurityDepositPageState extends State<TenantSecurityDepositPage> {
  Tenant? tenant;
  bool isApplySecurity = false;
  var depositAmount = 100000;

  Future<void> checkisApplySecurity() async {
    var myTenant = await FirebaseFirestore.instance
        .collection('Tenants')
        .doc(widget.uid)
        .get();

    setState(() {
      tenant = Tenant.fromJson(myTenant.data()!);
    });

    if (myTenant.data()?['isApplySecurity'] == true) {
      setState(() {
        isApplySecurity = true;
      });
    }
    if (myTenant.data()?['depositAmount'] != null) {
      setState(() {
        depositAmount = myTenant.data()?['depositAmount'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkisApplySecurity();
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
                        'Security Deposit',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff45BF7A),
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Colors.grey, width: 0.1),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            gradient: const LinearGradient(
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
                              onTap: //nothing
                                  () {},
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 32.0,
                                ),
                                child: Center(
                                  child: Text(
                                    // isApplySecurity ? 'Applied' :
                                    'PKR ${NumberFormat('#,##0').format(depositAmount)}',
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
                        SizedBox(height: size.height * 0.02),
                        Text(
                          '1 month Security Deposit to Rehnaa can only be withdrawn at the end of the contract from Rehnaa.',
                          style: TextStyle(
                            fontSize: 16,
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
                              colors: isApplySecurity
                                  ? [
                                      Colors.grey,
                                      Colors.grey,
                                      Colors.grey,
                                    ]
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
                              onTap: () {
                                if (isApplySecurity) {
                                  return;
                                }
                                // Handle button press
                                setState(() {
                                  isApplySecurity = true;
                                });
                                FirebaseFirestore.instance
                                    .collection('Tenants')
                                    .doc(widget.uid)
                                    .set({
                                  'isApplySecurity': true,
                                }, SetOptions(merge: true));

                                // //send an AdminRequest for the tenant
                                // FirebaseFirestore.instance
                                //     .collection('AdminRequests')
                                //     .doc(widget.uid)
                                //     .set(
                                //         {
                                //       'rentAccrualRequest':
                                //           FieldValue.arrayUnion([
                                //         {
                                //           'fullname':
                                //               '${tenant?.firstName} ${tenant?.lastName}',
                                //           'uid': widget.uid,
                                //         }
                                //       ]),
                                //       'timestamp': Timestamp.now()
                                //     },
                                //         SetOptions(
                                //             merge:
                                //                 true)); //TODO implement this call

                                // //send a notification to the tenant that the request has been sent
                                FirebaseFirestore.instance
                                    .collection('Notifications')
                                    .doc(widget.uid)
                                    .set({
                                  'notifications': FieldValue.arrayUnion([
                                    {
                                      'title':
                                          'Your request for security deposit withdrawal has been sent to the admin.',
                                    }
                                  ])
                                }, SetOptions(merge: true));

                                // // show in green snackbar that the request has been sent
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      'Your request for security deposit withdrawal has been sent to the admin.\nRehnaa team will contact you shortly. Thanks',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily:
                                            GoogleFonts.montserrat().fontFamily,
                                      ),
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
                                    // isApplySecurity ? 'Applied' :
                                    'Withdraw',
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Padding(
                            //     padding:
                            //         EdgeInsets.only(left: size.width * 0.27)),
                            Text(
                              DateFormat('dd MMMM yyyy').format(
                                  tenant?.dateJoined?.toDate() ??
                                      DateTime.now()),

                              // 'Date Joined',
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
                            // Padding(
                            //     padding:
                            //         EdgeInsets.only(left: size.width * 0.27)),
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
                ),
              ],
            ),
          ),
        ),
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