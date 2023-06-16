import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_propertyinfo.dart';
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
  List<Property> properties = [];
  bool shouldDisplay = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      // Fetch the document snapshot for the properties
      QuerySnapshot<Map<String, dynamic>> propertiesSnapshot =
          await FirebaseFirestore.instance.collection('Properties').get();

      if (propertiesSnapshot.size > 0) {
        List<Property> fetchedProperties = [];

        for (var docSnapshot in propertiesSnapshot.docs) {
          Map<String, dynamic> propertyData = docSnapshot.data();

          Property property = Property.fromJson(propertyData);
          property.landlord = await property.fetchLandlord();
          property.propertyID = docSnapshot.id;

          if (property.tenantRef != null) continue;

          fetchedProperties.add(property);
          // print('Fetched property: ${property.landlord?.firstName}');
        }

        if (mounted) {
          setState(() {
            // Update the state with the fetched properties
            properties = fetchedProperties;
            shouldDisplay = true;
          });
        }
      } else {
        // Handle the case where no properties are found
        properties = [];
      }
    } catch (e) {
      // Handle any error that occurred while fetching the properties
      if (kDebugMode) {
        print('Error fetching properties: $e');
      }
      properties = [];
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessary for AutomaticKeepAliveClientMixin

    if (properties.isEmpty && !shouldDisplay) {
      return const LandlordPropertiesSkeleton();
    } else if (properties.isEmpty && shouldDisplay) {
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
                  'Oops! No Properties yet...',
                  style: GoogleFonts.montserrat(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff33907c),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: ListView.builder(
          itemCount: properties.length,
          itemBuilder: (context, index) {
            return PropertyCard(
              property: properties[index],
              firstName: properties[index].landlord?.firstName ?? '',
              lastName: properties[index].landlord?.lastName ?? '',
              pathToImage: properties[index].landlord?.pathToImage ??
                  'assets/userimage.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TenantPropertyPage(
                      property: properties[index],
                      firstName: properties[index].landlord?.firstName ?? '',
                      lastName: properties[index].landlord?.lastName ?? '',
                      pathToImage: properties[index].landlord?.pathToImage ??
                          'assets/userimage.png',
                      location: properties[index].location,
                      address: properties[index].address,
                      propertyID: properties[index].propertyID ?? '',
                      uid: widget.uid,
                      isWithdraw: widget.isWithdraw,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final String firstName;
  final String lastName;
  final String? pathToImage;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
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
        child: SizedBox(
          width: screenWidth *
              0.4, // Adjust the width as a fraction of the screen width
          height: screenHeight *
              0.35, // Adjust the height as a fraction of the screen height
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
                      const CircularProgressIndicator(),
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
                          '$firstName $lastName',
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
