import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/backend/models/propertymodel.dart';
import 'package:rehnaa/backend/models/rentpaymentmodel.dart';

import '../../../backend/models/tenantsmodel.dart';
// import 'package:rehnaa/frontend/helper/bargraphs/bargraph.dart';

class AdminNewAnalyticsPage extends StatefulWidget {
  @override
  _AdminNewAnalyticsPageState createState() => _AdminNewAnalyticsPageState();
}

class _AdminNewAnalyticsPageState extends State<AdminNewAnalyticsPage> {
  Future<List<Landlord>> getLandlords() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Landlords').get();

    List<Landlord> landlordList = [];

    for (var doc in querySnapshot.docs) {
      Landlord landlord = Landlord.fromJson(doc.data());
      landlordList.add(landlord);
    }

    return landlordList;
  }

  Future<List<Property>> getProperties() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Properties').get();

    List<Property> propertyList = [];

    for (var doc in querySnapshot.docs) {
      Property property = await Property.fromJson(doc.data());
      propertyList.add(property);
    }

    return propertyList;
  }

  Future<List<RentPayment>> getrentPayments() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('rentPayments').get();

    List<RentPayment> rentPaymentsList = [];

    for (var doc in querySnapshot.docs) {
      RentPayment rentPayment = await RentPayment.fromJson(doc.data());
      rentPaymentsList.add(rentPayment);
    }

    return rentPaymentsList;
  }

  double calculateAverageRent(List<RentPayment> rentPayments) {
    double totalRent = 0;
    int count = rentPayments.length;

    for (RentPayment rentPayment in rentPayments) {
      totalRent += rentPayment.amount;
    }

    return totalRent / count;
  }

  Map<String, double> generateLocationAnalytics(List<Property> properties) {
    Map<String, double> locationCountMap = {};

    // Count the number of properties in each location
    for (Property property in properties) {
      String location = property.location;
      locationCountMap[location] = (locationCountMap[location] ?? 0) + 1;
    }

    return locationCountMap;
  }

  List<String> getCommercialResidentialAreas(List<Property> properties) {
    List<String> areas = [];

    // Perform calculations to determine commercial and residential areas

    return areas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics'),
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
            SizedBox(height: 20),
            Container(
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
              child: ElevatedButton(
                onPressed: getPropertyLocations,
                child: Text("Property Locations"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              // onPressed: () {},

              onPressed: getLandlordBalances,
              child: Text("Landlord Balances"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getTenantRents,
              // onPressed: () {},

              child: Text("Tenant Rents"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getPropertyTypes,
              // onPressed: () {},

              child: Text("Property Types"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              // onPressed: () {},

              onPressed: showPropertyRents,
              child: Text("Property Rents"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void showPropertyRents() {
    //objective is to show dialog of properties sorted by their rental values in descending order
    //circular progress indicator
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Property Rents"),
            content: Container(
              width: 300,
              height: 300,
              child: FutureBuilder(
                future: getProperties(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Property> properties = snapshot.data;
                    List<String> propertyNames = [];
                    List<double> propertyRents = [];

                    for (Property property in properties) {
                      propertyNames.add(property.title);
                      propertyRents.add(property.price!);
                    }

                    //sort propertyNames and propertyRents by descending order of propertyRents
                    for (int i = 0; i < propertyRents.length; i++) {
                      for (int j = i + 1; j < propertyRents.length; j++) {
                        if (propertyRents[i] < propertyRents[j]) {
                          double tempRent = propertyRents[i];
                          propertyRents[i] = propertyRents[j];
                          propertyRents[j] = tempRent;

                          String tempName = propertyNames[i];
                          propertyNames[i] = propertyNames[j];
                          propertyNames[j] = tempName;
                        }
                      }
                    }

                    return ListView.builder(
                      itemCount: propertyNames.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(propertyNames[index]),
                          subtitle: Text(propertyRents[index].toString()),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: SpinKitFadingCube(
                        color: Color.fromARGB(255, 30, 197, 83),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        });
  }

  void getPropertyLocations() {
    //objective is to show dialog of properties grouped by their locations
    //circular progress indicator
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Property Locations"),
            content: Container(
              width: 300,
              height: 300,
              child: FutureBuilder(
                future: getProperties(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Property> properties = snapshot.data;
                    List<String> propertyNames = [];
                    List<String> propertyLocs = [];

                    for (Property property in properties) {
                      propertyNames.add(property.title);
                      if (property.location == '') {
                        propertyLocs.add("No Location specified");
                      } else {
                        propertyLocs.add(property.location);
                      }
                    }

                    //group together properties with same location
                    Map locationMap = {};
                    for (int i = 0; i < propertyLocs.length; i++) {
                      if (locationMap.containsKey(propertyLocs[i])) {
                        locationMap[propertyLocs[i]].add(propertyNames[i]);
                      } else {
                        locationMap[propertyLocs[i]] = [propertyNames[i]];
                      }
                    }
                    //return locationMap as a listview
                    return ListView.builder(
                      itemCount: locationMap.length,
                      itemBuilder: (BuildContext context, int index) {
                        var elementAt = locationMap.values.elementAt(index);
                        //convert list elementAt to string
                        String elementAtString = "";
                        for (int i = 0; i < elementAt.length; i++) {
                          elementAtString += elementAt[i] + "\n";
                        }

                        return ListTile(
                          title: Text(locationMap.keys.elementAt(index)),
                          subtitle: Text(elementAtString),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: SpinKitFadingCube(
                        color: Color.fromARGB(255, 30, 197, 83),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        });
  }

  void getPropertyTypes() {
    //objective is to show dialog of properties grouped by their types
    //circular progress indicator
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Property Types"),
            content: Container(
              width: 300,
              height: 300,
              child: FutureBuilder(
                future: getProperties(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Property> properties = snapshot.data;
                    List<String> propertyNames = [];
                    List<String> propertyTypes = [];

                    for (Property property in properties) {
                      propertyNames.add(property.title);
                      if (property.type == '') {
                        propertyTypes.add("No Type specified");
                      } else {
                        propertyTypes.add(property.type);
                      }
                    }

                    //group together properties with same type
                    Map typeMap = {};
                    for (int i = 0; i < propertyTypes.length; i++) {
                      if (typeMap.containsKey(propertyTypes[i])) {
                        typeMap[propertyTypes[i]].add(propertyNames[i]);
                      } else {
                        typeMap[propertyTypes[i]] = [propertyNames[i]];
                      }
                    }
                    //return typeMap as a listview
                    return ListView.builder(
                      itemCount: typeMap.length,
                      itemBuilder: (BuildContext context, int index) {
                        var elementAt = typeMap.values.elementAt(index);
                        //convert list elementAt to string
                        String elementAtString = "";
                        for (int i = 0; i < elementAt.length; i++) {
                          elementAtString += elementAt[i] + "\n";
                        }

                        return ListTile(
                          title: Text(typeMap.keys.elementAt(index)),
                          subtitle: Text(elementAtString),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: SpinKitFadingCube(
                        color: Color.fromARGB(255, 30, 197, 83),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        });
  }

  void getTenantRents() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Tenant Rents"),
            content: Container(
              width: 300,
              height: 300,
              child: FutureBuilder(
                future: getTenants(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Tenant> tenants = snapshot.data;
                    List<String> tenantNames = [];
                    List<num> tenantRents = [];

                    for (Tenant tenant in tenants) {
                      tenantNames.add(tenant.firstName + " " + tenant.lastName);
                      tenantRents.add(tenant.balance);
                    }

                    //sort tenantNames and tenantRents by descending order of tenantRents
                    for (int i = 0; i < tenantRents.length; i++) {
                      for (int j = i + 1; j < tenantRents.length; j++) {
                        if (tenantRents[i] < tenantRents[j]) {
                          num tempRent = tenantRents[i];
                          tenantRents[i] = tenantRents[j];
                          tenantRents[j] = tempRent;

                          String tempName = tenantNames[i];
                          tenantNames[i] = tenantNames[j];
                          tenantNames[j] = tempName;
                        }
                      }
                    }

                    return ListView.builder(
                      itemCount: tenantNames.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(tenantNames[index]),
                          subtitle: Text(tenantRents[index].toString()),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: SpinKitFadingCube(
                        color: Color.fromARGB(255, 30, 197, 83),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        });
  }

  Future<List<Tenant>> getTenants() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Tenants').get();

    List<Tenant> tenantList = [];

    for (var doc in querySnapshot.docs) {
      Tenant tenant = Tenant.fromJson(doc.data());
      tenantList.add(tenant);
    }

    return tenantList;
  }

  void getLandlordBalances() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Landlord Balances"),
            content: Container(
              width: 300,
              height: 300,
              child: FutureBuilder(
                future: getLandlords(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Landlord> landlords = snapshot.data;
                    List<String> landlordNames = [];
                    List<num> landlordBalances = [];

                    for (Landlord landlord in landlords) {
                      landlordNames
                          .add(landlord.firstName + " " + landlord.lastName);
                      landlordBalances.add(landlord.balance);
                    }

                    //sort landlordNames and landlordBalances by descending order of landlordBalances
                    for (int i = 0; i < landlordBalances.length; i++) {
                      for (int j = i + 1; j < landlordBalances.length; j++) {
                        if (landlordBalances[i] < landlordBalances[j]) {
                          num tempBalance = landlordBalances[i];
                          landlordBalances[i] = landlordBalances[j];
                          landlordBalances[j] = tempBalance;

                          String tempName = landlordNames[i];
                          landlordNames[i] = landlordNames[j];
                          landlordNames[j] = tempName;
                        }
                      }
                    }

                    return ListView.builder(
                      itemCount: landlordNames.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(landlordNames[index]),
                          subtitle: Text(landlordBalances[index].toString()),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: SpinKitFadingCube(
                        color: Color.fromARGB(255, 30, 197, 83),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        });
  }
}
