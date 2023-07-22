import 'dart:math';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../backend/models/landlordmodel.dart';
import '../../Screens/Landlord/landlord_dashboard.dart';

class LandlordPropertyForms extends StatefulWidget {
  final String uid;

  const LandlordPropertyForms({Key? key, required this.uid}) : super(key: key);

  @override
  State<LandlordPropertyForms> createState() => _LandlordPropertyFormsState();
}

class _LandlordPropertyFormsState extends State<LandlordPropertyForms> {
  final _formKey = GlobalKey<FormState>();

  // String type;
  final TextEditingController _typeController = TextEditingController();
  // int beds;
  final TextEditingController _bedsController = TextEditingController();
  // int baths;
  final TextEditingController _bathsController = TextEditingController();
  // bool garden;
  bool _garden = false;
  // int living;
  final TextEditingController _livingController = TextEditingController();
  // int floors;
  final TextEditingController _floorsController = TextEditingController();
  // int carspace;
  final TextEditingController _carspaceController = TextEditingController();
  // String description;
  final TextEditingController _descriptionController = TextEditingController();
  // String title;
  final TextEditingController _titleController = TextEditingController();
  // String location;
  final TextEditingController _locationController = TextEditingController();
  // String address;
  final TextEditingController _addressController = TextEditingController();
  // double? price;
  final TextEditingController _priceController = TextEditingController();
  // num? area;
  final TextEditingController _areaController = TextEditingController();

  var pathToImage = <String>[];
  var data = 'Select Image';

