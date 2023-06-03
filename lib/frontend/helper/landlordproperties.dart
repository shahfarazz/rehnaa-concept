import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rehnaa/frontend/Screens/dashboard.dart';

import '../../backend/models/propertymodel.dart';
import 'Dashboard_pages/landlord_propertyinfo.dart';

class LandlordPropertiesPage extends StatelessWidget {
  final String uid; // UID of the landlord
  LandlordPropertiesPage({required this.uid});

  String firstName = '';
  String lastName = '';
  String pathToImage = '';

  Future<List<Property>> fetchProperties(List<dynamic> propertyDataList) async {
    List<Future<DocumentSnapshot<Map<String, dynamic>>>> propertySnapshots = [];
    for (var propertyDataRef in propertyDataList) {
      propertySnapshots.add(propertyDataRef.get());
    }

    List<DocumentSnapshot<Map<String, dynamic>>> propertyResults =
        await Future.wait(propertySnapshots);
    List<Property> properties = [];

    for (var propertySnapshot in propertyResults) {
      Map<String, dynamic>? propertyData = propertySnapshot.data();
      if (propertyData != null) {
        // print('propertyData: $propertyData');

        DocumentReference<Map<String, dynamic>> landlordRef =
            propertyData['landlordRef'];

        DocumentSnapshot<Map<String, dynamic>> landlordSnapshot =
            await landlordRef.get();

        if (landlordSnapshot.exists) {
          Map<String, dynamic> landlordData = landlordSnapshot.data()!;
          firstName = landlordData['firstName'];
          lastName = landlordData['lastName'];
          pathToImage = landlordData['pathToImage'];

          properties.add(Property(
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
            price: propertyData['price'].toDouble(),
            rehnaaRating: propertyData['rehnaaRating'],
            tenantRating: propertyData['tenantRating'],
            tenantReview: propertyData['tenantReview'],
          ));
        }
      }
    }

    return properties;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Property>>(
      future: fetchPropertiesFromFirebase(),
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
          List<Property> properties = snapshot.data!;
          return Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            body: ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                return PropertyCard(
                  property: properties[index],
                  firstName: firstName, // Pass the firstName string
                  lastName: lastName, // Pass the lastName string
                  pathToImage: pathToImage, // Pass the pathToImage string
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyPage(
                            property: properties[index],
                            firstName: firstName,
                            lastName: lastName,
                            pathToImage: pathToImage),
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else {
          // Handle the case where no data is available
          return Text('No data available');
        }
      },
    );
  }

  Future<List<Property>> fetchPropertiesFromFirebase() async {
    // Fetch the document snapshot for the landlord
    DocumentSnapshot<Map<String, dynamic>> landlordSnapshot =
        await FirebaseFirestore.instance.collection('Landlords').doc(uid).get();

    if (landlordSnapshot.exists) {
      Map<String, dynamic> data = landlordSnapshot.data()!;

      List<DocumentReference<Map<String, dynamic>>> propertyDataList =
          (data['propertyRef'] as List<dynamic>)
              .cast<DocumentReference<Map<String, dynamic>>>();

      // Fetch properties using the fetchProperties method
      return fetchProperties(propertyDataList);
    } else {
      // Handle the case where the landlord document doesn't exist
      return [];
    }
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final String firstName;
  final String lastName;
  final String pathToImage;
  final VoidCallback onTap;

  const PropertyCard({
    required this.property,
    required this.firstName,
    required this.lastName,
    required this.pathToImage,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          width: screenWidth *
              0.4, // Adjust the width as a fraction of the screen width
          height: screenHeight *
              0.35, // Adjust the height as a fraction of the screen height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: screenHeight *
                    0.2, // Adjust the height as a fraction of the card height
                width: double.infinity,
                child: Image.asset(
                  property
                      .imagePath[0], // TODO define a new property.iconimagepath
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: GoogleFonts.montserrat(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF33907C),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Icon(Icons.king_bed_outlined,
                            size: screenWidth * 0.035),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${property.beds} Bed',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Icon(Icons.bathtub_outlined, size: screenWidth * 0.035),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${property.baths} Bath',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(
                            pathToImage ?? 'assets/userimage.png',
                          ),
                          radius: screenWidth * 0.025,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${firstName} ${lastName}',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
