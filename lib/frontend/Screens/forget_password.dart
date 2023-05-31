import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:rehnaa/backend/services/authentication_service.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key});

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthenticationService authService =
      AuthenticationService(); // <--- Here

  Future<void> recoverAccountWithPhoneNumber(
      String phoneNumber, BuildContext context) async {
    // Strip the initial "0" if present and prepend "+92" to the start of the phoneNumber.
    if (phoneNumber.startsWith("0")) {
      phoneNumber = "+92" + phoneNumber.substring(1);
    }

    // Call your existing signInWithPhoneNumber function with the adjusted phone number.
    authService.signInWithPhoneNumber(phoneNumber, context);
  }

  // Handle password reset
  Future<void> handleForgetPassword(String emailOrPhone) async {
    // print('reached here' + emailOrPhone);
    if (authService.isEmail(emailOrPhone)) {
      await _auth.sendPasswordResetEmail(email: emailOrPhone);
      authService.showToast(
        'Email successfully sent to $emailOrPhone',
        Colors.green,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else if (authService.isPhoneNumber(emailOrPhone)) {
      recoverAccountWithPhoneNumber(emailOrPhone, context);
    } else {
      authService.showToast(
        'Invalid email or phone number. Please try again.',
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
      backgroundColor: Color(0xFF33907C),
      body: SafeArea(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/mainlogo.png',
                height: screenWidth * 0.4,
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                "Forget Password",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: screenWidth * 0.06,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.15),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildForgetPasswordDescription(),
                      SizedBox(height: screenHeight * 0.02),
                      _buildForgetPasswordTextField(),
                      SizedBox(height: screenHeight * 0.03),
                      _buildLoginLink(context),
                      SizedBox(height: screenHeight * 0.02),
                      _buildNextButton(),
                    ],
                  ),
                ),
              ),
            ],
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
            color: Colors.white,
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
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _emailOrPhoneController,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Email/Password',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
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
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: 'Login',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextButton(
        onPressed: () {
          print('Next button pressed');
          handleForgetPassword(_emailOrPhoneController.text);
        },
        child: Text(
          "Next",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: Color(0xFF33907C),
          ),
        ),
      ),
    );
  }
}
