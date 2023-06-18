import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rehnaa/backend/services/authentication_service.dart';

import '../../Screens/signup_page.dart';

class LandlordProfilePage extends StatefulWidget {
  final String uid;

  const LandlordProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  _LandlordProfilePageState createState() => _LandlordProfilePageState();
}

class _LandlordProfilePageState extends State<LandlordProfilePage> {
  bool showAdditionalSettings = false;
  bool showChangePassword = false;
  bool _obscurePassword = true; // Track whether the password is obscured or not
  bool _obscurePassword2 =
      true; // Track whether the password is obscured or not
  //define two new controllers for the password fields
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      //show green loading indicator
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(
                    color: Colors.green,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Text('Changing password...'),
                ],
              ),
            );
          });
      User? user = FirebaseAuth.instance.currentUser;

      //check if user is signed up using mobile number or email
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get()
          .then((value) async {
        String emailOrPhone = value['emailOrPhone'];
        if (emailOrPhone == null) {
          //show toast that there is no email or phone number associated with this account
          Fluttertoast.showToast(
              msg:
                  'There is no email or phone number associated with this account',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
        if (emailOrPhone.contains('@')) {
          //user signed up using email
          print(
              'user signed up using email is $emailOrPhone ,password is $oldPassword, new pass is $newPassword');

          if (user != null) {
            // Reauthenticate the user with their old password
            AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!,
              password: oldPassword,
            );
            await user.reauthenticateWithCredential(credential);

            // Change the user's password
            await user.updatePassword(newPassword);
            //show toast
            Fluttertoast.showToast(
                msg: 'Password changed successfully',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            print('No user signed in');
          }
        } else {
          //user signed up using mobile number
          print('user signed up using mobile number');
          String hashPassword = hashString(oldPassword);
          //check firebase firestore users collecion to get hashed password
          // stored in password field
          FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .get()
              .then((value) async {
            String password = value['password'];
            if (password == hashPassword) {
              //user entered correct old password
              //update password in firebase firestore
              String newHashPassword = hashString(newPassword);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .update({'password': newHashPassword});
              print('Password changed successfully');
            } else {
              //user entered wrong old password
              print('user entered wrong old password');
              Fluttertoast.showToast(
                  msg: 'Wrong old password entered',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          });
        }
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
    } catch (e) {
      print('Error changing password: $e');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  void toggleAdditionalSettings() {
    setState(() {
      showAdditionalSettings = !showAdditionalSettings;
    });
  }

  void toggleChangePassword() {
    setState(() {
      showChangePassword = !showChangePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthenticationService();
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('Landlords')
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage(pathToImage),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Handle edit image logic here
                      },
                    ),
                  ],
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
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      transitionBuilder: (child, animation) {
                                        final height = constraints.maxHeight;
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
                                      subtitle: 'Click to change your password',
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    setState) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Change Password'),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          controller:
                                                              _oldPasswordController,
                                                          obscureText:
                                                              _obscurePassword,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Old Password',
                                                            suffixIcon:
                                                                GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  _obscurePassword =
                                                                      !_obscurePassword;
                                                                });
                                                              },
                                                              child: Icon(
                                                                _obscurePassword
                                                                    ? Icons
                                                                        .visibility
                                                                    : Icons
                                                                        .visibility_off,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        TextField(
                                                          controller:
                                                              _newPasswordController,
                                                          obscureText:
                                                              _obscurePassword2,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'New Password',
                                                            suffixIcon:
                                                                GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  _obscurePassword2 =
                                                                      !_obscurePassword2;
                                                                });
                                                              },
                                                              child: Icon(
                                                                _obscurePassword2
                                                                    ? Icons
                                                                        .visibility
                                                                    : Icons
                                                                        .visibility_off,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          )),
                                                      TextButton(
                                                          onPressed: () {
                                                            changePassword(
                                                                _oldPasswordController
                                                                    .text,
                                                                _newPasswordController
                                                                    .text);
                                                            // Navigator.pop(context);
                                                          },
                                                          child: Text(
                                                            'Change',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ))
                                                    ],
                                                  );
                                                },
                                              );
                                            });
                                      },
                                    ),
                                    ProfileInfoItem(
                                      icon: Icons.delete,
                                      title: 'Delete Account',
                                      subtitle: 'Click to delete your account',
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
