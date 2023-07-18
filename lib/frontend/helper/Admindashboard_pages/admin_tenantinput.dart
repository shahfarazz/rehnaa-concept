import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  DocumentReference<Map<String, dynamic>>? landlordRef;

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

    DateTime? contractStartDate;
    DateTime? contractEndDate;

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

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text('Edit Tenant Details'),
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
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: rentController,
                  decoration: const InputDecoration(labelText: 'Rent'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: creditPointsController,
                  decoration: const InputDecoration(labelText: 'Credit Points'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cnicNumberController,
                  decoration: const InputDecoration(labelText: 'CNIC Number'),
                ),
                TextField(
                  controller: emailOrPhoneController,
                  decoration:
                      const InputDecoration(labelText: 'Email or Phone'),
                ),
                TextField(
                  controller: familyMembersController,
                  decoration:
                      const InputDecoration(labelText: 'Family Members'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
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
                TextField(
                  controller: propertyAddressController,
                  decoration:
                      const InputDecoration(labelText: 'Property Address'),
                ),
                TextField(
                  controller: monthlyRentController,
                  decoration: const InputDecoration(labelText: 'Monthly Rent'),
                ),
                TextField(
                  controller: otherInfoController,
                  decoration:
                      const InputDecoration(labelText: 'Other Information'),
                ),

                TextField(
                  controller: securityDepositController,
                  decoration:
                      const InputDecoration(labelText: 'Security Deposit'),
                ),
                TextField(
                  controller: creditScoreController,
                  decoration: const InputDecoration(labelText: 'Credit Score'),
                ),

                //field to ask for bool value from user for police verification
                //give options yes / no
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
                //field to ask for bool value from user for tasdeeq verification
                //give options yes / no
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
                      title: const Text('Select Landlord'),
                      subtitle: Text(
                        tenant.landlordRef != null
                            ? 'Selected landlord: ${tenant.landlordRef?.id}'
                            : 'Not selected',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _showLandlordSelectionDialog(() {
                            setState(() {
                              // Update the tenant's landlordRef directly
                              tenant.landlordRef = landlordRef;
                            });
                          });
                        });
                      },
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Update the tenant details in Firebase

                    //if the balance has been updated we need to create a rentPayments
                    // document and set tenantname to "Rehnaa App"
                    // and tenantRef to the tenant's tempID's document reference

                    var package = {
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'description': descriptionController.text,
                      'balance': double.tryParse(rentController.text) ?? 0.0,
                      'creditPoints':
                          int.tryParse(creditPointsController.text) ?? 0,
                      'cnicNumber': cnicNumberController.text.isNotEmpty
                          ? encryptString(cnicNumberController.text)
                          : '',
                      'emailOrPhone': emailOrPhoneController.text,
                      'familyMembers':
                          int.tryParse(familyMembersController.text) ?? 0,
                      'rating': double.tryParse(ratingController.text) ?? 0.0,
                      'landlordRef': landlordRef,
                      'propertyAddress': propertyAddressController.text,
                      'address': addressController.text,
                      'contractStartDate': contractStartDate != null
                          ? Timestamp.fromDate(contractStartDate!)
                          : FieldValue.delete(),
                      'contractEndDate': contractEndDate != null
                          ? Timestamp.fromDate(contractEndDate!)
                          : FieldValue.delete(),
                      'monthlyRent': monthlyRentController.text ?? '',
                      'policeVerification': policeVerification,
                      'tasdeeqVerification': tasdeeqVerification,
                      'securityDeposit': securityDepositController.text ?? '',
                      'creditScore': creditScoreController.text ?? '',
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
                                  children: package.keys.map((key) {
                                    return ListTile(
                                      title: Text(key),
                                      subtitle: Text(package[key].toString()),
                                    );
                                  }).toList(),
                                ),
                                ButtonBar(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Continue with the code
                                        print('User confirmed');

                                        await FirebaseFirestore.instance
                                            .collection('Tenants')
                                            .doc(tenant.tempID)
                                            .update(package);

                                        setState(() {
                                          // Update the tenant details in the local list
                                          tenant.firstName =
                                              firstNameController.text;
                                          tenant.lastName =
                                              lastNameController.text;
                                          tenant.description =
                                              descriptionController.text;
                                          tenant.balance = int.tryParse(
                                                  rentController.text) ??
                                              0;
                                          tenant.creditPoints = int.tryParse(
                                                  creditPointsController
                                                      .text) ??
                                              0;
                                          tenant.cnic = cnicNumberController
                                                  .text.isNotEmpty
                                              ? hashedCnic
                                              : '';
                                          tenant.emailOrPhone =
                                              emailOrPhoneController.text;
                                          tenant.familyMembers = int.tryParse(
                                                  familyMembersController
                                                      .text) ??
                                              0;
                                          tenant.rating = double.tryParse(
                                                  ratingController.text) ??
                                              0.0;
                                          tenant.landlordRef = landlordRef;
                                          tenant.propertyAddress =
                                              propertyAddressController.text;
                                          tenant.address =
                                              addressController.text;
                                          tenant.contractStartDate =
                                              contractStartDate;
                                          tenant.contractEndDate =
                                              contractEndDate;
                                          monthlyRentController.text ?? '';
                                          tenant.policeVerification =
                                              policeVerification;
                                          tenant.tasdeeqVerification =
                                              tasdeeqVerification;
                                          tenant.securityDeposit =
                                              securityDepositController.text ??
                                                  '';
                                          tenant.creditScore =
                                              creditScoreController.text ?? '';
                                        });

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
                                                        rentController.text) ??
                                                    0.0) +
                                                (tenant.balance),
                                            'date': DateTime.now(),
                                            'isMinus': true,
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
                                                  FieldValue.arrayUnion([value])
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
                                                      'Your account has been credited by ${-(double.tryParse(rentController.text) ?? 0.0) + (tenant.balance)}',
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
                                                        rentController.text) ??
                                                    0.0) -
                                                tenant.balance),
                                            'date': DateTime.now(),
                                            'isMinus': false,
                                            // 'description': 'Balance updated by landlord',
                                            'paymentType': '',
                                          }).then((value) {
                                            //add the rentpayment document reference to the tenant's
                                            // rentpayment array
                                            FirebaseFirestore.instance
                                                .collection('Tenants')
                                                .doc(tenant.tempID)
                                                .update({
                                              'rentpaymentRef':
                                                  FieldValue.arrayUnion([value])
                                            });
                                            FirebaseFirestore.instance
                                                .collection('Notifications')
                                                .doc(tenant.tempID)
                                                .set({
                                              'notifications':
                                                  FieldValue.arrayUnion([
                                                {
                                                  // 'amount': data.requestedAmount,
                                                  'title':
                                                      '${tenant.firstName}, you owe PKR${((double.tryParse(rentController.text) ?? 0.0) - tenant.balance)} to ${tenant.landlord?.firstName}. Thanks!',
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

  Future<void> _showLandlordSelectionDialog(
      VoidCallback onSelectionDone) async {
    showDialog(
      context: context,
      builder: (context) {
        int selectedLandlordIndex =
            -1; // Declare the selectedLandlordIndex variable inside the builder function

        List<QueryDocumentSnapshot<Map<String, dynamic>>> landlordDocs =
            []; // Declare the landlordDocs list outside the builder function

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select a Landlord'),
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

                    landlordDocs =
                        snapshot.data!.docs; // Assign value to landlordDocs

                    return SingleChildScrollView(
                      child: Column(
                        children: landlordDocs.map((doc) {
                          Map<String, dynamic>? landlordData = doc.data();
                          Landlord landlord = Landlord.fromJson(landlordData);
                          bool isSelected = selectedLandlordIndex ==
                              landlordDocs.indexOf(doc);

                          return RadioListTile<int>(
                            title: Text(
                                '${landlord.firstName} ${landlord.lastName}'),
                            value: landlordDocs.indexOf(doc),
                            groupValue: selectedLandlordIndex,
                            onChanged: (value) {
                              setState(() {
                                selectedLandlordIndex = value!;
                              });
                            },
                            selected: isSelected,
                          );
                        }).toList(),
                      ),
                    );
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
                    if (selectedLandlordIndex != -1) {
                      QueryDocumentSnapshot<Map<String, dynamic>>
                          selectedLandlordDoc =
                          landlordDocs[selectedLandlordIndex];
                      Map<String, dynamic> landlordData =
                          selectedLandlordDoc.data();
                      Landlord selectedLandlord =
                          Landlord.fromJson(landlordData);

                      setState(() {
                        landlordRef = FirebaseFirestore.instance
                            .collection('Landlords')
                            .doc(selectedLandlordDoc.id);
                      });
                      onSelectionDone();
                      Navigator.pop(context); // Close the dialog
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Please select a landlord',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
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
