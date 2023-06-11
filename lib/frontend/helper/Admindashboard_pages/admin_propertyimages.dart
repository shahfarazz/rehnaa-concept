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

class Property {
  final String title;
  final String location;
  final DocumentReference<Map<String, dynamic>>? landlordRef;

  Property({
    required this.title,
    required this.location,
    required this.landlordRef,
  });
}

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

    setState(() {
      properties = querySnapshot.docs.map((doc) {
        return Property(
          title: doc['title'],
          location: doc['location'],
          landlordRef: doc['landlordRef'],
        );
      }).toList();
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

  Future<void> openPropertyDetailsDialog(Property property) async {
    String landlordName = await getLandlordName(property.landlordRef);

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  property.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Landlord: $landlordName',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text(
                  property.location,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Add Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // Add image upload functionality here
              ElevatedButton(
                onPressed: () async {
                  List<XFile>? pickedImages;
                  // if (kDebugMode) {
                  //   // Load dummy images from assets
                  //   List<Uint8List> imageBytes = await Future.wait([
                  //     rootBundle
                  //         .load('assets/image1.jpg')
                  //         .then((data) => data.buffer.asUint8List()),
                  //     rootBundle
                  //         .load('assets/image2.jpg')
                  //         .then((data) => data.buffer.asUint8List()),
                  //   ]);

                  //   // Save dummy images to temporary files
                  //   pickedImages = [];
                  //   for (var i = 0; i < imageBytes.length; i++) {
                  //     Directory tempDir = await getTemporaryDirectory();
                  //     String tempPath = '${tempDir.path}/dummy_image$i.jpg';
                  //     File(tempPath).writeAsBytesSync(imageBytes[i]);
                  //     pickedImages.add(XFile(tempPath));
                  //   }
                  // } else {
                  pickedImages = await ImagePicker().pickMultiImage();
                  // }

                  if (pickedImages != null && pickedImages.isNotEmpty) {
                    XFile firstImage = pickedImages[0]; // Get the first image

                    // Upload image to Firebase Storage
                    // Replace 'images/properties/' with your desired storage path
                    Reference storageReference = FirebaseStorage.instance
                        .ref()
                        .child(
                            'images/properties/${DateTime.now().millisecondsSinceEpoch}');
                    TaskSnapshot storageSnapshot =
                        await storageReference.putFile(File(firstImage.path));
                    String imageUrl =
                        await storageSnapshot.ref.getDownloadURL();

                    // Use the image URL as needed
                    print(imageUrl);
                  }
                },
                child: Text('Upload Image'),
              ),

              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Images'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
                decoration: InputDecoration(
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
                    leading: Icon(Icons.home),
                    onTap: () => openPropertyDetailsDialog(property),
                  );
                },
              ),
            ),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
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
        child: Icon(Icons.add),
        backgroundColor: Color(0xff0FA697),
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

  List<DocumentSnapshot<Map<String, dynamic>>> landlordList = [];

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

  Future<void> uploadImages() async {
    List<XFile>? pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages != null && pickedImages.isNotEmpty) {
      for (var image in pickedImages) {
        // Upload image to Firebase Storage
        Reference storageReference = FirebaseStorage.instance.ref().child(
            'images/properties/${DateTime.now().millisecondsSinceEpoch}');
        TaskSnapshot storageSnapshot =
            await storageReference.putFile(File(image.path));
        String imageUrl = await storageSnapshot.ref.getDownloadURL();

        setState(() {
          imagePath.add(imageUrl);
        });
      }
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            size.width * 0.15,
            0,
            size.width * 0.15,
            0,
          ),
          child: Column(
            children: [
              ListTile(
                title: Text('Property Details'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Type'),
                onChanged: (value) {
                  setState(() {
                    type = value;
                  });
                },
              ),
              if (typeError != null)
                Text(
                  typeError!,
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Beds'),
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
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Baths'),
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
                  style: TextStyle(color: Colors.red),
                ),
              SwitchListTile(
                title: Text('Garden'),
                value: garden,
                onChanged: (value) {
                  setState(() {
                    garden = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Living'),
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
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Floors'),
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
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Carspace'),
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
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              if (descriptionError != null)
                Text(
                  descriptionError!,
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
              if (titleError != null)
                Text(
                  titleError!,
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  setState(() {
                    location = value;
                  });
                },
              ),
              if (locationError != null)
                Text(
                  locationError!,
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  style: TextStyle(color: Colors.red),
                ),
              DropdownButtonFormField<DocumentReference<Map<String, dynamic>>>(
                decoration: InputDecoration(labelText: 'Landlord'),
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
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Rehnaa Rating'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Tenant Rating'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                decoration: InputDecoration(labelText: 'Tenant Review'),
                onChanged: (value) {
                  setState(() {
                    tenantReview = value;
                  });
                },
              ),
              if (tenantReviewError != null)
                Text(
                  tenantReviewError!,
                  style: TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: uploadImages,
                child: Text('Upload Images'),
              ),
              ElevatedButton(
                onPressed: () {
                  bool isValid = validateInputs();
                  if (isValid) {
                    // Perform actions with the gathered inputs
                    // For example, you can print the values:
                    print('Type: $type');
                    print('Beds: $beds');
                    print('Baths: $baths');
                    print('Garden: $garden');
                    print('Living: $living');
                    print('Floors: $floors');
                    print('Carspace: $carspace');
                    print('Description: $description');
                    print('Title: $title');
                    print('Location: $location');
                    print('Price: $price');
                    print('Landlord Ref: $landlordRef');
                    print('Rehnaa Rating: $rehnaaRating');
                    print('Tenant Rating: $tenantRating');
                    print('Tenant Review: $tenantReview');
                    print('Image Paths: $imagePath');
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
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
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
