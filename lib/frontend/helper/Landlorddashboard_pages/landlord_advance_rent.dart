import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../backend/models/landlordmodel.dart';
import '../../Screens/Landlord/landlord_dashboard.dart';

class LandlordAdvanceRentPage extends StatefulWidget {
  final String uid;
  const LandlordAdvanceRentPage({super.key, required this.uid});

  @override
  State<LandlordAdvanceRentPage> createState() =>
      _LandlordAdvanceRentPageState();
}

class _LandlordAdvanceRentPageState extends State<LandlordAdvanceRentPage> {
  bool isApplied = false;
  Landlord? landlord;

  Future<void> checkIsApplied() async {
    var myLandlord = await FirebaseFirestore.instance
        .collection('Landlords')
        .doc(widget.uid)
        .get();

    setState(() {
      landlord = Landlord.fromJson(myLandlord.data()!);
    });

    if (myLandlord.data()?['isApplied'] == true) {
      setState(() {
        isApplied = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkIsApplied();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: //just add a back button
          AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff45BF7A),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LandlordDashboardPage(uid: widget.uid),
              ),
            );
          },
        ),
      ),
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Rent advance',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
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
                        const Text(
                          'You can apply for three months advance rent at 3% interest rate per month',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Montserrat',
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
                              onTap: () {
                                if (isApplied) {
                                  return;
                                }
                                // Handle button press
                                setState(() {
                                  isApplied = true;
                                });
                                FirebaseFirestore.instance
                                    .collection('Landlords')
                                    .doc(widget.uid)
                                    .set({
                                  'isApplied': true,
                                }, SetOptions(merge: true));

                                //send an AdminRequest for the tenant
                                // FirebaseFirestore.instance
                                //     .collection('AdminRequests')
                                //     .doc(widget.uid)
                                //     .set({
                                //   'rentAccrualRequest': FieldValue.arrayUnion([
                                //     {
                                //       'fullname':
                                //           '${landlord?.firstName} ${landlord?.lastName}',
                                //       'uid': widget.uid,
                                //     }
                                //   ]),
                                //   'timestamp': Timestamp.now()
                                // }, SetOptions(merge: true)); //TODO implement this call

                                //send a notification to the tenant that the request has been sent
                                FirebaseFirestore.instance
                                    .collection('Notifications')
                                    .doc(widget.uid)
                                    .set({
                                  'notifications': FieldValue.arrayUnion([
                                    {
                                      'title':
                                          'Your request for rent advance has been sent to the admin.',
                                    }
                                  ])
                                }, SetOptions(merge: true));

                                // show in green snackbar that the request has been sent
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      'Your request for rent advance has been sent to the admin.\nRehnaa team will contact you shortly. Thanks',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Montserrat',
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
                                    isApplied ? 'Applied' : 'Apply',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
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
                          children: [
                            Text(
                              landlord?.dateJoined
                                      ?.toDate()
                                      .toString()
                                      .substring(0, 10) ??
                                  'Date Joined',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                color: Color(0xff45BF7A),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Date Joined',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Montserrat',
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
