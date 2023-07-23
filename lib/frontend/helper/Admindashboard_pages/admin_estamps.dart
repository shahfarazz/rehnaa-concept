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

class _AdminEstampsPageState extends State<AdminEstampsPage> {
  List<Dealer> dealers = [];

  Future<void> _fetchDealers() async {
    return FirebaseFirestore.instance.collection('Dealers').get().then((value) {
      for (var element in value.docs) {
        Dealer dealer = Dealer.fromJson(element.data());
        print('found dealer with data ${element.data()}');
        dealer.tempID = element.id;
        dealers.add(dealer);
      }
    });
  }

  Future<List<Landlord>> loadLandlordsOfDealer(Dealer dealer) async {
    List<DocumentReference<Map<String, dynamic>>>? landlordrefs =
        dealer.landlordRef;
    List<Landlord> landlords = [];
    try {
      if (landlordrefs != null) {
        for (var landlordref in landlordrefs) {
          var tempLandlordData = await landlordref.get();
          Landlord landlord = Landlord.fromJson(tempLandlordData.data()!);
          landlord.tempID = tempLandlordData.id;
          landlords.add(landlord);
        }
        return landlords;
      }
    } catch (e) {
      return [];
    }
    return [];
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
                                        child: FutureBuilder(
                                          future: loadLandlordsOfDealer(
                                              dealers[index]),
                                          builder: (context, snapshot) {
                                            List<Landlord> landlordList =
                                                snapshot.data ?? [];
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              return ListView.builder(
                                                itemCount: landlordList.length,
                                                itemBuilder: (context, index2) {
                                                  return Card(
                                                    child: ListTile(
                                                      title: Text(
                                                          '${landlordList[index2].firstName} ${landlordList[index2].lastName}'),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => AdminEstampsEditorPage(
                                                                  landlord:
                                                                      landlordList[
                                                                          index2],
                                                                  dealer: dealers[
                                                                      index])),
                                                        );
                                                      },
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
