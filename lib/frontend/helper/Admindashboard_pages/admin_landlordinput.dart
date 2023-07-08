import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:path_provider/path_provider.dart';
// ignore: avoid_web_libraries_in_flutter

// import 'package:crypto/crypto.dart';
// import 'dart:convert';
// import 'dart:html' as html;

import '../../../backend/models/landlordmodel.dart';
// import '../../../backend/models/propertymodel.dart';
import '../../../backend/services/helperfunctions.dart';
import '../../Screens/Admin/admindashboard.dart';
import 'admin_landlordinputhelper.dart';

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
  List<DocumentReference<Map<String, dynamic>>> selectedDealers = [];

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
      Landlord landlord = Landlord.fromJson(doc.data());
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
                        // if tenant ref exists show yes otherwise no
                        'TenantRef: ${landlord.tenantRef != null ? 'Yes' : 'No'}',

                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(
                        // if property ref exists show yes otherwise no

                        'PropertyRef: ${landlord.propertyRef != null ? 'Yes' : 'No'}',
                        // 'Property Ref: ${landlord.propertyRef.toString()}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.receipt),
                      title: Text(
                        // if rent payment ref exists show yes otherwise no
                        'RentPaymentRef: ${landlord.rentpaymentRef != null ? 'Yes' : 'No'}',
                        // 'Rent Payment Ref: ${landlord.rentpaymentRef?.toString() ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(
                        'Address: ${landlord.address}',
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
                          return Container(
                            padding: EdgeInsets.only(left: 150.0),
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                            ),
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
    selectedDealers = List.from(landlord.dealerRef ?? []);

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
    final TextEditingController addressController =
        TextEditingController(text: landlord.address ?? '');

    final hashedCnic = encryptString(cnicController.text);
    final hashedBankName = encryptString(bankNameController.text);
    final hashedRaastId = encryptString(raastIdController.text);
    final hashedAccountNumber = encryptString(accountNumberController.text);
    final hashedIban = encryptString(ibanController.text);

    final TextEditingController contractStartDateController =
        TextEditingController(
            text: landlord.contractStartDate?.toString() ?? '');
    final TextEditingController contractEndDateController =
        TextEditingController(text: landlord.contractEndDate?.toString() ?? '');
    final TextEditingController monthlyRentController =
        TextEditingController(text: landlord.monthlyRent?.toString() ?? '');
    final TextEditingController upfrontBonusController =
        TextEditingController(text: landlord.upfrontBonus?.toString() ?? '');

    final TextEditingController monthlyProfitController =
        TextEditingController(text: landlord.monthlyProfit?.toString() ?? '');

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
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return ListTile(
                      title: const Text('Select Dealers'),
                      subtitle: Text(
                        selectedDealers.length.toString() + ' dealers selected',
                      ),
                      onTap: () {
                        setState(() {
                          _showDealerSelectionDialog(() {
                            setState(() {
                              // Update the state of selectedDealers here
                              // print('selectedDealers: $selectedDealers');
                            });
                          });
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Visibility(
                //   visible: landlord.dealerRef != null,
                //   child: TextField(
                //     controller: dealerRefController,
                //     decoration: const InputDecoration(labelText: 'Dealer Ref'),
                //   ),
                // ),
                TextField(
                  controller: cnicController,
                  decoration: const InputDecoration(labelText: 'CNIC'),
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
                      const InputDecoration(labelText: 'Account Number'),
                ),
                TextField(
                  controller: ibanController,
                  decoration: const InputDecoration(labelText: 'IBAN'),
                ),
                TextField(
                  controller: contractStartDateController,
                  decoration:
                      const InputDecoration(labelText: 'Contract Start Date'),
                ),
                TextField(
                  controller: contractEndDateController,
                  decoration:
                      const InputDecoration(labelText: 'Contract End Date'),
                ),
                TextField(
                  controller: monthlyRentController,
                  decoration: const InputDecoration(labelText: 'Monthly Rent'),
                ),
                TextField(
                  controller: upfrontBonusController,
                  decoration: const InputDecoration(labelText: 'Upfront Bonus'),
                ),
                TextField(
                  controller: monthlyProfitController,
                  decoration:
                      const InputDecoration(labelText: 'Monthly Profit'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Update the landlord details in Firebase

                    print('landlord id is ${landlord.tempID}');

                    FirebaseFirestore.instance
                        .collection('Landlords')
                        .doc(landlord.tempID)
                        .set({
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'balance': double.tryParse(balanceController.text) ?? 0.0,
                      'propertyRef': selectedProperties,
                      'tenantRef': selectedTenants,
                      'rentpaymentRef': selectedRentPayments,
                      'dealerRef': selectedDealers,
                      'cnic': cnicController.text.isNotEmpty
                          ? encryptString(cnicController.text)
                          : FieldValue.delete(),
                      'bankName': bankNameController.text.isNotEmpty
                          ? encryptString(bankNameController.text)
                          : FieldValue.delete(),
                      'raastId': raastIdController.text.isNotEmpty
                          ? encryptString(raastIdController.text)
                          : FieldValue.delete(),
                      'accountNumber': accountNumberController.text.isNotEmpty
                          ? encryptString(accountNumberController.text)
                          : FieldValue.delete(),
                      'iban': ibanController.text.isNotEmpty
                          ? encryptString(ibanController.text)
                          : FieldValue.delete(),
                      'address': addressController.text.isNotEmpty
                          ? encryptString(addressController.text)
                          : FieldValue.delete(),
                      'contractStartDate':
                          contractStartDateController.text.isNotEmpty &&
                                  contractStartDateController.text != 'null'
                              ? contractStartDateController.text
                              : FieldValue.delete(),
                      'contractEndDate':
                          contractEndDateController.text.isNotEmpty &&
                                  contractEndDateController.text != 'null'
                              ? contractEndDateController.text
                              : FieldValue.delete(),
                      'monthlyRent': monthlyRentController.text.isNotEmpty
                          ? monthlyRentController.text ?? 0.0
                          : FieldValue.delete(),
                      'upfrontBonus': upfrontBonusController.text.isNotEmpty
                          ? upfrontBonusController.text ?? 0.0
                          : FieldValue.delete(),
                      'monthlyProfit': monthlyProfitController.text.isNotEmpty
                          ? monthlyProfitController.text ?? 0.0
                          : FieldValue.delete(),
                    }, SetOptions(merge: true)).then((_) async {
                      if (landlord.balance >
                          (double.tryParse(balanceController.text) ?? 0.0)) {
                        await FirebaseFirestore.instance
                            .collection('rentPayments')
                            .add({
                          'tenantname': 'Rehnaa App',
                          'LandlordRef': FirebaseFirestore.instance
                              .collection('Landlords')
                              .doc(landlord.tempID),
                          'amount': -(double.tryParse(balanceController.text) ??
                                  0.0) +
                              landlord.balance,
                          'date': DateTime.now(),
                          'isMinus': true,
                          // 'description': 'Balance updated by landlord',
                          'paymentType': '',
                        }).then((value) {
                          //add the rentpayment document reference to the tenant's
                          // rentpayment array
                          FirebaseFirestore.instance
                              .collection('Landlords')
                              .doc(landlord.tempID)
                              .update({
                            'rentpaymentRef': FieldValue.arrayUnion([value])
                          });

                          //send a notification to the Landlord

                          FirebaseFirestore.instance
                              .collection('Notifications')
                              .doc(landlord.tempID)
                              .update({
                            'notifications': FieldValue.arrayUnion([
                              {
                                // 'amount': data.requestedAmount,
                                'title': 'Balance updated by Rehnaa Team Admin',
                              }
                            ])
                          });
                        });
                      } else if (landlord.balance <
                          (double.tryParse(balanceController.text) ?? 0.0)) {
                        await FirebaseFirestore.instance
                            .collection('rentPayments')
                            .add({
                          'tenantname': 'Rehnaa App',
                          'LandlordRef': FirebaseFirestore.instance
                              .collection('Landlords')
                              .doc(landlord.tempID),
                          'amount': ((double.tryParse(balanceController.text) ??
                                  0.0) -
                              landlord.balance),
                          'date': DateTime.now(),
                          'isMinus': false,
                          // 'description': 'Balance updated by landlord',
                          'paymentType': '',
                        }).then((value) {
                          //add the rentpayment document reference to the tenant's
                          // rentpayment array
                          // print('reached hrere 222');
                          FirebaseFirestore.instance
                              .collection('Landlords')
                              .doc(landlord.tempID)
                              .update({
                            'rentpaymentRef': FieldValue.arrayUnion([value])
                          });

                          FirebaseFirestore.instance
                              .collection('Notifications')
                              .doc(landlord.tempID)
                              .update({
                            'notifications': FieldValue.arrayUnion([
                              {
                                // 'amount': data.requestedAmount,
                                'title': 'Balance updated by Rehnaa Team Admin',
                              }
                            ])
                          });
                        });
                      }

                      Fluttertoast.showToast(
                        msg: 'Landlord details updated successfully!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                      // Navigator.pop(context); // Close the edit dialog
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AdminLandlordInputPage();
                      }));
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
                      return Container(
                          padding: EdgeInsets.only(left: 150.0),
                          child: CircularProgressIndicator());
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
                      return Container(
                        padding: EdgeInsets.only(left: 150.0),
                        child: CircularProgressIndicator(),
                      );
                      // CircularProgressIndicator();
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
                      return Container(
                          padding: EdgeInsets.only(left: 150.0),
                          child: CircularProgressIndicator());
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

  void _showDealerSelectionDialog(void Function() onSelectionDone) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Dealers'),
              content: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Dealers')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          dealerDocs = snapshot.data!.docs;
                      return Column(
                        children: dealerDocs.map((dealerDoc) {
                          String dealerName = dealerDoc['firstName'] +
                              ' ' +
                              dealerDoc['lastName'];
                          bool isSelected =
                              selectedDealers.contains(dealerDoc.reference);
                          return CheckboxListTile(
                            title: Text(dealerName),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (!selectedDealers
                                      .contains(dealerDoc.reference)) {
                                    selectedDealers.add(dealerDoc.reference);
                                  }
                                } else {
                                  selectedDealers.remove(dealerDoc.reference);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    } else {
                      return Container(
                          padding: EdgeInsets.only(left: 150.0),
                          child: CircularProgressIndicator());
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
                      List.from(selectedDealers),
                    ); // Pass selected dealers back to the caller
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          },
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
                    trailing: landlord.isGhost != null && landlord.isGhost!
                        ? const Text('Ghost User')
                        : SizedBox(),
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
            buildFloatingActionButton(context),
          ],
        ),
      ),
    );
  }
}

Widget buildFloatingActionButton(BuildContext context) {
  return FloatingActionButton(
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
  );
}
