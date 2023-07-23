import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Screens/Admin/admindashboard.dart';

class AdminSendMonthlyProfitsPage extends StatefulWidget {
  const AdminSendMonthlyProfitsPage({super.key});

  @override
  State<AdminSendMonthlyProfitsPage> createState() =>
      _AdminSendMonthlyProfitsPageState();
}

class _AdminSendMonthlyProfitsPageState
    extends State<AdminSendMonthlyProfitsPage> {
  List estamps = [];
  // Map dealerToEstamps = {};

  Future showAllEstamps() async {
    //an estamp is basically the mapping called landlordmap of a dealer where the key is the landlord id and the value are dynamic fields
    var dealerdata;
    dealerdata = await FirebaseFirestore.instance.collection('Dealers').get();

    //add each estamp to the estamps list
    // where estamp is called landlordMap

    for (var element in dealerdata.docs) {
      var landlordmap = element.data()['landlordMap'];
      for (var landlord in landlordmap.keys) {
        estamps.add({
          'dealerId': element.id, // Add dealer id here
          'uid': landlord,
          'data': landlordmap[landlord],
          'dealerName': element.data()['firstName'] ?? 'Unknown Dealer',
        });
      }
    }

    // return estamps;
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
        future: showAllEstamps(),
        builder: (context, snapshot) {
          print('estamps are $estamps');

          if (snapshot.connectionState == ConnectionState.done) {
            //save all the keys of the estamps in a list
            // List estampKeys = estamps.keys.toList();
            // List estampKeys = estamps.map((e) => e.keys).toList();
            // estampKeys where key is the landlord id
            // List estampKeys = estamps.expand((e) => e.keys).toList();
            List estampKeys = estamps.map((e) => e['uid']).toList();

            //instead of index we use the key of the estamp
            print('estampKeys are $estampKeys');

            return ListView.builder(
                itemCount: estampKeys.length,
                itemBuilder: (context, index) {
                  var estamp =
                      estamps.firstWhere((e) => e['uid'] == estampKeys[index]);
                  final startDate =
                      (estamp['data']['eStampContractStartDate'] as Timestamp)
                          .toDate();
                  final now = DateTime.now();

                  final daysPassed = now.difference(startDate).inDays;
                  final daysLeft = 30 - daysPassed;
                  return Card(
                    child: ListTile(
                      title: Text(estamp['data']['eStampTenantName'] ??
                          'Unknown tenant'),
                      subtitle: Text('Start date: ' +
                              (estamp['data']['eStampContractStartDate']
                                      as Timestamp)
                                  .toDate()
                                  .toString()
                                  .substring(0, 10) ??
                          'Unknown Date'),
                      leading: Text(estamp['dealerName'] ?? 'Unknown Dealer'),
                      onTap: () async {
                        // check if days passed is 30 or more
                        if (daysPassed >= 30) {
                          // send amount eStampMonthlyProfit to Dealer

                          //try parse cieling of eStampMonthlyProfit
                          var correctBalance;

                          try {
                            correctBalance = int.tryParse(
                                estamp['data']['eStampMonthlyProfit']);
                          } catch (e) {
                            print('reached ehre');
                            correctBalance = 0;
                          }

                          var landlordName = //get landlord name by calling the current key on firebase
                              await FirebaseFirestore.instance
                                  .collection('Landlords')
                                  .doc(estamp['uid'])
                                  .get()
                                  .then((value) =>
                                      value.data()?['firstName'] +
                                      ' ' +
                                      value.data()?['lastName']);

                          print('landlordName is $landlordName');
                          print('dealerid is ${estamp['dealerId']}');

                          FirebaseFirestore.instance
                              .collection('rentPayments')
                              .add({
                            'tenantname': landlordName,
                            'LandlordRef': FirebaseFirestore.instance
                                .collection('Dealers')
                                .doc(estamp['dealerId']),
                            'amount': correctBalance,
                            'date': DateTime.now(),
                            'isMinus': true,
                            'isNoPdf': true,
                            'isEstamp': true,
                            'eStampType': 'Monthly Profit',
                            'paymentType': '',
                          }).then((value) {
                            FirebaseFirestore.instance
                                .collection('Dealers')
                                .doc(estamp['dealerId'])
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
                    ),
                  );
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
