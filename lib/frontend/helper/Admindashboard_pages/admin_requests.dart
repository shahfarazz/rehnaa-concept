import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/helper/Admindashboard_pages/admin_requests_property_contracts.dart';

import '../../Screens/Admin/admindashboard.dart';

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
                  altTenantName: doc["withdrawRequest"][i]["tenantname"],
                  withinArrayID: doc["withdrawRequest"][i]["requestID"],
                  docTimestamp: doc["withdrawRequest"][i]["timestamp"],
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
                  withinArrayID: doc["paymentRequest"][i]["requestID"],
                  docTimestamp: doc["paymentRequest"][i]["timestamp"],
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error222: $e');
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
                  withinArrayID: doc["rentalRequest"][i]["requestID"],
                  propertyID: doc["rentalRequest"][i]["propertyID"],
                  docTimestamp: doc["rentalRequest"][i]["timestamp"],
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
          if (doc['rentAccrualRequest'] != null) {
            // print('rental request found');
            for (var i = 0; i < doc["rentAccrualRequest"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(AdminRequestData(
                name: doc["rentAccrualRequest"][i]["fullname"],
                uid: doc["rentAccrualRequest"][i]["uid"],
                requestType: 'Rent Accrual Request',
                requestID: doc.id,
                docTimestamp: doc["rentAccrualRequest"][i]["timestamp"],
              ));
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error: $e');
          }
        }
        try {
          if (doc["withdrawRequestDealer"] != null) {
            for (var i = 0; i < doc["withdrawRequestDealer"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(
                AdminRequestData(
                  name: doc["withdrawRequestDealer"][i]["fullname"],
                  requestedAmount:
                      doc["withdrawRequestDealer"][i]["amount"].toString(),
                  uid: doc["withdrawRequestDealer"][i]["uid"],
                  cashOrBankTransfer: doc["withdrawRequestDealer"][i]
                      ["paymentMethod"],
                  requestID: doc.id,
                  requestType: 'Dealer Withdraw Request',
                  invoiceNumber: doc["withdrawRequestDealer"][i]
                      ["invoiceNumber"],
                  withinArrayID: doc["withdrawRequestDealer"][i]["requestID"],
                  altTenantName: doc["withdrawRequestDealer"][i]["tenantname"],
                  docTimestamp: doc["withdrawRequestDealer"][i]["timestamp"],
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error222: $e');
          }
        }

        //try catch for rentAdvanceRequest
        try {
          if (doc["rentAdvanceRequest"] != null) {
            for (var i = 0; i < doc["rentAdvanceRequest"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(
                AdminRequestData(
                  name: doc["rentAdvanceRequest"][i]["fullname"],
                  // requestedAmount:
                  //     doc["rentAdvanceRequest"][i]["amount"].toString(),
                  uid: doc["rentAdvanceRequest"][i]["uid"],
                  // cashOrBankTransfer: doc["rentAdvanceRequest"][i]
                  //     ["paymentMethod"],
                  requestID: doc.id,
                  requestType: 'Rent Advance Request',
                  // invoiceNumber: doc["rentAdvanceRequest"][i]["invoiceNumber"],
                  withinArrayID: doc["rentAdvanceRequest"][i]["requestID"],
                  // altTenantName: doc["rentAdvanceRequest"][i]["tenantname"],
                  docTimestamp: doc["rentAdvanceRequest"][i]["timestamp"],
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error222: $e');
          }
        }

        //try catch for interestFreeLoanRequest
        try {
          if (doc["interestFreeLoanRequest"] != null) {
            for (var i = 0; i < doc["interestFreeLoanRequest"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(
                AdminRequestData(
                  name: doc["interestFreeLoanRequest"][i]["fullname"],
                  // requestedAmount:
                  //     doc["interestFreeLoanRequest"][i]["amount"].toString(),
                  uid: doc["interestFreeLoanRequest"][i]["uid"],
                  // cashOrBankTransfer: doc["interestFreeLoanRequest"][i]
                  //     ["paymentMethod"],
                  requestID: doc.id,
                  requestType: 'Interest Free Loan Request',
                  // invoiceNumber: doc["interestFreeLoanRequest"][i]["invoiceNumber"],
                  withinArrayID: doc["interestFreeLoanRequest"][i]["requestID"],
                  // altTenantName: doc["interestFreeLoanRequest"][i]["tenantname"],
                  docTimestamp: doc["interestFreeLoanRequest"][i]["timestamp"],
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error222: $e');
          }
        }

        //try catch for propertyApprovalRequest
        try {
          if (doc["propertyApprovalRequest"] != null) {
            for (var i = 0; i < doc["propertyApprovalRequest"].length; i++) {
              // add each request to the adminRequests list

              adminRequests.add(
                AdminRequestData(
                  name: doc["propertyApprovalRequest"][i]["fullname"],
                  // requestedAmount:
                  //     doc["propertyApprovalRequest"][i]["amount"].toString(),
                  uid: doc["propertyApprovalRequest"][i]["uid"],
                  // cashOrBankTransfer: doc["propertyApprovalRequest"][i]
                  //     ["paymentMethod"],
                  requestID: doc.id,
                  requestType: 'Property Approval Request',
                  // invoiceNumber: doc["propertyApprovalRequest"][i]["invoiceNumber"],
                  withinArrayID: doc["propertyApprovalRequest"][i]["requestID"],
                  // altTenantName: doc["propertyApprovalRequest"][i]["tenantname"],
                  docTimestamp: doc["propertyApprovalRequest"][i]["timestamp"],
                  dataFields: doc["propertyApprovalRequest"][i]["dataFields"],
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error222: $e');
          }
        }

        //TODO add other states of requests if needed
      }
      setState(() {
        displayedRequests.addAll(adminRequests);
        displayedRequests
            .sort((a, b) => b.docTimestamp.compareTo(a.docTimestamp));
        //reverse to make it descending
        // displayedRequests = displayedRequests.reversed.toList();
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

    return FutureBuilder(
        future: _getRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xff0FA697),
                ),
              ),
            );
          } else {
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
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminDashboard(),
                      ),
                    );
                  },
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
                    getPaginatedRequests().isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: getPaginatedRequests().length,
                            // reverse: true,
                            itemBuilder: (context, index) {
                              final request = getPaginatedRequests()[index];
                              return LandlordWithdrawalCard(data: request);
                            },
                          )
                        : Card(
                            child: Center(
                                child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Icon(
                                Icons.warning,
                                size: 50,
                                color: Colors.red,
                              ),
                              Text(
                                'No requests found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ))),
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
                                  (displayedRequests.length / itemsPerPage)
                                      .ceil();
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
        });
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
  String? altTenantName;
  String? withinArrayID;
  Timestamp docTimestamp;
  var dataFields;

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
    this.altTenantName,
    this.withinArrayID,
    required this.docTimestamp,
    this.dataFields,
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
                  print('data.uid: ${data.uid}');
                  print('data.requestType: ${data.requestType}');

                  //showdialog with a circular progress indicator
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const Center(
                        child: SpinKitFadingCube(
                          color: Color.fromARGB(255, 30, 197, 83),
                        ),
                      );
                    },
                  );

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
                          .get()
                          .then((snapshot) {
                        if (snapshot.exists) {
                          final List<dynamic> withdrawRequestArray =
                              snapshot.get('withdrawRequest') ?? [];

                          final updatedArray = List.from(withdrawRequestArray)
                            ..removeWhere((element) =>
                                element['requestID'] == data.withinArrayID);

                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(data.requestID)
                              .update({'withdrawRequest': updatedArray});
                        }
                      });
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
                        'invoiceNumber': data.invoiceNumber,
                        'tenantname': data.altTenantName
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
                          .get()
                          .then((snapshot) {
                        if (snapshot.exists) {
                          final List<dynamic> withdrawRequestArray =
                              snapshot.get('paymentRequest') ?? [];

                          final updatedArray = List.from(withdrawRequestArray)
                            ..removeWhere((element) =>
                                element['requestID'] == data.withinArrayID);

                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(data.requestID)
                              .update({'paymentRequest': updatedArray});
                        }
                      });

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
                    } else if (data.requestType == 'Rent Accrual Request') {
                      FirebaseFirestore.instance
                          .collection('Notifications')
                          .doc(data.uid)
                          .update({
                        'notifications': FieldValue.arrayUnion([
                          {
                            // 'amount': data.requestedAmount,
                            'title':
                                'Your Rent Accrual request has been accepted, somebody from the Rehnaa team will contact you shortly',
                          }
                        ])
                      });

                      FirebaseFirestore.instance
                          .collection('AdminRequests')
                          .doc(data.requestID)
                          .get()
                          .then((snapshot) {
                        if (snapshot.exists) {
                          final List<dynamic> withdrawRequestArray =
                              snapshot.get('rentAccrualRequest') ?? [];

                          final updatedArray = List.from(withdrawRequestArray)
                            ..removeWhere((element) =>
                                element['requestID'] == data.withinArrayID);

                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(data.requestID)
                              .update({'rentAccrualRequest': updatedArray});
                        }
                      });
                      //reset the state of the page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRequestsPage(),
                        ),
                      );
                    } else if (data.requestType == 'Dealer Withdraw Request') {
                      //withdrawal request
                      //update the landlord's balance
                      print('reached here');
                      FirebaseFirestore.instance
                          .collection('Dealers')
                          .doc(data.uid)
                          .update({
                        'balance': FieldValue.increment(
                            -int.parse(data.requestedAmount!)),
                      });
                      //remove the withdrawal request

                      FirebaseFirestore.instance
                          .collection('AdminRequests')
                          .doc(data.requestID)
                          .get()
                          .then((snapshot) {
                        if (snapshot.exists) {
                          final List<dynamic> withdrawRequestArray =
                              snapshot.get('withdrawRequestDealer') ?? [];

                          final updatedArray = List.from(withdrawRequestArray)
                            ..removeWhere((element) =>
                                element['requestID'] == data.withinArrayID);

                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(data.requestID)
                              .update({'withdrawRequestDealer': updatedArray});
                        }
                      });
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
                          .collection('Dealers')
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
                        'landlordRef': null,
                        'dealerRef': FirebaseFirestore.instance
                            .collection('Dealers')
                            .doc(data.uid),
                        'invoiceNumber': data.invoiceNumber,
                        'tenantname': data.altTenantName
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
                          .collection('Dealers')
                          .doc(data.uid)
                          .update({
                        'rentpaymentRef': FieldValue.arrayUnion([
                          rentPaymentRef,
                        ])
                      });
                    } else if (data.requestType == 'Rent Advance Request') {
                      //rent advance request

                      //remove the withdrawal request

                      FirebaseFirestore.instance
                          .collection('AdminRequests')
                          .doc(data.requestID)
                          .get()
                          .then((snapshot) {
                        if (snapshot.exists) {
                          final List<dynamic> withdrawRequestArray =
                              snapshot.get('rentAdvanceRequest') ?? [];

                          final updatedArray = List.from(withdrawRequestArray)
                            ..removeWhere((element) =>
                                element['requestID'] == data.withinArrayID);

                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(data.requestID)
                              .update({'rentAdvanceRequest': updatedArray});
                        }
                      });
                      //send a notification to the tenant
                      // by accessing the tenant's uid on Collection 'Notifications'
                      // and appending to the array called 'notifications' which has fields amount and title
                      FirebaseFirestore.instance
                          .collection('Notifications')
                          .doc(data.uid)
                          .update({
                        'notifications': FieldValue.arrayUnion([
                          {
                            // 'amount': data.requestedAmount,
                            'title': 'Rent Advance Request Accepted',
                          }
                        ])
                      });

                      //reset the state of the page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRequestsPage(),
                        ),
                      );
                    } else if (data.requestType ==
                        'Interest Free Loan Request') {
                      //remove the withdrawal request

                      FirebaseFirestore.instance
                          .collection('AdminRequests')
                          .doc(data.requestID)
                          .get()
                          .then((snapshot) {
                        if (snapshot.exists) {
                          final List<dynamic> withdrawRequestArray =
                              snapshot.get('interestFreeLoanRequest') ?? [];

                          final updatedArray = List.from(withdrawRequestArray)
                            ..removeWhere((element) =>
                                element['requestID'] == data.withinArrayID);

                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(data.requestID)
                              .update(
                                  {'interestFreeLoanRequest': updatedArray});
                        }
                      });
                      //send a notification to the tenant
                      // by accessing the tenant's uid on Collection 'Notifications'
                      // and appending to the array called 'notifications' which has fields amount and title
                      FirebaseFirestore.instance
                          .collection('Notifications')
                          .doc(data.uid)
                          .update({
                        'notifications': FieldValue.arrayUnion([
                          {
                            // 'amount': data.requestedAmount,
                            'title': 'Interest Free Loan Request Accepted',
                          }
                        ])
                      });

                      //reset the state of the page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRequestsPage(),
                        ),
                      );
                    } else if (data.requestType ==
                        'Property Approval Request') {
                      //property approval request

                      print('reached here222');

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Admin Approval'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: data.dataFields.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String key =
                                      data.dataFields.keys.elementAt(index);
                                  dynamic value =
                                      data.dataFields.values.elementAt(index);

                                  return ListTile(
                                    title: Text(key),
                                    subtitle: Text(value.toString()),
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); // Return false if rejected
                                },
                                child: Text('Reject'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(true); // Return true if approved
                                },
                                child: Text('Approve'),
                              ),
                            ],
                          );
                        },
                      ).then((value) {
                        if (value == true) {
                          // Continue with the code below
                          //remove the withdrawal request

                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(data.requestID)
                              .get()
                              .then((snapshot) {
                            if (snapshot.exists) {
                              final List<dynamic> withdrawRequestArray =
                                  snapshot.get('propertyApprovalRequest') ?? [];

                              final updatedArray = List.from(
                                  withdrawRequestArray)
                                ..removeWhere((element) =>
                                    element['requestID'] == data.withinArrayID);

                              FirebaseFirestore.instance
                                  .collection('AdminRequests')
                                  .doc(data.requestID)
                                  .update({
                                'propertyApprovalRequest': updatedArray
                              });
                            }
                          });
                          //send a notification to the landlord
                          // by accessing the landlord's uid on Collection 'Notifications'
                          // and appending to the array called 'notifications' which has fields amount and title
                          FirebaseFirestore.instance
                              .collection('Notifications')
                              .doc(data.uid)
                              .update({
                            'notifications': FieldValue.arrayUnion([
                              {
                                // 'amount': data.requestedAmount,
                                'title': 'Property Approval Request Accepted',
                              }
                            ])
                          });
                          //create document of property in the Properties collection
                          //with the dataFields of the request

                          //create a new doc in the properties collection
                          //and save its uid and then save the dataFields in it
                          var docRef = FirebaseFirestore.instance
                              .collection('Properties')
                              .doc();

                          var landlordRef = FirebaseFirestore.instance
                              .collection('Landlords')
                              .doc(data.uid);

                          docRef.set(data.dataFields);
                          docRef.update({
                            'landlordRef': landlordRef,
                            'imagePath': data.dataFields['pathToImage']
                          });
                          landlordRef.update({
                            'propertyRef': FieldValue.arrayUnion([docRef]),
                          });

                          //reset the state of the page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRequestsPage(),
                            ),
                          );

                          //
                        } else {
                          // Return to the admin requests page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRequestsPage(),
                            ),
                          );
                        }
                      });
                    }
                    print('property.requestType is ${data.requestType}');
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
                        'balance':
                            FieldValue.increment(int.parse(newRentalAmount)),
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('Tenants')
                          .doc(data.uid)
                          .update({
                        'balance': FieldValue.increment(
                            int.parse(data.requestedAmount!)),
                      });
                    }

                    //remove the rental request
                    FirebaseFirestore.instance
                        .collection('AdminRequests')
                        .doc(data.requestID)
                        .get()
                        .then((snapshot) {
                      if (snapshot.exists) {
                        final List<dynamic> withdrawRequestArray =
                            snapshot.get('rentalRequest') ?? [];

                        final updatedArray = List.from(withdrawRequestArray)
                          ..removeWhere((element) =>
                              element['requestID'] == data.withinArrayID);

                        FirebaseFirestore.instance
                            .collection('AdminRequests')
                            .doc(data.requestID)
                            .update({'rentalRequest': updatedArray});
                      }
                    });
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

                    // Update Properties's isRequestedbyTenants field
                    FirebaseFirestore.instance
                        .collection('Properties')
                        .doc(data.propertyID)
                        .update({
                      'isRequestedByTenants': FieldValue.arrayRemove([data.uid])
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

                  // Navigator.pop(context);
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
                onPressed: () async {
                  print('data.uid: ${data.uid}');
                  print('data.requestType: ${data.requestType}');
                  // Handle deny button press
                  // remove the request from the admin request collection
                  await FirebaseFirestore.instance
                      .collection('Notifications')
                      .doc(data.uid)
                      .update({
                    'notifications': FieldValue.arrayUnion([
                      {
                        'title': 'Your request has been denied',
                      }
                    ])
                  });

                  if (data.requestType == 'Landlord Withdraw Request') {
                    print('data.requestID: ${data.requestID}');
                    await FirebaseFirestore.instance
                        .collection('AdminRequests')
                        .doc(data.requestID)
                        .get()
                        .then((snapshot) {
                      if (snapshot.exists) {
                        final List<dynamic> withdrawRequestArray =
                            snapshot.get('withdrawRequest') ?? [];

                        final updatedArray = List.from(withdrawRequestArray)
                          ..removeWhere((element) =>
                              element['requestID'] == data.withinArrayID);

                        FirebaseFirestore.instance
                            .collection('AdminRequests')
                            .doc(data.requestID)
                            .update({'withdrawRequest': updatedArray});

                        FirebaseFirestore.instance
                            .collection('Landlords')
                            .doc(data.uid)
                            .update({
                          'isWithdraw': false,
                        });
                      }
                    });
                  } else if (data.requestType == 'Tenant Payment Request') {
                    await FirebaseFirestore.instance
                        .collection('AdminRequests')
                        .doc(data.requestID)
                        .get()
                        .then((snapshot) {
                      if (snapshot.exists) {
                        final List<dynamic> withdrawRequestArray =
                            snapshot.get('paymentRequest') ?? [];

                        final updatedArray = List.from(withdrawRequestArray)
                          ..removeWhere((element) =>
                              element['requestID'] == data.withinArrayID);

                        FirebaseFirestore.instance
                            .collection('AdminRequests')
                            .doc(data.requestID)
                            .update({'paymentRequest': updatedArray});
                      }

                      FirebaseFirestore.instance
                          .collection('Tenants')
                          .doc(data.uid)
                          .update({
                        'isWithdraw': false,
                      });
                    });
                  } else if (data.requestType == 'Tenant Rental Request') {
                    //remove the rental request
                    await FirebaseFirestore.instance
                        .collection('AdminRequests')
                        .doc(data.requestID)
                        .get()
                        .then((snapshot) {
                      if (snapshot.exists) {
                        final List<dynamic> withdrawRequestArray =
                            snapshot.get('rentalRequest') ?? [];

                        print('prev array: $withdrawRequestArray');

                        final updatedArray = List.from(withdrawRequestArray)
                          ..removeWhere((element) =>
                              element['requestID'] == data.withinArrayID);

                        print('new array: $updatedArray');

                        FirebaseFirestore.instance
                            .collection('AdminRequests')
                            .doc(data.requestID)
                            .update({'rentalRequest': updatedArray});
                      }
                    });
                    // Update Properties's isRequestedbyTenants field
                    FirebaseFirestore.instance
                        .collection('Properties')
                        .doc(data.propertyID)
                        .update({
                      'isRequestedByTenants': FieldValue.arrayRemove([data.uid])
                    });
                  } else if (data.requestType == 'Rent Accrual Request') {
                    await FirebaseFirestore.instance
                        .collection('AdminRequests')
                        .doc(data.requestID)
                        .get()
                        .then((snapshot) {
                      if (snapshot.exists) {
                        final List<dynamic> withdrawRequestArray =
                            snapshot.get('rentAccrualRequest') ?? [];

                        final updatedArray = List.from(withdrawRequestArray)
                          ..removeWhere((element) =>
                              element['requestID'] == data.withinArrayID);

                        FirebaseFirestore.instance
                            .collection('AdminRequests')
                            .doc(data.requestID)
                            .update({'rentAccrualRequest': updatedArray});
                      }
                    });
                  } else if (data.requestType == 'Dealer Withdraw Request') {
                    await FirebaseFirestore.instance
                        .collection('AdminRequests')
                        .doc(data.requestID)
                        .get()
                        .then((snapshot) {
                      if (snapshot.exists) {
                        final List<dynamic> withdrawRequestArray =
                            snapshot.get('withdrawRequestDealer') ?? [];

                        final updatedArray = List.from(withdrawRequestArray)
                          ..removeWhere((element) =>
                              element['requestID'] == data.withinArrayID);

                        FirebaseFirestore.instance
                            .collection('AdminRequests')
                            .doc(data.requestID)
                            .update({'withdrawRequestDealer': updatedArray});

                        FirebaseFirestore.instance
                            .collection('Dealers')
                            .doc(data.uid)
                            .update({
                          'isWithdraw': false,
                        });
                      }
                    });
                  } else if (data.requestType == 'Rent Advance Request') {
                    await FirebaseFirestore.instance
                        .collection('AdminRequests')
                        .doc(data.requestID)
                        .get()
                        .then((snapshot) {
                      if (snapshot.exists) {
                        final List<dynamic> withdrawRequestArray =
                            snapshot.get('rentAdvanceRequest') ?? [];

                        final updatedArray = List.from(withdrawRequestArray)
                          ..removeWhere((element) =>
                              element['requestID'] == data.withinArrayID);

                        FirebaseFirestore.instance
                            .collection('AdminRequests')
                            .doc(data.requestID)
                            .update({'rentAdvanceRequest': updatedArray});
                      }
                    });
                  } else if (data.requestType == 'Interest Free Loan Request') {
                    await FirebaseFirestore.instance
                        .collection('AdminRequests')
                        .doc(data.requestID)
                        .get()
                        .then((snapshot) {
                      if (snapshot.exists) {
                        final List<dynamic> withdrawRequestArray =
                            snapshot.get('interestFreeLoanRequest') ?? [];

                        final updatedArray = List.from(withdrawRequestArray)
                          ..removeWhere((element) =>
                              element['requestID'] == data.withinArrayID);

                        FirebaseFirestore.instance
                            .collection('AdminRequests')
                            .doc(data.requestID)
                            .update({'interestFreeLoanRequest': updatedArray});
                      }
                    });
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminRequestsPage()));
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
