import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/backend/models/propertymodel.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';

import 'package:rehnaa/frontend/Screens/login_page.dart';

class DashboardContent extends StatelessWidget {
  final String uid; // UID of the landlord
  const DashboardContent({required this.uid});
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('landlords')
          .doc('YOUR_DOCUMENT_ID')
          .get(), // Replace 'YOUR_DOCUMENT_ID' with the actual document ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the data
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle any error that occurred while fetching the data
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // Extract the data from the snapshot
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          // Extract the relevant fields from the data map
          String firstName = data['firstName'];
          String lastName = data['lastName'];
          int balance = data['balance'];
          List<Map<String, dynamic>> propertyDataList = data['property'];
          List<Map<String, dynamic>> tenantDataList = data['tenant'];
          String pathToImage = data['pathToImage'];

          // Convert the propertyDataList to a list of Property instances
          List<Property> properties = propertyDataList.map((propertyData) {
            return Property(
              imagePath: List<String>.from(propertyData['imagePath']),
              type: propertyData['type'],
              beds: propertyData['beds'],
              baths: propertyData['baths'],
              garden: propertyData['garden'],
              living: propertyData['living'],
              floors: propertyData['floors'],
              carspace: propertyData['carspace'],
              description: propertyData['description'],
              title: propertyData['title'],
              location: propertyData['location'],
              price: propertyData['price'],
              landlord:
                  null, // You may need to provide the landlord instance here
              rehnaaRating: propertyData['rehnaaRating'],
              tenantRating: propertyData['tenantRating'],
              tenantReview: propertyData['tenantReview'],
            );
          }).toList();

          // Convert the tenantDataList to a list of Tenant instances
          List<Tenant> tenants = tenantDataList.map((tenantData) {
            return Tenant(
              firstName: tenantData['firstName'],
              lastName: tenantData['lastName'],
              description: tenantData['description'],
              rating: tenantData['rating'],
              rent: tenantData['rent'],
              creditPoints: tenantData['creditPoints'],
              propertyDetails: tenantData['propertyDetails'],
              cnicNumber: tenantData['cnicNumber'],
              contactNumber: tenantData['contactNumber'],
              tasdeeqVerification: tenantData['tasdeeqVerification'],
              familyMembers: tenantData['familyMembers'],
              // landlord: Landlord(balance: 10000, firstName: 'John', lastName: 'Doe'),
            );
          }).toList();

          // Create the landlord1 instance using the extracted data
          Landlord landlord1 = Landlord(
            firstName: firstName,
            lastName: lastName,
            balance: balance.toDouble(),
            property: properties,
            tenant: tenants,
            pathToImage: pathToImage,
          );

          // Format the balance for display
          String formattedBalance =
              NumberFormat('#,##0').format(landlord1.balance);

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
                      'Welcome ${landlord1.firstName}!',
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
                          landlord1.pathToImage ?? 'assets/defaulticon.png',
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
