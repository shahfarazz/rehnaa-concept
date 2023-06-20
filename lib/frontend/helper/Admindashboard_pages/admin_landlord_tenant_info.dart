import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../backend/models/tenantsmodel.dart';

class Landlord {
  final String firstName;
  final String lastName;
  final double balance;
  final String? pathToImage;
  // final List<dynamic> propertyRef;
  // final List<dynamic>? rentpaymentRef;

  Landlord({
    required this.firstName,
    required this.lastName,
    required this.balance,
    required this.pathToImage,
    // required this.propertyRef,
    // this.rentpaymentRef,
  });
}

// class Tenant {
//   final String firstName;
//   final String lastName;
//   final String description;
//   final double rating;
//   final int rent;
//   final int creditPoints;
//   final String propertyDetails;
//   final String cnicNumber;
//   final String emailOrPhone;
//   final bool tasdeeqVerification;
//   // final bool policeVerification;
//   final int familyMembers;
//   final DocumentReference<Map<String, dynamic>>? landlordRef;
//   final String? pathToImage;

//   Tenant({
//     required this.firstName,
//     required this.lastName,
//     required this.description,
//     required this.rating,
//     required this.rent,
//     required this.creditPoints,
//     required this.propertyDetails,
//     required this.cnicNumber,
//     required this.emailOrPhone,
//     required this.tasdeeqVerification,
//     // required this.policeVerification,
//     required this.familyMembers,
//     required this.landlordRef,
//     required this.pathToImage,
//   });
// }

class AdminLandlordTenantInfoPage extends StatefulWidget {
  @override
  _AdminLandlordTenantInfoPageState createState() =>
      _AdminLandlordTenantInfoPageState();
}

class _AdminLandlordTenantInfoPageState
    extends State<AdminLandlordTenantInfoPage> {
  List<Landlord> landlords = [];
  List<Tenant> tenants = [];
  List<Landlord> filteredLandlords = [];
  List<Tenant> filteredTenants = [];
  TextEditingController searchController = TextEditingController();
  int currentPage = 1;
  int itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    fetchLandlords();
    fetchTenants();
  }

  Future<void> fetchLandlords() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Landlords').get();

    setState(() {
      landlords = querySnapshot.docs.map((doc) {
        return Landlord(
          firstName: doc['firstName'],
          lastName: doc['lastName'],
          balance: doc['balance'].toDouble(),
          pathToImage: doc['pathToImage'],
        );
      }).toList();
      filteredLandlords = List.from(landlords);
    });
  }

  QuerySnapshot<Map<String, dynamic>>? _querySnapshot;

  Future<void> fetchTenants() async {
    try {
      _querySnapshot =
          await FirebaseFirestore.instance.collection('Tenants').get();

      setState(() {
        tenants = _querySnapshot!.docs.map((doc1) {
          var doc = doc1.data();
          // print('reached here doc is ${doc.data()}');

          return Tenant(
            firstName: doc['firstName'] ?? '',
            lastName: doc['lastName'] ?? '',
            description: doc['description'] ?? '',
            rating: doc['rating'] ?? 0.0,
            rent: doc['rent'] ?? 0,
            creditPoints: doc['creditPoints'] ?? 0,
            cnicNumber: doc['cnicNumber'] ?? '',
            emailOrPhone: doc['emailOrPhone'] ?? '',
            tasdeeqVerification: doc['tasdeeqVerification'] ?? false,
            policeVerification: false,
            familyMembers: doc['familyMembers'] ?? 0,
            landlordRef: doc['landlordRef'] ?? null,
            pathToImage: doc['pathToImage'] ?? '',
          );
        }).toList();
        filteredTenants = List.from(tenants);
      });
    } catch (e) {
      print('Error is $e');
    }
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

  List<Landlord> getPaginatedLandlords() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (startIndex >= filteredLandlords.length) {
      return [];
    } else if (endIndex >= filteredLandlords.length) {
      return filteredLandlords.sublist(startIndex);
    } else {
      return filteredLandlords.sublist(startIndex, endIndex);
    }
  }

  List<Tenant> getPaginatedTenants() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (startIndex >= filteredTenants.length) {
      return [];
    } else if (endIndex >= filteredTenants.length) {
      return filteredTenants.sublist(startIndex);
    } else {
      return filteredTenants.sublist(startIndex, endIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord & Tenant Info'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  filterLandlords(value);
                  filterTenants(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: const Color(0xff0FA697),
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.lightBlue,
                      tabs: const [
                        Tab(
                          text: 'Landlords',
                        ),
                        Tab(
                          text: 'Tenants',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ListView.builder(
                            itemCount: getPaginatedLandlords().length,
                            itemBuilder: (context, index) {
                              Landlord landlord =
                                  getPaginatedLandlords()[index];

                              return Card(
                                elevation: 2.0,
                                child: ListTile(
                                  leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(landlord.pathToImage!)),
                                  title: Text(
                                    '${landlord.firstName} ${landlord.lastName}',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Balance: ${landlord.balance}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle landlord details
                                  },
                                ),
                              );
                            },
                          ),
                          ListView.builder(
                            itemCount: getPaginatedTenants().length,
                            itemBuilder: (context, index) {
                              Tenant tenant = getPaginatedTenants()[index];

                              return Card(
                                elevation: 2.0,
                                child: ListTile(
                                  leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(tenant.pathToImage!)),
                                  title: Text(
                                    '${tenant.firstName} ${tenant.lastName}',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Rent: ${tenant.rent}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle tenant details
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
    );
  }
}
