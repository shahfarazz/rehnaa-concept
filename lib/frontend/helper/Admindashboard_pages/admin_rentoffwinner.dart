import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class Tenant {
  final String firstName;
  final String lastName;
  final double rating;
  final int rent;
  final String propertyDetails;
  final String emailOrPhone;
  final int familyMembers;
  final String? pathToImage;
  final String docid;

  Tenant({
    required this.firstName,
    required this.lastName,
    required this.rating,
    required this.rent,
    required this.propertyDetails,
    required this.emailOrPhone,
    required this.familyMembers,
    required this.pathToImage,
    required this.docid,
  });
}

class AdminRentOffWinnerPage extends StatefulWidget {
  @override
  _AdminRentOffWinnerPageState createState() => _AdminRentOffWinnerPageState();
}

class _AdminRentOffWinnerPageState extends State<AdminRentOffWinnerPage> {
  List<Tenant> tenants = [];
  List<Tenant> filteredTenants = [];
  TextEditingController searchController = TextEditingController();
  int currentPage = 1;
  int itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    fetchTenants();
  }

  Future<void> fetchTenants() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('Tenants').get();

      setState(() {
        tenants = querySnapshot.docs.map((doc1) {
          var doc = doc1.data();
          return Tenant(
            firstName: doc['firstName'] ?? '',
            lastName: doc['lastName'] ?? '',
            rating: doc['rating'] ?? 0.0,
            rent: doc['rent'] ?? 0,
            propertyDetails: doc['propertyDetails'] ?? '',
            emailOrPhone: doc['emailOrPhone'] ?? '',
            familyMembers: doc['familyMembers'] ?? 0,
            pathToImage: doc['pathToImage'] ?? '',
            docid: doc1.id,
          );
        }).toList();
        filteredTenants = List.from(tenants);
      });
    } catch (e) {
      print('Error in fetching tenants: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    final totalPages = (filteredTenants.length / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Off Winners'),
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
                  filterTenants(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Text(
              'Click to add discount',
              style: GoogleFonts.montserrat(
                fontSize: 24.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: getPaginatedTenants().length,
                itemBuilder: (context, index) {
                  Tenant tenant = getPaginatedTenants()[index];

                  return Card(
                    elevation: 2.0,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          tenant.pathToImage ?? 'assets/placeholder.png',
                        ),
                      ),
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
                      onTap: () async {
                        double? discount = await showDialog<double>(
                          context: context,
                          builder: (BuildContext context) {
                            TextEditingController controller =
                                TextEditingController();
                            return AlertDialog(
                              title: const Text('Enter Discount'),
                              content: TextField(
                                controller: controller,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'Percentage discount',
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Confirm'),
                                  onPressed: () {
                                    double? enteredDiscount =
                                        double.tryParse(controller.text);
                                    if (enteredDiscount != null &&
                                        enteredDiscount >= 0 &&
                                        enteredDiscount <= 100) {
                                      Navigator.of(context)
                                          .pop(enteredDiscount);
                                    } else {
                                      Fluttertoast.showToast(
                                        msg:
                                            'Please enter a valid discount between 0 and 100.',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        if (discount != null) {
                          // Apply the discount to the tenant's rent
                          FirebaseFirestore.instance
                              .collection('Tenants')
                              .doc(tenant.docid)
                              .update({
                            'rent': tenant.rent * (1 - discount / 100),
                          });
                        }

                        // Refresh the list of tenants
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminRentOffWinnerPage(),
                          ),
                        );
                      },
                    ),
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
                  'Page $currentPage of $totalPages',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      if (currentPage < totalPages) {
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
