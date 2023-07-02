import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import '../../../backend/models/dealermodel.dart';

class AdminDealerInputPage extends StatefulWidget {
  const AdminDealerInputPage({super.key});

  @override
  State<AdminDealerInputPage> createState() => _AdminDealerInputPageState();
}

class _AdminDealerInputPageState extends State<AdminDealerInputPage> {
  List<Dealer> dealers = [];
  List<Dealer> filteredDealers = [];
  int currentPage = 1;
  TextEditingController searchController = TextEditingController();
  int itemsPerPage = 10;
  List<html.File>? selectedImages = [];
  String buttonLabel = 'Select Images';
  String pathToImage = '';
  bool isUploading = false;

  //function to fetch the current dealers from firestore
  Future<void> fetchDealers() async {
    List<Dealer> dealers_temp = [];

    FirebaseFirestore.instance.collection('Dealers').get().then((docSnap) {
      for (var doc in docSnap.docs) {
        Dealer dealer = Dealer.fromJson(doc.data() as Map<String, dynamic>);
        dealer.tempID = doc.id;
        dealers_temp.add(dealer);
      }

      setState(() {
        dealers = dealers_temp;
        filteredDealers = List.from(dealers);

        // print('Dealers fetched successfully!');
        // print('dealers list is $dealers');
      });
    });
  }

  Future<void> selectImages() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..multiple = true;
    input.click();

    await input.onChange.first;

