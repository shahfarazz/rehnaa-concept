import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter

import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:html' as html;

import '../../../backend/models/landlordmodel.dart';
import '../../../backend/models/propertymodel.dart';

class AdminLandlordInputPage extends StatefulWidget {
  @override
  _AdminLandlordInputPageState createState() => _AdminLandlordInputPageState();
}

class _AdminLandlordInputPageState extends State<AdminLandlordInputPage> {
  List<Landlord> landlords = [];
  List<Landlord> filteredLandlords = [];
  TextEditingController searchController = TextEditingController();
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchLandlords();
  }

  Future<void> fetchLandlords() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Landlords').get();

    List<Landlord> landlordList = [];

    for (var doc in querySnapshot.docs) {
      Landlord landlord =
          await Landlord.fromJson(doc.data() as Map<String, dynamic>);
      landlordList.add(landlord);
    }

    setState(() {
      landlords = landlordList;
      filteredLandlords = List.from(landlords);
    });
  }

  void filterLandlords(String query) {
    List<Landlord> tempList = [];
    if (query.isNotEmpty) {
      tempList = landlords.where((landlord) {
        return landlord.firstName.toLowerCase().contains(query.toLowerCase()) ||
            landlord.lastName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      tempList = List.from(landlords);
    }
    setState(() {
      filteredLandlords = tempList;
    });
  }

  List<Landlord> getPaginatedProperties() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (endIndex >= filteredLandlords.length) {
      return filteredLandlords.sublist(startIndex);
    } else {
      return filteredLandlords.sublist(startIndex, endIndex);
    }
  }

  Future<void> openPropertyDetailsDialog(Landlord landlord) async {
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        print('reached here');

        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    landlord.firstName + ' ' + landlord.lastName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Balance: Rs.${landlord.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person_2),
                  title: Text(
                    'tenantRef: ${landlord.tenantRef}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text(
                    'PropertyRef: ${landlord.propertyRef}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text(
                    'Rentpaymentref: ${landlord.rentpaymentRef}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Image:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // Display the images with loading indicator
                Container(
                  height: 200.0, // Adjust this value according to your needs.
                  child: CachedNetworkImage(
                    imageUrl: landlord.pathToImage ?? '',
                    errorWidget: (context, error, stackTrace) {
                      return Icon(Icons.error);
                    },
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return CircularProgressIndicator(
                        value: downloadProgress.progress,
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Landlord Input'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  filterLandlords(value);
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: getPaginatedProperties().length,
                itemBuilder: (context, index) {
                  Landlord landlord = getPaginatedProperties()[index];

                  return ListTile(
                    title: Text(landlord.firstName + ' ' + landlord.lastName),
                    subtitle: Text(landlord.balance.toString()),
                    leading: Icon(Icons.person),
                    onTap: () => openPropertyDetailsDialog(landlord),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      if (currentPage > 1) {
                        currentPage--;
                      }
                    });
                  },
                ),
                Text(
                  'Page $currentPage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      final maxPage =
                          (filteredLandlords.length / itemsPerPage).ceil();
                      if (currentPage < maxPage) {
                        currentPage++;
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: LandlordCardWidget(),
              );
            },
          );
          // Add functionality for the + floating action button here
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xff0FA697),
      ),
    );
  }
}

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

    if (selectedImages == null || selectedImages!.isEmpty) {
      // Display error message or perform necessary actions for no selected images
      // For example, show a snackbar or toast with an error message
      Fluttertoast.showToast(
        msg: 'Please select at least one image.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

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
        msg: 'Please select a bank name.',
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

    if (accountNumberController.text.length != 16) {
      // Display error message or perform necessary actions for invalid bank account number
      // For example, show a snackbar or toast with an error message
      Fluttertoast.showToast(
        msg:
            'Please enter a valid bank account number (20 alphanumeric characters).',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (ibanController.text.length != 24) {
      // Display error message or perform necessary actions for invalid IBAN
      // For example, show a snackbar or toast with an error message
      Fluttertoast.showToast(
        msg: 'Please enter a valid IBAN (24 alphanumeric characters).',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // All inputs are valid, proceed with submission
    handleSubmit();
  }

  Future<void> handleSubmit() async {
    setState(() {
      uploading = true;
    });

    await uploadImages();

    // Hash sensitive information
    final hashedCnic = hashString(cnicController.text);
    final hashedBankName = hashString(bankNameController.text);
    final hashedRaastId = hashString(raastIdController.text);
    final hashedAccountNumber = hashString(accountNumberController.text);
    final hashedIban = hashString(ibanController.text);

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
                  ListTile(
                    title: Text('Landlord Details'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'First Name'),
                    onChanged: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Last Name'),
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Balance'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        balance = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectImages,
                    child: Text(buttonLabel),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<DocumentSnapshot<Map<String, dynamic>>>(
                    value: selectedDealer,
                    hint: Text('Select Dealer'),
                    items: dealerList.map((dealer) {
                      String dealerName =
                          '${dealer.data()!['firstName']} ${dealer.data()!['lastName']}';
                      return DropdownMenuItem(
                        value: dealer,
                        child: Text(dealerName),
                      );
                    }).toList(),
                    onChanged: (dealer) {
                      setState(() {
                        selectedDealer = dealer;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: cnicController,
                    decoration: InputDecoration(labelText: 'CNIC Number'),
                  ),
                  TextField(
                    controller: bankNameController,
                    decoration: InputDecoration(labelText: 'Bank Name'),
                  ),
                  TextField(
                    controller: raastIdController,
                    decoration: InputDecoration(labelText: 'Raast ID'),
                  ),
                  TextField(
                    controller: accountNumberController,
                    decoration:
                        InputDecoration(labelText: 'Bank Account Number'),
                  ),
                  TextField(
                    controller: ibanController,
                    decoration: InputDecoration(labelText: 'IBAN'),
                  ),
                  TextField(
                    controller: creditPointsController,
                    decoration: InputDecoration(labelText: 'Credit Points'),
                  ),
                  TextField(
                    controller: creditScoreController,
                    decoration: InputDecoration(labelText: 'Credit Score'),
                  ),
                  SizedBox(height: 20),
                  AbsorbPointer(
                    absorbing: uploading,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: validateInputs,
                          child: Text('Submit'),
                        ),
                        if (uploading) CircularProgressIndicator(),
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
