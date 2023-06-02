import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rehnaa/frontend/Screens/dashboard.dart';

import 'Dashboard_pages/landlord_propertyinfo.dart';

class LandlordPropertiesPage extends StatelessWidget {
  final List<Property> properties = [
    Property(
      imagePath: 'assets/image1.jpg',
      type: 'House',
      beds: 3,
      baths: 2,
      garden: true,
      living: 1,
      floors: 2,
      carspace: 2,
      description: 'Spacious house with a beautiful garden.',
      title: 'Luxury House',
      location: 'City Center',
      price: 3000,
      owner: 'John Doe',
      pathToOwnerImage: 'assets/userimage.png',
      ownerPhoneNumber: '+1234567890',
      rehnaaRating: 4.5,
      tenantRating: 4.2,
      tenantReview: 'Great property! Highly recommended.',
    ),
    Property(
      imagePath: 'assets/image2.jpg',
      type: 'Apartment',
      beds: 2,
      baths: 1,
      garden: false,
      living: 1,
      floors: 1,
      carspace: 1,
      description: 'Cozy apartment in a prime location.',
      title: 'Modern Apartment',
      location: 'Suburb',
      price: 2000,
      owner: 'Jane Smith',
      pathToOwnerImage: 'assets/userimage.png',
      ownerPhoneNumber: '+0987654321',
      rehnaaRating: 4.2,
      tenantRating: 4.5,
      tenantReview: 'Excellent property! Had a wonderful stay.',
    ),
    // Add more properties as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: ListView.builder(
        itemCount: properties.length,
        itemBuilder: (context, index) {
          return PropertyCard(
            property: properties[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PropertyPage(property: properties[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Property {
  final String imagePath;
  final String type;
  final int beds;
  final int baths;
  final bool garden;
  final int living;
  final int floors;
  final int carspace;
  final String description;
  final String title;
  final String location;
  final double price;
  final String owner;
  final String pathToOwnerImage;
  final String ownerPhoneNumber;
  final double rehnaaRating;
  final double tenantRating;
  final String tenantReview;

  Property({
    required this.imagePath,
    required this.type,
    required this.beds,
    required this.baths,
    required this.garden,
    required this.living,
    required this.floors,
    required this.carspace,
    required this.description,
    required this.title,
    required this.location,
    required this.price,
    required this.owner,
    required this.pathToOwnerImage,
    required this.ownerPhoneNumber,
    required this.rehnaaRating,
    required this.tenantRating,
    required this.tenantReview,
  });
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({
    required this.property,
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
                  property.imagePath,
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
                          backgroundImage:
                              AssetImage(property.pathToOwnerImage),
                          radius: screenWidth * 0.025,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          property.owner,
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
