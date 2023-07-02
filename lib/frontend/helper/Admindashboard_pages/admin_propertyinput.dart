import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;

import '../../../backend/models/propertymodel.dart';
import 'admin_propertyedit.dart';

class AdminPropertyInputPage extends StatefulWidget {
  @override
  _AdminPropertyInputPageState createState() => _AdminPropertyInputPageState();
}

class _AdminPropertyInputPageState extends State<AdminPropertyInputPage> {
  List<Property> properties = [];
  List<Property> filteredProperties = [];
  TextEditingController searchController = TextEditingController();
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Properties').get();

    List<Property> propertyList = [];

    for (var doc in querySnapshot.docs) {
      Property property = Property.fromJson(doc.data());
      property.propertyID = doc.id;
      propertyList.add(property);
    }

    setState(() {
      properties = propertyList;
      filteredProperties = List.from(properties);
    });
  }

  Future<String> getLandlordName(
      DocumentReference<Map<String, dynamic>>? landlordRef) async {
    if (landlordRef == null) {
      return '';
    }

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await landlordRef.get();

    String firstName = documentSnapshot['firstName'] ?? '';
    String lastName = documentSnapshot['lastName'] ?? '';

    return '$firstName $lastName';
  }

  void filterProperties(String query) {
    List<Property> tempList = [];
    if (query.isNotEmpty) {
      tempList = properties.where((property) {
        return property.title.toLowerCase().contains(query.toLowerCase()) ||
            property.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      tempList = List.from(properties);
    }
    setState(() {
      filteredProperties = tempList;
    });
  }

  List<Property> getPaginatedProperties() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (endIndex >= filteredProperties.length) {
      return filteredProperties.sublist(startIndex);
    } else {
      return filteredProperties.sublist(startIndex, endIndex);
    }
  }

  Future<void> openPropertyDetailsPage(Property property) async {
    String landlordName = await getLandlordName(property.landlordRef);

    print('Property id is ${property.propertyID}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyEditPage(property: property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Images'),
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
                  filterProperties(value);
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
                itemCount: getPaginatedProperties().length,
                itemBuilder: (context, index) {
                  Property property = getPaginatedProperties()[index];

                  return ListTile(
                    title: Text(property.title),
                    subtitle: Text(property.location),
                    leading: const Icon(Icons.home),
                    onTap: () => openPropertyDetailsPage(property),
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
                          (filteredProperties.length / itemsPerPage).ceil();
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
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: PropertyCardWidget(),
              );
            },
          );
          // Add functionality for the + floating action button here
        },
        backgroundColor: const Color(0xff0FA697),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PropertyCardWidget extends StatefulWidget {
  @override
  _PropertyCardWidgetState createState() => _PropertyCardWidgetState();
}

class _PropertyCardWidgetState extends State<PropertyCardWidget> {
  String type = '';
  int beds = 0;
  int baths = 0;
  bool garden = false;
  int living = 0;
  int floors = 0;
  int carspace = 0;
  String description = '';
  String title = '';
  String location = '';
  String address = '';
  double price = 0.0;
  DocumentReference<Map<String, dynamic>>? landlordRef;
  double rehnaaRating = 0.0;
  double tenantRating = 0.0;
  String tenantReview = '';
  List<String> imagePath = [];
  String? typeError;
  String? bedsError;
  String? bathsError;
  String? livingError;
  String? floorsError;
  String? carspaceError;
  String? descriptionError;
  String? titleError;
  String? locationError;
  String? priceError;
  String? landlordError;
  String? rehnaaRatingError;
  String? tenantRatingError;
  String? tenantReviewError;
  String? imagePathError;
  String? imageError;
  String? imageCountError;
  String? imageTypeError;
  String? landlordRefError;
  String? addressError;
  String buttonLabel = 'Select Images';
  bool uploading = false; // Track the uploading state

  List<DocumentSnapshot<Map<String, dynamic>>> landlordList = [];
  List<html.File>? selectedImages = [];

  Future<void> fetchLandlords() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Landlords').get();

