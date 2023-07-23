import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;

import 'package:rehnaa/frontend/Screens/Admin/admindashboard.dart';

class AdminVouchersPage extends StatefulWidget {
  const AdminVouchersPage({Key? key}) : super(key: key);

  @override
  _AdminVouchersPageState createState() => _AdminVouchersPageState();
}

class Voucher {
  final String url;
  final firebase_storage.Reference ref;

  Voucher(this.url, this.ref);
}

class _AdminVouchersPageState extends State<AdminVouchersPage> {
  List<Voucher> vouchers = [];

  List<html.File>? selectedImages = [];
  double uploadProgress = 0.0;
  bool _isLoading = true;
  String? urls;
  List<String>? names = [];
  String? nameval;

  @override
  void initState() {
    super.initState();
    fetchVouchers();
    reloadVouchers();
  }

  Future<void> addVoucher() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..multiple = true;
    input.click();

    await input.onChange.first;
    late List<html.File>? pickedFile;

    if (input.files != null) {
      setState(() {
        pickedFile = input.files;
      });
    }

    if (pickedFile != null && pickedFile!.isNotEmpty) {
      for (var file in pickedFile!) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);

        final completer = Completer<String>();

        reader.onLoad.first.then((_) {
          completer.complete(reader.result.toString());
        });

        final encodedImage = await completer.future;

        //create or update a new collection called Vouchers and add the imageurl to firestore

