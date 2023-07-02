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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
                    'Rent: \$${tenant.rent.toStringAsFixed(2)}',
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
        TextEditingController(text: tenant.rent.toString());
    final TextEditingController creditPointsController =
        TextEditingController(text: tenant.creditPoints.toString());
    final TextEditingController cnicNumberController =
        TextEditingController(text: tenant.cnicNumber);
    final TextEditingController emailOrPhoneController =
        TextEditingController(text: tenant.emailOrPhone);
    final TextEditingController familyMembersController =
        TextEditingController(text: tenant.familyMembers.toString());
    final TextEditingController ratingController =
        TextEditingController(text: tenant.rating.toString());

    final hashedCnic = hashString(cnicNumberController.text);

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

                    FirebaseFirestore.instance
                        .collection('Tenants')
                        .doc(tenant.tempID)
                        .update({
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'description': descriptionController.text,
                      'rent': double.tryParse(rentController.text) ?? 0.0,
                      'creditPoints':
                          int.tryParse(creditPointsController.text) ?? 0,
                      'cnicNumber': cnicNumberController.text.isNotEmpty
                          ? hashedCnic
                          : '',
                      'emailOrPhone': emailOrPhoneController.text,
                      'familyMembers':
                          int.tryParse(familyMembersController.text) ?? 0,
                      'rating': double.tryParse(ratingController.text) ?? 0.0,
                      'landlordRef': landlordRef
                    });

                    setState(() {
                      // Update the tenant details in the local list
                      tenant.firstName = firstNameController.text;
                      tenant.lastName = lastNameController.text;
                      tenant.description = descriptionController.text;
                      tenant.rent = int.tryParse(rentController.text) ?? 0;
                      tenant.creditPoints =
                          int.tryParse(creditPointsController.text) ?? 0;
                      tenant.cnicNumber = cnicNumberController.text.isNotEmpty
                          ? hashedCnic
                          : '';
                      tenant.emailOrPhone = emailOrPhoneController.text;
                      tenant.familyMembers =
                          int.tryParse(familyMembersController.text) ?? 0;
                      tenant.rating =
                          double.tryParse(ratingController.text) ?? 0.0;
                    });

                    Navigator.of(context).pop(); // Close the dialog
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
                      return const CircularProgressIndicator();
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
            Expanded(
              child: ListView.builder(
                itemCount: getPaginatedTenants().length,
                itemBuilder: (context, index) {
                  Tenant tenant = getPaginatedTenants()[index];

                  return ListTile(
                    title: Text('${tenant.firstName} ${tenant.lastName}'),
                    subtitle: Text(tenant.rent.toString()),
                    leading: const Icon(Icons.person),
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
