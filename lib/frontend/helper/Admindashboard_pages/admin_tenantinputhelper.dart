import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:html' as html;

import '../../../backend/models/tenantsmodel.dart';
import 'admin_tenantinput.dart';

class TenantCardWidget extends StatefulWidget {
  @override
  _TenantCardWidgetState createState() => _TenantCardWidgetState();
}

class _TenantCardWidgetState extends State<TenantCardWidget> {
  String firstName = '';
  String lastName = '';
  String description = '';
  double rating = 0.0;
  int rent = 0;
  String? pathToImage;

  bool uploading = false;

  List<Tenant> tenantList = [];
  List<html.File>? selectedImages = [];

  final TextEditingController cnicController = TextEditingController();
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController propertyDetailsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTenants();
  }

  Future<void> fetchTenants() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Tenants').get();

    List<Tenant> tenants = [];

    for (var doc in querySnapshot.docs) {
      Tenant tenant = Tenant.fromJson(doc.data());
      tenants.add(tenant);
    }

    setState(() {
      tenantList = tenants;
    });
  }

  void validateInputs() {
    if (firstName.isEmpty || lastName.isEmpty || rent <= 0) {
      Fluttertoast.showToast(
        msg: 'Please enter valid first name, last name, and rent.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // if (selectedImages == null || selectedImages!.isEmpty) {
    //   Fluttertoast.showToast(
    //     msg: 'Please select at least one image.',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //   );
    //   return;
    // }

    handleSubmit();
  }

  Future<void> handleSubmit() async {
    setState(() {
      uploading = true;
    });

    await uploadImages();

    DocumentReference<Map<String, dynamic>> tenantDocRef =
        await FirebaseFirestore.instance.collection('Tenants').add({
      'firstName': firstName,
      'lastName': lastName,
      'description': description,
      'rating': rating,
      'balance': rent,
      'pathToImage': pathToImage,
      'creditPoints': 0,
      'cnicNumber': cnicController.text,
      'emailOrPhone': emailOrPhoneController.text,
      'familyMembers': 0,
      'landlordRef': null,
      'isGhost': true,
    });

    setState(() {
      uploading = false;
    });

    Fluttertoast.showToast(
      msg: 'Tenant added successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminTenantsInputPage(),
      ),
    );
  }

  Future<void> selectImages() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..multiple = true;
    input.click();

    await input.onChange.first;

    if (input.files != null) {
      setState(() {
        selectedImages = input.files;
      });
    }
  }

  Future<void> uploadImages() async {
    if (selectedImages != null && selectedImages!.isNotEmpty) {
      for (var file in selectedImages!) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);

        final completer = Completer<String>();

        reader.onLoad.first.then((_) {
          completer.complete(reader.result.toString());
        });

        final encodedImage = await completer.future;

        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('images/users/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageReference.putString(encodedImage,
            format: PutStringFormat.dataUrl);
        await uploadTask;
        String imageUrl = await storageReference.getDownloadURL();

        setState(() {
          pathToImage = imageUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Card(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.15,
                0,
                size.width * 0.15,
                0,
              ),
              child: Column(
                children: [
                  const ListTile(
                    title: Text('Tenant Details'),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'First Name'),
                    onChanged: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Rating'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        rating = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Balance'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        rent = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectImages,
                    child: const Text('Select Images'),
                  ),
                  const SizedBox(height: 20),
                  AbsorbPointer(
                    absorbing: uploading,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: validateInputs,
                          child: const Text('Submit'),
                        ),
                        if (uploading)
                          Container(
                            padding: EdgeInsets.only(left: 150.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
