import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// import 'package:rehnaa/frontend/Screens/Admin/admindashboard.dart';
// import 'package:rehnaa/frontend/Screens/Landlord/landlord_dashboard.dart';
// import 'package:rehnaa/frontend/Screens/login_page.dart';
// import 'package:rehnaa/frontend/Screens/signup_page.dart';
// import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_rented_property.dart';
import 'backend/services/authentication_service.dart';
// import 'frontend/Screens/Dealer/dealer_dashboard.dart';
// import 'frontend/Screens/Tenant/tenant_dashboard.dart';
// import 'frontend/Screens/Tenant/tenantsignupdetails.dart';
import 'frontend/Screens/splash.dart';
import 'firebase_options.dart';
// import 'frontend/helper/Tenantdashboard_pages/tenant_profile.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
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
          builder: ((context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: ResponsiveBreakpoints.builder(
                  child: BouncingScrollWrapper.builder(context, child!),
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(
                        start: 1921, end: double.infinity, name: '4K'),
                  ],
                ),
              )),

          debugShowCheckedModeBanner: false,
          title: 'Rehnaa',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(fontSize: 16),
                bodyMedium: TextStyle(fontSize: 14),
                bodySmall: TextStyle(fontSize: 12),
              )),
          // home: LandlordDashboardPage(
          //   uid: '9l1ZrmtJ0lRSSIazEpFf7xWau952',
          // ),
          // home: AdminDashboard(),
          home: const SplashScreen(),
          // home: DealerDashboardPage(uid: 'fUuFmW7bNaweyP5xkc4c'),
          // home: TenantDashboardPage(
          //   uid: 'b8F8kl7Hf2h4dOii1jzUFHsNvzw2',
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