        //showdialog to ask for the name of the voucher

        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Enter the name of the voucher'),
                  content: TextField(
                    onChanged: (value) {
                      setState(() {
                        nameval = value;
                      });
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Uploading...'),
                                content: SpinKitFadingCube(
                                  color: Color.fromARGB(255, 30, 197, 83),
                                ),
                              );
                            });

                        try {
                          names?.add(nameval!);
                        } catch (e) {
                          // TODO
                        }
                        Reference storageReference = FirebaseStorage.instance
                            .ref()
                            .child(
                                'images/vouchers/${DateTime.now().millisecondsSinceEpoch}');
                        UploadTask uploadTask = storageReference.putString(
                            encodedImage,
                            format: PutStringFormat.dataUrl);
                        await uploadTask;
                        String imageUrl =
                            await storageReference.getDownloadURL();
                        await FirebaseFirestore.instance
                            .collection('Vouchers')
                            .doc('voucherkey')
                            .set({
                          //add the url to a list of urls
                          'urls': FieldValue.arrayUnion([imageUrl]),
                          'names': FieldValue.arrayUnion([nameval])
                        }, SetOptions(merge: true));

                        setState(() {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminVouchersPage(),
                            ),
                          );
                        });

                        WriteBatch batch = FirebaseFirestore.instance.batch();

                        //get all ids in Tenants collection
                        var allTenantIDs = await FirebaseFirestore.instance
                            .collection('Tenants')
                            .get()
                            .then((value) {
                          return value.docs.map((e) => e.id).toList();
                        });

                        var allLandlordIDs = await FirebaseFirestore.instance
                            .collection('Landlords')
                            .get()
                            .then((value) {
                          return value.docs.map((e) => e.id).toList();
                        });

                        // Update documents in the Tenants collection
                        QuerySnapshot tenantsQuerySnapshot =
                            await FirebaseFirestore.instance
                                .collection('Tenants')
                                .get();
                        QuerySnapshot notifsQuerySnapshot =
                            await FirebaseFirestore.instance
                                .collection('Notifications')
                                .get();

                        //for all tenant ids in Notifications collection add a new notification
                        for (var myid in allTenantIDs) {
                          FirebaseFirestore.instance
                              .collection('Notifications')
                              .doc(myid)
                              .set({
                            'notifications': FieldValue.arrayUnion([
                              {
                                'title': '${nameval} Voucher has been added',
                              }
                            ])
                          }, SetOptions(merge: true));
                        }
                        for (var myid in allLandlordIDs) {
                          FirebaseFirestore.instance
                              .collection('Notifications')
                              .doc(myid)
                              .set({
                            'notifications': FieldValue.arrayUnion([
                              {
                                'title': '${nameval} Voucher has been added',
                              }
                            ])
                          }, SetOptions(merge: true));
                        }

                        tenantsQuerySnapshot.docs.forEach((tenantDoc) {
                          batch.set(tenantDoc.reference,
                              {'isNewVouchers': true}, SetOptions(merge: true));
                        });

                        // Update documents in the Landlords collection
                        QuerySnapshot landlordsQuerySnapshot =
                            await FirebaseFirestore.instance
                                .collection('Landlords')
                                .get();

                        landlordsQuerySnapshot.docs.forEach((landlordDoc) {
                          batch.set(landlordDoc.reference,
                              {'isNewVouchers': true}, SetOptions(merge: true));
                        });

                        // Commit the batch
                        await batch.commit();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Voucher>>? fetchVouchers() async {
    try {
      firebase_storage.ListResult listResult = await firebase_storage
          .FirebaseStorage.instance
          .ref('images/vouchers/')
          .listAll();
      List<Voucher> vouchersList = [];
      List<Future<String>> urlFutures = [];
      for (var ref in listResult.items) {
        urlFutures.add(ref.getDownloadURL());
      }

      // await on the list of futures
      List<String> urls = await Future.wait(urlFutures);

      // add urls and refs to the vouchers list
      for (var i = 0; i < urls.length; i++) {
        vouchersList.add(Voucher(urls[i], listResult.items[i]));
      }

      // print('reached here');
      FirebaseFirestore.instance
          .collection('Vouchers')
          .doc('voucherkey')
          .get()
          .then((value) {
        try {
          for (var name in value.data()?['names']) {
            names?.add(name);
          }
        } catch (e) {
          // TODO
          return;
        }
      });
      // print('reached here2');

      // setState(() {
      _isLoading = false;
      // });
      return vouchersList;
    } catch (error) {
      print('Error fetching vouchers: $error');
      // setState(() {
      _isLoading = false;
      // });
      return [];
    }
  }

  Future<void> deleteVoucher(int index) async {
    try {
      FirebaseFirestore.instance
          .collection('Vouchers')
          .doc('voucherkey')
          .update({
        'urls': FieldValue.arrayRemove([vouchers[index].url])
      });
      // print('current voucher: ${vouchers}');
      await firebase_storage.FirebaseStorage.instance
          .ref(vouchers[index].ref.fullPath)
          .delete();

      //delete name from names array at index
      FirebaseFirestore.instance
          .collection('Vouchers')
          .doc('voucherkey')
          .update({
        'names': FieldValue.arrayRemove([names![index]])
      });
      setState(() {
        vouchers.removeAt(index);
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminVouchersPage(),
        ),
      );
    } catch (error) {
      print('Error deleting voucher: $error');
    }
  }

  Future<void> reloadVouchers() async {
    setState(() {
      _isLoading = true;
      vouchers.clear();
    });

    try {
      firebase_storage.ListResult listResult = await firebase_storage
          .FirebaseStorage.instance
          .ref('images/vouchers/')
          .listAll();

      List<Voucher> newVouchers = [];
      for (var ref in listResult.items) {
        String url = await ref.getDownloadURL();
        newVouchers.add(Voucher(url, ref));
      }

      setState(() {
        vouchers = newVouchers;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching vouchers: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vouchers'),
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Voucher>>(
                  future: fetchVouchers(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Voucher>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SpinKitFadingCube(
                          color: Color.fromARGB(255, 30, 197, 83),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data?.length,
                        addAutomaticKeepAlives: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(names![index]), //voucher name
                            leading: Image.network(snapshot.data![index].url),
                            trailing: IconButton(
                              onPressed: () {
                                deleteVoucher(index);
                                // setState(() {});
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Column(
              children: [
                Text(
                  'Add Voucher',
                  style: TextStyle(
                    fontSize: 16, // Adjust the font size as desired
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () {
                    addVoucher();
                  },
                  backgroundColor: const Color(0xff0FA697),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
