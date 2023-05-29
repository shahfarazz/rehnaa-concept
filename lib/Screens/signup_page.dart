import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/Screens/login_page.dart';

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
              SizedBox(height: 21.0),
              buildSubtitle("Sign Up"),
              SizedBox(height: 21.0),
              buildInputField("First Name", onChanged: (value) {
                setState(() {
                  firstName = value;
                });
              }),
              SizedBox(height: 21.0),
              buildInputField("Last Name", onChanged: (value) {
                setState(() {
                  lastName = value;
                });
              }),
              SizedBox(height: 21.0),
              buildInputField("Email ID/Phone Number", onChanged: (value) {
                setState(() {
                  emailOrPhone = value;
                });
              }),
              SizedBox(height: 21.0),
              buildPasswordInputField("Password", onChanged: (value) {
                setState(() {
                  password = value;
                });
              }),
              SizedBox(height: 21.0),
              buildPasswordInputField("Re-enter Password", onChanged: (value) {
                setState(() {
                  confirmPassword = value;
                });
              }),
              SizedBox(height: 21.0),
              buildOptionSelector(),
              SizedBox(height: 21.0),
              buildCreateButton(),
              SizedBox(height: 21.0),
              buildSignInText(),
              SizedBox(height: 5.0), // Adjusted to avoid bottom overflow
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
      style: TextStyle(
        color: Color(0xff33907c),
        fontSize: 24,
        fontFamily: "Montserrat",
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget buildSubtitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xff33907c),
        fontSize: 16,
      ),
    );
  }

  Widget buildInputField(String label, {required Function(String) onChanged}) {
    return TextField(
      onChanged: onChanged,
      style: TextStyle(
        color: Color(0xff33907c),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xff33907c),
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

  Widget buildPasswordInputField(String label,
      {required Function(String) onChanged}) {
    return TextField(
      onChanged: onChanged,
      obscureText: true,
      style: TextStyle(
        color: Color(0xff33907c),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xff33907c),
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
          color: selectedOption == text ? Color(0xff33907c) : Colors.white,
          border: Border.all(color: Color(0xff33907c), width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selectedOption == text ? Colors.white : Color(0xff33907c),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCreateButton() {
    return ElevatedButton(
      onPressed: () {
        // Call your Firebase sign up function here with the input values
        print('First Name: $firstName');
        print('Last Name: $lastName');
        print('Email/Phone: $emailOrPhone');
        print('Password: $password');
        print('Confirm Password: $confirmPassword');
        print('Selected Option: $selectedOption');
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: Color(0xff13b58c),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 48,
        child: Center(
          child: Text(
            "Create",
            style: TextStyle(
              color: Color(0xff13b58c),
              fontSize: 16,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w500,
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
        text: "Have an account? ",
        style: GoogleFonts.montserrat(
          color: Color(0xff33907c),
          fontSize: 18,
        ),
        children: <TextSpan>[
          TextSpan(
            text: 'Sign in',
            style: const TextStyle(fontWeight: FontWeight.bold),
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
