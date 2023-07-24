import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:rehnaa/backend/services/authentication_service.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthenticationService authService =
      AuthenticationService(); // <--- Here

  // Future<void> recoverAccountWithPhoneNumber(
  //     String phoneNumber, BuildContext context) async {
  //   // Strip the initial "0" if present and prepend "+92" to the start of the phoneNumber.
  //   if (phoneNumber.startsWith("0")) {
  //     phoneNumber = "+92${phoneNumber.substring(1)}";
  //   }

  //   // Call your existing signInWithPhoneNumber function with the adjusted phone number.
  //   authService.signInForgetWithPhoneNumber(phoneNumber, context);
  // }

  // Handle password reset
  Future<void> handleForgetPassword(String emailOrPhone) async {
    // print('reached here' + emailOrPhone);
    if (authService.isEmail(emailOrPhone)) {
      await _auth.sendPasswordResetEmail(email: emailOrPhone);
      authService.showToast(
        'Email successfully sent to $emailOrPhone',
        Colors.green,
      );
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
    // else if (authService.isPhoneNumber(emailOrPhone)) {
    //   recoverAccountWithPhoneNumber(emailOrPhone, context);
    // }
    else {
      authService.showToast(
        'Invalid email. Please try again.',
        Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenHeight * 0.1),
                Image.asset(
                  'assets/mainlogo.png',
                  height: screenWidth * 0.4,
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  "Reset Password",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: screenWidth * 0.06,
                    color: const Color(0xFF33907C),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.05),
                _buildForgetPasswordDescription(),
                SizedBox(height: screenHeight * 0.02),
                _buildForgetPasswordTextField(),
                SizedBox(height: screenHeight * 0.05),
                _buildNextButton(),
                SizedBox(height: screenHeight * 0.05),
                Center(
                    child: _buildLoginLink(
                        context)), // Wrap _buildLoginLink with Center widget
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgetPasswordDescription() {
    return const Column(
      children: [
        Text(
          "Enter your email or phone number",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: Color(0xFF33907C),
          ),
        ),
      ],
    );
  }

  Widget _buildForgetPasswordTextField() {
    return Container(
      width: 311,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: const Color(0xFF33907C),
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _emailOrPhoneController,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Email/Phone Number',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Already know credentials?  ',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                color: Color(0xFF33907C),
              ),
            ),
            TextSpan(
              text: 'Login',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                color: Color(0xFF33907C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: 311,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          if (kDebugMode) {
            print('Next button pressed');
          }
          handleForgetPassword(_emailOrPhoneController.text);
        },
        child: const Center(
          child: Text(
            "Next",
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
