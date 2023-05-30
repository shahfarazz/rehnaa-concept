import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dashboard.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String firstName = '';
  String lastName = '';
  String emailOrPhone = '';
  String password = '';
  String confirmPassword = '';
  String selectedOption = '';
  // String smsCode = '';
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false; // New state variable
  String? firstNameError;
  String? lastNameError;
  String? emailOrPhoneError;
  String? passwordError;
  String? confirmPasswordError;
  String? verificationId; // Define a state to hold the verificationId

  bool isEmail(String input) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(input);
  }

  Future<void> signUpWithEmailAndPassword() async {
    String? formError = _validateForm();
    if (formError != null) {
      Fluttertoast.showToast(
        msg: formError,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    try {
      setState(() {
        isLoading = true; // Set isLoading to false after email is verified
      }); // Set isLoading to true before starting the sign-up process
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailOrPhone,
        password: password,
      );
      // Send verification email
      await userCredential.user!.sendEmailVerification();
      print(
          'User registered. Verification email sent: ${userCredential.user?.uid}');
      Fluttertoast.showToast(
        msg: 'Verification email has been sent. Please check your inbox.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Poll Firebase every 2 seconds to check if the email has been verified.
      Timer.periodic(Duration(seconds: 2), (timer) async {
        await FirebaseAuth.instance.currentUser!.reload();
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          timer.cancel();
          setState(() {
            isLoading = false; // Set isLoading to false after email is verified
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
        }
      });
    } catch (e) {
      // Error
      setState(() {
        isLoading = false; // Set isLoading to false if sign-up fails
      });
      print('Sign up failed: $e');
      Fluttertoast.showToast(
        msg: 'Sign up failed: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> signUpWithPhoneNumber() async {
    String? formError = _validateForm();
    if (formError != null) {
      Fluttertoast.showToast(
        msg: formError,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    String phoneNumber = emailOrPhone.replaceFirst(RegExp('^0'), '+92');

    // Start the sign-in process
    codeSent(String verificationId, int? forceResendingToken) async {
      this.verificationId = verificationId;
      // Show a dialog to enter the SMS code
      String smsCode = '';
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter SMS Code'),
            content: TextField(
              onChanged: (value) {
                // Update value of SMS code
                smsCode = value;
              },
            ),
            actions: [
              TextButton(
                child: Text('Verify'),
                onPressed: () {
                  Navigator.of(context).pop();
                  verifyPhoneNumberWithSms(smsCode);
                },
              ),
            ],
          );
        },
      );
    }

    codeAutoRetrievalTimeout(String verificationId) {
      this.verificationId = verificationId;
    }

    verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      print(
          'Phone number automatically verified and user signed in: ${FirebaseAuth.instance.currentUser!.uid}');
      Fluttertoast.showToast(
        msg: 'Phone number automatically verified and user signed in.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }

    verificationFailed(FirebaseAuthException authException) {
      print(
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      Fluttertoast.showToast(
        msg: 'Phone number verification failed.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber, // phone number to verify
        timeout: const Duration(seconds: 60), // timeout duration
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      print('Failed to Verify Phone Number: $e');
      Fluttertoast.showToast(
        msg: 'Failed to Verify Phone Number.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

// This function would be called when the user submits the SMS code
  Future<void> verifyPhoneNumberWithSms(String smsCode) async {
    // Create a PhoneCredential with the code
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: smsCode,
    );

    // Sign in the user with the credential
    try {
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      print(
          'Phone number successfully verified and user signed in: ${FirebaseAuth.instance.currentUser!.uid}');
      Fluttertoast.showToast(
        msg: 'Phone number successfully verified and user signed in.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Continue with the rest of your logic
      // Navigate to the DashboardPage, for example
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } catch (e) {
      print('Failed to verify SMS code: $e');
      Fluttertoast.showToast(
        msg: 'Failed to verify SMS code.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(
              16.0, 40.0, 16.0, 40.0), // Adjusted padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTitle("Welcome to Rehnaa"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              buildSubtitle("Sign Up"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              buildInputField("First Name", onChanged: (value) {
                setState(() {
                  firstName = value;
                });
              }, context: context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildInputField("Last Name", onChanged: (value) {
                setState(() {
                  lastName = value;
                });
              }, errorText: firstNameError, context: context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildInputField("Email ID/Phone Number", onChanged: (value) {
                setState(() {
                  emailOrPhone = value;
                });
              }, context: context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildPasswordInputField(
                "Password",
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                context: context,
                showPassword: showPassword,
                onToggle: () {
                  setState(() {
                    showPassword = !showPassword; // Toggle showPassword state
                  });
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildPasswordInputField(
                "Re-enter Password",
                onChanged: (value) {
                  setState(() {
                    confirmPassword = value;
                  });
                },
                context: context,
                showPassword: showConfirmPassword,
                onToggle: () {
                  setState(() {
                    showConfirmPassword =
                        !showConfirmPassword; // Toggle showConfirmPassword state
                  });
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildOptionSelector(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildCreateButton(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildSignInText(),
              if (isLoading) // Show loading icon if isLoading is true
                CircularProgressIndicator(), // Replace with your preferred loading widget
              SizedBox(height: 50.0), // Adjusted to avoid bottom overflow
            ],
          ),
        ),
      ),
    );
  }

  String? _validateForm() {
    // Regex to check for whitespace
    final noSpaces = RegExp(r'^\S*$');

    // First name validation
    if (firstName.isEmpty) {
      return 'First name cannot be empty';
    } else if (!noSpaces.hasMatch(firstName)) {
      return 'First name cannot contain spaces';
    }

    // Last name validation
    if (lastName.isEmpty) {
      return 'Last name cannot be empty';
    } else if (!noSpaces.hasMatch(lastName)) {
      return 'Last name cannot contain spaces';
    }

    // Email/Phone validation
    if (emailOrPhone.isEmpty) {
      return 'Email/Phone cannot be empty';
    }

    // Check if it's a phone number
    if (!isEmail(emailOrPhone)) {
      // Pakistani phone number validation
      final regex =
          RegExp(r'^03\d{9}$'); // Starts with '03' and is 11 digits long
      if (!regex.hasMatch(emailOrPhone)) {
        return 'Enter a valid Pakistani phone number';
      }
    }

    // Password validation
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Password complexity checks
    bool passwordHasUpper = password.contains(RegExp(r'[A-Z]'));
    bool passwordHasLower = password.contains(RegExp(r'[a-z]'));
    bool passwordHasDigit = password.contains(RegExp(r'[0-9]'));
    bool passwordHasSpecialCharacter =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!(passwordHasUpper &&
        passwordHasLower &&
        passwordHasDigit &&
        passwordHasSpecialCharacter)) {
      return 'Password must contain at least 1 uppercase, 1 lowercase, 1 digit, and 1 special character';
    }

    // Confirm password validation
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null; // If all validations pass, return null
  }

  Widget buildTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        color: Color(0xff33907c),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildSubtitle(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        color: Color(0xff33907c),
        fontSize: 18,
      ),
    );
  }

  Widget buildInputField(String label,
      {required Function(String) onChanged,
      String? errorText,
      required BuildContext context}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return TextField(
      onChanged: onChanged,
      style: GoogleFonts.montserrat(
        color: Color(0xff33907c),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        errorText: errorText, // Added this line
        contentPadding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01,
            horizontal:
                screenWidth * 0.02), // Adjust these values to fit your needs
        labelText: label,
        labelStyle: GoogleFonts.montserrat(
          color: Color(0xff33907c),
          fontSize: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Color(0xff33907c), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Color(0xff33907c), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Color(0xff33907c), width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget buildPasswordInputField(
    String label, {
    required Function(String) onChanged,
    String? errorText, // Added this line
    required BuildContext context,
    required bool showPassword,
    required Function() onToggle,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return TextField(
      onChanged: onChanged,
      obscureText: !showPassword, // Toggle obscureText based on showPassword
      style: GoogleFonts.montserrat(
        color: Color(0xff33907c),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01,
          horizontal: screenWidth * 0.02,
        ),
        labelText: label,
        labelStyle: GoogleFonts.montserrat(
          color: Color(0xff33907c),
          fontSize: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Color(0xff33907c), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Color(0xff33907c), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Color(0xff33907c), width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: Color(0xff33907c),
          ),
        ),
      ),
    );
  }

  Widget buildOptionSelector() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center-align the row
            children: [
              buildOptionButton("Landlord"),
              SizedBox(width: 16.0),
              buildOptionButton("Tenant"),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOptionButton(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedOption = text;
        });
      },
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selectedOption == text
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff0FA697),
                    Color(0xff45BF7A),
                    Color(0xff0DF205),
                  ],
                )
              : null,
          color: selectedOption == text ? null : Colors.white,
          border: Border.all(color: Color(0xff33907c), width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              color: selectedOption == text ? Colors.white : Color(0xff33907c),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCreateButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
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
            // Check if an option has been selected
            if (selectedOption == '') {
              // No option selected. Show a toast message.
              Fluttertoast.showToast(
                  msg: "Please select Landlord or Tenant",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              if (isEmail(emailOrPhone)) {
                // Sign up with email and password
                signUpWithEmailAndPassword();
              } else {
                // Sign up with phone number
                signUpWithPhoneNumber();
              }
            }
          },
          child: Center(
            child: Text(
              "Create",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignInText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "Already have an account? ",
        style: GoogleFonts.montserrat(
          color: Color(0xff33907c),
          fontSize: 18,
        ),
        children: <TextSpan>[
          TextSpan(
            text: 'Sign in',
            style: GoogleFonts.montserrat(
              color: Color(0xff33907c),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
                // Navigate to LoginPage
              },
          ),
        ],
      ),
    );
  }
}
