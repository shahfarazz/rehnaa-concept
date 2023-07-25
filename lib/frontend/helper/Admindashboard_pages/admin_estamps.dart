import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';

import '../../../backend/models/dealermodel.dart';
import '../../Screens/Admin/admindashboard.dart';
import 'admin_estamps_editor.dart';

class AdminEstampsPage extends StatefulWidget {
  const AdminEstampsPage({super.key});

  @override
  State<AdminEstampsPage> createState() => _AdminEstampsPageState();
}

class Estamp {
  final String id;
  final landlordData;

  Estamp({required this.id, required this.landlordData});
}

class _AdminEstampsPageState extends State<AdminEstampsPage> {
  List<Dealer> dealers = [];

  Future<void> _fetchDealers() async {
    return FirebaseFirestore.instance.collection('Dealers').get().then((value) {
      for (var element in value.docs) {
        Dealer dealer = Dealer.fromJson(element.data());
        // print('found dealer with data ${element.data()}');
        dealer.tempID = element.id;
        dealers.add(dealer);
      }
    }).catchError((error) {
      print('error loading dealers is $error');
    });
  }

  // Future<List<Landlord>> loadLandlordsOfDealer(Dealer dealer) async {
  //   List<DocumentReference<Map<String, dynamic>>>? landlordrefs =
  //       dealer.landlordRef;
  //   List<Landlord> landlords = [];

  //   print('landlordrefs is $landlordrefs');

  //   if (landlordrefs != null) {
  //     for (var landlordref in landlordrefs) {
  //       try {
  //         var tempLandlordData = await landlordref.get();
  //         Landlord landlord = Landlord.fromJson(tempLandlordData.data()!);
  //         landlord.tempID = tempLandlordData.id;
  //         landlords.add(landlord);
  //       } catch (e) {
  //         print('error loading landlord data is $e');
  //       }
  //     }
  //     return landlords;
  //   }

  //   return [];
  // }

  Future<List<Estamp>> loadDealerEstamps(Dealer dealer) async {
    Estamp? estamp;
    List<Estamp> estamps = [];
    await FirebaseFirestore.instance
        .collection('Dealers')
        .doc(dealer.tempID)
        .collection('Estamps')
        .get()
        .then((value) {
      var data = value.docs;
      for (var element in data) {
        estamp = Estamp(id: element.id, landlordData: element.data());
        // print('estampdata is ${element.data()}');
        if (estamp != null) {
          print('lol reached here');
          estamps.add(estamp!);
        }
      }
    });
    return estamps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Estamps Creator'),
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
        body: FutureBuilder(
            future: _fetchDealers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                  itemCount: dealers.length,
                  itemBuilder: (context, index) {
                    return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 5.0,
                        child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            title: Text(
                              "${dealers[index].firstName} ${dealers[index].lastName}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: Text('Estamps'),
                                      content: Container(
                                        height: 300,
                                        width: 300,
                                        child: Column(
                                          children: [
                                            Expanded(
                                                child: FutureBuilder(
                                              future: loadDealerEstamps(
                                                  dealers[index]),
                                              builder: (context, snapshot) {
                                                List<Estamp> eStampList =
                                                    snapshot.data ?? [];
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  print(
                                                      'estamps list is $eStampList');
                                                  return ListView.builder(
                                                    itemCount:
                                                        eStampList.length,
                                                    itemBuilder:
                                                        (context, index2) {
                                                      // print(
                                                      //     'data is ${eStampList[index2].landlordData}');

                                                      return Card(
                                                        child: ListTile(
                                                          title: Text(
                                                              '${eStampList[index2].landlordData['landlordData']['landlordName']}'),
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => AdminEstampsEditorPage(
                                                                      docID: eStampList[
                                                                              index2]
                                                                          .id,
                                                                      dealer: dealers[
                                                                          index])),
                                                            );
                                                          },
                                                          trailing: //add a delete button that deletes the estamp
                                                              IconButton(
                                                            icon: Icon(
                                                                Icons.delete),
                                                            onPressed: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        'Delete Estamp'),
                                                                    content: Text(
                                                                        'Are you sure you want to delete this estamp?'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text(
                                                                            'No'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          //delete the estamp
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('Dealers')
                                                                              .doc(dealers[index].tempID)
                                                                              .collection('Estamps')
                                                                              .doc(eStampList[index2].id)
                                                                              .delete();

                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text(
                                                                            'Yes'),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  return Center(
                                                    child: SpinKitFadingCube(
                                                      color: Color.fromARGB(
                                                          255, 30, 197, 83),
                                                    ),
                                                  );
                                                }
                                              },
                                            )),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AdminEstampsEditorPage(
                                                            dealer:
                                                                dealers[index],
                                                            docID: 'empty',
                                                          )),
                                                );
                                              },
                                              child: Text('Add Estamp'),
                                            ),
                                          ],
                                        ),
                                      ));
                                },
                              );
                            }));
                  },
                );
              } else {
                return Center(
                  child: SpinKitFadingCube(
                    color: Color.fromARGB(255, 30, 197, 83),
                  ),
                );
              }
            }));
  }
}
