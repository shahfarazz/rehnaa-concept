import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rehnaa/backend/models/rentpaymentmodel.dart';

import '../../../backend/models/tenantsmodel.dart';

class TenantNewRentHistoryPage extends StatefulWidget {
  final String uid;
  const TenantNewRentHistoryPage({super.key, required this.uid});

  @override
  State<TenantNewRentHistoryPage> createState() =>
      _TenantNewRentHistoryPageState();
}

class _TenantNewRentHistoryPageState extends State<TenantNewRentHistoryPage> {
  @override
  Widget build(BuildContext context) {
    @override
    void initState() {
      super.initState();
      // getAllRentpaymentDocs();
    }
    //rentpayments have amount, date, paymentType, propertyRef, tenantRef, landlordRef

    DocumentReference tenantRef =
        FirebaseFirestore.instance.collection('Tenants').doc(widget.uid);

    return Scaffold(
        appBar: AppBar(
          title: Text('Rent History'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('rentPayments')
              .where('tenantRef', isEqualTo: tenantRef)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              print('snapshot data is ${snapshot.data!.docs.length}');
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      // title: Text(rentpayment.property!.address),
                      subtitle: Text(data['date'].toString()),
                      trailing: Text(data['amount'].toString()),
                    ),
                  );
                  // print(
                  //     'snapshot data is ${snapshot.data!.docs[index].data()}');
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
