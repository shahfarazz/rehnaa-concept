import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/frontend/Screens/login_page.dart';

class DashboardContent extends StatefulWidget {
  final String uid; // UID of the landlord

  const DashboardContent({Key? key, required this.uid}) : super(key: key);

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent>
    with AutomaticKeepAliveClientMixin<DashboardContent> {
  late Future<Landlord> _landlordFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _landlordFuture = getLandlordFromFirestore(widget.uid);
  }

  Future<Landlord> getLandlordFromFirestore(String uid) async {
    try {
      // Fetch the landlord document from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Landlords')
          .doc(uid)
          .get();
      print('Fetched snapshot: $snapshot');

      // Convert the snapshot to JSON
      Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;
      print('Landlord JSON: $json');

      // Use the Landlord.fromJson method to create a Landlord instance
      Landlord landlord = await Landlord.fromJson(json);
      print('Created landlord: $landlord');

      return landlord;
    } catch (error) {
      print('Error fetching landlord: $error');
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the state is kept alive
    final Size size = MediaQuery.of(context).size;

    print('UID: ${widget.uid}');

    return FutureBuilder<Landlord>(
      future: _landlordFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the data
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
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
          return Column(
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
                        offset: Offset(0, 4), // changes position of shadow
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    },
                                    child: Center(
                                      child: Text(
                                        "Withdraw",
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
          );
        }

        // By default, return an empty container if no data is available
        return Container();
      },
    );
  }
}
