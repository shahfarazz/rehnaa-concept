import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/login_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final List<String> _pages = [
    "Home Page",
    "Tenant Page",
    "Property Page",
    "Rent History Page",
    "Profile Page",
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: _appBar(size),
        body: _mainContent(size),
        bottomNavigationBar: _bottomNavigationBar());
  }

  PreferredSizeWidget? _appBar(Size size) {
    return AppBar(
      // Set the height of the AppBar.
      toolbarHeight: 100,
      leading: Padding(
        padding: EdgeInsets.only(top: 15.0), // Move the menu icon a bit up
        child: IconButton(
          iconSize: 30.0, // Increase size of the menu icon
          icon: Icon(Icons.menu),
          onPressed: () {
            // TODO: Implement sidebar handling here
          },
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(
            top: 5.0,
            left: 30.0), // You can adjust this value to align vertically
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: [
                ClipPath(
                  clipper: HexagonClipper(),
                  child: Transform.scale(
                    scale:
                        1.0, // This value will control the size of the hexagonal container. Adjust as needed.
                    child: Container(
                      color: Colors.white,
                      width: 76,
                      height: 76,
                    ),
                  ),
                ),
                ClipPath(
                  clipper: HexagonClipper(),
                  child: Image.asset(
                    'assets/mainlogo.png',
                    width: 76,
                    height: 76,
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              top:
                  28.0), // Padding to align notification icon with userimage.png
          child: Stack(
            children: [
              IconButton(
                icon: Icon(Icons
                    .notifications_active), // Using a different notification icon
                onPressed: () {
                  // TODO: Implement notifications handling here
                },
              ),
              Positioned(
                right: 11,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '9', // Dummy number for notifications
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CircleAvatar(
            radius: 25, // Increase radius of the CircleAvatar
            child: ClipOval(
              child: Image.asset(
                'assets/userimage.png',
                width: 50, // Increase width and height of userimage.png
                height: 50,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff0FA697),
              Color(0xff45BF7A),
              Color(0xff0DF205) // Change to F6F9FF
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainContent(Size size) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Welcome Aristotle!',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
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

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: onTabTapped,
      currentIndex: _currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tenant'),
        BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'Property'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history), label: 'Rent History'),
        BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: 'Profile'),
      ],
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 4);
    path.lineTo(size.width, size.height * 3 / 4);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height * 3 / 4);
    path.lineTo(0, size.height / 4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
