import 'package:flutter/material.dart';
import 'package:rehnaa/frontend/helper/Dashboard_pages/dashboard_content.dart';
import 'package:rehnaa/frontend/helper/Dashboard_pages/landlord_profile.dart';

import '../helper/Dashboard_pages/landlord_propertyinfo.dart';
import '../helper/Dashboard_pages/landlord_renthistory.dart';
import '../helper/Dashboard_pages/landlord_tenants.dart';
import '../helper/landlordproperties.dart';

class DashboardPage extends StatefulWidget {
  final String uid; // UID of the landlord

  DashboardPage({required this.uid});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final _pageController = PageController();

  void onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _appBar(size),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          DashboardContent(
            uid: widget.uid,
          ),
          LandlordTenantsPage(
            uid: widget.uid,
          ),
          LandlordPropertiesPage(),
          LandlordRentHistoryPage(),
          LandlordProfilePage(),
          // ProfilePage(),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  // Your other methods go here (e.g., _appBar, _bottomNavigationBar)
  PreferredSizeWidget? _appBar(Size size) {
    return AppBar(
      // Set the height of the AppBar.
      toolbarHeight: 70,
      leading: Padding(
        padding: EdgeInsets.only(top: 8.0), // Move the menu icon a bit up
        child: IconButton(
          iconSize: 30.0, // Increase size of the menu icon
          icon: Icon(Icons.menu),
          onPressed: () {
            // TODO: Implement sidebar handling hered
          },
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(
          top: 2.0,
        ), // You can adjust this value to align vertically
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: [
                ClipPath(
                  clipper: HexagonClipper(),
                  child: Transform.scale(
                    scale:
                        0.87, // This value will control the size of the hexagonal container. Adjust as needed.
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
                  15.0), // Padding to align notification icon with userimage.png
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
                right: 13,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 10,
                    minHeight: 10,
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
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 8.0),
        //   child: CircleAvatar(
        //     radius: 25, // Increase radius of the CircleAvatar
        //     child: ClipOval(
        //       child: Image.asset(
        //         'assets/userimage.png',
        //         width: 50, // Increase width and height of userimage.png
        //         height: 50,
        //       ),
        //     ),
        //   ),
        // ),
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
