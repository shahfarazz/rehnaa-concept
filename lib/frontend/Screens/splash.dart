import 'package:flutter/material.dart';
import 'login_page.dart'; // Import your login page
import 'dashboard.dart'; // Import your main dashboard page

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUserLoginStatus();
  }

  Future<void> checkUserLoginStatus() async {
    // Here you'll perform your check with Firebase Auth in the future.
    // For now, we simulate a delay with Future.delayed.
    await Future.delayed(Duration(seconds: 2));

    // Replace this with your actual condition
    bool isLoggedIn = false;

    if (isLoggedIn) {
      // If the user is logged in, navigate to the main page.
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => DashboardPage(),
      ));
    } else {
      // If the user is not logged in, navigate to the login page.
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginPage(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                    'assets/splashlogo.png'), // replace this with your actual asset path
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                "@ 2022, Rehnaa",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff33907c),
                  fontSize: 15,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
