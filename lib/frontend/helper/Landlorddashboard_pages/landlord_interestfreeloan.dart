import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../backend/models/landlordmodel.dart';
import '../../Screens/Landlord/landlord_dashboard.dart';

class InterestFreeLoanPage extends StatefulWidget {
final String uid;
const InterestFreeLoanPage({super.key, required this.uid});

@override
State<InterestFreeLoanPage> createState() =>
    _InterestFreeLoanPageState();
}

class _InterestFreeLoanPageState extends State<InterestFreeLoanPage> {
bool isApplied = false;
Landlord? landlord;

Future<void> checkIsApplied() async {
  var myLandlord = await FirebaseFirestore.instance
      .collection('Landlords')
      .doc(widget.uid)
      .get();

  setState(() {
    landlord = Landlord.fromJson(myLandlord.data()!);
  });

}

@override
Widget build(BuildContext context) {
  final Size size = MediaQuery.of(context).size;

  
  return Scaffold(
    appBar: _buildAppBar(size, context),

    body: SingleChildScrollView(
      child: Container(
        color: Colors.grey[200], // Set the background color
        padding: const EdgeInsets.symmetric(
          vertical: 100.0,
          horizontal: 16.0,
        ), // Updated padding
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Interest Free Loan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Color(0xff45BF7A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.grey, width: 0.1),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'You can apply for one month worth rent as an interest free loan after being a Rehnaa member for six months',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                     
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Align contents vertically in the center
                    children: [
                      Row(
                        children: [
                      const SizedBox(width: 127),

                          Text(
                            landlord?.dateJoined
                                    ?.toDate()
                                    .toString()
                                    .substring(0, 10) ??
                                'Date Joined',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: Color(0xff45BF7A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      
                      Row(
                        children: [
                      const SizedBox(width: 127),

                          Text(
                            'Date Joined',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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


PreferredSizeWidget _buildAppBar(Size size, context) {
  return AppBar(
    toolbarHeight: 70,
    
    title: Padding(
      padding: EdgeInsets.only(
      // top: MediaQuery.of(context).size.height * 0.02, // 2% of the page height
      right: MediaQuery.of(context).size.width * 0.14, // 55% of the page width
    ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: [
              ClipPath(
                clipper: HexagonClipper(),
                child: Transform.scale(
                  scale: 0.87,
                  child: Container(
                    color: Colors.white,
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
              ClipPath(
                clipper: HexagonClipper(),
                child: Image.asset(
                  'assets/mainlogo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          // const SizedBox(width: 8),
        ],
      ),
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Stack(
          children: [
            
            
          ],
        ),
      ),
    ],
    flexibleSpace: Container(
      decoration: const BoxDecoration(
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
    ),
  );
}


class HexagonClipper extends CustomClipper<Path> {
@override
Path getClip(Size size) {
  final path = Path();
  final double controlPointOffset = size.height / 6;

  path.moveTo(size.width / 2, 0);
  path.lineTo(size.width, size.height / 2 - controlPointOffset);
  path.lineTo(size.width, size.height / 2 + controlPointOffset);
  path.lineTo(size.width / 2, size.height);
  path.lineTo(0, size.height / 2 + controlPointOffset);
  path.lineTo(0, size.height / 2 - controlPointOffset);
  path.close();
  return path;
}
@override
bool shouldReclip(CustomClipper<Path> oldClipper) {
  return false;
}
}


