import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../backend/models/landlordmodel.dart';
import '../../../backend/models/propertymodel.dart';
import '../Tenantdashboard_pages/tenant_propertyinfo.dart';
// import 'package:photo_view/photo_view.dart';

class PropertyPage extends StatefulWidget {
  final Property property;
  final String firstName;
  final String lastName;
  final String pathToImage;
  final String location;
  final String address;
  final String emailOrPhone;
  final bool isTenantCall;
  // final Landlord landlord;

  const PropertyPage({
    super.key,
    required this.property,
    required this.firstName,
    required this.lastName,
    required this.pathToImage,
    required this.location,
    required this.address,
    required this.emailOrPhone,
    required this.isTenantCall,
    // required this.landlord
  });

  @override
  // ignore: library_private_types_in_public_api
  _PropertyPageState createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
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
                    emailOrPhone: widget.emailOrPhone,
                    isTenantCall: widget.isTenantCall,
                    // landlord: widget.landlord,
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
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    // final List<String> imagePaths = [
    //   'assets/image1.jpg',
    //   'assets/image2.jpg',
    // ];

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
                      imageUrl:
                          imagePath, // TODO define a new property.iconimagepath

                      placeholder: (context, url) => const SpinKitFadingCube(
                        color: Color.fromARGB(255, 30, 197, 83),
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
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

class PropertyDetails extends StatelessWidget {
  final Property property;
  final String firstName;
  final String lastName;
  final String pathToImage;
  final String emailOrPhone;
  final bool isTenantCall;
  // final Landlord landlord;

  const PropertyDetails({
    super.key,
    required this.property,
    required this.firstName,
    required this.lastName,
    required this.pathToImage,
    required this.emailOrPhone,
    required this.isTenantCall,
    // required this.landlord
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * 0.92,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                              SizedBox(width: screenWidth * 0.025),
                              PropertySpecs(
                                icon: Icons.area_chart_outlined,
                                text:
                                    '${property.area?.round()} Marlas/ ${(property.area! * 272).round()} Sqft',
                              ),
                              SizedBox(width: screenWidth * 0.02),
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
                  isTenantCall
                      ? Container()
                      : Text(
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
              isTenantCall
                  ? Container()
                  : Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: CircleAvatar(
                              // Replace with the owner's image
                              // backgroundImage: AssetImage('assets/userimage.jpg'),
                              child: ClipOval(
                            child: pathToImage != null &&
                                    pathToImage!.isNotEmpty
                                ? (pathToImage!.startsWith('assets')
                                    ? Image.asset(
                                        pathToImage!,
                                        width: 150,
                                        height: 150,
                                      )
                                    : Image.network(
                                        fit: BoxFit.cover,
                                        pathToImage!,
                                        width: 150,
                                        height: 150,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: const SpinKitFadingCube(
                                              color: Color.fromARGB(
                                                  255, 30, 197, 83),
                                            ),
                                          );
                                        },
                                      ))
                                : Image.asset(
                                    'assets/defaulticon.png',
                                    width: 150,
                                    height: 150,
                                  ),
                          )),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // 'hello',
                              '$firstName $lastName', // Replace with the owner's name fetched from Firebase
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFF33907C),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              width: 150,
                              child: Text(
                                emailOrPhone, // Replace with the owner's phone number fetched from Firebase
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                ),
                              ),
                            )
                          ],
                        ),
                        const Spacer(),
                        // GradientButton(
                        //   onPressed: () {
                        //     // handle request button press
                        //   },
                        //   text: 'Request',
                        //   gradientColors: const [
                        //     Color(0xff0FA697),
                        //     Color(0xff45BF7A),
                        //     Color(0xff0DF205),
                        //   ],
                        // ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "PKR.${property.price.toString()}",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.gradientColors = const [
      Color(0xff0FA697),
      Color(0xff45BF7A),
      Color(0xff0DF205),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
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
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
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
