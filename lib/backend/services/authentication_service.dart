import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rehnaa/frontend/Screens/Landlord/landlord_dashboard.dart';

import '../../frontend/Screens/Dealer/dealer_dashboard.dart';
import '../../frontend/Screens/Tenant/tenant_dashboard.dart';
import '../../frontend/Screens/signup_page.dart';
// import 'package:rehnaa/frontend/helper/Admindashboard_pages/admin_landlordinputhelper.dart';
// Required for ChangeNotifier

class AuthenticationService extends ChangeNotifier {
  // Extend ChangeNotifier
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter to expose the current user
  User? get currentUser => _auth.currentUser;

  // rest of your code...

  void showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  bool isEmail(String input) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(input);
  }

  bool isPhoneNumber(String input) {
    // Remove any non-digit characters from the input
    String digitsOnly = input.replaceAll(RegExp(r'\D'), '');

    // Check if the input is a valid phone number using your regex pattern
    final regex = RegExp(r'^03\d{9}$');
    return regex.hasMatch(digitsOnly);
  }

  Future<void> loginWithPhoneNumberAndPasswordFromFirestore(
      String phoneNumber, String password, BuildContext context) async {
    try {
      // Get the user document from Firestore based on the phone number
      print(phoneNumber);
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('emailOrPhone', isEqualTo: phoneNumber)
          .get();

      //show error if userDoc is empty
      if (userDoc.size == 0) {
        showToast('Phone number not found. Please register first.', Colors.red);
        return;
      }

      if (userDoc.size == 1) {
        final user = userDoc.docs.first;
        phoneNumber = '+92${phoneNumber.substring(1)}';

        // Get the password stored in Firestore for the user
        final storedPassword = user.data()['password'];

        if (storedPassword == password) {
          // Use Firebase Authentication to sign in with phone number and password
          final credential = PhoneAuthProvider.credential(
            verificationId: '', // Empty verification ID
            smsCode: '', // Empty SMS code
          );

          final authResult =
              await FirebaseAuth.instance.signInWithCredential(credential);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LandlordDashboardPage(uid: _auth.currentUser!.uid)),
          );

          // User is successfully authenticated
          print('User authenticated');
        } else {
          // Incorrect password
          print('Incorrect password');
        }
      } else {
        // User not found in Firestore
        print('User not found');
      }
    } catch (e) {
      // Error occurred during login process
      print('Login error: $e');
    }
  }

  Future<void> signInWithPhoneNumber(
    String phoneNumber,
    String password,
    BuildContext context,
  ) async {
    bool isSignInCompleted = false; // Flag to track sign-in completion

    print(phoneNumber);
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('emailOrPhone', isEqualTo: phoneNumber)
        .get();

    // check in users if account is disabled
    if (userDoc.size == 1) {
      final user = userDoc.docs.first;
      if (user.data()['isDisabled'] == true) {
        showToast('Your account is disabled. Please contact admin.',
            Colors.redAccent);
        return;
      }
    }

    //show error if userDoc is empty
    if (userDoc.size == 0) {
      showToast('Phone number not found. Please register first.', Colors.red);
      return;
    }

    if (userDoc.size == 1) {
      final user = userDoc.docs.first;
      // String phoneNumber;

      if (phoneNumber.startsWith('0')) {
        phoneNumber = phoneNumber.replaceFirst(RegExp('^0'), '+92');
        // phoneNumber = '+92${phoneNumber.substring(1)}';
      } else if (phoneNumber.startsWith('+92')) {
        phoneNumber = phoneNumber;
      } else {
        // Handle invalid cases or default behavior
        // flutter taost error
        Fluttertoast.showToast(
            msg: 'Invalid Phone Number',
            textColor: Colors.red,
            backgroundColor: Colors.white);

        return;
      }

      print('phone number is $phoneNumber');

      // Get the password stored in Firestore for the user
      final storedPassword = user.data()['password'];
      final hashpass = hashString(password);

      if (hashpass == storedPassword) {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            if (kDebugMode) {
              print(
                  "Phone number automatically verified and user signed in: ${_auth.currentUser?.uid}");
            }

            // Notify listeners to update
            notifyListeners();
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .get();

            print('userDoc.data is ${userDoc.data()}');

            if (userDoc.data()!['type'] == 'Tenant') {
              //push to tenant dashboard
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TenantDashboardPage(uid: _auth.currentUser!.uid)),
              );
            } else if (userDoc.data()!['type'] == 'Landlord') {
              //push to landlord dashboard
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LandlordDashboardPage(uid: _auth.currentUser!.uid)),
              );
            } else if (userDoc.data()!['type'] == 'Dealer') {
              //push to dealer dashboard
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DealerDashboardPage(uid: _auth.currentUser!.uid)),
              );
            }
            isSignInCompleted = true; // Mark sign-in as completed
          },
          verificationFailed: (FirebaseAuthException e) {
            if (kDebugMode) {
              print(
                  "Phone number verification failed. Code: ${e.code}. Message: ${e.message}");
            }
            showToast('Phone number verification failed. Please try again.',
                Colors.red);
            Navigator.of(context).pop();
          },
          codeSent: (String verificationId, int? resendToken) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                TextEditingController smsController = TextEditingController();
                return AlertDialog(
                  title: const Text('Enter SMS Code'),
                  content: TextField(
                    controller: smsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SMS Code',
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Verify'),
                      onPressed: () async {
                        String smsCode = smsController.text.trim();
                        try {
                          PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: smsCode);
                          await _auth.signInWithCredential(credential);
                          if (kDebugMode) {
                            print(
                                "Phone number verified and user signed in: ${_auth.currentUser?.uid}");
                          }
                          // Navigator.of(context).pop();

                          //check if signed in user is tenant or landlord
                          //which is stored in the type field in doc of user
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .get();

                          print('userDoc.data is ${userDoc.data()}');

                          if (userDoc.data()!['type'] == 'Tenant') {
                            //push to tenant dashboard
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TenantDashboardPage(
                                      uid: _auth.currentUser!.uid)),
                            );
                          } else if (userDoc.data()!['type'] == 'Landlord') {
                            //push to landlord dashboard
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LandlordDashboardPage(
                                      uid: _auth.currentUser!.uid)),
                            );
                          } else if (userDoc.data()!['type'] == 'Dealer') {
                            //push to dealer dashboard
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DealerDashboardPage(
                                      uid: _auth.currentUser!.uid)),
                            );
                          }

                          isSignInCompleted = true; // Mark sign-in as completed
                        } catch (e) {
                          showToast('Invalid SMS code. Please try again.',
                              Colors.red);

                          print('error is $e');

                          // Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (!isSignInCompleted) {
              // Check if sign-in is not completed
              showToast(
                  'Phone number verification timed out. Please try again.',
                  Colors.red);
              Navigator.of(context).pop();
            }
          },
        );
      } else {
        // toast
        showToast('Incorrect password. Please try again.', Colors.red);
      }
    }
  }

  Future<void> signInForgetWithPhoneNumber(
    String phoneNumber,
    BuildContext context,
  ) async {
    bool isSignInCompleted = false; // Flag to track sign-in completion

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        if (kDebugMode) {
          print(
              "Phone number automatically verified and user signed in: ${_auth.currentUser?.uid}");
        }
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (userDoc.data()!['type'] == 'Tenant') {
          //push to tenant dashboard
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TenantDashboardPage(uid: _auth.currentUser!.uid)),
          );
        } else if (userDoc.data()!['type'] == 'Landlord') {
          //push to landlord dashboard
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LandlordDashboardPage(uid: _auth.currentUser!.uid)),
          );
        } else if (userDoc.data()!['type'] == 'Dealer') {
          //push to dealer dashboard
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DealerDashboardPage(uid: _auth.currentUser!.uid)),
          );
        }
        isSignInCompleted = true; // Mark sign-in as completed
      },
      verificationFailed: (FirebaseAuthException e) {
        if (kDebugMode) {
          print(
              "Phone number verification failed. Code: ${e.code}. Message: ${e.message}");
        }
        showToast(
            'Phone number verification failed. Please try again.', Colors.red);
        Navigator.of(context).pop();
      },
      codeSent: (String verificationId, int? resendToken) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            TextEditingController smsController = TextEditingController();
            return AlertDialog(
              title: const Text('Enter SMS Code'),
              content: TextField(
                controller: smsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'SMS Code',
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Verify'),
                  onPressed: () async {
                    String smsCode = smsController.text.trim();
                    try {
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                              verificationId: verificationId, smsCode: smsCode);
                      await _auth.signInWithCredential(credential);
                      if (kDebugMode) {
                        print(
                            "Phone number verified and user signed in: ${_auth.currentUser?.uid}");
                      }
                      // Navigator.of(context).pop();
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.uid)
                          .get();

                      if (userDoc.data()!['type'] == 'Tenant') {
                        //push to tenant dashboard
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TenantDashboardPage(
                                  uid: _auth.currentUser!.uid)),
                        );
                      } else if (userDoc.data()!['type'] == 'Landlord') {
                        //push to landlord dashboard
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LandlordDashboardPage(
                                  uid: _auth.currentUser!.uid)),
                        );
                      } else if (userDoc.data()!['type'] == 'Dealer') {
                        //push to dealer dashboard
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DealerDashboardPage(
                                  uid: _auth.currentUser!.uid)),
                        );
                      }
                      isSignInCompleted = true; // Mark sign-in as completed
                    } catch (e) {
                      showToast(
                          'Invalid SMS code. Please try again.', Colors.red);
                      // Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // if (!isSignInCompleted) {
        //   // Check if sign-in is not completed
        // showToast('Phone number verification timed out. Please try again.',
        //     Colors.red);
        // Navigator.of(context).pop();
      },
    );
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      if (kDebugMode) {
        print('Signing in with Email and Password...');
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print('Signed in with Email and Password.');
      }
      // Notify listeners to update
      notifyListeners();
      // ignore: use_build_context_synchronously
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      // check in users if account is disabled
      if (userDoc.exists) {
        final user = userDoc;
        if (user.data()?['isDisabled'] == true) {
          showToast('Your account is disabled. Please contact admin.',
              Colors.redAccent);
          return;
        }
      }

      if (userDoc.data()!['type'] == 'Tenant') {
        showToast('Signed in with Email and Password.', Colors.green);
        //push to tenant dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TenantDashboardPage(uid: _auth.currentUser!.uid)),
        );
      } else if (userDoc.data()!['type'] == 'Landlord') {
        showToast('Signed in with Email and Password.', Colors.green);

        //push to landlord dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LandlordDashboardPage(uid: _auth.currentUser!.uid)),
        );
      } else if (userDoc.data()!['type'] == 'Dealer') {
        //push to dealer dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DealerDashboardPage(uid: _auth.currentUser!.uid)),
        );
      }
    } catch (e) {
      print('Error signing in with Email and Password: $e');
      showToast('Failed to sign in with email and password.', Colors.red);
      Navigator.pop(context);
    }
  }
}
