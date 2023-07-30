import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';
import 'package:flutter/services.dart'
    show LengthLimitingTextInputFormatter, rootBundle;
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
  // List<DocumentReference<Map<String, dynamic>>> selectedDealers = [];

  bool _isLoading = true;

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
      _isLoading = false;
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
                        'TenantRef: ${landlord.tenantRef != null && landlord.tenantRef!.isNotEmpty ? 'Yes' : 'No'}',

                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(
                        // if property ref exists show yes otherwise no

                        'PropertyRef: ${landlord.propertyRef != null && landlord.propertyRef.isNotEmpty ? 'Yes' : 'No'}',
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
                        'RentPaymentRef: ${landlord.rentpaymentRef != null && landlord.rentpaymentRef!.isNotEmpty ? 'Yes' : 'No'}',
                        // 'Rent Payment Ref: ${landlord.rentpaymentRef?.toString() ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(
                        'Address: ${landlord.address == '' ? 'No' : 'Yes'}',
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
                            child: SpinKitFadingCube(
                              color: Color.fromARGB(255, 30, 197, 83),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
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
        TextEditingController(text: landlord.balance.ceil().toString());
    selectedProperties = List.from(landlord.propertyRef ?? []);
    selectedTenants = List.from(landlord.tenantRef ?? []);
    selectedRentPayments = List.from(landlord.rentpaymentRef ?? []);
    // selectedDealers = List.from(landlord.dealerRef ?? []);

    final TextEditingController dealerRefController =
        TextEditingController(text: landlord.dealerRef?.toString() ?? '');
    final TextEditingController cnicController =
        TextEditingController(text: decryptString(landlord.cnic ?? '') ?? '');
    final TextEditingController bankNameController =
        TextEditingController(text: landlord.bankName ?? '');
    final TextEditingController raastIdController =
        TextEditingController(text: landlord.raastId ?? '');
    final TextEditingController accountNumberController =
        TextEditingController(text: landlord.accountNumber ?? '');
    final TextEditingController ibanController =
        TextEditingController(text: landlord.iban ?? '');
    final TextEditingController addressController = TextEditingController(
        text: landlord.address == '' ? '' : landlord.address!);

    // description
    final TextEditingController descriptionController =
        TextEditingController(text: landlord.description ?? '');

    // print('landlord address is ${landlord.address}');

    // final hashedCnic = encryptString(cnicController.text);
    // final hashedBankName = encryptString(bankNameController.text);
    // final hashedRaastId = encryptString(raastIdController.text);
    // final hashedAccountNumber = encryptString(accountNumberController.text);
    // final hashedIban = encryptString(ibanController.text);

    // final TextEditingController contractStartDateController =
    //     TextEditingController(
    //         text: landlord.contractStartDate?.toString() ?? '');
    // DateTime? contractStartDate = landlord.contractStartDate;
    // DateTime? contractEndDate = landlord.contractEndDate;

    // Future<void> _selectDate(bool isStartDate, StateSetter setState1) async {
    //   final DateTime? picked = await showDatePicker(
    //     context: context,
    //     initialDate: DateTime.now(),
    //     firstDate: DateTime(2020),
    //     lastDate: DateTime(2025),
    //   );

    //   if (picked != null) {
    //     setState1(() {
    //       if (isStartDate) {
    //         contractStartDate = picked;
    //       } else {
    //         contractEndDate = picked;
    //       }
    //     });
    //   }
    // }

    // ;
    // final TextEditingController monthlyRentController =
    //     TextEditingController(text: landlord.monthlyRent?.toString() ?? '');
    // final TextEditingController upfrontBonusController =
    //     TextEditingController(text: landlord.upfrontBonus?.toString() ?? '');

    // final TextEditingController monthlyProfitController =
    //     TextEditingController(text: landlord.monthlyProfit?.toString() ?? '');

    //securityDeposit
    final TextEditingController securityDepositController =
        TextEditingController(text: landlord.securityDeposit?.toString() ?? '');

    //creditScore
    final TextEditingController creditScoreController =
        TextEditingController(text: landlord.creditScore?.toString() ?? '');
    //creditPoints
    final TextEditingController creditPointsController =
        TextEditingController(text: landlord.creditPoints?.toString() ?? '');

    //phoneNumber
    final TextEditingController phoneNumberController =
        TextEditingController(text: landlord.phoneNumber?.toString() ?? '');

    //pastTenantTestimonial
    final TextEditingController pastTenantTestimonialController =
        TextEditingController(
            text: landlord.pastTenantTestimonial?.toString() ?? '');

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text('Edit Landlord Details'),
                      ),
                      TextFormField(
                        controller: firstNameController,
                        decoration:
                            const InputDecoration(labelText: 'First Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: lastNameController,
                        decoration:
                            const InputDecoration(labelText: 'Last Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
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
                            },
                          );
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
                      // StatefulBuilder(
                      //   builder: (BuildContext context, StateSetter setState) {
                      //     return ListTile(
                      //       title: const Text('Select Dealers'),
                      //       subtitle: Text(
                      //         selectedDealers.length.toString() +
                      //             ' dealers selected',
                      //       ),
                      //       onTap: () {
                      //         setState(() {
                      //           _showDealerSelectionDialog(() {
                      //             setState(() {
                      //               // Update the state of selectedDealers here
                      //               // print('selectedDealers: $selectedDealers');
                      //             });
                      //           });
                      //         });
                      //       },
                      //     );
                      //   },
                      // ),
                      const SizedBox(height: 20),
                      // Visibility(
                      //   visible: landlord.dealerRef != null,
                      //   child: TextFormField(
                      //     controller: dealerRefController,
                      //     decoration: const InputDecoration(labelText: 'Dealer Ref'),
                      //   ),
                      // ),
                      TextFormField(
                        controller: cnicController,
                        decoration: const InputDecoration(labelText: 'CNIC'),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                              13), // Restrict maximum length to 13
                          // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        validator: (value) {
                          //can be null if not has to be 13 digits
                          //check if value can be parsed
                          if (value != null &&
                              value.length != 13 &&
                              value != '') {
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid CNIC';
                            }
                            return 'please enter a valid CNIC';
                          }
                        },
                      ),
                      //description
                      TextFormField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                      TextFormField(
                        controller: bankNameController,
                        decoration:
                            const InputDecoration(labelText: 'Bank Name'),
                      ),
                      TextFormField(
                        controller: raastIdController,
                        decoration:
                            const InputDecoration(labelText: 'Raast ID'),
                      ),
                      TextFormField(
                        controller: accountNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Account Number'),
                      ),
                      TextFormField(
                        controller: ibanController,
                        decoration: const InputDecoration(labelText: 'IBAN'),
                      ),
                      // StatefulBuilder(builder: (context, setState) {
                      //   return TextButton(
                      //     onPressed: () => _selectDate(true, setState),
                      //     child: Text(
                      //       contractStartDate != null
                      //           ? 'Contract Start Date: ${contractStartDate.toString()}'
                      //           : 'Select Contract Start Date',
                      //     ),
                      //   );
                      // }),
                      // StatefulBuilder(builder: (context, setState) {
                      //   return TextButton(
                      //     onPressed: () => _selectDate(false, setState),
                      //     child: Text(
                      //       contractEndDate != null
                      //           ? 'Contract End Date: ${contractEndDate.toString()}'
                      //           : 'Select Contract End Date',
                      //     ),
                      //   );
                      // }),
                      // TextFormField(
                      //   controller: monthlyRentController,
                      //   decoration:
                      //       const InputDecoration(labelText: 'Monthly Rent'),
                      //   validator: (value) {
                      //     //check if value can be parsed
                      //     if (value != null &&
                      //         int.tryParse(value) == null &&
                      //         value != '') {
                      //       return 'Please enter a valid monthly rent';
                      //     }
                      //   },
                      // ),
                      // TextFormField(
                      //     controller: upfrontBonusController,
                      //     decoration:
                      //         const InputDecoration(labelText: 'Upfront Bonus'),
                      //     validator: (value) {
                      //       //check if value can be parsed
                      //       if (value != null &&
                      //           int.tryParse(value) == null &&
                      //           value != '') {
                      //         return 'Please enter a valid upfront bonus';
                      //       }
                      //     }),
                      // TextFormField(
                      //     controller: monthlyProfitController,
                      //     decoration: const InputDecoration(
                      //         labelText: 'Monthly Profit'),
                      //     validator: (value) {
                      //       //check if value can be parsed
                      //       if (value != null &&
                      //           int.tryParse(value) == null &&
                      //           value != '') {
                      //         return 'Please enter a valid monthly profit';
                      //       }
                      //     }),
                      TextFormField(
                          controller: securityDepositController,
                          decoration: const InputDecoration(
                              labelText: 'Security Deposit'),
                          validator: (value) {
                            //check if value can be parsed
                            if (value != null &&
                                int.tryParse(value) == null &&
                                value != '') {
                              return 'Please enter a valid security deposit';
                            }
                          }),
                      TextFormField(
                        controller: creditScoreController,
                        decoration:
                            const InputDecoration(labelText: 'Credit Score'),
                        validator: (value) {
                          //check if value can be parsed
                          if (value != null &&
                              int.tryParse(value) == null &&
                              value != '') {
                            return 'Please enter valid credit score';
                          }

                          // return '';
                        },
                      ),
                      TextFormField(
                        controller: creditPointsController,
                        decoration:
                            const InputDecoration(labelText: 'Credit Points'),
                        validator: (value) {
                          //check if value can be parsed
                          if (value != null &&
                              int.tryParse(value) == null &&
                              value != '') {
                            return 'Please enter valid credit points';
                          }
                          // if (value != null && int.tryParse(value)! > 10) {
                          //   return 'Please enter valid credit points';
                          // }
                          // return '';
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: phoneNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Phone Number'),
                        validator: (value) {
                          //check if value can be parsed
                          if (value != null &&
                              int.tryParse(value) == null &&
                              value != '') {
                            return 'Please enter valid phone number';
                          }
                          // return '';
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: pastTenantTestimonialController,
                        decoration: const InputDecoration(
                            labelText: 'Past Tenant Testimonial'),
                      ),

                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            // Form is valid, proceed with saving data

                            var package = {
                              'firstName': firstNameController.text,
                              'lastName': lastNameController.text,
                              'balance':
                                  double.tryParse(balanceController.text) ??
                                      0.0,
                              'propertyRef': selectedProperties,
                              'tenantRef': selectedTenants,
                              'rentpaymentRef': selectedRentPayments,
                              // 'dealerRef': selectedDealers,
                              'cnic': cnicController.text.isNotEmpty
                                  ? encryptString(cnicController.text)
                                  : FieldValue.delete(),
                              'bankName': bankNameController.text.isNotEmpty
                                  ? encryptString(bankNameController.text)
                                  : FieldValue.delete(),
                              'raastId': raastIdController.text.isNotEmpty
                                  ? encryptString(raastIdController.text)
                                  : FieldValue.delete(),
                              'accountNumber': accountNumberController
                                      .text.isNotEmpty
                                  ? encryptString(accountNumberController.text)
                                  : FieldValue.delete(),
                              'iban': ibanController.text.isNotEmpty
                                  ? encryptString(ibanController.text)
                                  : FieldValue.delete(),
                              'address': addressController.text.isNotEmpty
                                  ? addressController.text
                                  : FieldValue.delete(),
                              // if (contractStartDate != null)
                              //   'contractStartDate':
                              //       Timestamp.fromDate(contractStartDate!),
                              // if (contractEndDate != null)
                              //   'contractEndDate':
                              //       Timestamp.fromDate(contractEndDate!),
                              // 'monthlyRent':
                              //     monthlyRentController.text.isNotEmpty
                              //         ? monthlyRentController.text ?? 0.0
                              //         : FieldValue.delete(),
                              // 'upfrontBonus':
                              //     upfrontBonusController.text.isNotEmpty
                              //         ? upfrontBonusController.text ?? 0.0
                              //         : FieldValue.delete(),
                              // 'monthlyProfit':
                              //     monthlyProfitController.text.isNotEmpty
                              //         ? monthlyProfitController.text ?? 0.0
                              //         : FieldValue.delete(),
                              'securityDeposit': securityDepositController
                                          .text.isNotEmpty &&
                                      securityDepositController.text != 'null'
                                  ? securityDepositController.text
                                  : FieldValue.delete(),
                              'creditScore':
                                  creditScoreController.text.isNotEmpty &&
                                          creditScoreController.text != 'null'
                                      ? creditScoreController.text
                                      : FieldValue.delete(),
                              'creditPoints':
                                  creditPointsController.text.isNotEmpty &&
                                          creditPointsController.text != 'null'
                                      ? creditPointsController.text
                                      : FieldValue.delete(),
                              'phoneNumber':
                                  phoneNumberController.text.isNotEmpty &&
                                          phoneNumberController.text != 'null'
                                      ? phoneNumberController.text
                                      : FieldValue.delete(),
                              'pastTenantTestimonial':
                                  pastTenantTestimonialController
                                              .text.isNotEmpty &&
                                          pastTenantTestimonialController
                                                  .text !=
                                              'null'
                                      ? pastTenantTestimonialController.text
                                      : FieldValue.delete(),
                              'description': descriptionController.text != ''
                                  ? descriptionController.text
                                  : FieldValue.delete(),
                            };

                            //create a checkpackage that discludes all the document references.
                            var checkpackage = {
                              'firstName': firstNameController.text,
                              'lastName': lastNameController.text,
                              'balance':
                                  double.tryParse(balanceController.text) ??
                                      0.0,
                              'cnic': cnicController.text.isNotEmpty
                                  ? cnicController.text
                                  : 'empty',
                              'bankName': bankNameController.text.isNotEmpty
                                  ? bankNameController.text
                                  : 'empty',
                              'raastId': raastIdController.text.isNotEmpty
                                  ? raastIdController.text
                                  : 'empty',
                              'accountNumber':
                                  accountNumberController.text.isNotEmpty
                                      ? accountNumberController.text
                                      : 'empty',
                              'iban': ibanController.text.isNotEmpty
                                  ? ibanController.text
                                  : 'empty',
                              'address': addressController.text.isNotEmpty
                                  ? addressController.text
                                  : 'empty',
                              // if (contractStartDate != null)
                              //   'contractStartDate':
                              //       Timestamp.fromDate(contractStartDate!),
                              // if (contractEndDate != null)
                              //   'contractEndDate':
                              //       Timestamp.fromDate(contractEndDate!),
                              // 'monthlyRent':
                              //     monthlyRentController.text.isNotEmpty
                              //         ? monthlyRentController.text ?? 0.0
                              //         : 'empty',
                              // 'upfrontBonus':
                              //     upfrontBonusController.text.isNotEmpty
                              //         ? upfrontBonusController.text ?? 0.0
                              //         : 'empty',
                              // 'monthlyProfit':
                              //     monthlyProfitController.text.isNotEmpty
                              //         ? monthlyProfitController.text ?? 0.0
                              //         : 'empty',
                              'securityDeposit': securityDepositController
                                          .text.isNotEmpty &&
                                      securityDepositController.text != 'null'
                                  ? securityDepositController.text
                                  : 'empty',
                              'creditScore':
                                  creditScoreController.text.isNotEmpty &&
                                          creditScoreController.text != 'null'
                                      ? creditScoreController.text
                                      : 'empty',
                              'creditPoints':
                                  creditPointsController.text.isNotEmpty &&
                                          creditPointsController.text != 'null'
                                      ? creditPointsController.text
                                      : 'empty',
                              'phoneNumber':
                                  phoneNumberController.text.isNotEmpty &&
                                          phoneNumberController.text != 'null'
                                      ? phoneNumberController.text
                                      : 'empty',
                              'pastTenantTestimonial':
                                  pastTenantTestimonialController
                                              .text.isNotEmpty &&
                                          pastTenantTestimonialController
                                                  .text !=
                                              'null'
                                      ? pastTenantTestimonialController.text
                                      : 'empty',
                              'description': descriptionController.text != ''
                                  ? descriptionController.text
                                  : 'empty',
                            };

                            // Show contents of package in a dialog and ask if you are sure about this
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          children:
                                              checkpackage.keys.map((key) {
                                            return ListTile(
                                              title: Text(key),
                                              subtitle: Text(
                                                  checkpackage[key].toString()),
                                            );
                                          }).toList(),
                                        ),
                                        ButtonBar(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                // Continue with the code
                                                print('User confirmed');
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const Center(
                                                      child: SpinKitFadingCube(
                                                        color: Color.fromARGB(
                                                            255, 30, 197, 83),
                                                      ),
                                                    );
                                                  },
                                                );

                                                // Your save logic goes here
                                                await FirebaseFirestore.instance
                                                    .collection('Landlords')
                                                    .doc(landlord.tempID)
                                                    .update(package);

                                                // if (selectedDealers
                                                //     .isNotEmpty) {
                                                //   selectedDealers
                                                //       .forEach((element) {
                                                //     element.set({
                                                //       'landlordRef': FieldValue
                                                //           .arrayUnion([
                                                //         FirebaseFirestore
                                                //             .instance
                                                //             .collection(
                                                //                 'Landlords')
                                                //             .doc(
                                                //                 landlord.tempID)
                                                //       ])
                                                //     }, SetOptions(merge: true));
                                                //   });
                                                // }

                                                if (landlord.balance >
                                                    (double.tryParse(
                                                            balanceController
                                                                .text) ??
                                                        0.0)) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'rentPayments')
                                                      .add({
                                                    'tenantname': 'Rehnaa.pk',
                                                    'tenantRef':
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Landlords')
                                                            .doc(landlord
                                                                .tempID),
                                                    'amount': -(double.tryParse(
                                                                balanceController
                                                                    .text) ??
                                                            0.0) +
                                                        (landlord.balance),
                                                    'date': DateTime.now(),
                                                    'isMinus': true,
                                                    'paymentType': '',
                                                    // 'description': 'Balance updated by landlord',
                                                    // 'paymentType': 'Bank Transfer',
                                                  }).then((value) {
                                                    //add the rentpayment document reference to the tenant's
                                                    // rentpayment array
                                                    FirebaseFirestore.instance
                                                        .collection('Landlords')
                                                        .doc(landlord.tempID)
                                                        .update({
                                                      'rentpaymentRef':
                                                          FieldValue.arrayUnion(
                                                              [value])
                                                    });

                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'Notifications')
                                                        .doc(landlord.tempID)
                                                        .update({
                                                      'notifications':
                                                          FieldValue
                                                              .arrayUnion([
                                                        {
                                                          // 'amount': data.requestedAmount,
                                                          'title':
                                                              'Your account has been debited by Rs${-(double.tryParse(balanceController.text) ?? 0.0) + (landlord.balance)}',
                                                        }
                                                      ])
                                                    });
                                                  });
                                                } else if (landlord.balance <
                                                    (double.tryParse(
                                                            balanceController
                                                                .text) ??
                                                        0.0)) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'rentPayments')
                                                      .add({
                                                    'tenantname': 'Rehnaa.pk',
                                                    'tenantRef':
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Landlords')
                                                            .doc(landlord
                                                                .tempID),
                                                    'amount': ((double.tryParse(
                                                                balanceController
                                                                    .text) ??
                                                            0.0) -
                                                        landlord.balance),
                                                    'date': DateTime.now(),
                                                    'isMinus': false,
                                                    // 'description': 'Balance updated by landlord',
                                                    'paymentType': '',
                                                  }).then((value) async {
                                                    //add the rentpayment document reference to the tenant's
                                                    // rentpayment array
                                                    FirebaseFirestore.instance
                                                        .collection('Landlords')
                                                        .doc(landlord.tempID)
                                                        .update({
                                                      'rentpaymentRef':
                                                          FieldValue.arrayUnion(
                                                              [value])
                                                    });

                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'Notifications')
                                                        .doc(landlord.tempID)
                                                        .set({
                                                      'notifications':
                                                          FieldValue
                                                              .arrayUnion([
                                                        {
                                                          // 'amount': data.requestedAmount,
                                                          'title':
                                                              'Your account has been credited by Rs${((double.tryParse(balanceController.text) ?? 0.0) - landlord.balance)}'
                                                        }
                                                      ])
                                                    }, SetOptions(merge: true));
                                                  });
                                                }

                                                setState(() {
                                                  landlord.balance =
                                                      double.tryParse(
                                                              balanceController
                                                                  .text) ??
                                                          0.0;
                                                  landlord.firstName =
                                                      firstNameController.text;
                                                  landlord.lastName =
                                                      lastNameController.text;
                                                  landlord.propertyRef =
                                                      selectedProperties;
                                                  landlord.tenantRef =
                                                      selectedTenants;
                                                  landlord.rentpaymentRef =
                                                      selectedRentPayments;
                                                  // landlord.dealerRef =
                                                  //     selectedDealers;
                                                  landlord.cnic = cnicController
                                                          .text.isNotEmpty
                                                      ? encryptString(
                                                          cnicController.text)
                                                      : '';
                                                  landlord.bankName =
                                                      bankNameController
                                                              .text.isNotEmpty
                                                          ? encryptString(
                                                              bankNameController
                                                                  .text)
                                                          : '';
                                                  landlord.raastId =
                                                      raastIdController
                                                              .text.isNotEmpty
                                                          ? encryptString(
                                                              raastIdController
                                                                  .text)
                                                          : '';
                                                  landlord.accountNumber =
                                                      accountNumberController
                                                              .text.isNotEmpty
                                                          ? encryptString(
                                                              accountNumberController
                                                                  .text)
                                                          : '';
                                                  landlord.iban = ibanController
                                                          .text.isNotEmpty
                                                      ? encryptString(
                                                          ibanController.text)
                                                      : '';
                                                  landlord.address =
                                                      addressController
                                                              .text.isNotEmpty
                                                          ? addressController
                                                              .text
                                                          : '';
                                                  // landlord.contractStartDate =
                                                  //     contractStartDate;
                                                  // landlord.contractEndDate =
                                                  //     contractEndDate;
                                                  landlord.description =
                                                      descriptionController
                                                                  .text !=
                                                              ''
                                                          ? descriptionController
                                                              .text
                                                          : '';
                                                  // landlord.monthlyRent =
                                                  //     monthlyRentController
                                                  //             .text.isNotEmpty
                                                  //         ? monthlyRentController
                                                  //                 .text ??
                                                  //             0.0
                                                  //         : 0.0;
                                                  // landlord.upfrontBonus =
                                                  //     upfrontBonusController
                                                  //             .text.isNotEmpty
                                                  //         ? upfrontBonusController
                                                  //                 .text ??
                                                  //             0.0
                                                  //         : 0.0;
                                                  // landlord.monthlyProfit =
                                                  //     monthlyProfitController
                                                  //             .text.isNotEmpty
                                                  //         ? monthlyProfitController
                                                  //                 .text ??
                                                  //             0.0
                                                  //         : 0.0;
                                                  landlord.securityDeposit =
                                                      securityDepositController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              securityDepositController
                                                                      .text !=
                                                                  'null'
                                                          ? securityDepositController
                                                              .text
                                                          : '';
                                                  landlord.creditScore =
                                                      creditScoreController.text
                                                                  .isNotEmpty &&
                                                              creditScoreController
                                                                      .text !=
                                                                  'null'
                                                          ? creditScoreController
                                                              .text
                                                          : '';
                                                  landlord.creditPoints =
                                                      creditPointsController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              creditPointsController
                                                                      .text !=
                                                                  'null'
                                                          ? creditPointsController
                                                              .text
                                                          : '';
                                                  landlord.phoneNumber =
                                                      phoneNumberController.text
                                                                  .isNotEmpty &&
                                                              phoneNumberController
                                                                      .text !=
                                                                  'null'
                                                          ? phoneNumberController
                                                              .text
                                                          : '';
                                                  landlord.pastTenantTestimonial =
                                                      pastTenantTestimonialController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              pastTenantTestimonialController
                                                                      .text !=
                                                                  'null'
                                                          ? pastTenantTestimonialController
                                                              .text
                                                          : '';
                                                });

                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();

                                                //snackbar
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Landlord Updated Successfully",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              },
                                              child: Text('Yes'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                // Do nothing and close the dialog
                                                print('User canceled');
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                              child: Text('No'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPropertySelectionDialog(void Function() onSelectionDone) {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Properties'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('Properties')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              propertyDocs = snapshot.data!.docs;

                          propertyDocs = propertyDocs.where((propertyDoc) {
                            String propertyName = propertyDoc['title'];
                            return propertyName
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase());
                          }).toList();

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
                            child: SpinKitFadingCube(
                              color: Color.fromARGB(255, 30, 197, 83),
                            ),
                          );
                        }
                      },
                    ),
                  ],
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

