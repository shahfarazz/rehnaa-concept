import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';
import 'dart:convert';
import '../../../backend/models/landlordmodel.dart';
import '../../../backend/models/dealermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_landlordinput.dart';

class LandlordCardWidget extends StatefulWidget {
  @override
  _LandlordCardWidgetState createState() => _LandlordCardWidgetState();
}

class _LandlordCardWidgetState extends State<LandlordCardWidget> {
  String firstName = '';
  String lastName = '';

  double balance = 0;
  String? pathToImage;
  List<DocumentReference<Map<String, dynamic>>>? tenantRef = [];
  List<DocumentReference<Map<String, dynamic>>>? propertyRef = [];
  List<DocumentReference<Map<String, dynamic>>>? dealerRef = [];
  String buttonLabel = 'Select Images';
  bool uploading = false; // Track the uploading state

  List<DocumentSnapshot<Map<String, dynamic>>> landlordList = [];
  List<html.File>? selectedImages = [];
  DocumentSnapshot<Map<String, dynamic>>? selectedDealer; // Selected dealer
  List<DocumentSnapshot<Map<String, dynamic>>> dealerList = [];

  final TextEditingController cnicController = TextEditingController();
  final TextEditingController creditPointsController = TextEditingController();
  final TextEditingController creditScoreController = TextEditingController();

  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController raastIdController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  void validateInputs() {
    // Validate input fields and perform necessary actions
    if (firstName.isEmpty || lastName.isEmpty || balance <= 0) {
      // Display error message or perform necessary actions for invalid inputs
      // For example, show a snackbar or toast with an error message
      Fluttertoast.showToast(
        msg: 'Please enter valid first name, last name, and balance.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // if (selectedImages == null || selectedImages!.isEmpty) {
    //   // Display error message or perform necessary actions for no selected images
    //   // For example, show a snackbar or toast with an error message
    //   Fluttertoast.showToast(
    //     msg: 'Please select at least one image.',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //   );
    //   return;
    // }

    // Perform necessary actions for valid inputs
    if (creditPointsController.text.isEmpty ||
        creditScoreController.text.isEmpty) {
      // Display error message or perform necessary actions for invalid credit points or scoring
      // For example, show a snackbar or toast with an error message
      Fluttertoast.showToast(
        msg: 'Please enter valid credit points and credit scoring.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (cnicController.text.length != 13) {
      // Display error message or perform necessary actions for invalid CNIC number
      // For example, show a snackbar or toast with an error message
      Fluttertoast.showToast(
        msg: 'Please enter a valid 13-digit CNIC number.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (bankNameController.text.isEmpty) {
      // Display error message or perform necessary actions for empty bank name
      // For example, show a snackbar or toast with an error message
      Fluttertoast.showToast(
        msg: 'Please add a bank name.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    if (addressController.text.isEmpty) {
      // Display error message or perform necessary actions for empty bank name
      // For example, show a snackbar or toast with an error message
      Fluttertoast.showToast(
        msg: 'Please enter an address',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (!raastIdController.text.startsWith('03')) {
      // Display error message or perform necessary actions for invalid Raast ID
      // For example, show a snackbar or toast with an error message
      Fluttertoast.showToast(
        msg: 'Please enter a valid Raast ID starting with "03".',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // if (accountNumberController.text.length != 16) {
    //   // Display error message or perform necessary actions for invalid bank account number
    //   // For example, show a snackbar or toast with an error message
    //   Fluttertoast.showToast(
    //     msg:
    //         'Please enter a valid bank account number (16 numbers).',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //   );
    //   return;
    // }

    // if (ibanController.text.length != 24) {
    //   // Display error message or perform necessary actions for invalid IBAN
    //   // For example, show a snackbar or toast with an error message
    //   Fluttertoast.showToast(
    //     msg: 'Please enter a valid IBAN (24 alphanumeric characters).',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //   );
    //   return;
    // }

    // All inputs are valid, proceed with submission
    handleSubmit();
  }

  Future<void> handleSubmit() async {
    setState(() {
      uploading = true;
    });

    await uploadImages();

    // Hash sensitive information
    final hashedCnic = encryptString(cnicController.text);
    final hashedBankName = encryptString(bankNameController.text);
    final hashedRaastId = encryptString(raastIdController.text);
    final hashedAccountNumber = encryptString(accountNumberController.text);
    final hashedIban = encryptString(ibanController.text);
    final hashedAddress = encryptString(addressController.text);

    // Add landlord details to Firestore
    DocumentReference<Map<String, dynamic>> landlordDocRef =
        await FirebaseFirestore.instance.collection('Landlords').add({
      'firstName': firstName,
      'lastName': lastName,
      'balance': balance,
      'pathToImage': pathToImage,
      'tenantRef': tenantRef,
      'propertyRef': propertyRef,
      'dealerRef': dealerRef,
      'cnic': hashedCnic,
      'bankName': hashedBankName,
      'raastId': hashedRaastId,
      'accountNumber': hashedAccountNumber,
      'iban': hashedIban,
      'address': hashedAddress,
      'isGhost': true,
    });

    // Set landlord reference for the selected dealer
    await setDealerRefForLandlord(landlordDocRef);

    setState(() {
      uploading = false;
    });

    Fluttertoast.showToast(
      msg: 'Landlord added successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminLandlordInputPage(),
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
        buttonLabel = 'Images Selected (${selectedImages!.length})';
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

  Future<void> setDealerRefForLandlord(
      DocumentReference<Map<String, dynamic>> landlordRef) async {
    if (selectedDealer != null) {
      final dealerRef = selectedDealer!.reference;
      setState(() {
        this.dealerRef!.add(dealerRef);
      });

      // Set landlord reference for the selected dealer
      await dealerRef.set(
        {
          'landlordRef': FieldValue.arrayUnion([landlordRef])
        },
        SetOptions(merge: true),
      );
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
                    title: Text('Landlord Details'),
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
                    decoration: const InputDecoration(labelText: 'Balance'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        balance = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectImages,
                    child: Text(buttonLabel),
                  ),
                  const SizedBox(height: 20),
                  // DropdownButton<DocumentSnapshot<Map<String, dynamic>>>(
                  //   value: selectedDealer,
                  //   hint: const Text('Select Dealer'),
                  //   items: dealerList.map((dealer) {
                  //     String dealerName =
                  //         '${dealer.data()!['firstName']} ${dealer.data()!['lastName']}';
                  //     return DropdownMenuItem(
                  //       value: dealer,
                  //       child: Text(dealerName),
                  //     );
                  //   }).toList(),
                  //   onChanged: (dealer) {
                  //     setState(() {
                  //       selectedDealer = dealer;
                  //     });
                  //   },
                  // ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: cnicController,
                    decoration: const InputDecoration(labelText: 'CNIC Number'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextField(
                    controller: bankNameController,
                    decoration: const InputDecoration(labelText: 'Bank Name'),
                  ),
                  TextField(
                    controller: raastIdController,
                    decoration: const InputDecoration(labelText: 'Raast ID'),
                  ),
                  TextField(
                    controller: accountNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Bank Account Number'),
                  ),
                  TextField(
                    controller: ibanController,
                    decoration: const InputDecoration(labelText: 'IBAN'),
                  ),
                  TextField(
                    controller: creditPointsController,
                    decoration:
                        const InputDecoration(labelText: 'Credit Points'),
                  ),
                  TextField(
                    controller: creditScoreController,
                    decoration:
                        const InputDecoration(labelText: 'Credit Score'),
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

String hashString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
