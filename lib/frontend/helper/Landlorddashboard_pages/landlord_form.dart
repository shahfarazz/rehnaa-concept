import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  // final TextEditingController _propertyAddressController =
  //     TextEditingController();
  // final TextEditingController _rentDemandController = TextEditingController();
  // //bankName
  final TextEditingController _phoneNumberController = TextEditingController();
  //raastId
  // final TextEditingController _raastIdController = TextEditingController();
  // //accountNumber
  // final TextEditingController _accountNumberController =
  //     TextEditingController();
  // //iban
  // final TextEditingController _ibanController = TextEditingController();

  //TODO add a cell phone number;

  @override
  void dispose() {
    _addressController.dispose();
    _cnicController.dispose();
    _phoneNumberController.dispose();
    // _phoneNumberController.dispose();
    // _raastIdController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    var encryptedCNIC = await encryptString(_cnicController.text);

    if (_formKey.currentState!.validate()) {
      final data = {
        'address': _addressController.text,
        'cnic': encryptedCNIC,
        // 'propertyAddress': _propertyAddressController.text,
        // 'rentDemand': _rentDemandController.text,
        // 'bankName': encryptString(_phoneNumberController.text),
        // 'raastId': _raastIdController.text,
        // 'accountNumber': encryptString(_accountNumberController.text),
        // 'iban': encryptString(_ibanController.text),
        // 'rating': _ratingController.text,
        'phoneNumber': _phoneNumberController.text,
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
                  color: Colors.green,
                ),
                controller: _cnicController,
                decoration: const InputDecoration(
                  labelText: 'CNIC Number',
                  focusColor: Colors.green,
                  hoverColor: Colors.green,
                  fillColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                      13), // Restrict maximum length to 13
                  // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onChanged: (value) {
                  //if alphabet is entered show an error using toast and clear the field and return
                  if (value.contains(RegExp(r'[a-zA-Z]'))) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     backgroundColor: Colors.red,
                    //     content: Text(
                    //       'Please enter digits only',
                    //       textAlign: TextAlign.center,
                    //     ),
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
                validator: (value) {
                  if (value!.isEmpty || value.length != 13) {
                    return 'Please enter a valid CNIC';
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
                controller: _phoneNumberController,
                onChanged: (value) {
                  //if alphabet is entered show an error using toast and clear the field and return
                  if (value.contains(RegExp(r'[a-zA-Z]'))) {
                    // replace with a red flutter toast
                    Fluttertoast.showToast(
                        msg: "Please enter digits only",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    _phoneNumberController.clear();
                    return;
                  }
                },
                decoration: const InputDecoration(
                    labelText: 'Phone number',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the phone number';
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(Size size, BuildContext context) {
  return AppBar(
    toolbarHeight: 70,
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        closeKeyboard(
            context); // Close the keyboard when the back icon is pressed
        Navigator.of(context).pop(); // You may also want to navigate back
      },
    ),
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

void closeKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}
