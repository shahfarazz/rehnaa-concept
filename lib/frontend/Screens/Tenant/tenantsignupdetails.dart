import 'package:flutter/material.dart';

class TenantsSignUpDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // buildTitle("Welcome to Rehnaa"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              // buildSubtitle("Sign Up"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              buildInputField("First Name"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildInputField("Last Name"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildInputField("Email ID/Phone Number"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildPasswordInputField("Password"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildPasswordInputField("Re-enter Password"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              // buildOptionSelector(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              buildnextButton(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }

//   Tenant profile fields in sign up page
// Name
// number
// Email
// CNIC number
// Address

  Widget buildTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xff33907c),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildSubtitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xff33907c),
        fontSize: 18,
      ),
    );
  }

  Widget buildInputField(String label) {
    return TextField(
      style: const TextStyle(
        color: Color(0xff33907c),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xff33907c),
          fontSize: 18,
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

  Widget buildPasswordInputField(String label) {
    return TextField(
      obscureText: true,
      style: const TextStyle(
        color: Color(0xff33907c),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xff33907c),
          fontSize: 18,
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
      onTap: () {},
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: null,
          color: Colors.white,
          border: Border.all(color: const Color(0xff33907c), width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xff33907c),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildnextButton() {
    return Container(
      width: double.infinity,
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
          onTap: () {},
          child: const Center(
            child: Text(
              "Next",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TenantsSignUpDetailsPage(),
  ));
}
