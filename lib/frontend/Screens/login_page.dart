import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart';
import 'forget_password.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  void _showToast(String message, Color color) {
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

  bool _isPhoneNumber(String input) {
    // Remove any non-digit characters from the input
    String digitsOnly = input.replaceAll(RegExp(r'\D'), '');

    // Check if the input is a valid phone number using your regex pattern
    final regex = RegExp(r'^03\d{9}$');
    return regex.hasMatch(digitsOnly);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithPhoneNumber(
      String phoneNumber, BuildContext context) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print(
            "Phone number automatically verified and user signed in: ${_auth.currentUser?.uid}");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        print(
            "Phone number verification failed. Code: ${e.code}. Message: ${e.message}");
        _showToast(
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
                      print(
                          "Phone number verified and user signed in: ${_auth.currentUser?.uid}");
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardPage()),
                      );
                    } catch (e) {
                      _showToast(
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
        _showToast(
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Sign-in successful, navigate to the dashboard or desired page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } catch (e) {
      // Handle sign-in error
      _showToast('Failed to sign in with email and password.', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Image.asset('assets/mainlogo.png',
                  height: MediaQuery.of(context).size.width * 0.4),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Text(
                'Login',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: const Color(0xff33907c),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              TextField(
                controller: _emailOrPhoneController,
                style: const TextStyle(
                  color: Color(0xff33907c), // Sets the color of the text
                ),
                decoration: InputDecoration(
                  labelText: 'Email/Mobile Number',
                  labelStyle: GoogleFonts.montserrat(
                    color: const Color(0xff33907c),
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: Color(0xff33907c), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: Color(0xff33907c), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: Color(0xff33907c), width: 1),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(
                  color: Color(0xff33907c), // Sets the color of the text
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: GoogleFonts.montserrat(
                    color: const Color(0xff33907c),
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: Color(0xff33907c), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: Color(0xff33907c), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: Color(0xff33907c), width: 1),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff0FA697),
                      Color(0xff45BF7A),
                      Color(0xff0DF205),
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      String emailOrPhone = _emailOrPhoneController.text.trim();

                      if (_isPhoneNumber(emailOrPhone)) {
                        // Modify the phone number format
                        emailOrPhone = '+92${emailOrPhone.substring(1)}';
                        print('email or phone is:');
                        print(emailOrPhone);

                        // Call the sign-in function using the modified phone number
                        signInWithPhoneNumber(emailOrPhone, context);
                      } else if (isEmail(emailOrPhone)) {
                        // Call the sign-in function using the email and password
                        String password = _passwordController.text.trim();
                        signInWithEmailAndPassword(
                            emailOrPhone, password, context);
                      } else {
                        // Invalid input, show error message to the user
                        _showToast(
                          'Invalid email or phone number. Please try again.',
                          Colors.red,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgetPasswordPage()),
                  );
                },
                child: Text(
                  'Forgot your password?',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xff33907c),
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: GoogleFonts.montserrat(
                    color: const Color(0xff33907c),
                    fontSize: 18,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Sign Up',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xff33907c),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
