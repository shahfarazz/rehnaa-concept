import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

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

class AdminPropertyImagesPage extends StatefulWidget {
  @override
  _AdminPropertyImagesPageState createState() =>
      _AdminPropertyImagesPageState();
}

class _AdminPropertyImagesPageState extends State<AdminPropertyImagesPage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Images'),
        flexibleSpace: Container(
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(24),
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
    );
  }
}
