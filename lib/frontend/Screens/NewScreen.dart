import 'package:flutter/material.dart';

class VouchersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyScreen(),
    );
  }
}

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30),

          Container(
            
            height: MediaQuery.of(context).size.height * 0.1,
            child: Image.asset(
              'assets/mainlogo.png',
              // fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            
            child: SingleChildScrollView(
              
              child: Center(
                
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Card(
                    
                    color: Color.fromARGB(255, 235, 235, 235),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                        SizedBox(height: 10),

                          Text(
                            "Vouchers",
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xff33907c),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          buildRoundedImageCard('assets/image1.jpg'),
                          SizedBox(height: 10),
                          buildRoundedImageCard('assets/image1.jpg'),
                          SizedBox(height: 10),
                          buildRoundedImageCard('assets/image1.jpg'),
                          SizedBox(height: 10),
                          buildRoundedImageCard('assets/image1.jpg'),
                          SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRoundedImageCard(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Card(
        child: Container(
          width: double.infinity,
          height: 200,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
