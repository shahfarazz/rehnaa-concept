import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';

import '../../Screens/Landlord/landlord_dashboard.dart';
import 'landlord_profile.dart';

class LandlordForms extends StatefulWidget {
  final String uid;

  const LandlordForms({Key? key, required this.uid}) : super(key: key);

  @override
  State<LandlordForms> createState() => _LandlordFormsState();
}

class _LandlordFormsState extends State<LandlordForms> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _propertyAddressController =
      TextEditingController();
  // final TextEditingController _rentDemandController = TextEditingController();
  // //bankName
  final TextEditingController _bankNameController = TextEditingController();
  //raastId
  final TextEditingController _raastIdController = TextEditingController();
  //accountNumber
  final TextEditingController _accountNumberController =
      TextEditingController();
  //iban
  final TextEditingController _ibanController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _cnicController.dispose();
    _propertyAddressController.dispose();
    // _rentDemandController.dispose();
    _bankNameController.dispose();
    _raastIdController.dispose();
    _accountNumberController.dispose();
    _ibanController.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'address': _addressController.text,
        'cnic': encryptString(_cnicController.text),
        'propertyAddress': _propertyAddressController.text,
        // 'rentDemand': _rentDemandController.text,
        'bankName': encryptString(_bankNameController.text),
        // 'raastId': _raastIdController.text,
        'accountNumber': encryptString(_accountNumberController.text),
        'iban': encryptString(_ibanController.text),
        // 'rating': _ratingController.text,
        'isDetailsFilled': true,
      };

      try {
        await FirebaseFirestore.instance
            .collection('Landlords')
            .doc(widget.uid)
            .update(data);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LandlordDashboardPage(uid: widget.uid)));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved successfully')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while saving data')),
        );
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
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _cnicController,
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
              ),
              const SizedBox(height: 16),
              Text(
                'Property Details',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
              ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _propertyAddressController,
                decoration: const InputDecoration(
                    labelText: 'Property Address',
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
              // TextFormField(
              //   style: TextStyle(
              //       fontSize: 16,
              //       fontFamily: GoogleFonts.montserrat().fontFamily,
              //       color: Colors.green),
              //   controller: _rentDemandController,
              //   decoration: const InputDecoration(
              //       labelText: 'Rent Demand for the Property',
              //       focusColor: Colors.green,
              //       hoverColor: Colors.green,
              //       fillColor: Colors.green,
              //       labelStyle: TextStyle(color: Colors.grey),
              //       focusedBorder: UnderlineInputBorder(
              //           borderSide: BorderSide(color: Colors.green))),
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return 'Please enter the rent demand for the property';
              //     }
              //     return null;
              //   },
              // ),

              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _bankNameController,
                decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the bank name';
                  }
                  return null;
                },
              ),
              // TextFormField(
              //   style: TextStyle(
              //       fontSize: 16,
              //       fontFamily: GoogleFonts.montserrat().fontFamily,
              //       color: Colors.green),
              //   controller: _raastIdController,
              //   decoration: const InputDecoration(
              //       labelText: 'Raast ID',
              //       focusColor: Colors.green,
              //       hoverColor: Colors.green,
              //       fillColor: Colors.green,
              //       labelStyle: TextStyle(color: Colors.grey),
              //       focusedBorder: UnderlineInputBorder(
              //           borderSide: BorderSide(color: Colors.green))),
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return 'Please enter the Raast ID';
              //     }
              //     return null;
              //   },
              // ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _accountNumberController,
                decoration: const InputDecoration(
                    labelText: 'Account Number',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the account number';
                  }
                  return null;
                },
              ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _ibanController,
                decoration: const InputDecoration(
                    labelText: 'IBAN',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the IBAN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
                onPressed: _saveForm,
                child: Text(
                  'Save',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts.montserrat().fontFamily),
                ),
              ),
            ],
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
