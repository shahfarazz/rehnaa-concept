import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show LengthLimitingTextInputFormatter, rootBundle;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';
import 'package:rehnaa/frontend/Screens/Admin/admindashboard.dart';

import '../../../backend/models/landlordmodel.dart';
import '../../../backend/models/propertymodel.dart';
import '../../../backend/models/tenantsmodel.dart';
import 'admin_landlordinputhelper.dart';
import 'admin_tenantinputhelper.dart';

class AdminTenantsInputPage extends StatefulWidget {
  @override
  _AdminTenantsInputPageState createState() => _AdminTenantsInputPageState();
}

class _AdminTenantsInputPageState extends State<AdminTenantsInputPage> {
  List<Tenant> tenants = [];
  List<Tenant> filteredTenants = [];
  TextEditingController searchController = TextEditingController();
  int currentPage = 1;
  int itemsPerPage = 10;
  // DocumentReference<Map<String, dynamic>>? landlordRef;
  // List<DocumentReference<Map<String, dynamic>>> selectedLandlords = [];
  List<DocumentReference<Map<String, dynamic>>> selectedLandlordRefs = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTenants();
  }

  Future<void> fetchTenants() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Tenants').get();

    List<Tenant> tenantList = [];

    for (var doc in querySnapshot.docs) {
      Tenant tenant = Tenant.fromJson(doc.data());
      tenant.tempID = doc.id;
      tenantList.add(tenant);
    }

    setState(() {
      tenants = tenantList;
      filteredTenants = List.from(tenants);
      _isLoading = false;
    });
  }

  void filterTenants(String query) {
    List<Tenant> tempList = [];
    if (query.isNotEmpty) {
      tempList = tenants.where((tenant) {
        return tenant.firstName.toLowerCase().contains(query.toLowerCase()) ||
            tenant.lastName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      tempList = List.from(tenants);
    }
    setState(() {
      filteredTenants = tempList;
    });
  }

  List<Tenant> getPaginatedTenants() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (endIndex >= filteredTenants.length) {
      return filteredTenants.sublist(startIndex);
    } else {
      return filteredTenants.sublist(startIndex, endIndex);
    }
  }

  Future<void> openTenantDetailsDialog(Tenant tenant) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    '${tenant.firstName} ${tenant.lastName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Rent: \$${tenant.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    'Description: ${tenant.description}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: Text(
                    'Rating: ${tenant.rating.toStringAsFixed(1)}',
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
                  height: 200.0, // Adjust this value according to your needs.
                  child: CachedNetworkImage(
                    imageUrl: tenant.pathToImage ?? '',
                    errorWidget: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return CircularProgressIndicator(
                        value: downloadProgress.progress,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(Tenant tenant) {
    final TextEditingController firstNameController =
        TextEditingController(text: tenant.firstName);
    final TextEditingController lastNameController =
        TextEditingController(text: tenant.lastName);
    final TextEditingController descriptionController =
        TextEditingController(text: tenant.description);
    final TextEditingController rentController =
        TextEditingController(text: tenant.balance.toString());
    final TextEditingController creditPointsController =
        TextEditingController(text: tenant.creditPoints.toString());
    final TextEditingController cnicNumberController =
        TextEditingController(text: decryptString(tenant.cnic ?? ''));
    final TextEditingController emailOrPhoneController =
        TextEditingController(text: tenant.emailOrPhone);
    final TextEditingController familyMembersController =
        TextEditingController(text: tenant.familyMembers.toString());
    final TextEditingController ratingController =
        TextEditingController(text: tenant.rating.toString());
    bool tasdeeqVerification = tenant.tasdeeqVerification ?? false;
    bool policeVerification = tenant.policeVerification ?? false;
    final TextEditingController addressController =
        TextEditingController(text: tenant.address ?? '');

    //phoneNumber
    final TextEditingController phoneNumberController =
        TextEditingController(text: tenant.phoneNumber ?? '');
    //pastLandlordTestimonial
    final TextEditingController pastLandlordTestimonialController =
        TextEditingController(text: tenant.pastLandlordTestimonial ?? '');

    DateTime? contractStartDate = tenant.contractStartDate;
    DateTime? contractEndDate = tenant.contractEndDate;

    Future<void> _selectDate(bool isStartDate, StateSetter setState1) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2025),
      );

      if (picked != null) {
        setState1(() {
          if (isStartDate) {
            contractStartDate = picked;
          } else {
            contractEndDate = picked;
          }
        });
      }
    }

    //propertyAddress
    final TextEditingController propertyAddressController =
        TextEditingController(text: tenant.propertyAddress ?? '');
    // monthlyRent
    final TextEditingController monthlyRentController =
        TextEditingController(text: tenant.monthlyRent.toString());

    //securityDeposit
    final TextEditingController securityDepositController =
        TextEditingController(text: tenant.securityDeposit.toString());

    //creditScore
    final TextEditingController creditScoreController =
        TextEditingController(text: tenant.creditScore.toString());

    //otherInfo
    final TextEditingController otherInfoController =
        TextEditingController(text: tenant.otherInfo.toString());

    final hashedCnic = encryptString(cnicNumberController.text);
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text('Edit Tenant Details'),
                  ),
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: rentController,
                    decoration: const InputDecoration(labelText: 'Balance'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: creditPointsController,
                    decoration:
                        const InputDecoration(labelText: 'Credit Points'),
                    keyboardType: TextInputType.number,
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
                  TextFormField(
                    controller: cnicNumberController,
                    decoration: const InputDecoration(labelText: 'CNIC Number'),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          13), // Restrict maximum length to 13
                      // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (value) {
                      //can be null if not has to be 13 digits
                      //check if value can be parsed
                      if (value != null && value.length != 13 && value != '') {
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid CNIC';
                        }
                        return 'please enter a valid CNIC';
                      }
                    },
                  ),
                  TextFormField(
                    controller: emailOrPhoneController,
                    decoration:
                        const InputDecoration(labelText: 'Email or Phone'),
                  ),
                  TextFormField(
                    controller: familyMembersController,
                    decoration:
                        const InputDecoration(labelText: 'Family Members'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: ratingController,
                    decoration: const InputDecoration(labelText: 'Rating'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  StatefulBuilder(builder: (context, setState) {
                    return TextButton(
                      onPressed: () => _selectDate(true, setState),
                      child: Text(
                        contractStartDate != null
                            ? 'Contract Start Date: ${contractStartDate.toString()}'
                            : 'Select Contract Start Date',
                      ),
                    );
                  }),
                  StatefulBuilder(builder: (context, setState) {
                    return TextButton(
                      onPressed: () => _selectDate(false, setState),
                      child: Text(
                        contractEndDate != null
                            ? 'Contract End Date: ${contractEndDate.toString()}'
                            : 'Select Contract End Date',
                      ),
                    );
                  }),
                  TextFormField(
                    controller: propertyAddressController,
                    decoration:
                        const InputDecoration(labelText: 'Property Address'),
                  ),
                  TextFormField(
                    controller: monthlyRentController,
                    decoration:
                        const InputDecoration(labelText: 'Monthly Rent'),
                    validator: (value) {
                      //check if value can be parsed
                      if (value != null &&
                          int.tryParse(value) == null &&
                          value != '') {
                        return 'Please enter a valid monthly rent';
                      }
                    },
                  ),
                  TextFormField(
                    controller: otherInfoController,
                    decoration:
                        const InputDecoration(labelText: 'Other Information'),
                  ),
                  TextFormField(
                    controller: securityDepositController,
                    decoration:
                        const InputDecoration(labelText: 'Security Deposit'),
                    validator: (value) {
                      //check if value can be parsed
                      if (value != null &&
                          int.tryParse(value) == null &&
                          value != '') {
                        return 'Please enter a valid security deposit';
                      }
                    },
                  ),
                  TextFormField(
                    controller: creditScoreController,
                    decoration:
                        const InputDecoration(labelText: 'Credit Score'),
                    validator: (value) {
                      //check if value can be parsed
                      if (value != null &&
                          int.tryParse(value) == null &&
                          value != '') {
                        return 'Please enter a valid credit score';
                      }
                    },
                  ),
                  TextFormField(
                      controller: phoneNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                      validator: (value) {
                        //check if value can be parsed
                        if (value != null &&
                            int.tryParse(value) == null &&
                            value != '') {
                          return 'Please enter a valid phone number';
                        }
                      }),
                  TextFormField(
                    controller: pastLandlordTestimonialController,
                    decoration: const InputDecoration(
                        labelText: 'Past Landlord Testimonial'),
                  ),
                  // Field to ask for bool value from user for police verification
                  // Give options yes / no
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return CheckboxListTile(
                        title: const Text('Police Verification'),
                        value: policeVerification,
                        onChanged: (bool? value) {
                          setState(() {
                            policeVerification = value ?? false;
                          });
                        },
                      );
                    },
                  ),
                  // Field to ask for bool value from user for tasdeeq verification
                  // Give options yes / no
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return CheckboxListTile(
                        title: const Text('Tasdeeq Verification'),
                        value: tasdeeqVerification,
                        onChanged: (bool? value) {
                          setState(() {
                            tasdeeqVerification = value ?? false;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return ListTile(
                        title: const Text('Select Landlords'),
                        subtitle: Text(
                          selectedLandlordRefs.length.toString() +
                              ' landlords selected',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _showLandlordSelectionDialog(tenant, () {
                              setState(() {
                                // Update the tenant's landlordRef directly
                                // tenant.landlordRef = landlordRef;
                                // tenant.landlordRefs = selectedLandlordRefs;
                              });
                            });
                          });
                        },
                      );
                    },
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Update the tenant details in Firebase

                        //if the balance has been updated we need to create a rentPayments
                        // document and set tenantname to "Rehnaa App"
                        // and tenantRef to the tenant's tempID's document reference

                        var package = {
                          'firstName': firstNameController.text,
                          'lastName': lastNameController.text,
                          'description': descriptionController.text,
                          'balance':
                              double.tryParse(rentController.text) ?? 0.0,
                          'creditPoints':
                              int.tryParse(creditPointsController.text) ?? 0,
                          'cnic': cnicNumberController.text.isNotEmpty
                              ? encryptString(cnicNumberController.text)
                              : '',
                          'emailOrPhone': emailOrPhoneController.text,
                          'familyMembers':
                              int.tryParse(familyMembersController.text) ?? 0,
                          'rating':
                              double.tryParse(ratingController.text) ?? 0.0,
                          'landlordRef': selectedLandlordRefs,
                          'propertyAddress': propertyAddressController.text,
                          'address': addressController.text,
                          if (contractStartDate != null)
                            'contractStartDate':
                                Timestamp.fromDate(contractStartDate!),
                          if (contractEndDate != null)
                            'contractEndDate':
                                Timestamp.fromDate(contractEndDate!),
                          'monthlyRent': monthlyRentController.text ?? '',
                          'policeVerification': policeVerification,
                          'tasdeeqVerification': tasdeeqVerification,
                          'securityDeposit':
                              securityDepositController.text ?? '',
                          'creditScore': creditScoreController.text ?? '',
                          'otherInfo': otherInfoController.text ?? '',
                          'phoneNumber': phoneNumberController.text ?? '',
                          'pastLandlordTestimonial':
                              pastLandlordTestimonialController.text ?? '',
                        };

                        //create a checkpackage that discludes all the document references.
                        var checkpackage = {
                          'firstName': firstNameController.text,
                          'lastName': lastNameController.text,
                          'balance':
                              double.tryParse(rentController.text) ?? 0.0,
                          'cnic': cnicNumberController.text.isNotEmpty
                              ? cnicNumberController.text
                              : 'empty',
                          'address': addressController.text.isNotEmpty
                              ? addressController.text
                              : 'empty',
                          if (contractStartDate != null)
                            'contractStartDate':
                                Timestamp.fromDate(contractStartDate!),
                          if (contractEndDate != null)
                            'contractEndDate':
                                Timestamp.fromDate(contractEndDate!),
                          'monthlyRent': monthlyRentController.text.isNotEmpty
                              ? monthlyRentController.text ?? 0.0
                              : 'empty',
                          'securityDeposit':
                              securityDepositController.text.isNotEmpty &&
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
                          'otherInfo': otherInfoController.text.isNotEmpty &&
                                  otherInfoController.text != 'null'
                              ? otherInfoController.text
                              : 'empty',
                          'phoneNumber': phoneNumberController.text.isNotEmpty
                              ? phoneNumberController.text
                              : 'empty',
                          'pastLandlordTestimonial':
                              pastLandlordTestimonialController.text.isNotEmpty
                                  ? pastLandlordTestimonialController.text
                                  : 'empty',
                        };

                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      children: checkpackage.keys.map((key) {
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
                                            // print('User confirmed');
                                            //showdialog with a circular progress indicator
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

                                            await FirebaseFirestore.instance
                                                .collection('Tenants')
                                                .doc(tenant.tempID)
                                                .update(package);

                                            if (tenant.balance >
                                                (double.tryParse(
                                                        rentController.text) ??
                                                    0.0)) {
                                              await FirebaseFirestore.instance
                                                  .collection('rentPayments')
                                                  .add({
                                                'tenantname': 'Rehnaa.pk',
                                                'tenantRef': FirebaseFirestore
                                                    .instance
                                                    .collection('Tenants')
                                                    .doc(tenant.tempID),
                                                'amount': -(double.tryParse(
                                                            rentController
                                                                .text) ??
                                                        0.0) +
                                                    (tenant.balance),
                                                'date': DateTime.now(),
                                                'isMinus': false,
                                                'paymentType': '',
                                                // 'description': 'Balance updated by landlord',
                                                // 'paymentType': 'Bank Transfer',
                                              }).then((value) {
                                                //add the rentpayment document reference to the tenant's
                                                // rentpayment array
                                                FirebaseFirestore.instance
                                                    .collection('Tenants')
                                                    .doc(tenant.tempID)
                                                    .update({
                                                  'rentpaymentRef':
                                                      FieldValue.arrayUnion(
                                                          [value])
                                                });

                                                FirebaseFirestore.instance
                                                    .collection('Notifications')
                                                    .doc(tenant.tempID)
                                                    .update({
                                                  'notifications':
                                                      FieldValue.arrayUnion([
                                                    {
                                                      // 'amount': data.requestedAmount,
                                                      'title':
                                                          'Your account has been debited by ${-(double.tryParse(rentController.text) ?? 0.0) + (tenant.balance)}',
                                                    }
                                                  ])
                                                });
                                              });
                                            } else if (tenant.balance <
                                                (double.tryParse(
                                                        rentController.text) ??
                                                    0.0)) {
                                              await FirebaseFirestore.instance
                                                  .collection('rentPayments')
                                                  .add({
                                                'tenantname': 'Rehnaa.pk',
                                                'tenantRef': FirebaseFirestore
                                                    .instance
                                                    .collection('Tenants')
                                                    .doc(tenant.tempID),
                                                'amount': ((double.tryParse(
                                                            rentController
                                                                .text) ??
                                                        0.0) -
                                                    tenant.balance),
                                                'date': DateTime.now(),
                                                'isMinus': true,
                                                // 'description': 'Balance updated by landlord',
                                                'paymentType': '',
                                              }).then((value) async {
                                                //add the rentpayment document reference to the tenant's
                                                // rentpayment array
                                                FirebaseFirestore.instance
                                                    .collection('Tenants')
                                                    .doc(tenant.tempID)
                                                    .update({
                                                  'rentpaymentRef':
                                                      FieldValue.arrayUnion(
                                                          [value])
                                                });
                                                // tenant.landlord =
                                                //     await tenant.getLandlord();
                                                FirebaseFirestore.instance
                                                    .collection('Notifications')
                                                    .doc(tenant.tempID)
                                                    .set({
                                                  'notifications':
                                                      FieldValue.arrayUnion([
                                                    {
                                                      // 'amount': data.requestedAmount,
                                                      'title':
                                                          '${tenant.firstName}, you owe\n PKR${((double.tryParse(rentController.text) ?? 0.0) - tenant.balance)}, Thanks!',
                                                    }
                                                  ])
                                                }, SetOptions(merge: true));
                                              });
                                            }

                                            //snackbar to show that tenant has been updated
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Tenant updated successfully'),
                                              ),
                                            );

                                            setState(() {
                                              tenant.firstName =
                                                  firstNameController.text ??
                                                      '';
                                              tenant.lastName =
                                                  lastNameController.text ?? '';
                                              tenant.description =
                                                  descriptionController.text ??
                                                      '';
                                              tenant.balance = double.tryParse(
                                                      rentController.text) ??
                                                  0.0;
                                              tenant.creditPoints =
                                                  int.tryParse(
                                                          creditPointsController
                                                              .text) ??
                                                      0;
                                              tenant.cnic = cnicNumberController
                                                      .text.isNotEmpty
                                                  ? encryptString(
                                                      cnicNumberController.text)
                                                  : '';
                                              tenant.emailOrPhone =
                                                  emailOrPhoneController.text ??
                                                      '';
                                              tenant
                                                  .familyMembers = int.tryParse(
                                                      familyMembersController
                                                          .text) ??
                                                  0;
                                              tenant.rating = double.tryParse(
                                                      ratingController.text) ??
                                                  0.0;
                                              // tenant.landlordRef =
                                              // tenant.landlordRef;
                                              tenant.landlordRefs =
                                                  selectedLandlordRefs;
                                              tenant.propertyAddress =
                                                  propertyAddressController
                                                          .text ??
                                                      '';
                                              tenant.address =
                                                  addressController.text ?? '';
                                              tenant.contractStartDate =
                                                  contractStartDate;
                                              tenant.contractEndDate =
                                                  contractEndDate;
                                              tenant.monthlyRent =
                                                  monthlyRentController.text ??
                                                      '';
                                              tenant.policeVerification =
                                                  policeVerification;
                                              tenant.tasdeeqVerification =
                                                  tasdeeqVerification;
                                              tenant.securityDeposit =
                                                  securityDepositController
                                                          .text ??
                                                      '';
                                              tenant.creditScore =
                                                  creditScoreController.text ??
                                                      '';
                                              tenant.otherInfo =
                                                  otherInfoController.text ??
                                                      '';
                                              tenant.phoneNumber =
                                                  phoneNumberController.text ??
                                                      '';

                                              tenant.pastLandlordTestimonial =
                                                  pastLandlordTestimonialController
                                                          .text ??
                                                      '';
                                            });

                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text('Yes'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Do nothing and navigate back or close the dialog
                                            print('User canceled');
                                            Navigator.of(context).pop();
                                            // Navigator.pop(context); // Close the edit dialog
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return AdminTenantsInputPage();
                                            }));
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLandlordSelectionDialog(
      Tenant tenant, VoidCallback onSelectionDone) async {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> landlordDocs = [];
        String searchString = '';

        // Initialize selectedLandlords set
        Set<int> selectedLandlords = {};

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  const Text('Select Landlords'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchString = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Search",
                        hintText: "Search",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.green,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Landlords')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SpinKitFadingCube(
                        color: Color.fromARGB(255, 30, 197, 83),
                      );
                    }

                    landlordDocs = snapshot.data!.docs;

                    // Pre-select landlords
                    if (tenant.landlordRefs != null &&
                        tenant.landlordRefs!.isNotEmpty) {
                      for (int i = 0; i < landlordDocs.length; i++) {
                        if (tenant.landlordRefs!
                            .any((ref) => ref.id == landlordDocs[i].id)) {
                          selectedLandlords.add(i);
                        }
                      }
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: landlordDocs.map((doc) {
                          Map<String, dynamic>? landlordData = doc.data();
                          Landlord landlord = Landlord.fromJson(landlordData);

                          String fullName =
                              '${landlord.firstName} ${landlord.lastName}'
                                  .toLowerCase();

                          // Filter based on search string
                          if (fullName.contains(searchString)) {
                            bool isSelected = selectedLandlords
                                .contains(landlordDocs.indexOf(doc));

                            return CheckboxListTile(
                              title: Text(
                                  '${landlord.firstName} ${landlord.lastName}'),
                              value: isSelected,
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    selectedLandlords
                                        .add(landlordDocs.indexOf(doc));
                                  } else {
                                    selectedLandlords
                                        .remove(landlordDocs.indexOf(doc));
                                  }
                                });
                              },
                            );
                          } else {
                            return Container(); // Empty container if not matched
                          }
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Clear the old references
                    selectedLandlordRefs.clear();

                    // Add the selected landlords to the selectedLandlordRefs list
                    for (var index in selectedLandlords) {
                      selectedLandlordRefs.add(FirebaseFirestore.instance
                          .collection('Landlords')
                          .doc(landlordDocs[index].id));
                    }

                    onSelectionDone();
                    Navigator.pop(context);
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
        title: const Text('Tenants Input'),
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
                  filterTenants(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            _isLoading
                ? SpinKitFadingCube(
                    color: Color.fromARGB(255, 30, 197, 83),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: getPaginatedTenants().length,
                      itemBuilder: (context, index) {
                        Tenant tenant = getPaginatedTenants()[index];

                        return ListTile(
                          title: Text('${tenant.firstName} ${tenant.lastName}'),
                          subtitle: Text(tenant.balance.toString()),
                          leading: const Icon(Icons.person),
                          trailing: tenant.isGhost != null && tenant.isGhost!
                              ? const Text('Ghost User')
                              : SizedBox(),
                          onTap: () {
                            _showEditDialog(tenant);
                          },
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
                          (filteredTenants.length / itemsPerPage).ceil();
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
            child: TenantCardWidget(),
          );
        },
      );
      // Add functionality for the + floating action button here
    },
    backgroundColor: const Color(0xff0FA697),
    child: const Icon(Icons.add),
  );
}
