import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/signup_page.dart';
import 'package:rehnaa/frontend/Screens/forget_password.dart';
import 'package:provider/provider.dart';
import 'package:rehnaa/backend/services/authentication_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<AuthenticationService>(
      builder: (context, authService, _) {
        return WillPopScope(
            onWillPop: () async => false,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(body: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: constraints.maxHeight * 0.1,
                          ),
                          Image.asset(
                            'assets/mainlogo.png',
                            height: constraints.maxWidth * 0.4,
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
                          ),
                          Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: const Color(0xff33907c),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
                          ),
                          TextField(
                            cursorColor: Colors.green,
                            controller: _emailOrPhoneController,
                            style: const TextStyle(
                              color: Color(0xff33907c),
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
                                  color: Color(0xff33907c),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xff33907c),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xff33907c),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.02,
                          ),
                          TextField(
                            cursorColor: Colors.green,
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(
                              color: Color(0xff33907c),
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
                                  color: Color(0xff33907c),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xff33907c),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xff33907c),
                                  width: 1,
                                ),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                child: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
                          ),
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
                                  showDialog(
                                    context: context,
                                    barrierDismissible:
                                        true, // Prevents dismissing the dialog by tapping outside
                                    builder: (context) =>
                                        //   WillPopScope(
                                        // onWillPop: () async =>
                                        //     false, // Prevents dismissing the dialog with the back button

                                        // title: Text('Processing',
                                        // style: TextStyle(
                                        //     color: Colors.green,
                                        //     fontFamily: GoogleFonts.montserrat()
                                        //         .fontFamily),
                                        // textAlign: TextAlign.center),
                                        const SpinKitFadingCube(
                                      color: Color.fromARGB(255, 30, 197, 83),
                                    ),

                                    // ),
                                  );
                                  String emailOrPhone =
                                      _emailOrPhoneController.text.trim();

                                  if (authService.isPhoneNumber(emailOrPhone)) {
                                    // Modify the phone number format
                                    String password =
                                        _passwordController.text.trim();

                                    if (kDebugMode) {
                                      print('email or phone is:');
                                      print(emailOrPhone);
                                    }

                                    authService.signInWithPhoneNumber(
                                      emailOrPhone,
                                      password,
                                      context,
                                    );
                                  } else if (authService
                                      .isEmail(emailOrPhone)) {
                                    // Call the sign-in function using the email and password
                                    String password =
                                        _passwordController.text.trim();
                                    authService.signInWithEmailAndPassword(
                                      emailOrPhone,
                                      password,
                                      context,
                                    );
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
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
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
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgetPasswordPage(),
                                ),
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
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
                          ),
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
                                          builder: (context) =>
                                              const SignUpPage(),
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
                  );
                },
              )),
            ));
      },
    );
  }
}
