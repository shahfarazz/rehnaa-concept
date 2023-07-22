import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rehnaa/frontend/Screens/Dealer/dealer_dashboard.dart';
import 'Tenant/tenant_dashboard.dart';
import 'login_page.dart'; // Import your login page
import 'Landlord/landlord_dashboard.dart'; // Import your main dashboard page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserLoginStatus();
    });
  }

  void checkUserLoginStatus() async {
    await Future.delayed(Duration(seconds: 2));

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // If the user is logged in, navigate to the main page.
        FirebaseCrashlytics.instance.setUserIdentifier(user.uid);

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          if (data['type'] == 'Tenant') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => TenantDashboardPage(uid: user.uid),
            ));
          } else if (data['type'] == 'Landlord') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => LandlordDashboardPage(uid: user.uid),
            ));
          } else if (data['type'] == 'Dealer') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => DealerDashboardPage(uid: user.uid),
            ));
          } else {
            print('User type not found');
          }
        } else {
          //edge case , go to login page
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => LoginPage(),
          ));
        }
      } else {
        // If the user is not logged in, navigate to the login page.
        if (kDebugMode) {
          print('User is not logged in');
        }
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
      }
    });
  }

  // store the current year in a String variable
  String year = DateTime.now().year.toString();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/splashlogo.png',
                ), // replace this with your actual asset path
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.01),
                  child: Text(
                    "@ ${year}, Rehnaa",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff33907c),
                      fontSize: 15,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.1),
                  child: Text(
                    "Registered with SECP",
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
          ],
        ),
      ),
    );
  }
}
