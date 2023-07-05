import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/skeleton.dart';
import '../../../backend/models/landlordmodel.dart';
import '../../../backend/models/propertymodel.dart';
import 'landlord_propertyinfo.dart';
import 'package:rxdart/rxdart.dart';

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
  // late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _propertyStream;
  String firstName = '';
  String lastName = '';

  bool shouldDisplay = false;
  bool isEmptyList = false;
  @override
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _propertyStream =
      const Stream.empty();
  Timer? _propertyStreamTimer;
  List<DocumentReference<Map<String, dynamic>>> propertyDataList = [];

  void initState() {
    super.initState();
    _loadProperties(); // Initialize the stream for the properties
  }

  void dispose() {
    _cancelPropertyStreamTimer();
    super.dispose();
  }

  void _loadProperties() {
    _getPropertyStream().then((stream) {
      setState(() {
        _propertyStream = stream;
      });
      _startPropertyStreamTimer(); // Start the timer to periodically update the property stream
    });
  }

  Future<void> _updatePropertyStream() async {
    _cancelPropertyStreamTimer(); // Cancel the timer before updating the stream

    // Fetch the latest property references from the Landlords collection
    final landlordSnapshot = await FirebaseFirestore.instance
        .collection('Landlords')
        .doc(widget.uid)
        .get();

    if (landlordSnapshot.exists) {
      // print('nahi yahan');
      Map<String, dynamic> data = landlordSnapshot.data()!;
      List<DocumentReference<Map<String, dynamic>>> propertyDataList2 =
          (data['propertyRef'] as List<dynamic>)
              .cast<DocumentReference<Map<String, dynamic>>>();

      if (propertyDataList.map((ref) => ref.path).toList().toString() !=
          propertyDataList2.map((ref) => ref.path).toList().toString()) {
        // print('propertyDataList is $propertyDataList');
        // print('propertyDataList2 is ${propertyDataList2.length}');

        Iterable<Stream<DocumentSnapshot<Map<String, dynamic>>>>
            propertySnapshotsStreams =
            propertyDataList2.map((ref) => ref.snapshots());

        properties = []; // Clear the properties list
        // Combine the property snapshot streams into a single stream
        if (propertyDataList2.isEmpty) {
          // print('reached here and doing this');
          // Set the propertyDataList to null if propertyDataList2 is null
          setState(() {
            // _propertyStream.drain();
            _propertyStream = const Stream.empty();
            propertyDataList = [];
            isEmptyList = true;
          });
        } else {
          Stream<List<DocumentSnapshot<Map<String, dynamic>>>> combinedStream =
              CombineLatestStream.list(propertySnapshotsStreams);

          setState(() {
            _propertyStream = combinedStream;
            propertyDataList = propertyDataList2;
            isEmptyList = false;
          });
        }
      }
    } else {
      print('yahan reach horha hai');
      setState(() {
        properties =
            []; // Handle the case where the landlord document doesn't exist
        _propertyStream = Stream.empty();
      });
    }

    _startPropertyStreamTimer(); // Restart the timer for periodic updates
  }

  void _startPropertyStreamTimer() {
    _propertyStreamTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updatePropertyStream();
    });
  }

  void _cancelPropertyStreamTimer() {
    _propertyStreamTimer?.cancel();
  }

  Future<Stream<List<DocumentSnapshot<Map<String, dynamic>>>>>
      _getPropertyStream() async {
    try {
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
        Landlord landlord = Landlord.fromJson(data as Map<String, dynamic>);
        firstName = landlord.firstName;
        lastName = landlord.lastName;

        propertyDataList = (data['propertyRef'] as List<dynamic>)
            .cast<DocumentReference<Map<String, dynamic>>>();

        Iterable<Stream<DocumentSnapshot<Map<String, dynamic>>>>
            propertySnapshotsStreams =
            propertyDataList.map((ref) => ref.snapshots());

        properties = []; // Clear the properties list
        // Combine the property snapshots streams into a single stream
        Stream<List<DocumentSnapshot<Map<String, dynamic>>>> combinedStream =
            CombineLatestStream.list(propertySnapshotsStreams);

        return combinedStream;
      } else {
        properties =
            []; // Handle the case where the landlord document doesn't exist
        return Stream.empty();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching properties: $e');
      }
      return Stream.empty();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessary for AutomaticKeepAliveClientMixin
    // print('properties.isEmpty is ${properties.isEmpty}');

    return StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      stream: _propertyStream,
      builder: (context, snapshot) {
        Size size = MediaQuery.of(context).size;
        // print('data is ${snapshot.data?.map((e) => e.data())}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LandlordPropertiesSkeleton();
        } else if (isEmptyList || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              SizedBox(height: size.height * 0.03),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.center,
                child: Text(
                  'Properties',
                  style: GoogleFonts.montserrat(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff33907c),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
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
                        'No properties to show',
                        style: GoogleFonts.montserrat(
                          fontSize: 20.0,
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
            body: ListView(
              children: snapshot.data!.map((propertySnapshot) {
                Property property = Property.fromJson(
                    propertySnapshot.data() as Map<String, dynamic>);

                return PropertyCard(
                  property: property,
                  firstName: firstName ?? '',
                  lastName: lastName ?? '',
                  pathToImage:
                      property.landlord?.pathToImage ?? 'assets/userimage.png',
                  location: property.location,
                  address: property.address,
                  type: property.type,
                  area: property.area ?? 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyPage(
                          property: property,
                          firstName: firstName ?? '',
                          lastName: lastName ?? '',
                          pathToImage: property.landlord?.pathToImage ??
                              'assets/userimage.png',
                          location: property.location,
                          address: property.address,
                          emailOrPhone: property.landlord?.emailOrPhone ?? '',
                          isTenantCall: false,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
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

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text
        .split(' ')
        .map((word) =>
            word.substring(0, 1).toUpperCase() +
            word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // print('property.imagepath is ${property.imagePath}');

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
                  imageUrl: property.imagePath[0],
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(
                    color: Colors.green,
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
                      capitalizeFirstLetter(property.title),
                      style: GoogleFonts.montserrat(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF33907C),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      '$location\n$address',
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Icon(Icons.area_chart, size: screenWidth * 0.035),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${property.area?.round()} Marlas / ${(property.area! * 272).round()} Sqft',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                        SizedBox(width: screenWidth * 0.01),
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
                          child: ClipOval(
                            child: pathToImage!.startsWith('https')
                                ? CachedNetworkImage(imageUrl: pathToImage!)
                                : Image.asset(pathToImage!),
                          ),
                          radius: screenWidth * 0.025,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '$firstName $lastName',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '($type)',
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
