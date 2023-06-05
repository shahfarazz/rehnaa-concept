import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:rehnaa/frontend/Screens/login_page.dart';
import 'backend/services/authentication_service.dart';
import 'frontend/Screens/Tenant/tenant_dashboard.dart';
import 'frontend/Screens/splash.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthenticationService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rehnaa',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // home: const SplashScreen(),
        home: TenantDashboardPage(
            uid: 'K55YzmkUXt09OgFwnDuT'), //TODO remove this Jugaar
        // home: LoginPage(),
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
