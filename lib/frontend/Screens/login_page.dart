import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/signup_page.dart';

class LoginPage extends StatelessWidget {
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
                  height: MediaQuery.of(context).size.width * 0.3),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Text(
                'Login to your account',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: Color(0xff33907c),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              TextField(
                style: TextStyle(
                  color: Color(0xff33907c), // Sets the color of the text
                ),
                decoration: InputDecoration(
                  labelText: 'Email/Mobile Number',
                  labelStyle: TextStyle(
                    color: Color(0xff33907c), // Sets the color of the label
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
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              TextField(
                obscureText: true,
                style: TextStyle(
                  color: Color(0xff33907c), // Sets the color of the text
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Color(0xff33907c), // Sets the color of the label
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
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ElevatedButton(
                onPressed: () {
                  // handle user login
                },
                child: Text(
                  'Login',
                  style: GoogleFonts.montserrat(),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Color(0xff13b58c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot your password?',
                  style: GoogleFonts.montserrat(
                    color: Color(0xff33907c),
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
                    color: Color(0xff33907c),
                    fontSize: 18,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Sign Up',
                      style: const TextStyle(
                          // decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w900),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
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
