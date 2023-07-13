import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/landlord_profile.dart';

import '../../Screens/Tenant/tenant_dashboard.dart';

// import '../../Screens/Landlord/landlord_dashboard.dart';

class TenantForms extends StatefulWidget {
  final String uid;

  const TenantForms({Key? key, required this.uid}) : super(key: key);

  @override
  State<TenantForms> createState() => _TenantFormsState();
}

class _TenantFormsState extends State<TenantForms> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();

  //whatareyoulookingfor
  final TextEditingController _whatAreYouLookingForController =
      TextEditingController();
  //estimatedTimeToShiftBudget
  final TextEditingController _estimatedTimeToShiftController =
      TextEditingController();
  final TextEditingController _estimatedBudgetController =
      TextEditingController();
  // String? _cnicError;

  @override
  void dispose() {
    _addressController.dispose();
    _cnicController.dispose();
    _whatAreYouLookingForController.dispose();
    _estimatedTimeToShiftController.dispose();
    _estimatedBudgetController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'address': _addressController.text,
        'cnic': encryptString(_cnicController.text),
        'whatAreYouLookingFor': _whatAreYouLookingForController.text,
        'estimatedTimetoShift': _estimatedTimeToShiftController.text,
        'estimatedBudget': _estimatedBudgetController.text,
        'isDetailsFilled': true,
      };

      try {
        await FirebaseFirestore.instance
            .collection('Tenants')
            .doc(widget.uid)
            .update(data);

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Data saved successfully')),
        // );
        //replace with a green flutter toast
        Fluttertoast.showToast(
            msg: "Data saved successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TenantDashboardPage(uid: widget.uid)));
        return;
      } catch (error) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('An error occurred while saving data')),
        // );
        //replace with a red flutter toast
        Fluttertoast.showToast(
            msg: "An error occurred while saving data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(size, context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _addressController,
                decoration: const InputDecoration(
                    labelText: 'Your Current Address',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your current address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _cnicController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                      13), // Restrict maximum length to 13
                  // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                decoration: const InputDecoration(
                    labelText: 'CNIC',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty && value.length != 13) {
                    return 'Please enter a valid CNIC';
                  }
                  return null;
                },
                onChanged: (value) {
                  //if alphabet is entered show an error using toast and clear the field and return
                  if (value.contains(RegExp(r'[a-zA-Z]'))) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     backgroundColor: Colors.red,
                    //     content: Text('Please enter digits only'),
                    //   ),
                    // );
                    //replace with a red flutter toast
                    Fluttertoast.showToast(
                        msg: "Please enter digits only",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    _cnicController.clear();
                    return;
                  }
                },
              ),
              const SizedBox(height: 16),
              // Text(
              //   'Property Details',
              //   style: TextStyle(
              //       fontSize: 16,
              //       fontFamily: GoogleFonts.montserrat().fontFamily,
              //       color: Colors.green),
              // ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _whatAreYouLookingForController,
                decoration: const InputDecoration(
                    labelText: 'What are you looking for?',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a property address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return InkWell(
                    onTap: _openOptionsDialog,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff0FA697),
                            Color(0xff45BF7A),
                            Color(0xff0DF205),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: Text(
                          _estimatedTimeToShiftController.text == ''
                              ? 'Estimated Time to Shift'
                              : _estimatedTimeToShiftController.text,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _estimatedBudgetController,
                decoration: const InputDecoration(
                    labelText: 'Estimated Rent Budget',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter valid estimated rent budget';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              Material(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff0FA697),
                        Color(0xff45BF7A),
                        Color(0xff0DF205),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: InkWell(
                    onTap: _saveForm,
                    borderRadius: BorderRadius.circular(32.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      child: Text(
                        'Save',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
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

  void _openOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Estimated Time to Shift',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  color: Colors.green,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(),
                  _buildOption('Time to Shift: 1 month', setState),
                  Divider(),
                  _buildOption('Time to Shift: 1-2 months', setState),
                  Divider(),
                  _buildOption('Time to Shift: 2-3 months', setState),
                  Divider(),
                  _buildOption('Time to Shift: 3-6 months', setState),
                  Divider(),
                  _buildOption('Time to Shift: 6+ months', setState),
                  Divider(),
                ],
              ),
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          // _selectedOption = value;
          _estimatedTimeToShiftController.text = value;
        });
      }
    });
  }

  Widget _buildOption(String option, Function setState) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(option);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontFamily: GoogleFonts.montserrat().fontFamily,
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(Size size, context) {
  return AppBar(
    toolbarHeight: 70,
    title: Padding(
      padding: EdgeInsets.only(
        right:
            MediaQuery.of(context).size.width * 0.14, // 55% of the page width
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: [
              ClipPath(
                clipper: HexagonClipper(),
                child: Transform.scale(
                  scale: 0.87,
                  child: Container(
                    color: Colors.white,
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
              ClipPath(
                clipper: HexagonClipper(),
                child: Image.asset(
                  'assets/mainlogo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          // const SizedBox(width: 8),
        ],
      ),
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Stack(
          children: [],
        ),
      ),
    ],
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
  );
}
