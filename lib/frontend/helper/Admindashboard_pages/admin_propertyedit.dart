import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../backend/models/propertymodel.dart';
import '../../../backend/models/tenantsmodel.dart';

class PropertyEditPage extends StatefulWidget {
  final Property property;

  const PropertyEditPage({required this.property});

  @override
  _PropertyEditPageState createState() => _PropertyEditPageState();
}

class _PropertyEditPageState extends State<PropertyEditPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController bedsController = TextEditingController();
  TextEditingController bathsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  DocumentReference<Map<String, dynamic>>? tenantRef;

  bool isLoading = false;
  int? selectedTenantIndex;

  @override
  void initState() {
    titleController = TextEditingController(text: widget.property.title);
    locationController = TextEditingController(text: widget.property.location);
    typeController = TextEditingController(text: widget.property.type);
    bedsController =
        TextEditingController(text: widget.property.beds.toString());
    bathsController =
        TextEditingController(text: widget.property.baths.toString());
    descriptionController =
        TextEditingController(text: widget.property.description);

    areaController =
        TextEditingController(text: widget.property.area.toString());

    FirebaseFirestore.instance.collection('Tenants').get().then((snapshot) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> tenantDocs =
          snapshot.docs;
      for (int i = 0; i < tenantDocs.length; i++) {
        // print('tenantDocs[${i}].id: ${tenantDocs[i].id}');
        // print('tenantRef?.id: ${widget.property.tenantRef?.id}');
        if (tenantDocs[i].id == widget.property.tenantRef?.id) {
          // print('LOOLOOLOL');
          setState(() {
            selectedTenantIndex = i;
          });
          break;
        }
      }
    });

    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  // @override
  // void dispose() {
  //   titleController.dispose();
  //   locationController.dispose();
  //   typeController.dispose();
  //   bedsController.dispose();
  //   bathsController.dispose();
  //   descriptionController.dispose();
  //   super.dispose();
  // }

  Future<void> saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Update property data in Firestore
      await FirebaseFirestore.instance
          .collection('Properties')
          .doc(widget.property.propertyID)
          .set({
        'title': titleController.text,
        'location': locationController.text,
        'type': typeController.text,
        'beds': int.tryParse(bedsController.text) ?? 0,
        'baths': int.tryParse(bathsController.text) ?? 0,
        'description': descriptionController.text,
        'area': int.tryParse(areaController.text) ?? 0,
        'tenantRef': tenantRef,
      }, SetOptions(merge: true));

      // Update property object with edited values
      widget.property.title = titleController.text;
      widget.property.location = locationController.text;
      widget.property.type = typeController.text;
      widget.property.beds = int.tryParse(bedsController.text) ?? 0;
      widget.property.baths = int.tryParse(bathsController.text) ?? 0;
      widget.property.description = descriptionController.text;
      widget.property.area = int.tryParse(areaController.text) ?? 0;

      Fluttertoast.showToast(
        msg: 'Changes saved successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to save changes. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showTenantSelectionDialog(VoidCallback onSelectionDone) async {
    showDialog(
      context: context,
      builder: (context) {
        // int? selectedTenantIndex;
        List<QueryDocumentSnapshot<Map<String, dynamic>>> tenantDocs = [];
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select a Tenant'),
              content: Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: Column(
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        hintText: 'Enter tenant name',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('Tenants')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SpinKitFadingCube(
                              color: Color.fromARGB(255, 30, 197, 83),
                            );
                          }
                          tenantDocs = snapshot.data!.docs;

                          // Filtering the tenantDocs based on the searchQuery.
                          final results = tenantDocs.where((tenantDoc) {
                            final tenantData = tenantDoc.data();
                            final tenant = Tenant.fromJson(tenantData);
                            final tenantName =
                                '${tenant.firstName} ${tenant.lastName}';
                            return tenantName
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase());
                          }).toList();

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                RadioListTile<int>(
                                  title: Text('No tenant'),
                                  value: -1,
                                  groupValue: selectedTenantIndex,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTenantIndex = value;
                                    });
                                  },
                                  selected: selectedTenantIndex == -1,
                                )
                              ]..addAll(results.map((doc) {
                                  Map<String, dynamic>? tenantData = doc.data();
                                  Tenant tenant = Tenant.fromJson(tenantData);
                                  bool isSelected = selectedTenantIndex ==
                                      tenantDocs.indexOf(doc);

                                  return RadioListTile<int>(
                                    title: Text(
                                        '${tenant.firstName} ${tenant.lastName}'),
                                    value: tenantDocs.indexOf(doc),
                                    groupValue: selectedTenantIndex,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTenantIndex = value!;
                                      });
                                    },
                                    selected: isSelected,
                                  );
                                }).toList()),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                    if (selectedTenantIndex != null &&
                        selectedTenantIndex != -1) {
                      QueryDocumentSnapshot<Map<String, dynamic>>
                          selectedTenantDoc = tenantDocs[selectedTenantIndex!];
                      setState(() {
                        tenantRef = FirebaseFirestore.instance
                            .collection('Tenants')
                            .doc(selectedTenantDoc.id);
                      });
                    } else {
                      setState(() {
                        tenantRef = null;
                      });
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
    // print('titleController text: ${titleController.text}');
    // print('locationController text: ${locationController.text}');
    // print('typeController text: ${typeController.text}');
    // print('bedsController text: ${bedsController.text}');
    // print('bathsController text: ${bathsController.text}');
    // print('descriptionController text: ${descriptionController.text}');
    setState(() {});

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
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
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: isLoading ? null : saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Text('Hello world'),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: bedsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Beds'),
            ),
            TextField(
              controller: bathsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Baths'),
            ),
            TextField(
              controller: areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Area in Marlas'),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ListTile(
                  title: const Text('Select Tenant'),
                  subtitle: Text(
                    widget.property.tenantRef != null
                        ? 'Selected Tenant: ${widget.property.tenantRef?.id}'
                        : 'Not selected',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _showTenantSelectionDialog(() {
                        setState(() {
                          // Update the tenant's propertyRef directly
                          widget.property.tenantRef = tenantRef;
                        });
                      });
                    });
                  },
                );
              },
            ),
            isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  )
                : SizedBox(height: 0),
          ],
        ),
      ),
      // bottomNavigationBar: Container(
      //   padding: EdgeInsets.all(16.0),
      //   child: isLoading
      //       ? LinearProgressIndicator(
      //           backgroundColor: Colors.grey[200],
      //           valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      //         )
      //       : null,
      // ),
    );
  }
}
