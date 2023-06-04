import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../backend/models/propertymodel.dart';

class PropertyPage extends StatefulWidget {
  final Property property;
  final String firstName;
  final String lastName;
  final String pathToImage;

  const PropertyPage(
      {required this.property,
      required this.firstName,
      required this.lastName,
      required this.pathToImage});

  @override
  _PropertyPageState createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpandedImagePage(imagePath: imagePath),
                      ),
                    );
                  },
                  child: Hero(
                    tag: imagePath,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.fill,
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
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < imagePaths.length; i++)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
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
          top: 30,
          left: 10,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Color(0xFF33907C),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
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
                icon: Icon(Icons.arrow_back, size:20,),
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

  const PropertyDetails(
      {required this.property,
      required this.firstName,
      required this.lastName,
      required this.pathToImage});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * 0.92,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, -3),
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
                  color: Color(0xFF33907C),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                property.description,
                style: GoogleFonts.montserrat(),
              ),
              SizedBox(height: screenHeight * 0.07),
              Text(
                'Specifications',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: AlwaysScrollableScrollPhysics(),
                child: Row(
                  children: [
                    if (property.beds > 0)
                      PropertySpecs(
                        icon: Icons.king_bed_outlined,
                        text: '${property.beds} Bed',
                      ),
                    if (property.baths > 0)
                      PropertySpecs(
                        icon: Icons.bathtub_outlined,
                        text: '${property.baths} Bath',
                      ),
                    if (property.garden)
                      PropertySpecs(
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
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Owner Details',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
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
                      backgroundImage: AssetImage('assets/userimage.jpg'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // 'hello',
                        '$firstName $lastName', // Replace with the owner's name fetched from Firebase
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '03333295546', // Replace with the owner's phone number fetched from Firebase
                        style: GoogleFonts.montserrat(),
                      ),
                    ],
                  ),
                  Spacer(),
                  GradientButton(
                    onPressed: () {
                      // handle request button press
                    },
                    text: 'Request',
                    gradientColors: [
                      Color(0xff0FA697),
                      Color(0xff45BF7A),
                      Color(0xff0DF205),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Ratings',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Rehnaa Rating: ${property.rehnaaRating}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Past Tenant Rating: ${property.tenantRating}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Past Tenant Review',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    property.tenantReview,
                    style: GoogleFonts.montserrat(),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Monthly Rent',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    property.price.toString(),
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
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Icon(
            icon,
            color: Color(0xFF33907C),
          ),
          SizedBox(height: 8),
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
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
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
class ExpandedImagePage extends StatefulWidget {
  final String imagePath;

  const ExpandedImagePage({required this.imagePath});

  @override
  _ExpandedImagePageState createState() => _ExpandedImagePageState();
}

class _ExpandedImagePageState extends State<ExpandedImagePage> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _previousOffset = Offset.zero;
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              // Do nothing when tapped on the image
            },
            onScaleStart: (ScaleStartDetails details) {
              _previousScale = _scale;
              _previousOffset = details.focalPoint - _offset;
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
                _offset = details.focalPoint - _previousOffset;
              });
            },
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Transform.scale(
                scale: _scale,
                child: Transform.translate(
                  offset: _offset,
                  child: Image.asset(widget.imagePath),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30.0,
            left: 10.0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF33907C),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff0FA697),
                      Color(0xff45BF7A),
                      Color(0xff0DF205),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
