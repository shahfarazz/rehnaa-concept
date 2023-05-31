import 'package:flutter/material.dart';
import 'login_page.dart'; // Import your login page


class ForgetPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Color(0xFF33907C),
      body: SafeArea(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(
                "Forget Password",
                style: TextStyle(
                  fontFamily: 'Montserrat', 
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 58),
              Column(
                children: [
                  Text(
                    "We will send you a Code/Link to the",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "entered number/email",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
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
                padding: EdgeInsets.symmetric(horizontal: 16), // Add horizontal padding
                child: TextField(
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
            ),


              SizedBox(height: 80),
              GestureDetector(
              onTap: () {
                // Handle Login text click here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Replace LoginPage with your actual login page widget
                );
              },
              child: RichText(
                text: TextSpan(
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
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 311,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextButton(
                onPressed: () {
                  // Handle Next button click here
                  print('Next button clicked');
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
            ),

            ],
          ),
        ),
      ),
    );
  }
}