    if (input.files != null) {
      setState(() {
        selectedImages = input.files;
        buttonLabel = 'Images Selected (${selectedImages!.length})';
        isUploading = true; // start uploading
        uploadImages(); // Upload images after selecting
      });
    }
  }

  Future<void> uploadImages() async {
    if (selectedImages != null && selectedImages!.isNotEmpty) {
      for (var file in selectedImages!) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);

        final completer = Completer<String>();

        reader.onLoad.first.then((_) {
          completer.complete(reader.result.toString());
        });

        final encodedImage = await completer.future;

        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('images/users/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageReference.putString(encodedImage,
            format: PutStringFormat.dataUrl);
        await uploadTask;
        String imageUrl = await storageReference.getDownloadURL();

        setState(() {
          pathToImage = imageUrl;
          isUploading = false; // end uploading
        });
      }
    }
  }

  void filterDealers(String query) {
    List<Dealer> tempList = [];
    if (query.isNotEmpty) {
      tempList = dealers.where((dealer) {
        return dealer.firstName.toLowerCase().contains(query.toLowerCase()) ||
            dealer.lastName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      tempList = List.from(dealers);
    }
    setState(() {
      filteredDealers = tempList;
    });
  }

  List<Dealer> getPaginatedDealers() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (endIndex >= filteredDealers.length) {
      return filteredDealers.sublist(startIndex);
    } else {
      return filteredDealers.sublist(startIndex, endIndex);
    }
  }

  Future<void> openDealerDetailsDialog(Dealer dealer) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    '${dealer.firstName} ${dealer.lastName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // subtitle: Text(
                  //   'Rent: \$${dealer.rent.toStringAsFixed(2)}',
                  //   style: const TextStyle(
                  //     fontSize: 16,
                  //   ),
                  // ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    'Dealer balance: ${dealer.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                // ListTile(
                //   leading: const Icon(Icons.star),
                //   title: Text(
                //     'Rating: ${dealer.rating.toStringAsFixed(1)}',
                //     style: const TextStyle(
                //       fontSize: 16,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 10),
                const Text(
                  'Image:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Display the images with loading indicator
                SizedBox(
                  height: 200.0, // Adjust this value according to your needs.
                  child: CachedNetworkImage(
                    imageUrl: dealer.pathToImage ?? '',
                    errorWidget: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return CircularProgressIndicator(
                        value: downloadProgress.progress,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(Dealer dealer) {
    final TextEditingController firstNameController =
        TextEditingController(text: dealer.firstName);
    final TextEditingController lastNameController =
        TextEditingController(text: dealer.lastName);
    final TextEditingController balanceController =
        TextEditingController(text: dealer.balance.toString());
    // final TextEditingController rentController =
    //     TextEditingController(text: dealer.rent.toString());
    // final TextEditingController creditPointsController =
    //     TextEditingController(text: dealer.creditPoints.toString());
    // final TextEditingController cnicNumberController =
    //     TextEditingController(text: dealer.cnicNumber);
    // final TextEditingController emailOrPhoneController =
    //     TextEditingController(text: dealer.emailOrPhone);
    // final TextEditingController familyMembersController =
    //     TextEditingController(text: dealer.familyMembers.toString());
    // final TextEditingController ratingController =
    // TextEditingController(text: dealer.rating.toString());

    // final hashedCnic = hashString(cnicNumberController.text);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text('Edit Dealer Details'),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: balanceController,
                  decoration:
                      const InputDecoration(labelText: 'Dealer Balance'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Update the tenant details in Firebase

                    var balanceInt = int.tryParse(balanceController.text) ?? 0;

                    FirebaseFirestore.instance
                        .collection('Dealers')
                        .doc(dealer.tempID)
                        .update({
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'balance': balanceInt,
                    });

                    setState(() {
                      // Update the tenant details in the local list
                      dealer.firstName = firstNameController.text;
                      dealer.lastName = lastNameController.text;
                      dealer.balance = balanceInt.toDouble();
                    });

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //write a function to show dialog to add a new dealer which should have the following fields
  //firstName, lastName, balance, pathToImage after uploading image to firebase storage
  void _addNewDealerDialog() {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController balanceController = TextEditingController();
    bool isUploading =
        false; // to control if we're currently uploading the image or not

    void validateInputs() {
      if (firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          balanceController.text.isEmpty ||
          pathToImage.isEmpty) {
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            // Wrap the dialog in a StatefulBuilder to enable updating the state
            builder: (BuildContext context, setState) {
          return Dialog(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text('Add New Dealer'),
                  ),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  TextField(
                    controller: balanceController,
                    decoration:
                        const InputDecoration(labelText: 'Dealer Balance'),
                  ),

                  //button to upload image to firebase storage and get the path to image
                  ElevatedButton(
                    onPressed: selectImages,
                    child: Text(buttonLabel),
                  ),
                  if (isUploading)
                    CircularProgressIndicator(), // show progress indicator when image is uploading
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: !isUploading
                        ? () async {
                            var balanceInt =
                                int.tryParse(balanceController.text) ?? 0;

                            validateInputs();

                            // Generate a random email and password for the dealer
                            String randomEmail =
                                "dealer${Random().nextInt(10000)}@example.com"; // ensure it's a unique email
                            String randomPassword =
                                "password${Random().nextInt(10000)}"; // simple password, consider making it more complex

                            try {
                              // Create a user with the random email and password
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .createUserWithEmailAndPassword(
                                email: randomEmail,
                                password: randomPassword,
                              );

                              // Get the uid of the newly created user
                              String uid = userCredential.user!.uid;

                              // Now that the user has been created in Firebase Auth, add them to the Dealers collection in Firestore
                              FirebaseFirestore.instance
                                  .collection('Dealers')
                                  .doc(uid)
                                  .set({
                                'firstName': firstNameController.text,
                                'lastName': lastNameController.text,
                                'balance': balanceInt,
                                'pathToImage': pathToImage,
                                'email':
                                    randomEmail, // save the email to the Firestore document
                                'password':
                                    randomPassword, // save the password to the Firestore document
                                'uid':
                                    uid, // save the uid to the Firestore document
                              }, SetOptions(merge: true));

                              setState(() {
                                dealers.add(Dealer(
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  balance: balanceInt.toDouble(),
                                  pathToImage: pathToImage,
                                  // email:
                                  //     randomEmail, // optional, if you need it in your Dealer model
                                  // password:
                                  //     randomPassword, // optional, if you need it in your Dealer model
                                  // uid:
                                  //     uid, // optional, if you need it in your Dealer model
                                ));
                              });

                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return const AdminDealerInputPage();
                                },
                              ));
                            } catch (e) {
                              // Handle error
                              print(e);
                            }
                          }
                        : null,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchDealers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealers Input'),
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
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  filterDealers(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: getPaginatedDealers().length,
                itemBuilder: (context, index) {
                  Dealer dealer = getPaginatedDealers()[index];

                  return ListTile(
                    title: Text('${dealer.firstName} ${dealer.lastName}'),
                    subtitle: Text(dealer.balance.toString()),
                    leading: const Icon(Icons.person),
                    onTap: () {
                      _showEditDialog(dealer);
                    },
                  );
                },
              ),
            ),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      final maxPage =
                          (filteredDealers.length / itemsPerPage).ceil();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewDealerDialog();
        },
        backgroundColor: const Color(0xff0FA697),
        child: const Icon(Icons.add),
      ),
    );
  }
}
