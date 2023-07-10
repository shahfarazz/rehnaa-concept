import 'dart:math';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
        'pathToImage': pathToImage,
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent successfully')),
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
              TextFormField(
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _typeController,
                decoration: const InputDecoration(
                    labelText: 'Type of Property',
                    focusColor: Colors.green,
                    hoverColor: Colors.green,
                    fillColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the type of property';
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
                  try {
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
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
                decoration: const InputDecoration(
                    labelText: 'Property Price',
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
                cursorColor: Colors.green,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: Colors.green),
                controller: _areaController,
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
                  return Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context2) {
                                return const SpinKitFadingCube(
                                  color: Color.fromARGB(255, 30, 197, 83),
                                );
                              });
                          uploadImages().then((success) {
                            Navigator.pop(context);
                            final message = success
                                ? 'Images uploaded successfully'
                                : 'Failed to upload images';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.green,
                              ),
                            );

                            return;
                          });
                        },
                        child: Text(
                          'Select Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),

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

  List<String> imagePath = []; // Store the uploaded image URLs

  Future<bool> uploadImages() async {
    try {
      final picker = ImagePicker();
      final List<XFile>? selectedImages = await picker.pickMultiImage();

      if (selectedImages != null && selectedImages.isNotEmpty) {
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
            pathToImage = imagePath;
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
