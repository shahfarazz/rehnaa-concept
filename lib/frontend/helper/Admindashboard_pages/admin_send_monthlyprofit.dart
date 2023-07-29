import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Screens/Admin/admindashboard.dart';
import '../Dealerdashboard_pages/dealerlandlordonboarded.dart';

class AdminSendMonthlyProfitsPage extends StatefulWidget {
  const AdminSendMonthlyProfitsPage({super.key});

  @override
  State<AdminSendMonthlyProfitsPage> createState() =>
      _AdminSendMonthlyProfitsPageState();
}

class _AdminSendMonthlyProfitsPageState
    extends State<AdminSendMonthlyProfitsPage> {
  // List estamps = [];
  // Map dealerToEstamps = {};
  List<Estamp> estamps = [];
  List<String> dealerIds = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> fetchAllEstamps() async {
    QuerySnapshot dealerSnapshot = await firestore.collection('Dealers').get();
    List<QueryDocumentSnapshot> dealerDocuments = dealerSnapshot.docs;

    List<Future<List<Map<String, dynamic>>>> allEstampsDataFutures =
        dealerDocuments.map((dealerDoc) async {
      QuerySnapshot estampSnapshot =
          await dealerDoc.reference.collection('Estamps').get();

      // Add the dealer id to the list of dealer ids
      dealerIds.add(dealerDoc.id);

      return estampSnapshot.docs
          .map((estampDoc) => {'id': estampDoc.id, 'data': estampDoc.data()})
          .toList();
    }).toList();

    List<List<Map<String, dynamic>>> allEstampsDataNested =
        await Future.wait(allEstampsDataFutures);

    // Flatten the nested list
    List<Map<String, dynamic>> allEstampsData =
        allEstampsDataNested.expand((x) => x).toList();

    // Now allEstampsData contains the data of all documents in the 'Estamps' subcollections
    // of all documents in the 'Dealers' collection
    allEstampsData.forEach((element) {
      estamps.add(Estamp(id: element['id'], landlordData: element['data']));
    });
    return;
  }

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
      body: // futurebuilder which shows in cards each estamp which is stored in estamps variable and make the cards clickable and on the cards show the fields:
          // eStampContractStartDate which is a timestamp
          // eStampContractEndDate which is a timestamp
          // eStampTenantName which is a string
          // eStampLandlordName which is a string
          FutureBuilder(
        future: fetchAllEstamps(),
        builder: (context, snapshot) {
          print('estamps are $estamps');

          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                itemCount: estamps.length,
                itemBuilder: (context, index) {
                  var startDate;
                  var now;
                  var daysPassed;
                  var daysLeft;

                  if (estamps[index].landlordData['daysPassed'] != null &&
                      estamps[index].landlordData['daysLeft'] != null) {
                    daysPassed = estamps[index].landlordData['daysPassed'];
                    daysLeft = estamps[index].landlordData['daysLeft'];
                    // now = DateTime.now();
                  } else {
                    startDate = (estamps[index].landlordData['landlordData']
                            ['eStampContractStartDate'] as Timestamp)
                        .toDate();
                    now = DateTime.now();

                    daysPassed = now.difference(startDate).inDays;
                    daysLeft = 30 - daysPassed;
                  }

                  return Card(
                      child: ListTile(
                    onTap: () async {
                      // check if days passed is 30 or more
                      if (daysPassed >= 30) {
                        // send amount eStampMonthlyProfit to Dealer

                        //try parse cieling of eStampMonthlyProfit
                        var correctBalance;

                        try {
                          correctBalance = int.tryParse(
                              estamps[index].landlordData['landlordData']
                                  ['eStampMonthlyProfit']);
                        } catch (e) {
                          print('reached ehre');
                          correctBalance = 0;
                        }

                        var landlordName = estamps[index]
                            .landlordData['landlordData']['landlordName'];

                        print('landlordName is $landlordName');
                        // print('dealerid is ${estamp['dealerId']}');

                        var currentDealerID = dealerIds[index];

                        FirebaseFirestore.instance
                            .collection('rentPayments')
                            .add({
                          'tenantname': landlordName,
                          'LandlordRef': FirebaseFirestore.instance
                              .collection('Dealers')
                              .doc(currentDealerID),
                          'amount': correctBalance,
                          'date': DateTime.now(),
                          'isMinus': false,
                          'isNoPdf': true,
                          'isEstamp': true,
                          'eStampType': 'Monthly Profit',
                          'paymentType': '',
                        }).then((value) {
                          FirebaseFirestore.instance
                              .collection('Dealers')
                              .doc(currentDealerID)
                              .update({
                            'rentpaymentRef': FieldValue.arrayUnion([value]),
                            'balance': FieldValue.increment(correctBalance),
                          });
                          //Snackbar to show that the amount has been sent
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Amount sent to dealer'),
                            ),
                          );

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AdminSendMonthlyProfitsPage(),
                              ));

                          //i need a way to reset the days passed to 0 without updating the estamp
                          //this can be done by adding a new field called days passed and days left
                          //and then updating them when the amount is sent
                          FirebaseFirestore.instance
                              .collection('Dealers')
                              .doc(currentDealerID)
                              .collection('Estamps')
                              .doc(estamps[index].id)
                              .update({
                            'daysPassed': 0,
                            'daysLeft': 30,
                          });
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Days passed are less than 30'),
                          ),
                        );
                      }
                    },
                    trailing: Column(
                      children: [
                        Text('Days passed: $daysPassed'),
                        Text('Days left: $daysLeft'),
                      ],
                    ),
                    title: Text(
                      estamps[index].landlordData['landlordData']
                          ['eStampTenantName'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      estamps[index].landlordData['landlordData']
                          ['landlordName'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // trailing: Text(
                    //   estamps[index]
                    //       .landlordData['landlordData']
                    //           ['eStampContractEndDate']
                    //       .toDate()
                    //       .toString(),
                    //   style: const TextStyle(
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ));
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
