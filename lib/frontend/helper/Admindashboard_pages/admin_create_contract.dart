import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rehnaa/frontend/helper/Admindashboard_pages/admin_requests_property_contracts.dart';

import '../../Screens/Admin/admindashboard.dart';

class AdminCreateContractsPage extends StatefulWidget {
  const AdminCreateContractsPage({super.key});

  @override
  State<AdminCreateContractsPage> createState() =>
      _AdminCreateContractsPageState();
}

class _AdminCreateContractsPageState extends State<AdminCreateContractsPage> {
  var selectLandlordText = 'Select Landlord';
  var selectTenantText = 'Select Tenant';
  var selectPropertyText = 'Select Property';

  var selectedLandlord;
  var selectedTenant;
  var selectedProperty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Contracts'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboard()),
              );
            }),
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
      body: Center(
        child: Column(
          children: [
            //three statefulbuilders with elevated buttons as children, one button to select a landlord, one to select a tenant, and one to select a property
            SizedBox(height: 50),
            Text("Landlord:"),
            SizedBox(height: 10),
            StatefulBuilder(builder: (context, setState) {
              // selectLandlordText = 'Select Landlord';
              return ElevatedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                onPressed: () {
                  //show dialog with loading
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return
                            // title: Text('Loading...'),
                            SpinKitFadingCube(
                          color: Color.fromARGB(255, 30, 197, 83),
                        );
                      });
                  selectLandlordFunc();
                  setState() {}
                  ;
                },
                child: Text('${selectLandlordText}'),
              );
            }),
            SizedBox(height: 50),
            Text("Tenant:"),
            SizedBox(height: 10),
            StatefulBuilder(builder: (context, setState) {
              // selectTenantText = 'Select Tenant';
              return ElevatedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return
                            // title: Text('Loading...'),
                            SpinKitFadingCube(
                          color: Color.fromARGB(255, 30, 197, 83),
                        );
                      });
                  selectTenantFunc();
                  setState() {}
                  ;
                },
                child: Text('${selectTenantText}'),
              );
            }),
            SizedBox(height: 50),
            Text("Property:"),
            SizedBox(height: 10),

            StatefulBuilder(builder: (context, setState) {
              // selectPropertyText = 'Select Property';
              return ElevatedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return
                            // title: Text('Loading...'),
                            SpinKitFadingCube(
                          color: Color.fromARGB(255, 30, 197, 83),
                        );
                      });
                  selectPropertFunc();
                  setState() {}
                  ;
                },
                child: Text('${selectPropertyText}'),
              );
            }),
            SizedBox(height: 10),
            //add a save button
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () async {
                //check if all of selectedLandlord selectedTenant and selectedProperty are not null
                if (selectedLandlord != null &&
                    selectedTenant != null &&
                    selectedProperty != null) {
                  //if they are not null, call the admin requests property page with tenant and landlord id
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return
                            // title: Text('Loading...'),
                            SpinKitFadingCube(
                          color: Color.fromARGB(255, 30, 197, 83),
                        );
                      });

                  print(selectedLandlord);
                  print(selectedTenant);
                  print(selectedProperty);

                  // Send a notification to the tenant
                  FirebaseFirestore.instance
                      .collection('Notifications')
                      .doc(selectedTenant)
                      .update({
                    'notifications': FieldValue.arrayUnion([
                      {
                        'title': 'Rental Request Accepted',
                      }
                    ])
                  });

                  // Set the tenant's isWithdraw to false and set propertyRef and address
                  await FirebaseFirestore.instance
                      .collection('Tenants')
                      .doc(selectedTenant)
                      .update({
                    // 'isWithdraw': false,
                    'propertyRef': FirebaseFirestore.instance
                        .collection('Properties')
                        .doc(selectedProperty),
                    // 'address': FirebaseFirestore.instance
                    //     .collection('Properties')
                    //     .doc(selectedProperty)
                    //     .get()
                    //     .then((value) => value['address']),
                  });

                  // Set the property's tenantRef to the tenant's document reference
                  FirebaseFirestore.instance
                      .collection('Properties')
                      .doc(selectedProperty)
                      .update({
                    'tenantRef': FirebaseFirestore.instance
                        .collection('Tenants')
                        .doc(selectedTenant),
                  });

                  // Set the tenant's landlordRef to the property's landlordRef
                  FirebaseFirestore.instance
                      .collection('Tenants')
                      .doc(selectedTenant)
                      .update({
                    'landlordRef': FirebaseFirestore.instance
                        .collection('Landlords')
                        .doc(selectedLandlord)
                  });

                  // Update the landlord's tenantRef with the tenant's document reference
                  FirebaseFirestore.instance
                      .collection('Landlords')
                      .doc(selectedLandlord)
                      .update({
                    //fieldvalue array union
                    'tenantRef': FieldValue.arrayUnion([
                      FirebaseFirestore.instance
                          .collection('Tenants')
                          .doc(selectedTenant)
                    ]),
                  });

                  // Update the property's isRequestedByTenants field
                  FirebaseFirestore.instance
                      .collection('Properties')
                      .doc(selectedProperty)
                      .update({
                    'isRequestedByTenants': false,
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminPropertyContractsPage(
                              landlordID: selectedLandlord,
                              tenantID: selectedTenant,
                              landlordName: selectLandlordText,
                              tenantName: selectTenantText,
                            )),
                  );
                } else {
                  //if they are null, show a snackbar saying that all fields are required
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All fields are required'),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> selectLandlordFunc() {
    return FirebaseFirestore.instance
        .collection('Landlords')
        .get()
        .then((snapshot) {
      List<DropdownMenuItem> landlordList = [];
      snapshot.docs.forEach((doc) {
        landlordList.add(DropdownMenuItem(
          child: Text(doc['firstName'] + ' ' + doc['lastName']),
          value: doc.id,
        ));
      });
      //map ids to names with ids as keys and names as values
      Map landlordMap = Map.fromIterables(snapshot.docs.map((doc) => doc.id),
          snapshot.docs.map((doc) => doc['firstName'] + ' ' + doc['lastName']));
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select Landlord'),
              content: StatefulBuilder(builder: (context, setState) {
                return DropdownButton(
                  items: landlordList,
                  onChanged: (value) {
                    setState(() {
                      //selected landlord text should have the name of the landlord

                      selectLandlordText = landlordMap[value];
                      selectedLandlord = value;
                      // selectLandlordText = ;
                    });
                  },
                  value: selectedLandlord,
                  isExpanded: true,
                );
              }),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectLandlordText = landlordMap[selectedLandlord];
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('Done'),
                ),
              ],
            );
          });
    });
  }

  Future<void> selectTenantFunc() {
    return FirebaseFirestore.instance
        .collection('Tenants')
        .get()
        .then((snapshot) {
      List<DropdownMenuItem> tenantList = [];
      snapshot.docs.forEach((doc) {
        tenantList.add(DropdownMenuItem(
          child: Text(doc['firstName'] + ' ' + doc['lastName']),
          value: doc.id,
        ));
      });
      //map ids to names with ids as keys and names as values
      Map tenantMap = Map.fromIterables(snapshot.docs.map((doc) => doc.id),
          snapshot.docs.map((doc) => doc['firstName'] + ' ' + doc['lastName']));
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select Tenant'),
              content: StatefulBuilder(builder: (context, setState) {
                return DropdownButton(
                  items: tenantList,
                  onChanged: (value) {
                    setState(() {
                      //selected tenant text should have the name of the tenant
                      selectTenantText = tenantMap[value];
                      selectedTenant = value;
                    });
                  },
                  value: selectedTenant,
                  isExpanded: true,
                );
              }),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectTenantText = tenantMap[selectedTenant];
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('Done'),
                ),
              ],
            );
          });
    });
  }

  Future<void> selectPropertFunc() {
    return FirebaseFirestore.instance
        .collection('Properties')
        .get()
        .then((snapshot) {
      List<DropdownMenuItem> propertyList = [];
      snapshot.docs.forEach((doc) {
        propertyList.add(DropdownMenuItem(
          child: Text(doc['title']),
          value: doc.id,
        ));
      });
      //map ids to names with ids as keys and names as values
      Map propertyMap = Map.fromIterables(snapshot.docs.map((doc) => doc.id),
          snapshot.docs.map((doc) => doc['title']));
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select Property'),
              content: StatefulBuilder(builder: (context, setState) {
                return DropdownButton(
                  items: propertyList,
                  onChanged: (value) {
                    setState(() {
                      //selected property text should have the title of the property
                      selectPropertyText = propertyMap[value];
                      selectedProperty = value;
                    });
                  },
                  value: selectedProperty,
                  isExpanded: true,
                );
              }),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectPropertyText = propertyMap[selectedProperty];
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('Done'),
                ),
              ],
            );
          });
    });
  }
}
