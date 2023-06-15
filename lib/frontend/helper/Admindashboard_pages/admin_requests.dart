import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdminRequestsPage extends StatefulWidget {
  const AdminRequestsPage({super.key});

  @override
  _AdminRequestsPageState createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  Future<void> _getRequests() async {
    FirebaseFirestore.instance
        .collection('AdminRequests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        try {
          if (doc["withdrawRequest"] != null) {
            // if yes, then loop through the array
            for (var i = 0; i < doc["withdrawRequest"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(
                AdminRequestData(
                  name: doc["withdrawRequest"][i]["fullname"],
                  requestedAmount:
                      doc["withdrawRequest"][i]["amount"].toString(),
                  uid: doc["withdrawRequest"][i]["uid"],
                  cashOrBankTransfer: doc["withdrawRequest"][i]
                      ["paymentMethod"],
                  requestType: 'Landlord Withdraw Request',
                  requestID: doc.id,
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error: $e');
          }
        }

        try {
          if (doc["paymentRequest"] != null) {
            for (var i = 0; i < doc["paymentRequest"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(
                AdminRequestData(
                  name: doc["paymentRequest"][i]["fullname"],
                  requestedAmount:
                      doc["paymentRequest"][i]["amount"].toString(),
                  uid: doc["paymentRequest"][i]["uid"],
                  cashOrBankTransfer: doc["paymentRequest"][i]["paymentMethod"],
                  requestType: 'Tenant Payment Request',
                  requestID: doc.id,
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error: $e');
          }
        }

        try {
          if (doc['rentalRequest'] != null) {
            print('rental request found');
            for (var i = 0; i < doc["rentalRequest"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(
                AdminRequestData(
                    name: doc["rentalRequest"][i]["fullname"],
                    requestedAmount:
                        doc["rentalRequest"][i]["amount"].toString(),
                    uid: doc["rentalRequest"][i]["uid"],
                    requestType: 'Rental  Request',
                    propertyTitle: doc["rentalRequest"][i]["property"]["title"],
                    propertyLocation: doc["rentalRequest"][i]["property"]
                        ["location"],
                    requestID: doc.id),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error: $e');
          }
        }
      }
      setState(() {
        displayedRequests.addAll(adminRequests);
      });
    });
  }

  List<AdminRequestData> adminRequests = [];

  List<AdminRequestData> displayedRequests = [];

  TextEditingController searchController = TextEditingController();

  int currentPage = 1;
  int itemsPerPage = 2;

  @override
  void initState() {
    super.initState();
    displayedRequests.addAll(adminRequests);
    _getRequests();
  }

  void filterRequests(String query) {
    setState(() {
      displayedRequests = adminRequests
          .where((request) =>
              request.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<AdminRequestData> getPaginatedRequests() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (endIndex >= displayedRequests.length) {
      return displayedRequests.sublist(startIndex);
    } else {
      return displayedRequests.sublist(startIndex, endIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Requests'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            // borderRadius: BorderRadius.circular(24),
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
      body: SingleChildScrollView(
        // child: Padding(
        // padding: EdgeInsets.fromLTRB(
        //   // size.width * 0.0,
        //   // size.height * 0.1,
        //   0,
        //   0,
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   children: [
            //     IconButton(
            //       icon: Icon(
            //         Icons.arrow_back,
            //         color: Colors.green,
            //       ),
            //       onPressed: () {
            //         Navigator.pop(context);
            //       },
            //     ),
            //   ],
            // ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(
            //     size.width * 0.1,
            //     size.height * 0.0,
            //     0,
            //     0,
            //   ),
            //   child: Text(
            //     'Requests',
            //     style: TextStyle(
            //       fontSize: 34,
            //       fontWeight: FontWeight.bold,
            //       fontFamily: 'Montserrat',
            //       color: Colors.green,*
            //     ),
            //   ),
            // ),
            // SizedBox(height: size.height * 0.07),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(
            //     size.width * 0.1,
            //     size.height * 0.0,
            //     0,
            //     0,
            //   ),
            //   child: Text(
            //     'Withdrawal Requests:',
            //     style: TextStyle(
            //       fontSize: 20,
            //       fontFamily: 'Montserrat',
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: filterRequests,
                decoration: const InputDecoration(
                  labelText: 'Search(name)',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: getPaginatedRequests().length,
              itemBuilder: (context, index) {
                final request = getPaginatedRequests()[index];
                return LandlordWithdrawalCard(data: request);
              },
            ),
            SizedBox(height: size.height * 0.05),
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
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      final maxPage =
                          (displayedRequests.length / itemsPerPage).ceil();
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
      // ),
    );
  }
}

class AdminRequestData {
  final String name;
  String? requestedAmount;
  final String uid;
  String? cashOrBankTransfer;
  String? requestType;
  String? propertyTitle;
  String? propertyLocation;
  final String requestID;

  AdminRequestData({
    required this.name,
    this.requestedAmount,
    required this.uid,
    this.cashOrBankTransfer,
    this.requestType,
    this.propertyTitle,
    this.propertyLocation,
    required this.requestID,
  });
}

class LandlordWithdrawalCard extends StatelessWidget {
  final AdminRequestData data;

  const LandlordWithdrawalCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Request Type: ${data.requestType}',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Name: ${data.name}',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Requested Amount: ${data.requestedAmount}',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'UID: ${data.uid}',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Cash/BankTransfer: ${data.cashOrBankTransfer}',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          data.propertyTitle.isNull
              ? const SizedBox()
              : Text(
                  'Property Title: ${data.propertyTitle}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
          const SizedBox(height: 10),
          data.propertyLocation.isNull
              ? const SizedBox()
              : Text(
                  'Property Location: ${data.propertyLocation}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle accept button press
                  //check if i can access the data here by printing all the data
                  // print all possible fields in the data object
                  if (data.propertyLocation.isNull) {
                    //withdrawal request or payment request
                    if (data.requestType == 'Landlord Withdraw Request') {
                      //withdrawal request
                      //update the landlord's balance
                      FirebaseFirestore.instance
                          .collection('Landlords')
                          .doc(data.uid)
                          .update({
                        'balance': FieldValue.increment(
                            -int.parse(data.requestedAmount!)),
                      });
                      //remove the withdrawal request
                      FirebaseFirestore.instance
                          .collection('AdminRequests')
                          .doc(data.requestID)
                          .delete();
                      //send a notification to the landlord by accessing the landlord's uid on Collection 'Notifications'
                      // and appending to the array called 'notifications' which has fields amount and title
                      FirebaseFirestore.instance
                          .collection('Notifications')
                          .doc(data.uid)
                          .update({
                        'notifications': FieldValue.arrayUnion([
                          {
                            'amount': data.requestedAmount,
                            'title': 'Withdrawal Request Accepted',
                          }
                        ])
                      });
                      // set isWithdraw in Landlord's document to false
                      FirebaseFirestore.instance
                          .collection('Landlords')
                          .doc(data.uid)
                          .update({
                        'isWithdraw': false,
                      });
                      //create a rentPayment firebase document that will be used to track the payment
                      FirebaseFirestore.instance
                          .collection('RentPayment')
                          .doc(data.uid)
                          .set({
                        'amount': data.requestedAmount,
                        'date': DateTime.now(),
                        'isPaid': false,
                        'isWithdraw': true,
                        'landlordUID': data.uid,
                        'tenantUID': '',
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Handle deny button press
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Deny',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
