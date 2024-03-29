import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:rehnaa/frontend/Screens/Tenant/tenant_dashboard.dart';
// import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_dashboard_content.dart';
// import 'package:photo_view/photo_view.dart';

import '../../../backend/models/propertymodel.dart';
import '../../../backend/models/tenantsmodel.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

class TenantPropertyPage extends StatefulWidget {
  final Property property;
  final String firstName;
  final String lastName;
  final String pathToImage;
  final String location;
  final String address;
  final String uid;
  final String propertyID;
  final bool isWithdraw;
  final String emailOrPhone;

  const TenantPropertyPage({
    super.key,
    required this.property,
    required this.firstName,
    required this.lastName,
    required this.pathToImage,
    required this.location,
    required this.address,
    required this.uid,
    required this.isWithdraw,
    required this.propertyID,
    required this.emailOrPhone,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TenantPropertyPageState createState() => _TenantPropertyPageState();
}

class _TenantPropertyPageState extends State<TenantPropertyPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 5,
                  child: PropertyCarousel(
                    currentIndex: currentIndex,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    imagePaths: widget.property.imagePath,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: PropertyDetails(
                    property: widget.property,
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    pathToImage: widget.pathToImage,
                    uid: widget.uid,
                    isWithdraw: widget.isWithdraw,
                    location: widget.location,
                    address: widget.address,
                    propertyID: widget.propertyID,
                    emailOrPhone: widget.emailOrPhone,
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}

class PropertyCarousel extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final List<String> imagePaths;

  const PropertyCarousel({
    Key? key,
    required this.currentIndex,
    required this.onPageChanged,
    required this.imagePaths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            onPageChanged: (int index, CarouselPageChangedReason reason) {
              onPageChanged(index);
            },
          ),
          items: imagePaths.map((imagePath) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () async {
                    // final imageProvider = CachedNetworkImageProvider(imagePath);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullScreenImagePage(
                                currentIndex: currentIndex,
                                imagePaths: imagePaths,
                                onPageChanged: onPageChanged,
                                // onClose: _toggleFullScreen,
                              )),
                    );
                  },
                  child: Hero(
                    tag: imagePath,
                    child: CachedNetworkImage(
                      imageUrl: imagePath,
                      placeholder: (context, url) => const Center(
                        child: SpinKitFadingCube(
                          color: Color.fromARGB(255, 30, 197, 83),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/mainlogo.png',
                        fit: BoxFit.scaleDown,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < imagePaths.length; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == i ? Colors.white : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 65,
          left: 10,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF33907C),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff0FA697),
                    Color(0xff45BF7A),
                    Color(0xff0DF205),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 20,
                ),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenImagePage extends StatefulWidget {
  final int currentIndex;
  final List<String> imagePaths;
  final ValueChanged<int>? onPageChanged;
  // final VoidCallback onClose;

  const FullScreenImagePage({
    Key? key,
    required this.currentIndex,
    required this.imagePaths,
    this.onPageChanged,
    // required this.onClose,
  }) : super(key: key);

  @override
  _FullScreenImagePageState createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // widget.onClose();
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (context, index) {
              final imagePath = widget.imagePaths[index];
              return InteractiveViewer(
                panEnabled: false,
                child: CachedNetworkImage(
                  imageUrl: imagePath,
                  placeholder: (context, url) => const Center(
                    child: SpinKitFadingCube(
                      color: Color.fromARGB(255, 30, 197, 83),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/mainlogo.png',
                    fit: BoxFit.scaleDown,
                  ),
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PropertyDetails extends StatelessWidget {
  final Property property;
  final String firstName;
  final String lastName;
  final String pathToImage;
  final String uid;
  final bool isWithdraw;
  final String location;
  final String address;
  final String propertyID;
  final String emailOrPhone;

  const PropertyDetails({
    super.key,
    required this.property,
    required this.firstName,
    required this.lastName,
    required this.pathToImage,
    required this.uid,
    required this.isWithdraw,
    required this.location,
    required this.address,
    required this.propertyID,
    required this.emailOrPhone,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Properties')
          .doc(propertyID)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          print("snapshot.data!.data() is ${snapshot.data!.data()}");

          bool isRequested = false;
          var isRequestedByTenants = (snapshot.data!.data()
              as Map<String, dynamic>)['isRequestedByTenants'];
          if (isRequestedByTenants == false || isRequestedByTenants == null) {
            isRequestedByTenants = [];
          }
          if (isRequestedByTenants != null &&
              isRequestedByTenants.contains(uid)) {
            isRequested = true;
            // Handle the condition when your uid exists in the list of isRequestedByTenants
          }

          return SizedBox(
            width: screenWidth * 0.92,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      property.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        // color: const Color(0xFF33907C),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      property.description,
                      style: GoogleFonts.montserrat(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),

                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      property.location,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                        // color: const Color(0xFF33907C),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      property.address,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                        // color: const Color(0xFF33907C),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text.rich(
                      TextSpan(
                        text: "Type: ",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          // color: const Color(0xFF33907C),
                        ),
                        children: [
                          TextSpan(
                            text: "${property.type}",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              // color: const Color(0xFF33907C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Specifications',
                          style: GoogleFonts.montserrat(
                            // fontStyle: FontStyle.italic,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .arrow_back_ios, // Replace with your desired arrow icon
                              size: 20,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Row(
                                  children: [
                                    SizedBox(width: screenWidth * 0.02),
                                    PropertySpecs(
                                      icon: Icons.area_chart_outlined,
                                      text:
                                          '${property.area?.round()} Marlas/ ${(property.area! * 272).round()} Sqft',
                                    ),
                                    SizedBox(width: screenWidth * 0.035),
                                    if (property.beds > 0)
                                      PropertySpecs(
                                        icon: Icons.king_bed_outlined,
                                        text: '${property.beds} Bed',
                                      ),
                                    SizedBox(width: screenWidth * 0.02),
                                    if (property.baths > 0)
                                      PropertySpecs(
                                        icon: Icons.bathtub_outlined,
                                        text: '${property.baths} Bath',
                                      ),
                                    SizedBox(width: screenWidth * 0.02),
                                    if (property.garden)
                                      const PropertySpecs(
                                        icon: Icons.landscape_outlined,
                                        text: '1 Garden',
                                      ),
                                    if (property.living > 0)
                                      PropertySpecs(
                                        icon: Icons.weekend_outlined,
                                        text: '${property.living} Living',
                                      ),
                                    if (property.floors > 0)
                                      PropertySpecs(
                                        icon: Icons.house_outlined,
                                        text: '${property.floors} Floor',
                                      ),
                                    if (property.carspace > 0)
                                      PropertySpecs(
                                        icon: Icons.directions_car_outlined,
                                        text: '${property.carspace} Carspace',
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const Icon(
                              Icons
                                  .arrow_forward_ios, // Replace with your desired arrow icon
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Owner Details',
                          style: GoogleFonts.montserrat(
                            // fontStyle: FontStyle.italic,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // const SizedBox(width: 8),
                        // const Spacer(),
                        // Padding(
                        //     padding: EdgeInsets.only(left: screenWidth * 0.3)),
                        Center(
                          child: isRequested
                              ? GradientButton(
                                  onPressed: () {},
                                  text: 'Requested',
                                  isRequested: isRequested,
                                )
                              : GradientButton(
                                  isRequested: isRequested,
                                  onPressed: () async {
                                    // Fetch tenant data from Firebase
                                    Tenant tenant = await getTenant();

                                    // Convert property to a map
                                    Map<String, dynamic> propertyMap =
                                        property.toMap();

                                    // Generate a random ID
                                    final Random random = Random();
                                    final String randomID = random
                                        .nextInt(999999)
                                        .toString()
                                        .padLeft(6, '0');

                                    // Send request to admin
                                    FirebaseFirestore.instance
                                        .collection('AdminRequests')
                                        .doc(uid)
                                        .set({
                                      'rentalRequest': FieldValue.arrayUnion([
                                        {
                                          'fullname':
                                              '${tenant.firstName} ${tenant.lastName}',
                                          'uid': uid,
                                          'property': propertyMap,
                                          'propertyID': propertyID,
                                          'requestID': randomID,
                                          'timestamp': Timestamp.now(),
                                        }
                                      ]),
                                    }, SetOptions(merge: true));

                                    // Create a notification for the tenant
                                    FirebaseFirestore.instance
                                        .collection('Notifications')
                                        .doc(uid)
                                        .set({
                                      'notifications': FieldValue.arrayUnion([
                                        {
                                          'title':
                                              'Rental Request of property ${property.title} has been sent to the admin',
                                        }
                                      ]),
                                    }, SetOptions(merge: true));

                                    // Update Properties's isRequestedbyTenants field
                                    FirebaseFirestore.instance
                                        .collection('Properties')
                                        .doc(propertyID)
                                        .set({
                                      'isRequestedByTenants':
                                          FieldValue.arrayUnion([uid])
                                    }, SetOptions(merge: true));

                                    // Navigate to the TenantDashboardPage
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TenantPropertyPage(
                                                property: property,
                                                firstName: firstName,
                                                lastName: lastName,
                                                pathToImage: pathToImage,
                                                location: location,
                                                address: address,
                                                uid: uid,
                                                isWithdraw: isWithdraw,
                                                propertyID: propertyID,
                                                emailOrPhone: emailOrPhone,
                                              )),
                                    );
                                  },
                                  text: 'Request',
                                  gradientColors: const [
                                    Color(0xff0FA697),
                                    Color(0xff45BF7A),
                                    Color(0xff0DF205),
                                  ],
                                ),
                        )
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      'Ratings',
                      style: GoogleFonts.montserrat(
                        // fontStyle: FontStyle.italic,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text(
                                  'Rehnaa Rating: ${property.rehnaaRating}/10',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text(
                                  'Past Tenant Rating: ${property.tenantRating}/10',
                                  style: GoogleFonts.montserrat(
                                    // fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Past Tenant Review',
                      style: GoogleFonts.montserrat(
                        // fontStyle: FontStyle.italic,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          property.tenantReview,
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Monthly Rent',
                      style: GoogleFonts.montserrat(
                        // fontStyle: FontStyle.italic,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          // 'PKR.${property.price.toString()}',
                          'PKR.' + NumberFormat('#,##0').format(property.price),
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Center(
            child: SpinKitFadingCube(
              color: Color.fromARGB(255, 30, 197, 83),
            ),
          );
        }
      },
    );
  }

  Future<Tenant> getTenant() async {
    Tenant tenant = await FirebaseFirestore.instance
        .collection('Tenants')
        .doc(uid)
        .get()
        .then((value) {
      Map<String, dynamic> jsondata = value.data() as Map<String, dynamic>;
      Tenant tenant = Tenant.fromJson(jsondata);
      return tenant;
    });
    return tenant;
  }
}

class PropertySpecs extends StatelessWidget {
  final IconData icon;
  final String text;

  const PropertySpecs({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF33907C),
          ),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final List<Color> gradientColors;
  final bool isRequested;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.gradientColors = const [
      Color(0xff0FA697),
      Color(0xff45BF7A),
      Color(0xff0DF205),
    ],
    required this.isRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isRequested
              ? [Colors.grey, Colors.grey]
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
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Icon(
                //   Icons.arrow_forward,
                //   color: Colors.white,
                // ),
                const SizedBox(width: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
