import 'dart:async';
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
  bool _isLoading = true;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _requestsSubscription;

  void _listenForRequests() {
    _requestsSubscription = FirebaseFirestore.instance
        .collection('AdminRequests')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      adminRequests.clear();
      // Process the updated querySnapshot and update your adminRequests list
      querySnapshot.docs.forEach((DocumentSnapshot doc) {
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
                  isHandled: doc["withdrawRequest"][i]["isHandled"] ?? false,
                  txnType: 'withdrawRequest',
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
                    cashOrBankTransfer: doc["paymentRequest"][i]
                        ["paymentMethod"],
                    requestID: doc.id,
                    requestType: 'Tenant Payment Request',
                    invoiceNumber: doc["paymentRequest"][i]["invoiceNumber"],
                    withinArrayID: doc["paymentRequest"][i]["requestID"],
                    docTimestamp: doc["paymentRequest"][i]["timestamp"],
                    isHandled: doc["paymentRequest"][i]["isHandled"] ?? false,
                    txnType: 'paymentRequest'),
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
                    isHandled: doc["rentalRequest"][i]['isHandled'] ?? false,
                    txnType: 'rentalRequest'),
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
                isHandled: doc["rentAccrualRequest"][i]["isHandled"] ?? false,
                withinArrayID: doc["rentAccrualRequest"][i]["requestID"],
                txnType: 'rentAccrualRequest',
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
                  isHandled:
                      doc["withdrawRequestDealer"][i]["isHandled"] ?? false,
                  txnType: 'withdrawRequestDealer',
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
                  isHandled: doc["rentAdvanceRequest"][i]["isHandled"] ?? false,
                  txnType: 'rentAdvanceRequest',
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
                  isHandled:
                      doc["interestFreeLoanRequest"][i]["isHandled"] ?? false,

                  txnType: 'interestFreeLoanRequest',
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
                  isHandled:
                      doc["propertyApprovalRequest"][i]["isHandled"] ?? false,
                  txnType: 'propertyApprovalRequest',
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
      });

      setState(() {
        displayedRequests.clear();
        displayedRequests.addAll(adminRequests);
        displayedRequests
            .sort((a, b) => b.docTimestamp.compareTo(a.docTimestamp));
        //reverse to make it descending
        // displayedRequests = displayedRequests.reversed.toList();
        _isLoading = false;
      });
    });
  }

  List<AdminRequestData> adminRequests = [];

  List<AdminRequestData> displayedRequests = [];

  TextEditingController searchController = TextEditingController();

  int currentPage = 1;
  int itemsPerPage = 2;
  // Timer? _timer;

  @override
  void initState() {
    super.initState();
    displayedRequests.addAll(adminRequests);
    // _getRequests();
    _listenForRequests();
    // _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
    //   //
    //   _getRequests();
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // _timer!.cancel();
    _requestsSubscription?.cancel();
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

    return _isLoading
        ? Center(
            child: SpinKitFadingCube(
              color: Color.fromARGB(255, 30, 197, 83),
            ),
          )
        : Scaffold(
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
                            return LandlordWithdrawalCard(
                              data: request,
                              // timer: _timer!,
                            );
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
                                fontFamily: GoogleFonts.montserrat().fontFamily,
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
    //   }
    // });
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
  var isHandled;
  var txnType;

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
    required this.isHandled,
    required this.txnType,
  });
}

class LandlordWithdrawalCard extends StatelessWidget {
  AdminRequestData data;
  // Timer timer;

