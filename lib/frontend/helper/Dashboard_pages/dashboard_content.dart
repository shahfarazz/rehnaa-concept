import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/login_page.dart';

class DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // Move the code for your dashboard's content here
    return Column(
      children: <Widget>[
        SizedBox(height: size.height * 0.05),

        Column(
          
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome Aristotle!',
              style: GoogleFonts.montserrat(
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CircleAvatar(
              radius: 75,
              child: ClipOval(
                child: Image.asset(
                  'assets/userimage.png',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
          ),
        SizedBox(height: size.height * 0.05),

        ],
      ),

        Center(
          child: Container(
            width: size.width * 0.8,
            height: size.height * 0.4, // Adjust the height as needed
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4), // changes position of shadow
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Available Balance',
                          style: GoogleFonts.montserrat(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromARGB(150, 0, 0, 0),
                          ),
                        ),
                        Text(
                          'PKR 90,000',
                          style: GoogleFonts.montserrat(
                            fontSize: size.width * 0.07,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),
                        Container(
                          width:
                              size.width * 0.6, // Increase the width as needed
                          height: size.height * 0.06,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
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
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  "Withdraw",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