    setState(() {
      landlordList = querySnapshot.docs;
    });
  }

  Future<String> getLandlordName(
      DocumentReference<Map<String, dynamic>> landlordRef) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await landlordRef.get();

    String firstName = documentSnapshot['firstName'] ?? '';
    String lastName = documentSnapshot['lastName'] ?? '';

    return '$firstName $lastName';
  }

  Future<void> selectImages() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..multiple = true;
    input.click();

    await input.onChange.first;

    if (input.files != null) {
      setState(() {
        selectedImages = input.files;
        imagePath.add('dummy_image_path'); // Add a dummy image path
        buttonLabel = 'Images Selected (${selectedImages!.length})';
      });
    }
  }

  Future<void> uploadImages() async {
    if (selectedImages != null && selectedImages!.isNotEmpty) {
      // Remove the dummy image path
      setState(() {
        imagePath.remove('dummy_image_path');
      });

      for (var file in selectedImages!) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);

        final completer = Completer<String>();

        reader.onLoad.first.then((_) {
          completer.complete(reader.result.toString());
        });

        final encodedImage = await completer.future;

        Reference storageReference = FirebaseStorage.instance.ref().child(
            'images/properties/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageReference.putString(encodedImage,
            format: PutStringFormat.dataUrl);
        TaskSnapshot storageSnapshot = await uploadTask;
        String imageUrl = await storageSnapshot.ref.getDownloadURL();

        imagePath.add(imageUrl);
      }

      setState(() {
        imagePath = imagePath;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLandlords();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Card(
        child: SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            size.width * 0.15,
            0,
            size.width * 0.15,
            0,
          ),
          child: Column(
            children: [
              const ListTile(
                title: Text('Property Details'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
              if (titleError != null)
                Text(
                  titleError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Type'),
                onChanged: (value) {
                  setState(() {
                    type = value;
                  });
                },
              ),
              if (typeError != null)
                Text(
                  typeError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Beds'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    beds = int.tryParse(value) ?? 0;
                  });
                },
              ),
              if (bedsError != null)
                Text(
                  bedsError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Baths'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    baths = int.tryParse(value) ?? 0;
                  });
                },
              ),
              if (bathsError != null)
                Text(
                  bathsError!,
                  style: const TextStyle(color: Colors.red),
                ),
              SwitchListTile(
                title: const Text('Garden'),
                value: garden,
                onChanged: (value) {
                  setState(() {
                    garden = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Living'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    living = int.tryParse(value) ?? 0;
                  });
                },
              ),
              if (livingError != null)
                Text(
                  livingError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Floors'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    floors = int.tryParse(value) ?? 0;
                  });
                },
              ),
              if (floorsError != null)
                Text(
                  floorsError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Carspace'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    carspace = int.tryParse(value) ?? 0;
                  });
                },
              ),
              if (carspaceError != null)
                Text(
                  carspaceError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              if (descriptionError != null)
                Text(
                  descriptionError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  setState(() {
                    location = value;
                  });
                },
              ),
              if (locationError != null)
                Text(
                  locationError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
              ),
              if (addressError != null)
                Text(
                  addressError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                onChanged: (value) {
                  setState(() {
                    price = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              if (priceError != null)
                Text(
                  priceError!,
                  style: const TextStyle(color: Colors.red),
                ),
              DropdownButtonFormField<DocumentReference<Map<String, dynamic>>>(
                decoration: const InputDecoration(labelText: 'Landlord'),
                value: landlordRef,
                items: landlordList.map((landlord) {
                  String landlordName =
                      '${landlord['firstName']} ${landlord['lastName']}';
                  return DropdownMenuItem(
                    value: landlord.reference,
                    child: Text(landlordName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    landlordRef = value;
                  });
                },
              ),
              if (landlordRefError != null)
                Text(
                  landlordRefError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Rehnaa Rating'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                onChanged: (value) {
                  setState(() {
                    rehnaaRating = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              if (rehnaaRatingError != null)
                Text(
                  rehnaaRatingError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Tenant Rating'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                onChanged: (value) {
                  setState(() {
                    tenantRating = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              if (tenantRatingError != null)
                Text(
                  tenantRatingError!,
                  style: const TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: const InputDecoration(labelText: 'Tenant Review'),
                onChanged: (value) {
                  setState(() {
                    tenantReview = value;
                  });
                },
              ),
              if (tenantReviewError != null)
                Text(
                  tenantReviewError!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectImages,
                style: ElevatedButton.styleFrom(
                    // Add your button styles here
                    ),
                child: Text(buttonLabel),
              ),
              const SizedBox(height: 20),
              AbsorbPointer(
                absorbing:
                    uploading, // Disable the button when uploading is in progress
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        bool isValid = validateInputs();
                        if (isValid) {
                          setState(() {
                            uploading = true; // Set the uploading state to true
                          });

                          // Perform actions with the gathered inputs
                          // For example, you can print the values:

                          // Upload selected images
                          await uploadImages();

                          //upload property details to firebase// random doc id
                          // get that random doc id below
                          DocumentReference<Map<String, dynamic>> propertyRef =
                              FirebaseFirestore.instance
                                  .collection('Properties')
                                  .doc();

                          //set the values of propertyref
                          await propertyRef.set({
                            'imagePath': imagePath,
                            'type': type,
                            'beds': beds,
                            'baths': baths,
                            'floors': floors,
                            'carspace': carspace,
                            'description': description,
                            'garden': garden,
                            'living': living,
                            'title': title,
                            'location': location,
                            'address': address,
                            'price': price,
                            'landlordRef': landlordRef,
                            'rehnaaRating': rehnaaRating,
                            'tenantRating': tenantRating,
                            'tenantReview': tenantReview,
                          }, SetOptions(merge: true));

                          // set landlord's property ref to the new property ref above
                          await landlordRef!.update({
                            'propertyRef': FieldValue.arrayUnion(
                                [propertyRef as DocumentReference])
                          });

                          setState(() {
                            uploading =
                                false; // Set the uploading state to false
                          });

                          // Navigate to the AdminPropertyInputPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminPropertyInputPage(),
                            ),
                          );
                        } else {
                          // Show an error message
                          Fluttertoast.showToast(
                            msg:
                                'Please fill in all the required fields with valid input.',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          // Add your button styles here
                          ),
                      child: const Text('Submit'),
                    ),
                    if (uploading) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    ));
  }

  bool validateInputs() {
    bool isValid = true;

    if (type.isEmpty) {
      setState(() {
        typeError = 'Type is required.';
        isValid = false;
      });
    } else {
      setState(() {
        typeError = null;
      });
    }

    if (beds <= 0) {
      setState(() {
        bedsError = 'Beds must be greater than zero.';
        isValid = false;
      });
    } else {
      setState(() {
        bedsError = null;
      });
    }

    if (baths <= 0) {
      setState(() {
        bathsError = 'Baths must be greater than zero.';
        isValid = false;
      });
    } else {
      setState(() {
        bathsError = null;
      });
    }

    if (living <= 0) {
      setState(() {
        livingError = 'Living must be greater than zero.';
        isValid = false;
      });
    } else {
      setState(() {
        livingError = null;
      });
    }

    if (floors <= 0) {
      setState(() {
        floorsError = 'Floors must be greater than zero.';
        isValid = false;
      });
    } else {
      setState(() {
        floorsError = null;
      });
    }

    if (carspace <= 0) {
      setState(() {
        carspaceError = 'Carspace must be greater than zero.';
        isValid = false;
      });
    } else {
      setState(() {
        carspaceError = null;
      });
    }

    if (description.isEmpty) {
      setState(() {
        descriptionError = 'Description is required.';
        isValid = false;
      });
    } else {
      setState(() {
        descriptionError = null;
      });
    }

    if (title.isEmpty) {
      setState(() {
        titleError = 'Title is required.';
        isValid = false;
      });
    } else {
      setState(() {
        titleError = null;
      });
    }

    if (location.isEmpty) {
      setState(() {
        locationError = 'Location is required.';
        isValid = false;
      });
    } else {
      setState(() {
        locationError = null;
      });
    }
    if (address.isEmpty) {
      setState(() {
        addressError = 'Location is required.';
        isValid = false;
      });
    } else {
      setState(() {
        addressError = null;
      });
    }

    if (price <= 0) {
      setState(() {
        priceError = 'Price must be greater than zero.';
        isValid = false;
      });
    } else {
      setState(() {
        priceError = null;
      });
    }

    if (landlordRef == null) {
      setState(() {
        landlordRefError = 'Landlord is required.';
        isValid = false;
      });
    } else {
      setState(() {
        landlordRefError = null;
      });
    }

    if (rehnaaRating < 0 || rehnaaRating > 10) {
      setState(() {
        rehnaaRatingError = 'Rehnaa Rating must be between 0 and 10.';
        isValid = false;
      });
    } else {
      setState(() {
        rehnaaRatingError = null;
      });
    }

    if (tenantRating < 0 || tenantRating > 10) {
      setState(() {
        tenantRatingError = 'Tenant Rating must be between 0 and 10.';
        isValid = false;
      });
    } else {
      setState(() {
        tenantRatingError = null;
      });
    }

    if (tenantReview.isEmpty) {
      setState(() {
        tenantReviewError = 'Tenant Review is required.';
        isValid = false;
      });
    } else {
      setState(() {
        tenantReviewError = null;
      });
    }

    if (imagePath.isEmpty) {
      setState(() {
        imagePathError = 'Please upload at least one image.';
        isValid = false;
      });
    } else {
      setState(() {
        imagePathError = null;
      });
    }

    return isValid;
  }
}
