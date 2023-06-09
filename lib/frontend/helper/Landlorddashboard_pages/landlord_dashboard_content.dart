import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'skeleton.dart';

class LandlordDashboardContent extends StatefulWidget {
  final String uid;
  final bool isWithdraw;
  final Function(bool) onUpdateWithdrawState;

  const LandlordDashboardContent({
    Key? key,
    required this.uid,
    required this.isWithdraw,
    required this.onUpdateWithdrawState,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LandlordDashboardContentState createState() =>
      _LandlordDashboardContentState();
}

class _LandlordDashboardContentState extends State<LandlordDashboardContent>
    with AutomaticKeepAliveClientMixin<LandlordDashboardContent> {
  late Future<Landlord> _landlordFuture;

  @override
  bool get wantKeepAlive => true;
  bool isWithdraw = false;

  @override
  void initState() {
    super.initState();
    // Fetch landlord data from Firestore
    _landlordFuture = getLandlordFromFirestore(widget.uid);
  }

  Future<Landlord> getLandlordFromFirestore(String uid) async {
    try {
      // Fetch the landlord document from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Landlords')
          .doc(uid)
          .get();
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
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching landlord: $error');
      }
      rethrow;
    }
  }

  void showOptionDialog(Function callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedOption = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Your AlertDialog code goes here...
            return AlertDialog(
              title: const Padding(
                padding:
                    EdgeInsets.only(top: 16.0), // Adjust the value as needed
                child: Text(
                  'Withdraw Options',
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
                ),
              ),

              titlePadding: const EdgeInsets.fromLTRB(
                  20.0, 16.0, 16.0, 0.0), // padding above title
              contentPadding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Divider(
                    color: Colors.grey,
                  ), // added grey line
                  buildOptionTile(
                    selectedOption: selectedOption,
                    optionImage: 'assets/cashicon.png',
                    optionName: 'Cash',
                    onTap: () {
                      setState(() {
                        selectedOption = 'Cash';
                      });
                    },
                  ),
                  // buildOptionTile(
                  //   selectedOption: selectedOption,
                  //   optionImage: 'assets/easypaisa.png',
                  //   optionName: 'Easy Paisa',
                  //   onTap: () {
                  //     setState(() {
                  //       selectedOption = 'Easy Paisa';
                  //     });
                  //   },
                  // ),
                  // buildOptionTile(
                  //   selectedOption: selectedOption,
                  //   optionImage: 'assets/jazzcash.png',
                  //   optionName: 'Jazz Cash',
                  //   onTap: () {
                  //     setState(() {
                  //       selectedOption = 'Jazz Cash';
                  //     });
                  //   },
                  // ),
                  buildOptionTile(
                    selectedOption: selectedOption,
                    optionImage: 'assets/banktransfer.png',
                    optionName: 'Bank Transfer',
                    onTap: () {
                      setState(() {
                        selectedOption = 'Bank Transfer';
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedOption.isNotEmpty ? Colors.grey : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedOption.isNotEmpty ? Colors.green : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (selectedOption.isNotEmpty) {
                      if (kDebugMode) {
                        print('Selected option: $selectedOption');
                      }
                      Fluttertoast.showToast(
                        msg:
                            'An admin will contact you soon regarding your payment via: $selectedOption',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Color(0xff45BF7A),
                      );
                      Navigator.pop(context);

                      setState(() {
                        isWithdraw = true;
                      });
                    } else {
                      if (kDebugMode) {
                        print('Please select an option');
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) => callback());
  }

  void someFunction() {
    showOptionDialog(() {
      // setState(() {
      //   isWithdraw = true;
      // });
      widget.onUpdateWithdrawState(isWithdraw);
    });
  }

  Widget buildOptionTile({
    String selectedOption = "",
    String optionImage = "",
    String optionName = "",
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: selectedOption == optionName
          ? const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 10,
            )
          : const Icon(Icons.circle, size: 20),
      title: Row(
        children: [
          Image.asset(
            optionImage,
            width: 50,
            height: 30,
          ),
          const SizedBox(width: 20),
          Text(optionName),
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the state is kept alive
    final Size size = MediaQuery.of(context).size;

    if (kDebugMode) {
      print('UID: ${widget.uid}');
    }

    return FutureBuilder<Landlord>(
      future: _landlordFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LandlordDashboardContentSkeleton();
        } else if (snapshot.hasError) {
          // Handle any error that occurred while fetching the data
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // Fetch landlord
          Landlord landlord = snapshot.data!;

          // Format the balance for display
          String formattedBalance =
              NumberFormat('#,##0').format(landlord.balance);

          // Return the widget tree with the fetched data

          return SingleChildScrollView(
              // child: AnimatedContainer(
              //     duration: Duration(milliseconds: 500),
              //     curve: Curves.easeInOut,
              //     height:
              //         _showContent ? size.height : 0, // Show/hide the content
              child: Column(
            children: <Widget>[
              SizedBox(height: size.height * 0.05),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Welcome ${landlord.firstName}!',
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CircleAvatar(
                      radius: 75,
                      child: ClipOval(
                        child: Image.asset(
                          landlord.pathToImage ?? 'assets/defaulticon.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                ],
              ),
              Center(
                child: Container(
                  width: size.width * 0.8,
                  height: size.height * 0.4, // Adjust the height as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset:
                            const Offset(0, 4), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Available Balance',
                                style: GoogleFonts.montserrat(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromARGB(150, 0, 0, 0),
                                ),
                              ),
                              Text(
                                'PKR $formattedBalance',
                                style: GoogleFonts.montserrat(
                                  fontSize: size.width * 0.07,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: size.height * 0.05),
                              Container(
                                width: size.width *
                                    0.6, // Increase the width as needed
                                height: size.height * 0.06,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isWithdraw
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
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      isWithdraw
                                          ? null
                                          : someFunction(); // Show the option dialog
                                    },
                                    child: Center(
                                      child: Text(
                                        isWithdraw
                                            ? "Withdraw Requested"
                                            : "Withdraw",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 18,
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
                    ),
                  ),
                ),
              ),
            ],
          ));
          // )));
        }

        // By default, return an empty container if no data is available
        return Container();
      },
    );
  }
}

class LandlordDashboardContentSkeleton extends StatelessWidget {
  const LandlordDashboardContentSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: size.height * 0.05),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Skeleton(width: size.width * 0.5, height: 30),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CircleSkeleton(
                  size: 150,
                ),
              ),
              SizedBox(height: size.height * 0.05),
            ],
          ),
          Center(
            child: Container(
              width: size.width * 0.8,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Skeleton(width: size.width * 0.5, height: 20),
                        SizedBox(height: 16),
                        Skeleton(width: size.width * 0.5, height: 30),
                        SizedBox(height: size.height * 0.05),
                        Skeleton(width: size.width * 0.5, height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
