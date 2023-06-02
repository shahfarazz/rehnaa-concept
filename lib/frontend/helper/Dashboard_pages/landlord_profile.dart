import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'landlord_tenants.dart';
import 'package:flutter/material.dart';

class LandlordProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/userimage.jpg'),
            ),
            SizedBox(height: 20),
            Text(
              'Shah Faraz',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Landlord',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            ProfileInfoItem(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'johndoe@example.com',
            ),
            ProfileInfoItem(
              icon: Icons.phone,
              title: 'Phone',
              subtitle: '+92 333-248-0587',
            ),
            ProfileInfoItem(
              icon: Icons.location_on,
              title: 'Location',
              subtitle: 'Lahore, Punjab',
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  ProfileInfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LandlordProfilePage(),
  ));
}
