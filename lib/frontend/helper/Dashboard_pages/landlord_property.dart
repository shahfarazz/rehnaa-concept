import 'package:flutter/material.dart';

class PropertyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
  flex: 4,
  child: Stack(
    children: [
      PageView(
        // FutureBuilder to fetch images from Firebase in the future
        children: [
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
              'Image 1 of 2', // Update with current image and total count from future snapshot
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 8), // Add desired space width
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
            color: Color.fromRGBO(0, 0, 0, 0.298), // Transparency color: #33907C with 30% opacity
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: () {
              // Handle back button press
            },
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
          ),
        ),
      ),
    ],
  ),
),

          Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 13),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
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
                SizedBox(height: 15),
                Text(
                  'Specifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Specifications details go here...',
                ),
              ],
            ),
          ),
        ),

          Expanded(
            flex: 6,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.8,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
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
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        'Owner Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Owner details go here...'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Implement contact owner logic here
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF33907C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          child: Text(
                            'Contact Owner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
