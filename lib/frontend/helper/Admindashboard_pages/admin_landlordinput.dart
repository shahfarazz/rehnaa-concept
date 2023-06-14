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
  List<DocumentReference<Map<String, dynamic>>> selectedProperties = [];

  List<DocumentReference<Map<String, dynamic>>> selectedTenants = [];
  List<DocumentReference<Map<String, dynamic>>> selectedRentPayments = [];

  @override
  void initState() {
    super.initState();
    fetchLandlords();
  }

  Future<List<Landlord>> fetchLandlords() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Landlords').get();

    List<Landlord> landlordList = [];

    for (var doc in querySnapshot.docs) {
      Landlord landlord = await Landlord.fromJson(doc.data());
      landlord.tempID = doc.id;
      landlordList.add(landlord);
    }

    setState(() {
      landlords = landlordList;
      filteredLandlords = List.from(landlords);
    });
    return landlords;
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

  List<Landlord> getPaginatedLandlords() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (endIndex >= filteredLandlords.length) {
      return filteredLandlords.sublist(startIndex);
    } else {
      return filteredLandlords.sublist(startIndex, endIndex);
    }
  }

  Future<void> openLandlordDetailsDialog(Landlord landlord) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        '${landlord.firstName} ${landlord.lastName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Balance: Rs.${landlord.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_2),
                      title: Text(
                        'Tenant Ref: ${landlord.tenantRef?.toString() ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(
                        'Property Ref: ${landlord.propertyRef.toString()}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.receipt),
                      title: Text(
                        'Rent Payment Ref: ${landlord.rentpaymentRef?.toString() ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Image:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Display the images with loading indicator
                    SizedBox(
                      height: 200.0,
                      child: CachedNetworkImage(
                        imageUrl: landlord.pathToImage ?? '',
                        errorWidget: (context, error, stackTrace) {
                          return const Icon(Icons.error);
                        },
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) {
                          return CircularProgressIndicator(
                            value: downloadProgress.progress,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the details dialog
                        _showEditDialog(landlord); // Open the edit dialog
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(Landlord landlord) {
    // print()
    final TextEditingController firstNameController =
        TextEditingController(text: landlord.firstName);
    final TextEditingController lastNameController =
        TextEditingController(text: landlord.lastName);
    final TextEditingController balanceController =
        TextEditingController(text: landlord.balance.toString());
    selectedProperties = List.from(landlord.propertyRef ?? []);
    selectedTenants = List.from(landlord.tenantRef ?? []);
    selectedRentPayments = List.from(landlord.rentpaymentRef ?? []);

    final TextEditingController dealerRefController =
        TextEditingController(text: landlord.dealerRef?.toString() ?? '');
    final TextEditingController cnicController =
        TextEditingController(text: landlord.cnic ?? '');
    final TextEditingController bankNameController =
        TextEditingController(text: landlord.bankName ?? '');
    final TextEditingController raastIdController =
        TextEditingController(text: landlord.raastId ?? '');
    final TextEditingController accountNumberController =
        TextEditingController(text: landlord.accountNumber ?? '');
    final TextEditingController ibanController =
        TextEditingController(text: landlord.iban ?? '');

    final hashedCnic = hashString(cnicController.text);
    final hashedBankName = hashString(bankNameController.text);
    final hashedRaastId = hashString(raastIdController.text);
    final hashedAccountNumber = hashString(accountNumberController.text);
    final hashedIban = hashString(ibanController.text);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text('Edit Landlord Details'),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(labelText: 'Balance'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return ListTile(
                      title: const Text('Select Properties'),
                      subtitle: Text(
                        '${selectedProperties.length} properties selected',
                        // Add any necessary style modifications here
                      ),
                      onTap: () {
                        setState(() {
                          _showPropertySelectionDialog(() {
                            setState(() {
                              // Update the state of selectedProperties here
                              // print('selectedproperties: $selectedProperties');
                            });
                          });
                        });
                      },
                    );
                  },
                ),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return ListTile(
                        title: const Text('Select Tenants'),
                        subtitle: Text(
                          selectedTenants.length.toString() +
                              ' tenants selected',
                        ),
                        onTap: () {
                          setState(() {
                            _showTenantSelectionDialog(() {
                              setState(() {
                                // Update the state of selectedTenants here
                                // print('selectedTenants: $selectedTenants');
                              });
                            });
                          });
                        });
                  },
                ),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return ListTile(
                      title: const Text('Select Rent Payments'),
                      subtitle: Text(
                        selectedRentPayments.length.toString() +
                            ' rent payments selected',
                      ),
                      onTap: () {
                        setState(() {
                          _showRentPaymentSelectionDialog(() {
                            setState(() {
                              // Update the state of selectedRentPayments here
                              // print('selectedRentPayments: $selectedRentPayments');
                            });
                          });
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: landlord.dealerRef != null,
                  child: TextField(
                    controller: dealerRefController,
                    decoration: const InputDecoration(labelText: 'Dealer Ref'),
                  ),
                ),
                TextField(
                  controller: cnicController,
                  decoration: const InputDecoration(labelText: 'CNIC'),
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
                      const InputDecoration(labelText: 'Account Number'),
                ),
                TextField(
                  controller: ibanController,
                  decoration: const InputDecoration(labelText: 'IBAN'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Update the landlord details in Firebase

                    print('landlord id is ${landlord.tempID}');

                    FirebaseFirestore.instance
                        .collection('Landlords')
                        .doc(landlord.tempID)
                        .update({
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'balance': double.tryParse(balanceController.text) ?? 0.0,
                      'propertyRef': selectedProperties,
                      'tenantRef': selectedTenants,
                      'rentpaymentRef': selectedRentPayments,
                      'dealerRef': dealerRefController.text.isNotEmpty
                          ? dealerRefController.text
                          : FieldValue.delete(),
                      'cnic': cnicController.text.isNotEmpty
                          ? hashedCnic
                          : FieldValue.delete(),
                      'bankName': bankNameController.text.isNotEmpty
                          ? hashedBankName
                          : FieldValue.delete(),
                      'raastId': raastIdController.text.isNotEmpty
                          ? hashedRaastId
                          : FieldValue.delete(),
                      'accountNumber': accountNumberController.text.isNotEmpty
                          ? hashedAccountNumber
                          : FieldValue.delete(),
                      'iban': ibanController.text.isNotEmpty
                          ? hashedIban
                          : FieldValue.delete(),
                    }).then((_) {
                      Fluttertoast.showToast(
                        msg: 'Landlord details updated successfully!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                      Navigator.pop(context); // Close the edit dialog
                    }).catchError((error) {
                      print('error is $error');
                      Fluttertoast.showToast(
                        msg:
                            'Failed to update landlord details. Please try again.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      throw error;
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPropertySelectionDialog(void Function() onSelectionDone) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Properties'),
              content: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Properties')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          propertyDocs = snapshot.data!.docs;
                      return Column(
                        children: propertyDocs.map((propertyDoc) {
                          String propertyName = propertyDoc['title'];
                          bool isSelected = selectedProperties
                              .contains(propertyDoc.reference);
                          return CheckboxListTile(
                            title: Text(propertyName),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (!selectedProperties
                                      .contains(propertyDoc.reference)) {
                                    selectedProperties
                                        .add(propertyDoc.reference);
                                  }
                                } else {
                                  selectedProperties
                                      .remove(propertyDoc.reference);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      List.from(selectedProperties),
                    ); // Pass selected properties back to the caller
                    onSelectionDone();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTenantSelectionDialog(void Function() onSelectionDone) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Tenants'),
              content: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Tenants')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          tenantDocs = snapshot.data!.docs;
                      return Column(
                        children: tenantDocs.map((tenantDoc) {
                          String tenantName = tenantDoc['firstName'] +
                              ' ' +
                              tenantDoc['lastName'];
                          bool isSelected =
                              selectedTenants.contains(tenantDoc.reference);
                          return CheckboxListTile(
                            title: Text(tenantName),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (!selectedTenants
                                      .contains(tenantDoc.reference)) {
                                    selectedTenants.add(tenantDoc.reference);
                                  }
                                } else {
                                  selectedTenants.remove(tenantDoc.reference);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onSelectionDone();

                    Navigator.pop(
                      context,
                      List.from(selectedTenants),
                    ); // Pass selected tenants back to the caller
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRentPaymentSelectionDialog(void Function() onSelectionDone) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select RentPayments'),
              content: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('rentPayments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          rentPaymentsDocs = snapshot.data!.docs;
                      return Column(
                        children: rentPaymentsDocs.map((rentPaymentDoc) {
                          String rentPaymentDate =
                              rentPaymentDoc['date'].toString();
                          bool isSelected = selectedRentPayments
                              .contains(rentPaymentDoc.reference);
                          return CheckboxListTile(
                            title: Text(rentPaymentDate),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (!selectedRentPayments
                                      .contains(rentPaymentDoc.reference)) {
                                    selectedRentPayments
                                        .add(rentPaymentDoc.reference);
                                  }
                                } else {
                                  selectedRentPayments
                                      .remove(rentPaymentDoc.reference);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onSelectionDone();

                    Navigator.pop(
                      context,
                      List.from(selectedRentPayments),
                    ); // Pass selected rent payments back to the caller
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord Input'),
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
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: getPaginatedLandlords().length,
                itemBuilder: (context, index) {
                  Landlord landlord = getPaginatedLandlords()[index];

                  return ListTile(
                    title: Text('${landlord.firstName} ${landlord.lastName}'),
                    subtitle: Text(landlord.balance.toString()),
                    leading: const Icon(Icons.person),
                    onTap: () => openLandlordDetailsDialog(landlord),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
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
        backgroundColor: const Color(0xff0FA697),
        child: const Icon(Icons.add),
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
                  DropdownButton<DocumentSnapshot<Map<String, dynamic>>>(
                    value: selectedDealer,
                    hint: const Text('Select Dealer'),
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
                  const SizedBox(height: 20),
                  TextField(
                    controller: cnicController,
                    decoration: const InputDecoration(labelText: 'CNIC Number'),
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
                        if (uploading) const CircularProgressIndicator(),
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
