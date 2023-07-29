import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../backend/models/landlordmodel.dart';
import '../../../backend/models/tenantsmodel.dart';
import '../../../backend/services/helperfunctions.dart';
import '../../Screens/Landlord/landlord_dashboard.dart';
import '../../Screens/Tenant/tenant_dashboard.dart';

class TenantSecurityDepositPage extends StatefulWidget {
  final String uid;
  final String callerType;
  const TenantSecurityDepositPage(
      {super.key, required this.uid, required this.callerType});

  @override
  State<TenantSecurityDepositPage> createState() =>
      _TenantSecurityDepositPageState();
}

class _TenantSecurityDepositPageState extends State<TenantSecurityDepositPage> {
  Tenant? tenant;
  Landlord? landlord;
  bool isApplySecurity = false;
  var depositAmount = 0;

  Future<void> checkisApplySecurity() async {
    var myTenant = await FirebaseFirestore.instance
        .collection(widget.callerType)
        .doc(widget.uid)
        .get();

    setState(() {
      if (widget.callerType == 'Tenants') {
        tenant = Tenant.fromJson(myTenant.data()!);
      } else if (widget.callerType == 'Landlords') {
        landlord = Landlord.fromJson(myTenant.data()!);
      }
    });

    if (myTenant.data()?['isApplySecurity'] == true) {
      setState(() {
        isApplySecurity = true;
      });
    } else {
      print('reached here');
      setState(() {
        isApplySecurity = false;
      });
    }
    if (myTenant.data()?['securityDeposit'] != null) {
      setState(() {
        depositAmount = int.parse(myTenant.data()?['securityDeposit'] != ''
            ? (myTenant.data()?['securityDeposit'])
            : 0);
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
      appBar: _buildAppBar(size, context, widget.callerType, widget.uid),
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
                        Center(
                          child: Text(
                            // isApplySecurity ? 'Applied' :
                            'PKR ${NumberFormat('#,##0').format(depositAmount)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                              color: Colors.green,
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
                                if (depositAmount == 0) {
                                  //replace above with red flutter toast
                                  Fluttertoast.showToast(
                                    msg: 'Your deposit amount is 0',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  return;
                                } else if (isApplySecurity) {
                                  //replace above with red flutter toast
                                  Fluttertoast.showToast(
                                    msg:
                                        'You have already applied for security deposit withdrawal.',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  return;
                                }
                                // Handle button press
                                setState(() {
                                  isApplySecurity = true;
                                });
                                FirebaseFirestore.instance
                                    .collection(widget.callerType)
                                    .doc(widget.uid)
                                    .set({
                                  'isApplySecurity': true,
                                }, SetOptions(merge: true));

                                final Random random = Random();
                                final String randomID = random
                                    .nextInt(999999)
                                    .toString()
                                    .padLeft(6, '0');
                                var fullname;
                                if (widget.callerType == 'Tenants') {
                                  fullname = tenant!.firstName +
                                      ' ' +
                                      tenant!.lastName;
                                } else if (widget.callerType == 'Landlords') {
                                  fullname = landlord!.firstName +
                                      ' ' +
                                      landlord!.lastName;
                                }
                                FirebaseFirestore.instance
                                    .collection('AdminRequests')
                                    .doc(widget.uid)
                                    .set(
                                        {
                                      'securityDepositRequest':
                                          FieldValue.arrayUnion([
                                        {
                                          'fullname': fullname,
                                          'uid': widget.uid,
                                          'timestamp': Timestamp.now(),
                                          'requestID': randomID,
                                        }
                                      ]),
                                    },
                                        SetOptions(
                                            merge:
                                                true)); //TODO implement this call

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
                              widget.callerType == 'Tenants'
                                  ? tenant?.dateJoined
                                          ?.toDate()
                                          .toString()
                                          .substring(0, 10) ??
                                      'No date found'
                                  : widget.callerType == 'Landlords'
                                      ? landlord?.dateJoined
                                              ?.toDate()
                                              .toString()
                                              .substring(0, 10) ??
                                          'No date found'
                                      : '',

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

PreferredSizeWidget _buildAppBar(Size size, context, callerType, uid) {
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

                if (callerType == 'Tenants') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TenantDashboardPage(
                              uid: uid,
                            )),
                  );
                } else if (callerType == 'Landlords') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LandlordDashboardPage(
                              uid: uid,
                            )),
                  );
                }
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
