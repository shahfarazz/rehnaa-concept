import 'package:flutter/material.dart';

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
        title:
            Text("Landlord Dashboard", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Handle your sidebar here
          },
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(height: size.height),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
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
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Available Balance: PKR 90,000',
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w400,
                    color: Colors.green,
                  ),
                ),
                ElevatedButton(
                  child:
                      Text("Withdraw", style: TextStyle(color: Colors.black)),
                  onPressed: () {
                    // Handle your withdraw function here
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  _pages[_currentIndex],
                  style: TextStyle(fontSize: size.width * 0.05),
                ),
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
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
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
