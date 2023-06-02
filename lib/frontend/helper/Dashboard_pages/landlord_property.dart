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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 2; i++)
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
                  top: 20,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF33907C),
                      
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Handle back button press
                      },
                      icon: Icon(Icons.arrow_back),
                      
                      color:  Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: SizedBox(
              width: 385,
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
                  Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.king_bed_outlined,
                                color: Color(0xFF33907C),
                              ),
                              SizedBox(height: 8),
                              Text('1 Bed'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bathtub_outlined,
                                color: Color(0xFF33907C),
                              ),
                              SizedBox(height: 8),
                              Text('1 Bath'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.landscape_outlined,
                                color: Color(0xFF33907C),
                              ),
                              SizedBox(height: 8),
                              Text('1 Garden'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.weekend_outlined,
                                color: Color(0xFF33907C),
                              ),
                              SizedBox(height: 8),
                              Text('1 Living'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.house_outlined,
                                color: Color(0xFF33907C),
                              ),
                              SizedBox(height: 8),
                              Text('1 Floor'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                color: Color(0xFF33907C),
                              ),
                              SizedBox(height: 8),
                              Text('1 Carspace'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -6,
                    top: 0,
                    bottom: 50,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF33907C).withOpacity(0.3),
                      size: 20,
                    ),
                  ),
                ],
              ),
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

