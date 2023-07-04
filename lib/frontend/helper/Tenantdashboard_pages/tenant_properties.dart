import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_propertyinfo.dart';
import '../../../backend/models/landlordmodel.dart';
import '../../../backend/models/propertymodel.dart';
import '../Landlorddashboard_pages/landlord_propertyinfo.dart';
import '../Landlorddashboard_pages/landlordproperties.dart';

class TenantPropertiesPage extends StatefulWidget {
  final String uid; // UID of the landlord
  final bool isWithdraw;

  const TenantPropertiesPage({
    Key? key,
    required this.uid,
    required this.isWithdraw,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TenantPropertiesPageState createState() => _TenantPropertiesPageState();
}

class _TenantPropertiesPageState extends State<TenantPropertiesPage>
    with AutomaticKeepAliveClientMixin<TenantPropertiesPage> {
  late Future<List<Property>> _propertiesFuture;
  bool shouldDisplay = false;
  String? emailOrPhone;

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _fetchProperties();
  }

  Future<List<Property>> _fetchProperties() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('Properties').get();

    List<Property> properties = [];
    for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in snapshot.docs) {
      Property property =
          Property.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      property.propertyID = documentSnapshot.id;

      DocumentSnapshot<Map<String, dynamic>> landlordSnapshot =
          await property.landlordRef!.get();
      if (landlordSnapshot.exists) {
        Landlord landlord =
            Landlord.fromJson(landlordSnapshot.data() as Map<String, dynamic>);
        property.landlord = landlord;
      }

      properties.add(property);
    }

    return properties;
  }

  Future<void> _refreshProperties() async {
    setState(() {
      _propertiesFuture = _fetchProperties();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessary for AutomaticKeepAliveClientMixin

    return FutureBuilder<List<Property>>(
      future: _propertiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.green,
          ));
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error retrieving data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.house,
                      size: 48.0,
                      color: Color(0xff33907c),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'No Properties to show',
                      style: GoogleFonts.montserrat(
                        fontSize: 20.0,
                        color: const Color(0xff33907c),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          List<Property> properties = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshProperties,
            child: ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                Property property = properties[index];
                return PropertyCard(
                  property: property,
                  firstName: property.landlord?.firstName ?? '',
                  lastName: property.landlord?.lastName ?? '',
                  location: property.location,
                  address: property.address,
                  type: property.type,
                  area: property.area ?? 0.0,
                  pathToImage:
                      property.landlord?.pathToImage ?? 'assets/userimage.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TenantPropertyPage(
                          property: property,
                          firstName: property.landlord?.firstName ?? '',
                          lastName: property.landlord?.lastName ?? '',
                          pathToImage: property.landlord?.pathToImage ??
                              'assets/userimage.png',
                          location: property.location,
                          address: property.address,
                          propertyID: property.propertyID ?? '',
                          uid: widget.uid,
                          isWithdraw: widget.isWithdraw,
                          emailOrPhone: property.landlord?.emailOrPhone ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final String firstName;
  final String lastName;
  final String? pathToImage;
  final VoidCallback onTap;
  final String location;
  final String address;
  final String type;
  final num area;

  const PropertyCard({
    super.key,
    required this.property,
    required this.firstName,
    required this.lastName,
    required this.pathToImage,
    required this.onTap,
    required this.location,
    required this.address,
    required this.type,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: SizedBox(
          width: screenWidth *
              0.4, // Adjust the width as a fraction of the screen width
          height: screenHeight *
              0.37, // Adjust the height as a fraction of the screen height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight *
                    0.2, // Adjust the height as a fraction of the card height
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: property
                      .imagePath[0], // TODO define a new property.iconimagepath

                  placeholder: (context, url) =>
                      const CircularProgressIndicator(
                    color: Color(0xFF33907C),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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
                        color: const Color(0xFF33907C),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      '$location\n$address',
                      style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontFamily: GoogleFonts.montserrat().fontFamily),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Icon(Icons.area_chart_outlined,
                            size: screenWidth * 0.035),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${property.area?.round()} Marlas / ${(property.area! * 272).round()} Sqft',
                          style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontFamily: GoogleFonts.montserrat().fontFamily),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Icon(Icons.king_bed_outlined,
                            size: screenWidth * 0.035),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${property.beds} Bed',
                          style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontFamily: GoogleFonts.montserrat().fontFamily),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Icon(Icons.bathtub_outlined, size: screenWidth * 0.035),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${property.baths} Bath',
                          style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontFamily: GoogleFonts.montserrat().fontFamily),
                        ),
                      ],
                    ),
                    // SizedBox(height: screenHeight * 0.01),
                    // Row(
                    //   children: [
                    //     // CircleAvatar(
                    //     //   backgroundImage: Image.network(
                    //     //     pathToImage ?? 'assets/userimage.png',
                    //     //   ).image,
                    //     //   radius: screenWidth * 0.025,
                    //     // ),
                    //     SizedBox(width: screenWidth * 0.01),
                    //     // Text(
                    //     //   '$firstName $lastName',
                    //     //   style: TextStyle(
                    //     //       fontSize: screenWidth * 0.035,
                    //     //       fontFamily: GoogleFonts.montserrat().fontFamily),
                    //     // ),
                    //     // SizedBox(width: screenWidth * 0.01),
                    //     // Text(
                    //     //   '($type)',
                    //     //   style: TextStyle(
                    //     //     fontSize: screenWidth * 0.035,
                    //     //     fontFamily: GoogleFonts.montserrat().fontFamily,
                    //     //   ),
                    //     // ),
                    //   ],
                    // ),
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
