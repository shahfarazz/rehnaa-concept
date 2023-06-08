import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../backend/services/authentication_service.dart';
import '../Landlorddashboard_pages/landlord_profile.dart';

class TenantProfilePage extends StatefulWidget {
  final String uid;

  const TenantProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  _TenantProfilePageState createState() => _TenantProfilePageState();
}

class _TenantProfilePageState extends State<TenantProfilePage> {
  bool showChangePassword = false;

  @override
  Widget build(BuildContext context) {
    final authService = AuthenticationService();

    void toggleChangePassword() {
      setState(() {
        showChangePassword = !showChangePassword;
      });
    }

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('Tenants').doc(widget.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is being fetched, show a loading indicator
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // If there's an error fetching data, display an error message
            return Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData) {
            // If no data is available, display a message
            return Center(child: Text('No data available'));
          }

          final docData = snapshot.data!.data();

          if (docData == null) {
            // If document data is null, display a message
            return Center(child: Text('Data is null'));
          }

          final emailOrPhone = docData['emailOrPhone'] as String? ?? '';

          final firstName = docData['firstName'] as String? ?? '';
          final lastName = docData['lastName'] as String? ?? '';
          final pathToImage = docData['pathToImage'] as String? ?? '';
          final description = docData['description'] as String? ?? '';

          final isEmail = authService.isEmail(emailOrPhone);
          final isPhoneNumber = authService.isPhoneNumber(emailOrPhone);
          String contactInfo = '';

          if (isEmail) {
            contactInfo = 'Email: $emailOrPhone';
          } else if (isPhoneNumber) {
            contactInfo = 'Phone: $emailOrPhone';
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage(pathToImage),
                ),
                SizedBox(height: 20),
                Text(
                  '$firstName $lastName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$description',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Divider(),
                ProfileInfoItem(
                  icon: Icons.email,
                  title: isEmail ? 'Email' : 'Contact',
                  subtitle: contactInfo,
                ),
                ProfileInfoItem(
                  icon: Icons.location_on,
                  title: 'Location',
                  subtitle: 'Lahore, Punjab',
                ),
                if (showChangePassword)
                  Column(
                    children: [
                      SizedBox(height: 2),
                      ProfileInfoItem(
                        icon: Icons.lock,
                        title: 'Change Password',
                        subtitle: 'Click to change your password',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String newPassword = '';

                              return AlertDialog(
                                title: Text('Change Password'),
                                content: TextField(
                                  onChanged: (value) {
                                    newPassword = value;
                                  },
                                  decoration: InputDecoration(hintText: 'Enter new password'),
                                ),
                                actions: [
                                  ElevatedButton(
                                    
                                    onPressed: () {
                                      // Handle password change logic here
                                      print('New password: $newPassword');
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Save'),
                                    
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                GestureDetector(
                  onTap: toggleChangePassword,
                  child: Row(
                    children: [
                      SizedBox(width: 17, height: 60),
                      Icon(
                        Icons.settings,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 31),
                      Expanded(
                        child: Text(
                          'Additional Settings',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: showChangePassword
                              ? Icon(
                                  Icons.arrow_drop_up,
                                  color: Colors.grey,
                                  key: UniqueKey(),
                                )
                              : Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                  key: UniqueKey(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ProfileInfoItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
