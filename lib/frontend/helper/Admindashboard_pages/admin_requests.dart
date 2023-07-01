import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rehnaa/frontend/helper/Admindashboard_pages/admin_requests_property_contracts.dart';

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
            print('withdraw request found doc is ${doc["withdrawRequest"]}');
            for (var i = 0; i < doc["withdrawRequest"].length; i++) {
              // add each request to the adminRequests list
              // var withdrawRequest = doc["withdrawRequest"][i];
              // print('data of this is ${withdrawRequest}');
              // print('data of this is ${withdrawRequest["fullname"]}');
              // print('data of this is ${withdrawRequest["amount"].toString()}');
              // print('data of this is ${withdrawRequest["uid"]}');
              // print('data of this is ${withdrawRequest["paymentMethod"]}');
              // print('data of this is ${withdrawRequest["invoiceNumber"]}');
              // print('data of this is  ${doc["withdrawRequest"][i]["requestID"]}');

              adminRequests.add(
                AdminRequestData(
                  name: doc["withdrawRequest"][i]["fullname"],
                  requestedAmount:
                      doc["withdrawRequest"][i]["amount"].toString(),
                  uid: doc["withdrawRequest"][i]["uid"],
                  cashOrBankTransfer: doc["withdrawRequest"][i]
                      ["paymentMethod"],
                  requestID: doc.id,
                  requestType: 'Landlord Withdraw Request',
                  invoiceNumber: doc["withdrawRequest"][i]["invoiceNumber"],
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
                  requestID: doc.id,
                  requestType: 'Tenant Payment Request',
                  invoiceNumber: doc["paymentRequest"][i]["invoiceNumber"],
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
            // print('rental request found');
            for (var i = 0; i < doc["rentalRequest"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(
                AdminRequestData(
                    name: doc["rentalRequest"][i]["fullname"],
                    requestedAmount:
                        doc["rentalRequest"][i]["property"]["price"].toString(),
                    uid: doc["rentalRequest"][i]["uid"],
                    propertyTitle: doc["rentalRequest"][i]["property"]["title"],
                    propertyLocation: doc["rentalRequest"][i]["property"]
                        ["location"],
                    requestID: doc.id,
                    requestType: 'Tenant Rental Request',
                    propertyLandlordRef: doc["rentalRequest"][i]["property"]
                        ["landlordRef"],
                    propertyID: doc["rentalRequest"][i]["propertyID"]),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error: $e');
          }
        }

        try {
          if (doc['rentAccrualRequest'] != null) {
            // print('rental request found');
            for (var i = 0; i < doc["rentAccrualRequest"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(AdminRequestData(
                name: doc["rentAccrualRequest"][i]["fullname"],
                uid: doc["rentAccrualRequest"][i]["uid"],
                requestType: 'Rent Accrual Request',
                requestID: doc.id,
              ));
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error: $e');
          }
        }

        //TODO add other states of requests if needed
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
  String?
      cashOrBankTransfer; // TODO convert to other forms of payment in the future
  String? requestType;
  String? propertyTitle;
  String? propertyLocation;
  final String requestID;
  DocumentReference<Map<String, dynamic>>? propertyLandlordRef;
  String? propertyID;
  String? invoiceNumber;

  AdminRequestData({
    required this.name,
    this.requestedAmount,
    required this.uid,
    this.cashOrBankTransfer,
    this.requestType,
    this.propertyTitle,
    this.propertyLocation,
    required this.requestID,
    this.propertyLandlordRef,
    this.propertyID,
    this.invoiceNumber,
  });
}

class LandlordWithdrawalCard extends StatelessWidget {
  final AdminRequestData data;

  LandlordWithdrawalCard({
    required this.data,
  });

  TextEditingController _newRentalAmountController = TextEditingController();

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
            // i have multiple cases of data.requestType, so i need to check for each one
            data.requestType == 'Landlord Withdraw Request'
                ? 'Requested Amount: ${data.requestedAmount}'
                : data.requestType == 'Tenant Payment Request'
                    ? 'Payable Amount: ${data.requestedAmount}'
                    : data.requestType == 'Tenant Rental Request'
                        ? 'Rental Amount: ${data.requestedAmount}'
                        : 'Requested Amount: ${data.requestedAmount}',
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
                onPressed: () async {
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
                      // rentpayment will have fields amount date paymenttype propertyRef and tenantRef and landlordRef
                      // with a random id and store this id in a local variable

                      final rentPaymentRef = FirebaseFirestore.instance
                          .collection('rentPayments')
                          .doc();

                      //go to rentPayments firebase collection and create a document with the id stored in the local variable
                      // and set the fields amount date paymenttype propertyRef and tenantRef and landlordRef
                      // with the values from the data object
                      rentPaymentRef.set({
                        //convert requestedAmount to an integer
                        //date should be a firebase timestamp
                        // if payment type is cash set paymenttype to "cash" on "Bank Transfer" make it "banktransfer"
                        'amount': int.parse(data.requestedAmount!),
                        'date': DateTime.now(),
                        'paymentType': data.cashOrBankTransfer == 'Cash'
                            ? 'cash'
                            : 'banktransfer',
                        'propertyRef': null,
                        'tenantRef': null,
                        //landlord ref has to be a document reference to data.uid in Landlord doc
                        'landlordRef': FirebaseFirestore.instance
                            .collection('Landlords')
                            .doc(data.uid),
                        'invoiceNumber': data.invoiceNumber
                      });

                      //reset the state of the page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRequestsPage(),
                        ),
                      );

                      // append the landlord's rentPaymentRef whic is a list of documentreferences to the rentPaymentRef
                      // in the Landlord's document
                      FirebaseFirestore.instance
                          .collection('Landlords')
                          .doc(data.uid)
                          .update({
                        'rentpaymentRef': FieldValue.arrayUnion([
                          rentPaymentRef,
                        ])
                      });
                    } else if (data.requestType == 'Tenant Payment Request') {
                      //payment request
                      //update the tenant's balance
                      FirebaseFirestore.instance
                          .collection('Tenants')
                          .doc(data.uid)
                          .update({
                        'balance': FieldValue.increment(
                            -int.parse(data.requestedAmount!)),
                      });
                      //remove the payment request
                      FirebaseFirestore.instance
                          .collection('AdminRequests')
                          .doc(data.requestID)
                          .delete();
                      //send a notification to the tenant by accessing the tenant's uid on Collection 'Notifications'
                      // and appending to the array called 'notifications' which has fields amount and title
                      FirebaseFirestore.instance
                          .collection('Notifications')
                          .doc(data.uid)
                          .update({
                        'notifications': FieldValue.arrayUnion([
                          {
                            'amount': data.requestedAmount,
                            'title': 'Payment Request Accepted',
                          }
                        ])
                      });
                      // set isWithdraw in Tenant's document to false
                      FirebaseFirestore.instance
                          .collection('Tenants')
                          .doc(data.uid)
                          .update({
                        'isWithdraw': false,
                      });
                      //create a rentPayment firebase document that will be used to track the payment
                      // rentpayment will have fields amount date paymenttype propertyRef and tenantRef and landlordRef
                      // with a random id and store this id in a local variable
                      final rentPaymentRef = FirebaseFirestore.instance
                          .collection('rentPayments')
                          .doc();

                      //go to rentPayments firebase collection and create a document with the id stored in the local variable
                      // and set the fields amount date paymenttype propertyRef and tenantRef and landlordRef
                      // with the values from the data object
                      rentPaymentRef.set({
                        //convert requestedAmount to an integer
                        //date should be a firebase timestamp
                        // if payment type is cash set paymenttype to "cash" on "Bank Transfer" make it "banktransfer"
                        'amount': int.parse(data.requestedAmount!),
                        'date': DateTime.now(),
                        'paymentType': data.cashOrBankTransfer == 'Cash'
                            ? 'cash'
                            : 'banktransfer',
                        'propertyRef': null,
                        //tenant ref has to be a document reference to data.uid in Tenant doc
                        'tenantRef': FirebaseFirestore.instance
                            .collection('Tenants')
                            .doc(data.uid),
                        'landlordRef': null,
                        'invoiceNumber': data.invoiceNumber
                      });

                      // set the tenant's rentPaymentRef to tenant's own id reference which is data.requestID
                      FirebaseFirestore.instance
                          .collection('Tenants')
                          .doc(data.uid)
                          .update({
                        'rentpaymentRef': FieldValue.arrayUnion([
                          rentPaymentRef,
                        ])
                      });

                      //reset the state of the page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRequestsPage(),
                        ),
                      );
                    }
                  } else if (data.requestType == 'Tenant Rental Request') {
                    //rental request

                    //before updating with data.requestedamount
                    //prompt the admin to enter a new rental amount
                    // print('mai idher hee hon');
                    // pop up a dialog box to enter the new rental amount

                    //newrenatal amount is coming as null there is some mistake
                    //fix it use _newRentalAmountController

                    final newRentalAmount = await showDialog<String?>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Enter New Rental Amount'),
                        content: TextField(
                          controller: _newRentalAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'New Rental Amount',
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
                              Navigator.pop(
                                  context, _newRentalAmountController?.text);
                            },
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    );

                    //update the tenant's balance to show they owe this amount
                    // this is done by adding the requested amount to the tenant's balance
                    if (newRentalAmount != null) {
                      FirebaseFirestore.instance
                          .collection('Tenants')
                          .doc(data.uid)
                          .update({
                        'rent':
                            FieldValue.increment(int.parse(newRentalAmount)),
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('Tenants')
                          .doc(data.uid)
                          .update({
                        'rent': FieldValue.increment(
                            int.parse(data.requestedAmount!)),
                      });
                    }

                    //remove the rental request
                    FirebaseFirestore.instance
                        .collection('AdminRequests')
                        .doc(data.requestID)
                        .delete();
                    //send a notification to the tenant by accessing the tenant's uid on Collection 'Notifications'
                    // and appending to the array called 'notifications' which has fields amount and title
                    FirebaseFirestore.instance
                        .collection('Notifications')
                        .doc(data.uid)
                        .update({
                      'notifications': FieldValue.arrayUnion([
                        {
                          'amount': data.requestedAmount,
                          'title': 'Rental Request Accepted',
                        }
                      ])
                    });

                    //get property's address from the property's document
                    // store in a local variable

                    var propAddress = await FirebaseFirestore.instance
                        .collection('Properties')
                        .doc(data.propertyID)
                        .get()
                        .then((value) => value.data()!['address']);

                    // set isWithdraw in Tenant's document to false and set propertyRef to the property's document reference
                    FirebaseFirestore.instance
                        .collection('Tenants')
                        .doc(data.uid)
                        .set({
                      'isWithdraw': false,
                      'propertyRef': FirebaseFirestore.instance
                          .collection('Properties')
                          .doc(data.propertyID),
                      'address': propAddress ?? 'No address provided',
                    }, SetOptions(merge: true));

                    //set properties tenantref to the tenant's document reference
                    FirebaseFirestore.instance
                        .collection('Properties')
                        .doc(data.propertyID)
                        .update({
                      'tenantRef': FirebaseFirestore.instance
                          .collection('Tenants')
                          .doc(data.uid),
                    });

                    //set tenants landlordref to the property's landlordref
                    // first get landlordref from the property
                    // then set the tenant's landlordref to the property's landlordref
                    DocumentReference<Map<String, dynamic>>? landlordRef =
                        data.propertyLandlordRef;

                    //set the tenant's landlordref to the tenant's landlordref
                    FirebaseFirestore.instance
                        .collection('Tenants')
                        .doc(data.uid)
                        .update({
                      'landlordRef': landlordRef,
                    });

                    // set the landlord's tenantRef to the document reference of tenant's uid
                    // tenants uid is stored in data.uid
                    // tenantRef is a list of document references append tenant ref to it
                    FirebaseFirestore.instance
                        .collection('Landlords')
                        .doc(landlordRef!.id)
                        .update({
                      'tenantRef': FieldValue.arrayUnion([
                        FirebaseFirestore.instance
                            .collection('Tenants')
                            .doc(data.uid),
                      ])
                    });

                    //a new page should be called for setting the contract

                    // make a navigation to that page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminPropertyContractsPage(
                          landlordID: landlordRef.id,
                          tenantID: data.uid,
                        ),
                      ),
                    );
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
