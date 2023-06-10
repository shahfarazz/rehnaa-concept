import 'package:flutter/material.dart';

class LandlordRequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.1,
              size.height * 0.1,
              0,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.green, // Set the color to green
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Navigate back on button press
                      },
                    ),
                  ],
                ),
                Text(
                  'Landlord Requests',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                // Add your request items or content here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
