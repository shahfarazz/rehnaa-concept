import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PropertyPage extends StatefulWidget {
  @override
  _PropertyPageState createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                    ),
                    items: [
                      Image.asset(
                        'assets/image1.jpg',
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        'assets/image2.jpg',
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Image ${currentIndex + 1} of 2',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(253, 249, 249, 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Handle back button press
                      },
                      icon: Icon(Icons.arrow_back),
                      color:  Color(0xFF33907C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: SizedBox(
              width: double.infinity,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  Text(
                    'Property Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Property details go here...',
                  ),
                  SizedBox(height: 65),
                  Text(
                    'Specifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.king_bed_outlined,
                            color: Color(0xFF33907C),
                          ),
                          SizedBox(height: 8),
                          Text('1 Bed'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.bathtub_outlined,
                            color: Color(0xFF33907C),
                          ),
                          SizedBox(height: 8),
                          Text('1 Bath'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.landscape_outlined,
                            color: Color(0xFF33907C),
                          ),
                          SizedBox(height: 8),
                          Text('1 Garden'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.weekend_outlined,
                            color: Color(0xFF33907C),
                          ),
                          SizedBox(height: 8),
                          Text('1 Living'),
                        ],
                      ),
                    ],
                  ),
                    SizedBox(height: 30),
                    Text(
                      'Owner Details',
                      style: TextStyle(
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
                              'Owner Name', // Replace with the owner's name fetched from Firebase
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Phone Number', // Replace with the owner's phone number fetched from Firebase
                            ),
                          ],
                        ),
                        Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement request logic here
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF33907C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(Icons.arrow_forward),
                          label: Text('Request'),
                        ),
                      ],
                    ),
                  ],



                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
