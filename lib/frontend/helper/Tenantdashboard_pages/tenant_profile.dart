import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

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
  bool showDeleteAccount = false;

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

  @override
  Widget build(BuildContext context) {
    final authService = AuthenticationService();

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('Tenants')
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

          return Container(
              constraints: BoxConstraints(),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
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
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showChangePassword = !showChangePassword;
                                  });
                                },
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            transitionBuilder:
                                                (child, animation) {
                                              final height =
                                                  constraints.maxHeight;
                                              return ScaleTransition(
                                                scale: CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOut,
                                                ),
                                                child: child,
                                              );
                                            },
                                            child: showChangePassword
                                                ? const Icon(
                                                    Icons.arrow_drop_up,
                                                    color: Colors.grey,
                                                    key: Key('arrow_up'),
                                                  )
                                                : const Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.grey,
                                                    key: Key('arrow_down'),
                                                  ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, -0.5),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: showChangePassword
                                    ? Column(
                                        key: const Key('additional_settings'),
                                        children: [
                                          const SizedBox(
                                            height: 17,
                                            width: 8,
                                          ),
                                          ProfileInfoItem(
                                            icon: Icons.lock,
                                            title: 'Change Password',
                                            subtitle:
                                                'Click to change your password',
                                            onTap: () {
                                              // Change password logic
                                            },
                                          ),
                                          ProfileInfoItem(
                                            icon: Icons.delete,
                                            title: 'Delete Account',
                                            subtitle:
                                                'Click to delete your account',
                                            onTap: () {
                                              // Delete account logic
                                            },
                                          ),
                                        ],
                                      )
                                    : const SizedBox(
                                        width: 0,
                                        height: 0,
                                      ), // Empty SizedBox
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ));
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
