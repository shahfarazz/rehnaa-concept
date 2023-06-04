import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rehnaa/frontend/Screens/Landlord/landlord_dashboard.dart';
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

  Future<void> signInWithPhoneNumber(
      String phoneNumber, BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        if (kDebugMode) {
          print(
              "Phone number automatically verified and user signed in: ${_auth.currentUser?.uid}");
        }
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DashboardPage(uid: _auth.currentUser!.uid)),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        if (kDebugMode) {
          print(
              "Phone number verification failed. Code: ${e.code}. Message: ${e.message}");
        }
        showToast(
          'Phone number verification failed. Please try again.',
          Colors.red,
        );
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
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DashboardPage(uid: _auth.currentUser!.uid)),
                      );
                    } catch (e) {
                      showToast(
                        'Invalid SMS code. Please try again.',
                        Colors.red,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        showToast(
          'Phone number verification timed out. Please try again.',
          Colors.red,
        );
        Navigator.of(context).pop();
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
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardPage(
                  uid: _auth.currentUser!.uid,
                )),
      );
    } catch (e) {
      showToast('Failed to sign in with email and password.', Colors.red);
    }
  }
}