  @override
  void dispose() {
    _typeController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();

    _livingController.dispose();
    _floorsController.dispose();
    _carspaceController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final dataFields = {
        'type': _typeController.text,
        'beds': int.parse(_bedsController.text),
        'baths': int.parse(_bathsController.text),
        'garden': _garden,
        'living': int.parse(_livingController.text),
        'floors': int.parse(_floorsController.text),
        'carspace': int.parse(_carspaceController.text),
        'description': _descriptionController.text,
        'title': _titleController.text,
        'location': _locationController.text,
        'address': _addressController.text,
        'price': double.parse(_priceController.text),
        'area': double.parse(_areaController.text),
        'isDetailsFilled': true,
        'imagePath': pathToImage.isNotEmpty ? pathToImage : [''],
      };

      try {
        //send an AdminRequest for the tenant
        Landlord? landlord;
        await FirebaseFirestore.instance
            .collection('Landlords')
            .doc(widget.uid)
            .get()
            .then((value) {
          landlord = Landlord.fromJson(value.data()!);
        });

        final Random random = Random();
        final String randomID =
            random.nextInt(999999).toString().padLeft(6, '0');
        FirebaseFirestore.instance
            .collection('AdminRequests')
            .doc(widget.uid)
            .set({
          'propertyApprovalRequest': FieldValue.arrayUnion([
            {
              'fullname': '${landlord?.firstName} ${landlord?.lastName}',
              'uid': widget.uid,
              'timestamp': Timestamp.now(),
              'requestID': randomID,
              'dataFields': dataFields,
            }
          ]),
        }, SetOptions(merge: true)); //TODO implement this call

        //send a notification to the tenant that the request has been sent
        FirebaseFirestore.instance
            .collection('Notifications')
            .doc(widget.uid)
            .set({
          'notifications': FieldValue.arrayUnion([
            {
              'title':
                  'Your request for property approval has been sent to the admin.',
            }
          ])
        }, SetOptions(merge: true));

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LandlordDashboardPage(uid: widget.uid)));

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Request sent successfully')),
        // );
        //replace with a green flutter toast
        Fluttertoast.showToast(
            msg: 'Request sent successfully',
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
            msg: 'An error occurred while saving data',
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
              //property title
              TextFormField(
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Property Title',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the title of the property';
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
                          _typeController.text == ''
                              ? 'Type of Property'
                              : _typeController.text,
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
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                // ],
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
                        msg: 'Please enter digits only',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    _bedsController.clear();
                    return;
                  }
                },
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _bedsController,
                decoration: const InputDecoration(
                    labelText: 'Number of Bedrooms',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  //check if value is a number
                  try {
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  if (value.isEmpty) {
                    return 'Please enter the number of bedrooms';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _bathsController,
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                // ],
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
                        msg: 'Please enter digits only',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    _bathsController.clear();
                    return;
                  }
                },
                decoration: const InputDecoration(
                    labelText: 'Number of Bathrooms',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  //check if value is a number
                  try {
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  if (value!.isEmpty) {
                    return 'Please enter the number of bathrooms';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //stateful builder boolean gardern checkbox listtile _garden
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return CheckboxListTile(
                    title: const Text('Garden'),
                    value: _garden,
                    onChanged: (bool? value) {
                      setState(() {
                        _garden = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
              const SizedBox(height: 16),
              //_livingController number of living rooms
              TextFormField(
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _livingController,
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                // ],
                onChanged: (value) {
                  //if alphabet is entered show an error using toast and clear the field and return
                  if (value.contains(RegExp(r'[a-zA-Z]'))) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     backgroundColor: Colors.red,
                    //     content: Text('Please enter digits only'),
                    //   ),
                    // );
                    // replace with a red flutter toast
                    Fluttertoast.showToast(
                        msg: 'Please enter digits only',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    _livingController.clear();
                    return;
                  }
                },
                decoration: const InputDecoration(
                    labelText: 'Number of Living Rooms',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  try {
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  if (value!.isEmpty) {
                    return 'Please enter the number of living rooms';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //number of floors
              TextFormField(
                cursorColor: Colors.green,
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                // ],
                onChanged: (value) {
                  //if alphabet is entered show an error using toast and clear the field and return
                  if (value.contains(RegExp(r'[a-zA-Z]'))) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     backgroundColor: Colors.red,
                    //     content: Text('Please enter digits only'),
                    //   ),
                    // );
                    // replace with a red flutter toast
                    Fluttertoast.showToast(
                        msg: 'Please enter digits only',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white);
                    _floorsController.clear();
                    return;
                  }
                },
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _floorsController,
                decoration: const InputDecoration(
                    labelText: 'Number of Floors',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  try {
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  if (value!.isEmpty) {
                    return 'Please enter the number of floors';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //number of parking spaces
              TextFormField(
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _carspaceController,
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                // ],
                onChanged: (value) {
                  //if alphabet is entered show an error using toast and clear the field and return
                  if (value.contains(RegExp(r'[a-zA-Z]'))) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     backgroundColor: Colors.red,
                    //     content: Text('Please enter digits only'),
                    //   ),
                    // );
                    // replace with a red flutter toast
                    Fluttertoast.showToast(
                        msg: 'Please enter digits only',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white);
                    _carspaceController.clear();
                    return;
                  }
                },
                decoration: const InputDecoration(
                    labelText: 'Number of Parking Spaces',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  try {
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  if (value!.isEmpty) {
                    return 'Please enter the number of parking spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //property description
              TextFormField(
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Property Description',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description of the property';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _addressController,
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
                    return 'Please enter your current address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //property price
              TextFormField(
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _priceController,
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                // ],
                onChanged: (value) {
                  //if alphabet is entered show an error using toast and clear the field and return
                  if (value.contains(RegExp(r'[a-zA-Z]'))) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     backgroundColor: Colors.red,
                    //     content: Text('Please enter digits only'),
                    //   ),
                    // );
                    // replace with a red flutter toast
                    Fluttertoast.showToast(
                        msg: "Please enter digits only",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    _priceController.clear();
                    return;
                  }
                },
                decoration: const InputDecoration(
                    labelText: 'Property Rent Demand',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  try {
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  if (value!.isEmpty) {
                    return 'Please enter the price of the property';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //area in Marlas
              TextFormField(
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
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    _areaController.clear();
                    return;
                  }
                },
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _areaController,
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                // ],
                decoration: const InputDecoration(
                    labelText: 'Area in Marlas',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  try {
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  if (value!.isEmpty) {
                    return 'Please enter the area of the property';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              //property image using stateful builder and image picker
              //should save to pathToImage variable list which is the image path
              // to firebase storage which will be properties/imageName

              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return pathToImage.length > 0
                      ? Container()
                      : Column(
                          children: [
                            Material(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xff0FA697),
                                      const Color(0xff45BF7A),
                                      const Color(0xff0DF205),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if (data ==
                                        'images uploaded successfully') {
                                      return;
                                    }
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context2) {
                                        return const SpinKitFadingCube(
                                          color:
                                              Color.fromARGB(255, 30, 197, 83),
                                        );
                                      },
                                    );
                                    uploadImages().then((success) {
                                      Navigator.pop(context);
                                      final message = success
                                          ? 'Images uploaded successfully'
                                          : 'Failed to upload images';

                                      if (success) {
                                        setState(() {
                                          data = 'Uploaded';
                                        });
                                      }
                                      Fluttertoast.showToast(
                                          msg: message,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      return;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(32.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 24.0),
                                        child: Text(
                                          data,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: GoogleFonts.montserrat()
                                                .fontFamily,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),
              pathToImage.length > 0
                  ? Column(
                      children: [
                        Container(
                          height: 100,
                          child: ListView(
                            padding: EdgeInsets.only(left: 40),
                            children: [
                              Text('Uploaded Images:',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                    color: Colors.green,
                                  )),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: pathToImage.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      3, // change this number as needed
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return Stack(
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          pathToImage[
                                              index], // assuming pathToImage is list of file paths
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: const SpinKitFadingCube(
                                                color: Color.fromARGB(
                                                    255, 30, 197, 83),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        //gesture detector plus icon that adds more images and resets state

                        SizedBox(height: size.height * 0.02),

                        GestureDetector(
                          onTap: () {
                            if (data == 'images uploaded successfully') {
                              return;
                            }
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context2) {
                                return const SpinKitFadingCube(
                                  color: Color.fromARGB(255, 30, 197, 83),
                                );
                              },
                            );
                            uploadImages().then((success) {
                              Navigator.pop(context);
                              final message = success
                                  ? 'Images uploaded successfully'
                                  : 'Failed to upload images';

                              if (success) {
                                setState(() {
                                  data = 'Uploaded';
                                });
                              }
                              Fluttertoast.showToast(
                                  msg: message,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              print('now pathToImage is $pathToImage');
                              return;
                            });
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            color: Colors.green,
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),

              SizedBox(height: size.height * 0.02),

              Material(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff0FA697),
                        const Color(0xff45BF7A),
                        const Color(0xff0DF205),
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

  List<String> imagePath = []; // Store the uploaded image URLs

  Future<bool> uploadImages() async {
    try {
      final picker = ImagePicker();
      final List<XFile>? selectedImages = await picker.pickMultiImage();

      if (selectedImages != null && selectedImages.isNotEmpty) {
        if (selectedImages.length > 10) {
          Fluttertoast.showToast(
            msg: 'You can select up to 10 images',
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return false;
        }
        for (var imageFile in selectedImages) {
          String fileName = path.basename(imageFile.path);

          Reference storageReference = FirebaseStorage.instance.ref().child(
              'images/properties/${DateTime.now().millisecondsSinceEpoch}_$fileName');
          UploadTask uploadTask =
              storageReference.putFile(File(imageFile.path));
          TaskSnapshot storageSnapshot = await uploadTask;
          String imageUrl = await storageSnapshot.ref.getDownloadURL();

          setState(() {
            imagePath.add(imageUrl);
            pathToImage.add(imageUrl);
          });
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void _openOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Property Type',
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
                  _buildOption('Property Type: Residential', setState),
                  Divider(),
                  _buildOption('Property Type: Commercial', setState),
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
          _typeController.text = value;
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
