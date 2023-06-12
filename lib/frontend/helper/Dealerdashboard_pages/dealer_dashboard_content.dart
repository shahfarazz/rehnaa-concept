import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';

import '../Landlorddashboard_pages/landlord_dashboard_content.dart';

class DealerDashboardContent extends StatefulWidget {
  final String uid; // UID of the tenant

  const DealerDashboardContent({Key? key, required this.uid}) : super(key: key);

  @override
  _DealerDashboardContentState createState() => _DealerDashboardContentState();
}

class _DealerDashboardContentState extends State<DealerDashboardContent>
    with AutomaticKeepAliveClientMixin<DealerDashboardContent> {
  late Future<Tenant> _dealerFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Fetch tenant data from Firestore
    _dealerFuture = getTenantFromFirestore(widget.uid);
  }

  Future<Tenant> getTenantFromFirestore(String uid) async {
    try {
      // Fetch the tenant document from Firestore
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('Tenants').doc(uid).get();
      if (kDebugMode) {
        print('Fetched snapshot: $snapshot');
      }

      // Convert the snapshot to JSON
      Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;
      if (kDebugMode) {
        print('Tenant JSON: $json');
      }

      // Use the Tenant.fromJson method to create a Tenant instance
      Tenant tenant = await Tenant.fromJson(json);
      if (kDebugMode) {
        print('Created tenant: $tenant');
      }

      return tenant;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching tenant: $error');
      }
      rethrow;
    }
  }

  void showOptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedOption = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Padding(
                padding:
                    EdgeInsets.only(top: 16.0), // Adjust the value as needed
                child: Text(
                  'Payment Options',
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
                  buildOptionTile(
                    selectedOption: selectedOption,
                    optionImage: 'assets/easypaisa.png',
                    optionName: 'Easy Paisa',
                    onTap: () {
                      setState(() {
                        selectedOption = 'Easy Paisa';
                      });
                    },
                  ),
                  buildOptionTile(
                    selectedOption: selectedOption,
                    optionImage: 'assets/jazzcash.png',
                    optionName: 'Jazz Cash',
                    onTap: () {
                      setState(() {
                        selectedOption = 'Jazz Cash';
                      });
                    },
                  ),
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
                      Navigator.pop(context);
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
    );
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

    return FutureBuilder<Tenant>(
      future: _dealerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the data
          return LandlordDashboardContentSkeleton();
        } else if (snapshot.hasError) {
          // Handle any error that occurred while fetching the data
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // Fetch tenant
          Tenant tenant = snapshot.data!;

          // Format the rent for display
          String formattedRent = NumberFormat('#,##0').format(tenant.rent);

          // Return the widget tree with the fetched data
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: size.height * 0.05),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Welcome ${tenant.firstName}!',
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
                            tenant.pathToImage ?? 'assets/defaulticon.png',
                            width: 150,
                            height: 150,
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
                                  'Rent Accrue',
                                  style: GoogleFonts.montserrat(
                                    fontSize: size.width * 0.05,
                                    fontWeight: FontWeight.w400,
                                    color: const Color.fromARGB(150, 0, 0, 0),
                                  ),
                                ),
                                Text(
                                  'PKR $formattedRent',
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
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        showOptionDialog(); // Show the option dialog
                                      },
                                      child: Center(
                                        child: Text(
                                          "Pay",
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
            ),
          );
        }

        // By default, return an empty container if no data is available
        return Container();
      },
    );
  }
}