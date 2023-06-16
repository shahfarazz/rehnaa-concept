import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../backend/services/authentication_service.dart';
import '../Landlorddashboard_pages/landlord_profile.dart';

class DealerProfilePage extends StatefulWidget {
  final String uid;

  const DealerProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  _DealerProfilePageState createState() => _DealerProfilePageState();
}

class _DealerProfilePageState extends State<DealerProfilePage> {
  bool showChangePassword = false;
  bool showDeleteAccount = false;

  @override
  Widget build(BuildContext context) {
    final authService = AuthenticationService();

    void toggleChangePassword() {
      setState(() {
        showChangePassword = !showChangePassword;
      });
    }

    void toggleDeleteAccount() {
      setState(() {
        showDeleteAccount = !showDeleteAccount;
      });
    }

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('Dealers')
            .doc(widget.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is being fetched, show a loading indicator
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // If there's an error fetching data, display an error message
            return const Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData) {
            // If no data is available, display a message
            return const Center(child: Text('No data available'));
          }

          final docData = snapshot.data!.data();

          if (docData == null) {
            // If document data is null, display a message
            return const Center(child: Text('Data is null'));
          }

          final emailOrPhone = docData['emailOrPhone'] as String? ?? '';

          final firstName = docData['firstName'] as String? ?? '';
          final lastName = docData['lastName'] as String? ?? '';
          final pathToImage =
              docData['pathToImage'] as String? ?? 'assets/defaulticon.png';
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage(pathToImage),
                ),
                const SizedBox(height: 20),
                Text(
                  '$firstName $lastName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ProfileInfoItem(
                  icon: Icons.email,
                  title: isEmail ? 'Email' : 'Contact',
                  subtitle: contactInfo,
                ),
                const ProfileInfoItem(
                  icon: Icons.location_on,
                  title: 'Location',
                  subtitle: 'Lahore, Punjab',
                ),
                GestureDetector(
                  onTap: toggleChangePassword,
                  child: Row(
                    children: [
                      const SizedBox(width: 17, height: 60),
                      Icon(
                        Icons.settings,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 31),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 18),
                            const Text(
                              'Additional Settings',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Click to access additional settings',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
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
                if (showChangePassword)
                  Column(
                    children: [
                      const SizedBox(
                        height: 17,
                        width: 8,
                      ),
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
                                title: const Text('Change Password'),
                                content: TextField(
                                  onChanged: (value) {
                                    newPassword = value;
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Enter new password'),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle password change logic here
                                      print('New password: $newPassword');
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Save'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      ProfileInfoItem(
                        icon: Icons.delete,
                        title: 'Delete Account',
                        subtitle: 'Click to delete your account',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String password = '';

                              return AlertDialog(
                                title: const Text('Delete Account'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                        'Enter your password to confirm account deletion:'),
                                    TextField(
                                      onChanged: (value) {
                                        password = value;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: 'Password'),
                                      obscureText: true,
                                    ),
                                    if (password.isNotEmpty &&
                                        password != 'correct_password')
                                      const Text(
                                        'Incorrect password',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (password == 'correct_password') {
                                        // Handle account deletion logic here
                                        print('Deleting account...');
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
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
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
