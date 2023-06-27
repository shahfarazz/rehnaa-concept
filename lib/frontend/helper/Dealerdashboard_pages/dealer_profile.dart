import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../backend/services/authentication_service.dart';
import '../../Screens/splash.dart';
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
  final TextEditingController _enterPasswordController =
      TextEditingController();
  final TextEditingController _enterCodeController = TextEditingController();

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
          // final isPhoneNumber = authService.isPhoneNumber(emailOrPhone);
          String contactInfo = '';

          if (isEmail) {
            contactInfo = 'Email: $emailOrPhone';
          } else {
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
                  backgroundImage:
                      pathToImage != null && pathToImage.startsWith('https')
                          ? NetworkImage(pathToImage) as ImageProvider<Object>?
                          : AssetImage('assets/defaulticon.png'),
                ),
                const SizedBox(height: 20),
                Text(
                  '$firstName $lastName',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.montserrat().fontFamily),
                ),
                Text(
                  description,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: GoogleFonts.montserrat().fontFamily),
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
                            Text(
                              'Additional Settings',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Click to access additional settings',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily),
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
                        onTap: () async {
                          User? currentUser = FirebaseAuth.instance.currentUser;
                          String? phoneNumber = currentUser?.phoneNumber;
                          bool isPhoneNumberLogin = phoneNumber != null;

                          if (isPhoneNumberLogin) {
                            String? enteredVerificationCode;
                            print('phone number is $phoneNumber');

                            // Send verification code via SMS
                            await FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: phoneNumber!,
                              verificationCompleted:
                                  (PhoneAuthCredential credential) async {
                                try {
                                  // Reauthenticate the user with the credential
                                  print('credential is $credential');
                                  await currentUser
                                      ?.reauthenticateWithCredential(
                                          credential);

                                  // Delete the user account
                                  await currentUser?.delete();

                                  // Show a success message to the user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Account deleted successfully.'),
                                    ),
                                  );
                                } catch (e) {
                                  // Show an error message if the account deletion fails
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString().substring(30)),
                                    ),
                                  );
                                  print('Error: $e');
                                }
                              },
                              verificationFailed: (FirebaseAuthException e) {
                                // Handle verification failure
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().substring(30)),
                                  ),
                                );
                                print(
                                    'Phone number verification failed: ${e.message}');
                              },
                              codeSent: (String verificationId,
                                  [int? forceResendingToken]) async {
                                // Prompt the user to enter the verification code
                                enteredVerificationCode = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Phone Verification'),
                                    content: TextFormField(
                                      controller: _enterCodeController,
                                      decoration: InputDecoration(
                                        labelText:
                                            'Enter the verification code',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the verification code';
                                        }
                                        return null;
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(null),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          enteredVerificationCode =
                                              _enterCodeController.text;
                                          Navigator.of(context)
                                              .pop(enteredVerificationCode);
                                        },
                                        child: Text('Verify'),
                                      ),
                                    ],
                                  ),
                                );

                                if (enteredVerificationCode != null) {
                                  // Create PhoneAuthCredential using the entered verification code
                                  PhoneAuthCredential credential =
                                      PhoneAuthProvider.credential(
                                    verificationId: verificationId,
                                    smsCode: enteredVerificationCode!,
                                  );

                                  try {
                                    // Reauthenticate the user with the credential
                                    await currentUser
                                        ?.reauthenticateWithCredential(
                                            credential);

                                    // // Delete the user account
                                    // await currentUser
                                    //     ?.delete();

                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(currentUser?.uid)
                                        .set({
                                      'isDisabled': true,
                                    }, SetOptions(merge: true));

                                    // Show a success message to the user
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Account deleted successfully.'),
                                      ),
                                    );

                                    // Sign out the user
                                    await FirebaseAuth.instance.signOut();
                                    // navigate to splash screen
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => SplashScreen(),
                                      ),
                                    );
                                  } catch (e) {
                                    // Show an error message if the reauthentication fails
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(e.toString().substring(30)),
                                      ),
                                    );
                                    print('Error: $e');
                                  }
                                }
                              },
                              codeAutoRetrievalTimeout:
                                  (String verificationId) {},
                            );
                          } else {
                            String? enteredPassword;

                            // Show a password prompt dialog to the user
                            enteredPassword = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Password Confirmation'),
                                content: TextFormField(
                                  controller: _enterPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Enter your password',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(null),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      enteredPassword =
                                          _enterPasswordController.text;
                                      Navigator.of(context)
                                          .pop(enteredPassword);
                                    },
                                    child: Text('Confirm'),
                                  ),
                                ],
                              ),
                            );

                            if (enteredPassword != null) {
                              try {
                                // Reauthenticate the user with the entered password
                                AuthCredential credential =
                                    EmailAuthProvider.credential(
                                  email: currentUser?.email ?? '',
                                  password: enteredPassword!,
                                );

                                // Delete the user account
                                await currentUser
                                    ?.reauthenticateWithCredential(credential);
                                await currentUser?.delete();

                                // Show a success message to the user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Account deleted successfully.'),
                                  ),
                                );
                              } catch (e) {
                                // Show an error message if the account deletion fails
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().substring(30)),
                                  ),
                                );
                                print('Error: $e');
                              }
                            }
                          }
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
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.montserrat().fontFamily),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
