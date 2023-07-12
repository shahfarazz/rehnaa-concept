import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypto/crypto.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:rehnaa/frontend/helper/Admindashboard_pages/admin_landlordinputhelper.dart';

import 'Landlord/landlord_dashboard.dart';
import 'Tenant/tenant_dashboard.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

String hashString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class _SignUpPageState extends State<SignUpPage> {
  String firstName = '';
  String lastName = '';
  String emailOrPhone = '';
  String password = '';
  String confirmPassword = '';
  String selectedOption = '';
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  String? firstNameError;
  String? lastNameError;
  String? emailOrPhoneError;
  String? passwordError;
  String? confirmPasswordError;
  String? verificationId;
  Timer? verificationTimer;
  Timer? letVerifyTimer;

  dispose() {
    verificationTimer?.cancel();
    letVerifyTimer?.cancel();
    super.dispose();
  }

  bool isEmail(String input) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(input);
  }

  Future<void> signUpWithEmailAndPassword() async {
    String? formError = _validateForm();
    if (formError != null) {
      _showToast(formError, Colors.red);
      return;
    }
    try {
      setState(() => isLoading = true);
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailOrPhone,
        password: password,
      );
      await userCredential.user!.sendEmailVerification();
      _showToast(
        'Verification email has been sent. Please check your inbox.',
        Colors.green,
      );
      verificationTimer?.cancel(); // Cancel any existing timer
      letVerifyTimer?.cancel(); // Cancel any existing timer
      letVerifyTimer = Timer.periodic(const Duration(seconds: 30), (timer) {});
      verificationTimer =
          Timer.periodic(const Duration(seconds: 5), (timer) async {
        await FirebaseAuth.instance.currentUser!.reload();
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          timer.cancel();
          setState(() => isLoading = false);
          // ignore: use_build_context_synchronously
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            'firstName': firstName,
            'lastName': lastName,
            'emailOrPhone': emailOrPhone,
            'type': selectedOption,
          });

          if (selectedOption == 'Landlord') {
            await FirebaseFirestore.instance
                .collection('Landlords')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set({
              'firstName': firstName,
              'lastName': lastName,
              'emailOrPhone': emailOrPhone,
              'type': selectedOption,
              'balance': 0,
              'pathToImage': 'assets/defaulticon.png',
              'dateJoined': Timestamp.now(),
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LandlordDashboardPage(
                      uid: FirebaseAuth.instance.currentUser!.uid)),
            );
          } else if (selectedOption == 'Tenant') {
            await FirebaseFirestore.instance
                .collection('Tenants')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set({
              'firstName': firstName,
              'lastName': lastName,
              'emailOrPhone': emailOrPhone,
              'type': selectedOption,
              'balance': 0,
              'pathToImage': 'assets/defaulticon.png',
              'dateJoined': Timestamp.now(),
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TenantDashboardPage(
                      uid: FirebaseAuth.instance.currentUser!.uid)),
            );
          }

          _showToast('Sign up successful.', Colors.green);
        }
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showToast('Sign up failed, please try again', Colors.red);
      return;
    }
  }

  Future<void> signUpWithPhoneNumber() async {
    String? formError = _validateForm();
    if (formError != null) {
      _showToast(formError, Colors.red);
      return;
    }
    String phoneNumber;

    if (emailOrPhone.startsWith('0')) {
      phoneNumber = emailOrPhone.replaceFirst(RegExp('^0'), '+92');
    } else if (emailOrPhone.startsWith('+92')) {
      phoneNumber = emailOrPhone;
    } else {
      // Handle invalid cases or default behavior
      phoneNumber = '';
    }

    // check if phoneNumber is already registered in users collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('emailOrPhone', isEqualTo: emailOrPhone)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      _showToast('Phone number already registered.', Colors.red);
      return;
    }

    codeSent(String verificationId, int? forceResendingToken) async {
      this.verificationId = verificationId;
      String smsCode = '';
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Enter SMS Code'),
          content: TextField(
            onChanged: (value) => smsCode = value,
          ),
          actions: [
            TextButton(
              child: const Text('Verify'),
              onPressed: () {
                Navigator.of(context).pop();
                verifyPhoneNumberWithSms(smsCode);
              },
            ),
          ],
        ),
      );
    }

    codeAutoRetrievalTimeout(String verificationId) {
      this.verificationId = verificationId;
    }

    verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      _showToast('Phone number automatically verified and user signed in.',
          Colors.green);
    }

    verificationFailed(FirebaseAuthException authException) {
      _showToast('Phone number verification failed.', Colors.red);
      print('exception occured: ${authException.message}');
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      _showToast('Failed to Verify Phone Number.', Colors.red);
      print('error that occured: $e');
      return;
    }
  }

  Future<void> verifyPhoneNumberWithSms(String smsCode) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: smsCode,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      _showToast('Phone number successfully verified and user signed in.',
          Colors.green);
      // ignore: use_build_context_synchronously

      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'emailOrPhone': emailOrPhone,
        'type': selectedOption,
        'password': hashString(password),
        'dateJoined': Timestamp.now(),
      });

      if (selectedOption == 'Landlord') {
        await FirebaseFirestore.instance
            .collection('Landlords')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'firstName': firstName,
          'lastName': lastName,
          'emailOrPhone': emailOrPhone,
          'type': selectedOption,
          'balance': 0,
          'pathToImage': 'assets/defaulticon.png',
          'dateJoined': Timestamp.now(),
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LandlordDashboardPage(
                  uid: FirebaseAuth.instance.currentUser!.uid)),
        );
      } else if (selectedOption == 'Tenant') {
        await FirebaseFirestore.instance
            .collection('Tenants')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'firstName': firstName,
          'lastName': lastName,
          'emailOrPhone': emailOrPhone,
          'type': selectedOption,
          'balance': 0,
          'pathToImage': 'assets/defaulticon.png',
          'dateJoined': Timestamp.now(),
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TenantDashboardPage(
                  uid: FirebaseAuth.instance.currentUser!.uid)),
        );
      }
    } catch (e) {
      _showToast('Failed to verify SMS code.', Colors.red);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTitle("Welcome to Rehnaa"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              buildSubtitle("Sign Up"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              buildInputField("First Name",
                  onChanged: (value) => firstName = value),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildInputField("Last Name",
                  onChanged: (value) => lastName = value,
                  errorText: firstNameError),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildInputField("Email ID/Phone Number",
                  onChanged: (value) => emailOrPhone = value),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildPasswordInputField(
                "Password",
                onChanged: (value) => password = value,
                showPassword: showPassword,
                onToggle: () => setState(() => showPassword = !showPassword),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildPasswordInputField(
                "Re-enter Password",
                onChanged: (value) => confirmPassword = value,
                showPassword: showConfirmPassword,
                onToggle: () =>
                    setState(() => showConfirmPassword = !showConfirmPassword),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildOptionSelector(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildCreateButton(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildSignInText(),
              if (isLoading)
                const SpinKitFadingCube(
                  color: Color.fromARGB(255, 30, 197, 83),
                ),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateForm() {
    final noSpaces = RegExp(r'^\S*$');

    if (firstName.isEmpty) return 'First name cannot be empty';
    // if (!noSpaces.hasMatch(firstName)) {
    //   return 'First name cannot contain spaces';
    // }

    if (lastName.isEmpty) return 'Last name cannot be empty';
    if (!noSpaces.hasMatch(lastName)) return 'Last name cannot contain spaces';

    if (emailOrPhone.isEmpty) return 'Email/Phone cannot be empty';
    if (!isEmail(emailOrPhone)) {
      final regex = RegExp(r'^(03\d{9}|\+92\d{10})$');
      if (!regex.hasMatch(emailOrPhone)) {
        return 'Enter a valid Pakistani phone number or email id';
      }
    }

    if (password.isEmpty) return 'Password cannot be empty';
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
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

    if (password != confirmPassword) return 'Passwords do not match';

    return null;
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Widget buildTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xff33907c),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
    );
  }

  Widget buildSubtitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xff33907c),
        fontSize: 18,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
    );
  }

  Widget buildInputField(String label,
      {required Function(String) onChanged, String? errorText}) {
    return TextField(
      onChanged: onChanged,
      style: TextStyle(
        color: Color(0xff33907c),
        fontSize: 18,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      decoration: InputDecoration(
        errorText: errorText,
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xff33907c),
          fontSize: 18,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xff33907c), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xff33907c), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xff33907c), width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget buildPasswordInputField(
    String label, {
    required Function(String) onChanged,
    required bool showPassword,
    required Function() onToggle,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: !showPassword,
      style: TextStyle(
        color: Color(0xff33907c),
        fontSize: 18,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xff33907c),
          fontSize: 18,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xff33907c), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xff33907c), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xff33907c), width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xff33907c),
          ),
        ),
      ),
    );
  }

  Widget buildOptionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildOptionButton("Landlord"),
            const SizedBox(width: 16.0),
            buildOptionButton("Tenant"),
          ],
        ),
      ],
    );
  }

  Widget buildOptionButton(String text) {
    return InkWell(
      onTap: () => setState(() => selectedOption = text),
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selectedOption == text
              ? const LinearGradient(
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
          border: Border.all(color: const Color(0xff33907c), width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selectedOption == text
                  ? Colors.white
                  : const Color(0xff33907c),
              fontSize: 16,
              fontFamily: GoogleFonts.montserrat().fontFamily,
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
            if (selectedOption == '') {
              _showToast("Please select Landlord or Tenant", Colors.red);
            } else {
              if (isEmail(emailOrPhone)) {
                signUpWithEmailAndPassword();
              } else {
                signUpWithPhoneNumber();
              }
            }
          },
          child: Center(
            child: Text(
              "Create",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: GoogleFonts.montserrat().fontFamily,
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
        style: TextStyle(
          color: Color(0xff33907c),
          fontSize: 18,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
        children: <TextSpan>[
          TextSpan(
            text: 'Sign in',
            style: TextStyle(
              color: Color(0xff33907c),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Navigate to the login page and dispose of the sign-up page

                //check if verification timer is running and if so dont let user go back to login page
                if (letVerifyTimer != null && letVerifyTimer!.isActive) {
                  _showToast("Please complete verification", Colors.red);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
              },
          ),
        ],
      ),
    );
  }
}
