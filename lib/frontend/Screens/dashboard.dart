import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      appBar: AppBar(
        title: const Text("Hello ${1}",
            style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Color(0xff33907C),
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Handle your sidebar here
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              top: size.height * 0.03,
              left: size.width * 0.05,
              right: size.width * 0.05),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: size.width * 0.15,
                  // backgroundImage: NetworkImage('Your image URL here'),
                  // For now, let's use a basic Flutter logo as a placeholder
                  child: FlutterLogo(size: size.width * 0.1),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Landlord Name',
                  style: TextStyle(
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Container(
                  width: size.width * 0.6,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2, // Decreased Spread Radius
                        blurRadius: 3, // Decreased Blur Radius
                        offset: Offset(0, 3), // Shadow only at the bottom
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'PKR 90,000',
                        style: TextStyle(
                          fontSize: size.width * 0.07,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Updated just now',
                        style: TextStyle(
                          fontSize: size.width * 0.03,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                InkWell(
                  onTap: () {
                    // Handle your withdraw function here
                    // temporarily making withdraw button logout and redirect to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: size.width * 0.6,
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
                    child: const Center(
                      child: Text(
                        "Withdraw",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                // Text(
                //   _pages[_currentIndex],
                //   style: TextStyle(fontSize: size.width * 0.05),
                // ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(
              icon: Icon(Icons.home_work), label: 'Property'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Rent History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin), label: 'Profile'),
        ],
      ),
    );
  }
}
