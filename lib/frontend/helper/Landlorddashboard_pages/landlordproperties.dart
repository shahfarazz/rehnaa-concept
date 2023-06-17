import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/skeleton.dart';
import '../../../backend/models/propertymodel.dart';
import 'landlord_propertyinfo.dart';

class LandlordPropertiesPage extends StatefulWidget {
  final String uid; // UID of the landlord

  const LandlordPropertiesPage({Key? key, required this.uid}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LandlordPropertiesPageState createState() => _LandlordPropertiesPageState();
}

class _LandlordPropertiesPageState extends State<LandlordPropertiesPage>
    with AutomaticKeepAliveClientMixin<LandlordPropertiesPage> {
  List<Property> properties = [];

  bool shouldDisplay = false;
  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      // Fetch the document snapshot for the landlord
      DocumentSnapshot<Map<String, dynamic>> landlordSnapshot =
          await FirebaseFirestore.instance
              .collection('Landlords')
              .doc(widget.uid)
              .get();

      if (landlordSnapshot.exists) {
        setState(() {
          shouldDisplay = true;
        });
        Map<String, dynamic> data = landlordSnapshot.data()!;

        List<DocumentReference<Map<String, dynamic>>> propertyDataList =
            (data['propertyRef'] as List<dynamic>)
                .cast<DocumentReference<Map<String, dynamic>>>();

        // Fetch properties using the fetchProperties method
        properties = await fetchProperties(propertyDataList, context);

        if (mounted) {
          setState(() {
            // Update the state with the fetched properties
            properties = properties;
          });
        }
      } else {
        // Handle the case where the landlord document doesn't exist
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

  Future<List<Property>> fetchProperties(
      List<dynamic> propertyDataList, BuildContext context) async {
    List<Property> fetchedProperties = [];

    for (var propertyDataRef in propertyDataList) {
      DocumentSnapshot<Map<String, dynamic>> propertySnapshot =
          await propertyDataRef.get();

      Map<String, dynamic>? propertyData = propertySnapshot.data();
      if (propertyData != null) {
        Property property = await Property.fromJson(propertyData);
        property.landlord = await property.fetchLandlord();
        precacheImage(NetworkImage(property.imagePath[0]), context);

        fetchedProperties.add(property);
      }
    }

    return fetchedProperties;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessary for AutomaticKeepAliveClientMixin
    // print('properties.isEmpty is ${properties.isEmpty}');

    if (properties.isEmpty && !shouldDisplay) {
      return const LandlordPropertiesSkeleton();
    } else if (properties.isEmpty && shouldDisplay) {
      return Column(
        children: [
          const SizedBox(height: 50),
          Card(
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
                      // fontWeight: FontWeight.bold,
                      color: const Color(0xff33907c),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: ListView.builder(
          itemCount: properties.length,
          itemBuilder: (context, index) {
            // if properties is empty return empty container

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
                    builder: (_) => PropertyPage(
                      property: properties[index],
                      firstName: properties[index].landlord?.firstName ?? '',
                      lastName: properties[index].landlord?.lastName ?? '',
                      pathToImage: properties[index].landlord?.pathToImage ??
                          'assets/userimage.png',
                      location: properties[index].location,
                      address: properties[index].address,
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

    print('property.imagepath is ${property.imagePath}');

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

class LandlordPropertiesSkeleton extends StatelessWidget {
  const LandlordPropertiesSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: size.height * 0.03),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: Skeleton(
              width: size.width * 0.5,
              height: 30,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CardSkeleton(
                  height: size.height * 0.25,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
