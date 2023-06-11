import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdmninRequestsPage extends StatefulWidget {
  @override
  _AdmninRequestsPageState createState() => _AdmninRequestsPageState();
}

class _AdmninRequestsPageState extends State<AdmninRequestsPage> {
  Future<void> _getRequests() async {
    FirebaseFirestore.instance
        .collection('AdminRequests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
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
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error: $e');
          }
        }
      });
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
        title: Text('Withdrawal Requests'),
        flexibleSpace: Container(
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
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
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: filterRequests,
                  decoration: InputDecoration(
                    labelText: 'Search(name)',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                    icon: Icon(Icons.arrow_back),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
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
  final String requestedAmount;
  final String uid;
  final String cashOrBankTransfer;
  final String requestType;

  AdminRequestData({
    required this.name,
    required this.requestedAmount,
    required this.uid,
    required this.cashOrBankTransfer,
    required this.requestType,
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
      margin: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Request Type: ${data.requestType}',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Name: ${data.name}',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Requested Amount: ${data.requestedAmount}',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'UID: ${data.uid}',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Cash/BankTransfer: ${data.cashOrBankTransfer}',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle accept button press
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
                child: Text(
                  'Accept',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Handle deny button press
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text(
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
