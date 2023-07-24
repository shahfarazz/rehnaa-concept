import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';

import '../../../backend/models/tenantsmodel.dart';
import '../../Screens/Admin/admindashboard.dart';

class AdminTenantFormsViewPage extends StatefulWidget {
  const AdminTenantFormsViewPage({super.key});

  @override
  State<AdminTenantFormsViewPage> createState() =>
      _AdminTenantFormsViewPageState();
}

class _AdminTenantFormsViewPageState extends State<AdminTenantFormsViewPage> {
  List<Tenant> tenants = [];

  List<Tenant> filterTenants = []; // this will hold the filtered filterTenants

  void _filterTenants(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        filterTenants = tenants;
      });
    } else {
      List<Tenant> temp = [];
      for (Tenant tenant in tenants) {
        final String tenantName = tenant.firstName + ' ' + tenant.lastName;
        if (tenantName.toLowerCase().contains(searchText.toLowerCase())) {
          temp.add(tenant);
        }
      }
      setState(() {
        filterTenants = temp;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTenants().then((_) {
      setState(() {
        filterTenants = tenants;
      });
    });
  }

  Future<void> getTenants() async {
    var tenantsDataSnapshot =
        await FirebaseFirestore.instance.collection('Tenants').get();

    tenantsDataSnapshot.docs.forEach((element) {
      Tenant tenant = Tenant.fromJson(element.data());

      tenant.tempID = element.id;

      if (tenant.isDetailsFilled && tenant.isFormDeleted == false) {
        tenants.add(tenant);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //show a scaffold with app bar and in body show a list view of cards that are clickable for each tenant
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Tenant Forms'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          },
        ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                // call your filtering function here if you have one
                // _filterContracts(value);
                _filterTenants(value);
              },
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: filterTenants.length,
            itemBuilder: (context, index) {
              //post frame callback

              return Card(
                child: ListTile(
                  onTap: () {
                    //show dialog box which shows fields tenant.whatAreYouLookingFor, estimatedTimetoShift, estimatedBudget, cnic, address if they ar enot null
                    //if they are null then show a message that says that the tenant has not filled the form yet
                    if (filterTenants[index].isDetailsFilled == false) {
                      //show a message that says that the tenant has not filled the form yet
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Tenant Form'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tenant has not filled the form yet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Tenant Form'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'What are you looking for?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(filterTenants[index].whatAreYouLookingFor!),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Estimated time to shift',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(filterTenants[index].estimatedTimetoShift!),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Estimated budget',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(filterTenants[index].estimatedBudget!),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'CNIC',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(decryptString(filterTenants[index].cnic!)),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Address',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(filterTenants[index].address!),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  title: Text(filterTenants[index].firstName),
                  subtitle: Text(filterTenants[index].lastName),
                  trailing: //let the user delete the form and on delete mark tenant.isFormDeleted to true and put it on firebase
                      // then reset the page
                      IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Delete Form'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Are you sure you want to delete this form?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  //delete the form
                                  filterTenants[index].isFormDeleted = true;
                                  await FirebaseFirestore.instance
                                      .collection('Tenants')
                                      .doc(filterTenants[index].tempID)
                                      .update({
                                    'isFormDeleted': true,
                                  });
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AdminTenantFormsViewPage(),
                                    ),
                                  );
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ))
        ],
      ),
    );
  }
}