// Implementing search functionality for Tenant and RentPayment selection dialogs will follow a similar pattern.

  void _showTenantSelectionDialog(void Function() onSelectionDone) {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Tenants'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('Tenants')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              tenantDocs = snapshot.data!.docs;

                          tenantDocs = tenantDocs.where((tenantDoc) {
                            String tenantName = tenantDoc['firstName'] +
                                ' ' +
                                tenantDoc['lastName'];
                            return tenantName
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase());
                          }).toList();

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
                                        selectedTenants
                                            .add(tenantDoc.reference);
                                      }
                                    } else {
                                      selectedTenants
                                          .remove(tenantDoc.reference);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        } else {
                          return Container(
                            padding: EdgeInsets.only(left: 150.0),
                            child: SpinKitFadingCube(
                              color: Color.fromARGB(255, 30, 197, 83),
                            ),
                          );
                        }
                      },
                    ),
                  ],
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
                      List.from(selectedTenants),
                    ); // Pass selected tenants back to the caller
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
                        child: SpinKitFadingCube(
                          color: Color.fromARGB(255, 30, 197, 83),
                        ),
                      );
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

  // void _showDealerSelectionDialog(void Function() onSelectionDone) {
  //   TextEditingController searchController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: const Text('Select Dealers'),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 children: [
  //                   TextFormField(
  //                     controller: searchController,
  //                     decoration: InputDecoration(
  //                       labelText: 'Search',
  //                       prefixIcon: Icon(Icons.search),
  //                     ),
  //                     onChanged: (value) {
  //                       setState(() {}); // Refresh the UI
  //                     },
  //                   ),
  //                   StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  //                     stream: FirebaseFirestore.instance
  //                         .collection('Dealers')
  //                         .snapshots(),
  //                     builder: (context, snapshot) {
  //                       if (snapshot.hasData) {
  //                         List<QueryDocumentSnapshot<Map<String, dynamic>>>
  //                             dealerDocs = snapshot.data!.docs;

  //                         // Filter the dealerDocs list based on the search text
  //                         dealerDocs = dealerDocs.where((dealerDoc) {
  //                           String dealerName = dealerDoc['firstName'] +
  //                               ' ' +
  //                               dealerDoc['lastName'];
  //                           return dealerName
  //                               .toLowerCase()
  //                               .contains(searchController.text.toLowerCase());
  //                         }).toList();

  //                         return Column(
  //                           children: dealerDocs.map((dealerDoc) {
  //                             String dealerName = dealerDoc['firstName'] +
  //                                 ' ' +
  //                                 dealerDoc['lastName'];
  //                             bool isSelected =
  //                                 selectedDealers.contains(dealerDoc.reference);
  //                             return CheckboxListTile(
  //                               title: Text(dealerName),
  //                               value: isSelected,
  //                               onChanged: (value) {
  //                                 setState(() {
  //                                   if (value == true) {
  //                                     if (!selectedDealers
  //                                         .contains(dealerDoc.reference)) {
  //                                       selectedDealers
  //                                           .add(dealerDoc.reference);
  //                                     }
  //                                   } else {
  //                                     selectedDealers
  //                                         .remove(dealerDoc.reference);
  //                                   }
  //                                 });
  //                               },
  //                             );
  //                           }).toList(),
  //                         );
  //                       } else {
  //                         return Container(
  //                           padding: EdgeInsets.only(left: 150.0),
  //                           child: SpinKitFadingCube(
  //                             color: Color.fromARGB(255, 30, 197, 83),
  //                           ),
  //                         );
  //                       }
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context); // Close the dialog
  //                 },
  //                 child: const Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   onSelectionDone();

  //                   Navigator.pop(
  //                     context,
  //                     List.from(selectedDealers),
  //                   ); // Pass selected dealers back to the caller
  //                 },
  //                 child: const Text('Done'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

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
            _isLoading
                ? const SpinKitFadingCube(
                    color: Color.fromARGB(255, 30, 197, 83),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: getPaginatedLandlords().length,
                      itemBuilder: (context, index) {
                        Landlord landlord = getPaginatedLandlords()[index];

                        return ListTile(
                          title: Text(
                              '${landlord.firstName} ${landlord.lastName}'),
                          subtitle: Text(landlord.balance.ceil().toString()),
                          leading: const Icon(Icons.person),
                          trailing:
                              landlord.isGhost != null && landlord.isGhost!
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
  return Material(
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28.0),
    ),
    child: InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: LandlordCardWidget(),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(28.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
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
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    ),
  );
}