  LandlordWithdrawalCard({
    required this.data,
    // required this.timer,
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
                  try {
                    // Step 3: Perform the await transaction logic within the lock
                    await FirebaseFirestore.instance
                        .runTransaction((transaction) async {
                      //pause the timer until the transaction is complete
                      // timer.cancel();

                      DocumentSnapshot requestSnapshot = await transaction.get(
                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(data.requestID));

                      if (!requestSnapshot.exists) {
                        throw Exception("AdminRequest document does not exist");
                      }

                      // Check if the 'data' object is present in the 'withdrawRequest' array
                      final List<dynamic> withdrawRequestArray =
                          requestSnapshot.get(data.txnType) ?? [];

                      final dynamic requestData =
                          withdrawRequestArray.firstWhere(
                              (element) =>
                                  element['requestID'] == data.withinArrayID,
                              orElse: () => null);

                      // If the 'data' object isn't found, throw an exception (or handle this scenario in a way that suits your use case)
                      if (requestData == null) {
                        throw Exception(
                            "Request data is no longer present in the AdminRequests document");
                      }

                      var newRentalAmount;
                      var newBalance;
                      var rentalAmount;
                      DocumentSnapshot tenantSnapshot;
                      DocumentSnapshot propertySnapshot;
                      String? propAddress;
                      DocumentReference? landlordRef;

                      // reads required for Tenant Rental Request
                      if (data.txnType == 'rentalRequest') {
                        // Get the necessary data
                        tenantSnapshot = await transaction.get(FirebaseFirestore
                            .instance
                            .collection('Tenants')
                            .doc(data.uid));
                        propertySnapshot = await transaction.get(
                            FirebaseFirestore.instance
                                .collection('Properties')
                                .doc(data.propertyID));

                        // Extract the needed data
                        propAddress = propertySnapshot.get('address');
                        landlordRef = propertySnapshot.get('landlordRef');

                        newRentalAmount = await showDialog<String?>(
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
                                  Navigator.pop(context,
                                      _newRentalAmountController?.text);
                                },
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        );
                        rentalAmount = newRentalAmount ?? data.requestedAmount!;
                        newBalance = int.parse(rentalAmount);
                      }

                      if (requestSnapshot.exists) {
                        final List<dynamic> withdrawRequestArray =
                            requestSnapshot.get(data.txnType) ?? [];

                        final updatedArray = List.from(withdrawRequestArray)
                          ..removeWhere((element) =>
                              element['requestID'] == data.withinArrayID);

                        transaction.update(
                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(data.requestID),
                          {data.txnType: updatedArray},
                        );
                      }

                      // Update the request as handled
                      await transaction.update(
                          requestSnapshot.reference, {'isHandled': true});

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
                        // Check if it is a withdrawal request
                        if (data.requestType == 'Landlord Withdraw Request') {
                          // Withdrawal request
                          // Update the landlord's balance
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Landlords')
                                .doc(data.uid),
                            {
                              'balance': FieldValue.increment(
                                  -int.parse(data.requestedAmount!)),
                            },
                          );

                          // Remove the withdrawal request from the AdminRequests document

                          // Send a notification to the landlord by appending to the 'notifications' array
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Notifications')
                                .doc(data.uid),
                            {
                              'notifications': FieldValue.arrayUnion([
                                {
                                  'amount': data.requestedAmount,
                                  'title': 'Withdrawal Request Accepted',
                                }
                              ])
                            },
                          );

                          // Set 'isWithdraw' in the Landlord's document to false
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Landlords')
                                .doc(data.uid),
                            {'isWithdraw': false},
                          );

                          // Create a rentPayment document in the 'rentPayments' collection
                          final rentPaymentRef = FirebaseFirestore.instance
                              .collection('rentPayments')
                              .doc();

                          // Set the fields of the rentPayment document
                          await transaction.set(
                            rentPaymentRef,
                            {
                              'amount': int.parse(data.requestedAmount!),
                              'date': DateTime.now(),
                              'paymentType': data.cashOrBankTransfer == 'Cash'
                                  ? 'cash'
                                  : 'banktransfer',
                              'propertyRef': null,
                              'tenantRef': null,
                              'landlordRef': FirebaseFirestore.instance
                                  .collection('Landlords')
                                  .doc(data.uid),
                              'invoiceNumber': data.invoiceNumber,
                              'tenantname': data.altTenantName
                            },
                          );

                          // Append the rentPaymentRef to the 'rentpaymentRef' array in the Landlord's document
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Landlords')
                                .doc(data.uid),
                            {
                              'rentpaymentRef':
                                  FieldValue.arrayUnion([rentPaymentRef]),
                            },
                          );

                          Navigator.pop(context);

                          // Reset the state of the page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRequestsPage(),
                            ),
                          );
                        } else if (data.requestType ==
                            'Tenant Payment Request') {
                          // Payment request
                          // Update the tenant's balance
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Tenants')
                                .doc(data.uid),
                            {
                              'balance': FieldValue.increment(
                                  -int.parse(data.requestedAmount!)),
                            },
                          );

                          // Send a notification to the tenant by appending to the 'notifications' array
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Notifications')
                                .doc(data.uid),
                            {
                              'notifications': FieldValue.arrayUnion([
                                {
                                  'amount': data.requestedAmount,
                                  'title': 'Payment Request Accepted',
                                }
                              ])
                            },
                          );

                          // Set 'isWithdraw' in the Tenant's document to false
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Tenants')
                                .doc(data.uid),
                            {'isWithdraw': false},
                          );

                          // Create a rentPayment document in the 'rentPayments' collection
                          final rentPaymentRef = FirebaseFirestore.instance
                              .collection('rentPayments')
                              .doc();

                          // Set the fields of the rentPayment document
                          await transaction.set(
                            rentPaymentRef,
                            {
                              'amount': int.parse(data.requestedAmount!),
                              'date': DateTime.now(),
                              'paymentType': data.cashOrBankTransfer == 'Cash'
                                  ? 'cash'
                                  : 'banktransfer',
                              'propertyRef': null,
                              'tenantRef': FirebaseFirestore.instance
                                  .collection('Tenants')
                                  .doc(data.uid),
                              'landlordRef': null,
                              'invoiceNumber': data.invoiceNumber
                            },
                          );

                          // Append the rentPaymentRef to the 'rentpaymentRef' array in the Tenant's document
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Tenants')
                                .doc(data.uid),
                            {
                              'rentpaymentRef':
                                  FieldValue.arrayUnion([rentPaymentRef]),
                            },
                          );
                          //reset the state of the page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRequestsPage(),
                            ),
                          );
                        } else if (data.requestType == 'Rent Accrual Request') {
                          // Send a notification to the tenant
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Notifications')
                                .doc(data.uid),
                            {
                              'notifications': FieldValue.arrayUnion([
                                {
                                  'title':
                                      'Your Rent Accrual request has been accepted, somebody from the Rehnaa team will contact you shortly',
                                }
                              ])
                            },
                          );

                          // Reset the state of the page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRequestsPage(),
                            ),
                          );
                        } else if (data.requestType ==
                            'Dealer Withdraw Request') {
                          // Update the dealer's balance
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Dealers')
                                .doc(data.uid),
                            {
                              'balance': FieldValue.increment(
                                  -int.parse(data.requestedAmount!)),
                            },
                          );

                          // Send a notification to the dealer
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Notifications')
                                .doc(data.uid),
                            {
                              'notifications': FieldValue.arrayUnion([
                                {
                                  'amount': data.requestedAmount,
                                  'title': 'Withdrawal Request Accepted',
                                }
                              ])
                            },
                          );

                          // Update the dealer's isWithdraw field
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Dealers')
                                .doc(data.uid),
                            {'isWithdraw': false},
                          );

                          // Create a rentPayment document for the withdrawal
                          final rentPaymentRef = FirebaseFirestore.instance
                              .collection('rentPayments')
                              .doc();

                          await transaction.set(rentPaymentRef, {
                            'amount': int.parse(data.requestedAmount!),
                            'date': DateTime.now(),
                            'paymentType': data.cashOrBankTransfer == 'Cash'
                                ? 'cash'
                                : 'banktransfer',
                            'propertyRef': null,
                            'tenantRef': null,
                            'landlordRef': null,
                            'dealerRef': FirebaseFirestore.instance
                                .collection('Dealers')
                                .doc(data.uid),
                            'invoiceNumber': data.invoiceNumber,
                            'tenantname': data.altTenantName
                          });

                          // Append the rentPaymentRef to the dealer's rentpaymentRef array
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Dealers')
                                .doc(data.uid),
                            {
                              'rentpaymentRef':
                                  FieldValue.arrayUnion([rentPaymentRef]),
                            },
                          );

                          // Reset the state of the page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRequestsPage(),
                            ),
                          );
                        } else if (data.requestType == 'Rent Advance Request') {
                          // Send a notification to the tenant
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Notifications')
                                .doc(data.uid),
                            {
                              'notifications': FieldValue.arrayUnion([
                                {
                                  'title': 'Rent Advance Request Accepted',
                                }
                              ])
                            },
                          );

                          // Reset the state of the page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRequestsPage(),
                            ),
                          );
                        } else if (data.requestType ==
                            'Interest Free Loan Request') {
                          // Send a notification to the tenant
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Notifications')
                                .doc(data.uid),
                            {
                              'notifications': FieldValue.arrayUnion([
                                {
                                  'title':
                                      'Interest Free Loan Request Accepted',
                                }
                              ])
                            },
                          );

                          // Reset the state of the page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRequestsPage(),
                            ),
                          );
                        } else if (data.requestType ==
                            'Property Approval Request') {
                          // Send a notification to the landlord
                          await transaction.update(
                            FirebaseFirestore.instance
                                .collection('Notifications')
                                .doc(data.uid),
                            {
                              'notifications': FieldValue.arrayUnion([
                                {
                                  'title': 'Property Approval Request Accepted',
                                }
                              ])
                            },
                          );

                          // ignore: use_build_context_synchronously
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Admin Approval'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: data.dataFields.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      String key =
                                          data.dataFields.keys.elementAt(index);
                                      dynamic value = data.dataFields.values
                                          .elementAt(index);

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
                                      Navigator.of(context).pop(
                                          false); // Return false if rejected
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
                          ).then((value) async {
                            if (value == true) {
                              // Create a document for the property in the Properties collection
                              var docRef = FirebaseFirestore.instance
                                  .collection('Properties')
                                  .doc();
                              var landlordRef = FirebaseFirestore.instance
                                  .collection('Landlords')
                                  .doc(data.uid);

                              // Set the data fields of the property document
                              await transaction.set(docRef, data.dataFields);
                              await transaction.update(docRef, {
                                'landlordRef': landlordRef,
                                //check if imagePath exists otherwise set it to empty string
                                'imagePath':
                                    data.dataFields['imagePath'] == 'no images'
                                        ? ''
                                        : data.dataFields['imagePath'],
                              });

                              // Update the landlord's propertyRef array with the property document reference
                              await transaction.update(landlordRef, {
                                'propertyRef': FieldValue.arrayUnion([docRef]),
                              });
                            } else {
                              // Reset the state of the page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminRequestsPage(),
                                ),
                              );
                            }
                          });

                          // Reset the state of the page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminRequestsPage(),
                            ),
                          );
                        }

                        print('property.requestType is ${data.requestType}');
                      } else if (data.requestType == 'Tenant Rental Request') {
                        // Prompt the admin to enter a new rental amount

                        // Update the tenant's balance with the requested or new rental amount
                        // final rentalAmount =
                        //     newRentalAmount ?? data.requestedAmount!;
                        await transaction.update(
                          FirebaseFirestore.instance
                              .collection('Tenants')
                              .doc(data.uid),
                          {
                            'balance':
                                FieldValue.increment(int.parse(newBalance)),
                          },
                        );

                        // Send a notification to the tenant
                        await transaction.update(
                          FirebaseFirestore.instance
                              .collection('Notifications')
                              .doc(data.uid),
                          {
                            'notifications': FieldValue.arrayUnion([
                              {
                                'amount': rentalAmount,
                                'title': 'Rental Request Accepted',
                              }
                            ])
                          },
                        );

                        // Set the tenant's isWithdraw to false and set propertyRef and address
                        await transaction.set(
                            FirebaseFirestore.instance
                                .collection('Tenants')
                                .doc(data.uid),
                            {
                              'isWithdraw': false,
                              'propertyRef': FirebaseFirestore.instance
                                  .collection('Properties')
                                  .doc(data.propertyID),
                              'address': propAddress ?? 'No address provided',
                            },
                            SetOptions(merge: true));

                        // Set the property's tenantRef to the tenant's document reference
                        await transaction.update(
                          FirebaseFirestore.instance
                              .collection('Properties')
                              .doc(data.propertyID),
                          {
                            'tenantRef': FirebaseFirestore.instance
                                .collection('Tenants')
                                .doc(data.uid),
                          },
                        );

                        // Set the tenant's landlordRef to the property's landlordRef
                        await transaction.update(
                          FirebaseFirestore.instance
                              .collection('Tenants')
                              .doc(data.uid),
                          {
                            'landlordRef': landlordRef,
                          },
                        );

                        // Update the landlord's tenantRef with the tenant's document reference
                        await transaction.update(
                          FirebaseFirestore.instance
                              .collection('Landlords')
                              .doc(landlordRef!.id),
                          {
                            'tenantRef': FieldValue.arrayUnion([
                              FirebaseFirestore.instance
                                  .collection('Tenants')
                                  .doc(data.uid),
                            ])
                          },
                        );

                        // Update the property's isRequestedByTenants field
                        await transaction.update(
                          FirebaseFirestore.instance
                              .collection('Properties')
                              .doc(data.propertyID),
                          {
                            'isRequestedByTenants':
                                FieldValue.arrayRemove([data.uid])
                          },
                        );

                        // Navigate to the AdminPropertyContractsPage
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminPropertyContractsPage(
                              landlordID: landlordRef!.id,
                              tenantID: data.uid,
                            ),
                          ),
                        );
                      }

                      //commit
                      // await transaction.commit();
                    });
                  } catch (e) {
                    // Handle any errors that occurred during the await transaction
                    //show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('An admin is already handling this request'),
                      ),
                    );
                    await Future.delayed(const Duration(seconds: 2));
                    //reload the page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminRequestsPage(),
                      ),
                    );
                  } finally {
                    //close the dialog
                    Navigator.pop(context);
                    //reload the page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminRequestsPage(),
                      ),
                    );
                  }

                  // print('data.uid: ${data.uid}');
                  // print('data.requestType: ${data.requestType}');

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

  // _getNewData(
  //     String? withinArrayID, String? requestID, String? requestType) async {
  //   DocumentSnapshot<Map<String, dynamic>> newData = await FirebaseFirestore
  //       .instance
  //       .collection('AdminRequests')
  //       .doc(requestID)
  //       .get();

  //   var doc = newData.data() as Map<String, dynamic>;

  //   //doc contains many array types
  //   //inside those arrays find the one with the withinArrayID
  //   //then add it as an adminrequest

  //   try {
  //     if (doc["withdrawRequest"] != null) {
  //       // if yes, then loop through the array
  //       print('withdraw request found doc is ${doc["withdrawRequest"]}');

  //       //find

  //       //find the instance of the array with the withinArrayID
  //       List<dynamic> doclist = doc['withdrawRequest'];

  //       var mydoc = doclist.firstWhere(
  //         (element) => element['requestID'] == withinArrayID,
  //         orElse: () => null,
  //       ) as Map<String, dynamic>;

  //       // print('mydoc is $mydoc');

  //       return AdminRequestData(
  //         name: mydoc["fullname"],
  //         requestedAmount: mydoc["amount"].toString(),
  //         uid: mydoc["uid"],
  //         cashOrBankTransfer: mydoc["paymentMethod"],
  //         requestID: requestID!,
  //         requestType: 'Landlord Withdraw Request',
  //         invoiceNumber: mydoc["invoiceNumber"],
  //         altTenantName: mydoc["tenantname"],
  //         withinArrayID: mydoc["requestID"],
  //         docTimestamp: mydoc["timestamp"],
  //         isHandled: mydoc["isHandled"] ?? false,
  //       );
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error: $e');
  //     }
  //   }

  //   try {
  //     if (doc["paymentRequest"] != null) {
  //       for (var i = 0; i < doc["paymentRequest"].length; i++) {
  //         // add each request to the adminRequests list

  //         AdminRequestData(
  //           name: doc["paymentRequest"][i]["fullname"],
  //           requestedAmount: doc["paymentRequest"][i]["amount"].toString(),
  //           uid: doc["paymentRequest"][i]["uid"],
  //           cashOrBankTransfer: doc["paymentRequest"][i]["paymentMethod"],
  //           requestID: requestID!,
  //           requestType: 'Tenant Payment Request',
  //           invoiceNumber: doc["paymentRequest"][i]["invoiceNumber"],
  //           withinArrayID: doc["paymentRequest"][i]["requestID"],
  //           docTimestamp: doc["paymentRequest"][i]["timestamp"],
  //           isHandled: doc["paymentRequest"][i]["isHandled"] ?? false,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error222: $e');
  //     }
  //   }

  //   try {
  //     if (doc['rentalRequest'] != null) {
  //       // print('rental request found');
  //       for (var i = 0; i < doc["rentalRequest"].length; i++) {
  //         // add each request to the adminRequests list

  //         AdminRequestData(
  //           name: doc["rentalRequest"][i]["fullname"],
  //           requestedAmount:
  //               doc["rentalRequest"][i]["property"]["price"].toString(),
  //           uid: doc["rentalRequest"][i]["uid"],
  //           propertyTitle: doc["rentalRequest"][i]["property"]["title"],
  //           propertyLocation: doc["rentalRequest"][i]["property"]["location"],
  //           requestID: requestID!,
  //           requestType: 'Tenant Rental Request',
  //           propertyLandlordRef: doc["rentalRequest"][i]["property"]
  //               ["landlordRef"],
  //           withinArrayID: doc["rentalRequest"][i]["requestID"],
  //           propertyID: doc["rentalRequest"][i]["propertyID"],
  //           docTimestamp: doc["rentalRequest"][i]["timestamp"],
  //           isHandled: doc["rentalRequest"][i]['isHandled'] ?? false,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error: $e');
  //     }
  //   }

  //   try {
  //     if (doc['rentAccrualRequest'] != null) {
  //       // print('rental request found');
  //       for (var i = 0; i < doc["rentAccrualRequest"].length; i++) {
  //         // add each request to the adminRequests list

  //         AdminRequestData(
  //           name: doc["rentAccrualRequest"][i]["fullname"],
  //           uid: doc["rentAccrualRequest"][i]["uid"],
  //           requestType: 'Rent Accrual Request',
  //           requestID: requestID!,
  //           docTimestamp: doc["rentAccrualRequest"][i]["timestamp"],
  //           isHandled: doc["rentAccrualRequest"][i]["isHandled"] ?? false,
  //           withinArrayID: doc["rentAccrualRequest"][i]["requestID"],
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error: $e');
  //     }
  //   }
  //   try {
  //     if (doc["withdrawRequestDealer"] != null) {
  //       for (var i = 0; i < doc["withdrawRequestDealer"].length; i++) {
  //         // add each request to the adminRequests list

  //         AdminRequestData(
  //           name: doc["withdrawRequestDealer"][i]["fullname"],
  //           requestedAmount:
  //               doc["withdrawRequestDealer"][i]["amount"].toString(),
  //           uid: doc["withdrawRequestDealer"][i]["uid"],
  //           cashOrBankTransfer: doc["withdrawRequestDealer"][i]
  //               ["paymentMethod"],
  //           requestID: requestID!,
  //           requestType: 'Dealer Withdraw Request',
  //           invoiceNumber: doc["withdrawRequestDealer"][i]["invoiceNumber"],
  //           withinArrayID: doc["withdrawRequestDealer"][i]["requestID"],
  //           altTenantName: doc["withdrawRequestDealer"][i]["tenantname"],
  //           docTimestamp: doc["withdrawRequestDealer"][i]["timestamp"],
  //           isHandled: doc["withdrawRequestDealer"][i]["isHandled"] ?? false,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error222: $e');
  //     }
  //   }

  //   //try catch for rentAdvanceRequest
  //   try {
  //     if (doc["rentAdvanceRequest"] != null) {
  //       for (var i = 0; i < doc["rentAdvanceRequest"].length; i++) {
  //         // add each request to the adminRequests list

  //         AdminRequestData(
  //           name: doc["rentAdvanceRequest"][i]["fullname"],
  //           // requestedAmount:
  //           //     doc["rentAdvanceRequest"][i]["amount"].toString(),
  //           uid: doc["rentAdvanceRequest"][i]["uid"],
  //           // cashOrBankTransfer: doc["rentAdvanceRequest"][i]
  //           //     ["paymentMethod"],
  //           requestID: requestID!,
  //           requestType: 'Rent Advance Request',
  //           // invoiceNumber: doc["rentAdvanceRequest"][i]["invoiceNumber"],
  //           withinArrayID: doc["rentAdvanceRequest"][i]["requestID"],
  //           // altTenantName: doc["rentAdvanceRequest"][i]["tenantname"],
  //           docTimestamp: doc["rentAdvanceRequest"][i]["timestamp"],
  //           isHandled: doc["rentAdvanceRequest"][i]["isHandled"] ?? false,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error222: $e');
  //     }
  //   }

  //   //try catch for interestFreeLoanRequest
  //   try {
  //     if (doc["interestFreeLoanRequest"] != null) {
  //       for (var i = 0; i < doc["interestFreeLoanRequest"].length; i++) {
  //         // add each request to the adminRequests list

  //         AdminRequestData(
  //           name: doc["interestFreeLoanRequest"][i]["fullname"],
  //           // requestedAmount:
  //           //     doc["interestFreeLoanRequest"][i]["amount"].toString(),
  //           uid: doc["interestFreeLoanRequest"][i]["uid"],
  //           // cashOrBankTransfer: doc["interestFreeLoanRequest"][i]
  //           //     ["paymentMethod"],
  //           requestID: requestID!,
  //           requestType: 'Interest Free Loan Request',
  //           // invoiceNumber: doc["interestFreeLoanRequest"][i]["invoiceNumber"],
  //           withinArrayID: doc["interestFreeLoanRequest"][i]["requestID"],
  //           // altTenantName: doc["interestFreeLoanRequest"][i]["tenantname"],
  //           docTimestamp: doc["interestFreeLoanRequest"][i]["timestamp"],
  //           isHandled: doc["interestFreeLoanRequest"][i]["isHandled"] ?? false,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error222: $e');
  //     }
  //   }

  //   //try catch for propertyApprovalRequest
  //   try {
  //     if (doc["propertyApprovalRequest"] != null) {
  //       for (var i = 0; i < doc["propertyApprovalRequest"].length; i++) {
  //         // add each request to the adminRequests list

  //         AdminRequestData(
  //           name: doc["propertyApprovalRequest"][i]["fullname"],
  //           // requestedAmount:
  //           //     doc["propertyApprovalRequest"][i]["amount"].toString(),
  //           uid: doc["propertyApprovalRequest"][i]["uid"],
  //           // cashOrBankTransfer: doc["propertyApprovalRequest"][i]
  //           //     ["paymentMethod"],
  //           requestID: requestID!,
  //           requestType: 'Property Approval Request',
  //           // invoiceNumber: doc["propertyApprovalRequest"][i]["invoiceNumber"],
  //           withinArrayID: doc["propertyApprovalRequest"][i]["requestID"],
  //           // altTenantName: doc["propertyApprovalRequest"][i]["tenantname"],
  //           docTimestamp: doc["propertyApprovalRequest"][i]["timestamp"],
  //           dataFields: doc["propertyApprovalRequest"][i]["dataFields"],
  //           isHandled: doc["propertyApprovalRequest"][i]["isHandled"] ?? false,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error222: $e');
  //     }
  //   }
  // }
}
