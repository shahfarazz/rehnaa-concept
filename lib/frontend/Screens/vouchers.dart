import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VouchersPage(),
    );
  }
}

class VouchersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 40.0,
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
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 20,
                  ),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Column(
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
                              buildRoundedImageCard(context, 'assets/image1.jpg'),
                              SizedBox(height: 10),
                              buildRoundedImageCard(context, 'assets/image1.jpg'),
                              SizedBox(height: 10),
                              buildRoundedImageCard(context, 'assets/image1.jpg'),
                              SizedBox(height: 10),
                              buildRoundedImageCard(context, 'assets/image1.jpg'),
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
        ],
      ),
    );
  }

  Widget buildRoundedImageCard(BuildContext context, String imagePath) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ExpandedImageDialog(imagePath: imagePath);
          },
        );
      },
      child: ClipRRect(
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
      ),
    );
  }
}
class ExpandedImageDialog extends StatelessWidget {
  final String imagePath;

  const ExpandedImageDialog({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Container(
        
        constraints: BoxConstraints.expand(),
        child: InteractiveViewer(
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
