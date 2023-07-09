import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rehnaa/frontend/Screens/Admin/admindashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible =
      false; // Added variable to track password visibility

  void checkAlreadyLoggedIn() {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          if (value.data()!['type'] == 'Admin') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminDashboard()));
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } catch (e) {
      print(e);
    }

    //check if login is successful
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        if (value.data()!['type'] == 'Admin') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Invalid email or password'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      });
    } else {
      //if login is not successful, show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid email or password'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    checkAlreadyLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Textfields to ask for email and password
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
        ),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextFormField(
              controller: _passwordController,
              obscureText:
                  !_isPasswordVisible, // Set obscureText based on visibility state
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible =
                          !_isPasswordVisible; // Toggle password visibility
                    });
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
