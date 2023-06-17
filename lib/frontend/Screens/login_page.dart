import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/signup_page.dart';
import 'package:rehnaa/frontend/Screens/forget_password.dart';
import 'package:provider/provider.dart';
import 'package:rehnaa/backend/services/authentication_service.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationService>(
      builder: (context, authService, _) {
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
                        borderSide: const BorderSide(
                            color: Color(0xff33907c), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: Color(0xff33907c), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: Color(0xff33907c), width: 1),
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
                        borderSide: const BorderSide(
                            color: Color(0xff33907c), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: Color(0xff33907c), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: Color(0xff33907c), width: 1),
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
                          String emailOrPhone =
                              _emailOrPhoneController.text.trim();

                          if (authService.isPhoneNumber(emailOrPhone)) {
                            // Modify the phone number format
                            String password = _passwordController.text.trim();

                            if (kDebugMode) {
                              print('email or phone is:');
                            }
                            if (kDebugMode) {
                              print(emailOrPhone);
                            }

                            authService.signInWithPhoneNumber(
                                emailOrPhone, password, context);
                          } else if (authService.isEmail(emailOrPhone)) {
                            // Call the sign-in function using the email and password
                            String password = _passwordController.text.trim();
                            authService.signInWithEmailAndPassword(
                                emailOrPhone, password, context);
                          } else {
                            // Invalid input, show error message to the user
                            authService.showToast(
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
      },
    );
  }
}
