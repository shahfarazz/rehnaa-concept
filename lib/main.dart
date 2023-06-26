import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// import 'package:rehnaa/frontend/Screens/Admin/admindashboard.dart';
import 'package:rehnaa/frontend/Screens/Landlord/landlord_dashboard.dart';
import 'package:rehnaa/frontend/Screens/login_page.dart';
import 'package:rehnaa/frontend/Screens/signup_page.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_rented_property.dart';
import 'backend/services/authentication_service.dart';
import 'frontend/Screens/Dealer/dealer_dashboard.dart';
import 'frontend/Screens/Tenant/tenant_dashboard.dart';
import 'frontend/Screens/Tenant/tenantsignupdetails.dart';
import 'frontend/Screens/splash.dart';
import 'firebase_options.dart';
import 'frontend/helper/Tenantdashboard_pages/tenant_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Check if the user is swiping from the left edge
        if (details.delta.dx < 0) {
          // Disable the pop gesture by consuming the event
          return;
        }
      },
      child: ChangeNotifierProvider(
        create: (context) => AuthenticationService(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Rehnaa',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: LandlordDashboardPage(
            uid: '0RrAUsYh5EO2QH01RVarNP1MIir1',
          ),
          // home: AdminDashboard(),
          // home: const SplashScreen(),
          // home: DealerDashboardPage(uid: 'fUuFmW7bNaweyP5xkc4c'),
          // home: TenantDashboardPage(
          //   uid: 'GjGmEM8AnvXIebnvKuCvOOkTDpL2',
          // ), //TODO remove this Jugaar
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rehnaa'),
      ),
      body: const Center(
        child: Text(
          'Firebase Initialized!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
