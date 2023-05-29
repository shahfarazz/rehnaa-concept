import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/login_page.dart';

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
  bool showPassword = false; // Added showPassword state

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
              }, context: context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildInputField("Email ID/Phone Number", onChanged: (value) {
                setState(() {
                  emailOrPhone = value;
                });
              }, context: context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildPasswordInputField("Password", onChanged: (value) {
                setState(() {
                  password = value;
                });
              }, context: context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildPasswordInputField("Re-enter Password", onChanged: (value) {
                setState(() {
                  confirmPassword = value;
                });
              }, context: context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildOptionSelector(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildCreateButton(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildSignInText(),
              SizedBox(height: 50.0), // Adjusted to avoid bottom overflow
            ],
          ),
        ),
      ),
    );
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
      {required Function(String) onChanged, required BuildContext context}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return TextField(
      onChanged: onChanged,
      style: GoogleFonts.montserrat(
        color: Color(0xff33907c),
        fontSize: 18,
      ),
      decoration: InputDecoration(
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
    required BuildContext context,
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
          onPressed: () {
            setState(() {
              showPassword = !showPassword; // Toggle showPassword state
            });
          },
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
            // Call your Firebase sign up function here with the input values
            print('First Name: $firstName');
            print('Last Name: $lastName');
            print('Email/Phone: $emailOrPhone');
            print('Password: $password');
            print('Confirm Password: $confirmPassword');
            print('Selected Option: $selectedOption');
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
