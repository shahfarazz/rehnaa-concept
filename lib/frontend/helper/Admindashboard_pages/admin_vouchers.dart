import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;

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
  bool isLoading = false;
  String? urls;

  @override
  void initState() {
    super.initState();
    fetchVouchers();
  }

  Future<void> addVoucher() async {
    setState(() {
      uploadProgress = 0.0;
      isLoading = true;
    });

    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..multiple = true;
    input.click();

    await input.onChange.first;
    late List<html.File>? pickedFile;

    if (input.files != null) {
      setState(() {
        pickedFile = input.files;
        // buttonLabel = 'Images Selected (${selectedImages!.length})';
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

        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('images/vouchers/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageReference.putString(encodedImage,
            format: PutStringFormat.dataUrl);
        await uploadTask;
        String imageUrl = await storageReference.getDownloadURL();

        //create or update a new collection called Vouchers and add the imageurl to firestore

        await FirebaseFirestore.instance
            .collection('Vouchers')
            .doc('voucherkey')
            .set({
          //add the url to a list of urls
          'urls': FieldValue.arrayUnion([imageUrl])
        }, SetOptions(merge: true));

        setState(() {
          isLoading = false;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminVouchersPage(),
            ),
          );
        });

        WriteBatch batch = FirebaseFirestore.instance.batch();

        // Update documents in the Tenants collection
        QuerySnapshot tenantsQuerySnapshot =
            await FirebaseFirestore.instance.collection('Tenants').get();
        tenantsQuerySnapshot.docs.forEach((tenantDoc) {
          batch.set(tenantDoc.reference, {'isNewVouchers': true},
              SetOptions(merge: true));
        });

        // Update documents in the Landlords collection
        QuerySnapshot landlordsQuerySnapshot =
            await FirebaseFirestore.instance.collection('Landlords').get();
        landlordsQuerySnapshot.docs.forEach((landlordDoc) {
          batch.set(landlordDoc.reference, {'isNewVouchers': true},
              SetOptions(merge: true));
        });

        // Commit the batched write operation
        await batch.commit();
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchVouchers() async {
    try {
      firebase_storage.ListResult listResult = await firebase_storage
          .FirebaseStorage.instance
          .ref('images/vouchers/')
          .listAll();
      List<Voucher> vouchersList = [];
      for (var ref in listResult.items) {
        String url = await ref.getDownloadURL();
        vouchersList.add(Voucher(url, ref));
      }
      setState(() {
        vouchers = vouchersList;
      });
    } catch (error) {
      print('Error fetching vouchers: $error');
    }
  }

  Future<void> deleteVoucher(int index) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(vouchers[index].ref.fullPath)
          .delete();
      setState(() {
        vouchers.removeAt(index);
      });
      FirebaseFirestore.instance
          .collection('Vouchers')
          .doc('voucherkey')
          .update({
        'urls': FieldValue.arrayRemove([vouchers[index].url])
      });
    } catch (error) {
      print('Error deleting voucher: $error');
    }
  }

  Future<void> reloadVouchers() async {
    setState(() {
      isLoading = true;
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
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching vouchers: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord & Tenant Info'),
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
      body: Center(
        child: Column(
          children: [
            Stack(
              children: [
                ElevatedButton(
                  onPressed: () {
                    addVoucher();
                  },
                  child: const Text('Add Voucher'),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: vouchers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Voucher ${index + 1}'),
                    leading: Image.network(vouchers[index].url),
                    trailing: IconButton(
                      onPressed: () => deleteVoucher(index),
                      icon: const Icon(Icons.delete),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
