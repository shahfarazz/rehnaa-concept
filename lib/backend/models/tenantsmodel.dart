import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';

class Tenant {
  final String firstName;
  final String lastName;
  final String description;
  final double rating;
  final int rent;
  final int creditPoints;
  // final String propertyDetails;
  final String cnicNumber;
  final String emailOrPhone;
  final bool tasdeeqVerification;
  final bool policeVerification;
  final int familyMembers;
  final DocumentReference<Map<String, dynamic>>? landlordRef;
  Landlord? landlord;
  final String? pathToImage;

  Tenant({
    required this.firstName,
    required this.lastName,
    required this.description,
    required this.rating,
    required this.rent,
    required this.creditPoints,
    // required this.propertyDetails,
    required this.cnicNumber,
    required this.emailOrPhone,
    required this.tasdeeqVerification,
    required this.familyMembers,
    required this.policeVerification,
    this.landlordRef,
    this.landlord,
    this.pathToImage,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      firstName: json['firstName'],
      lastName: json['lastName'],
      description: json['description'] ?? 'No description',
      rating: json['rating'] ?? 0.0,
      rent: json['rent'] ?? 0.0,
      creditPoints: json['creditPoints'] ?? 0,
      // propertyDetails: json['propertyDetails'] ?? 'No property details',
      cnicNumber: json['cnicNumber'] ?? 'N/A',
      emailOrPhone: json['emailOrPhone'] ?? 'N/A',
      tasdeeqVerification: json['tasdeeqVerification'] ?? false,
      familyMembers: json['familyMembers'] ?? 0,
      landlordRef: json['landlordRef'],
      pathToImage: json['pathToImage'] ?? 'assets/defaultimage.png',
      policeVerification: json['policeVerification'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'description': description,
      'rating': rating,
      'rent': rent,
      'creditPoints': creditPoints,
      // 'propertyDetails': propertyDetails,
      'cnicNumber': cnicNumber,
      'emailOrPhone': emailOrPhone,
      'tasdeeqVerification': tasdeeqVerification,
      'familyMembers': familyMembers,
      'landlordRef': landlordRef,
      'pathToImage': pathToImage,
      'policeVerification': policeVerification,
    };
  }

  Future<void> getLandlord() async {
    if (landlordRef != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await landlordRef!.get();
      landlord = await Landlord.fromJson(snapshot.data());
    }
  }

  static void addDummyTenant() async {
    // Create a new instance of Firestore
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Create a dummy tenant object with all the required values
    Tenant dummyTenant = Tenant(
      firstName: 'Dummy',
      lastName: 'Tenant',
      description: 'This is a dummy tenant',
      rating: 4.5,
      rent: 1000,
      creditPoints: 100,
      // propertyDetails: 'Dummy property',
      cnicNumber: '123456789',
      emailOrPhone: 'dummy@example.com',
      tasdeeqVerification: true,
      familyMembers: 2,
      pathToImage: 'assets/defaulticon.png',
      policeVerification: true,
    );

    try {
      // Add the dummy tenant to the "Tenants" collection
      DocumentReference<Map<String, dynamic>> tenantDocRef =
          await firestore.collection('Tenants').add(dummyTenant.toJson());

      // Get the landlord document reference
      DocumentReference<Map<String, dynamic>> landlordDocRef =
          firestore.collection('Landlords').doc('R88XI7AqrOZBtGZzQwgyX2Wr7Yz1');

      // Update the "tenantRef" field in the landlord document
      landlordDocRef.update({
        'tenantRef': FieldValue.arrayUnion([tenantDocRef])
      });

      print('Dummy tenant added successfully!');
    } catch (error) {
      print('Error adding dummy tenant: $error');
    }
  }
}

class TenantCardWidget extends StatefulWidget {
  final Tenant? tenant; // Pass the existing tenant object if editing

  TenantCardWidget({this.tenant});

  @override
  _TenantCardWidgetState createState() => _TenantCardWidgetState();
}

class _TenantCardWidgetState extends State<TenantCardWidget> {
  String firstName = '';
  String lastName = '';
  String description = '';
  double rating = 0.0;
  int rent = 0;
  String? pathToImage;

  bool uploading = false;

  List<Tenant> tenantList = [];
  List<html.File>? selectedImages = [];

  final TextEditingController cnicController = TextEditingController();
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController propertyDetailsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tenant != null) {
      // Populate the fields if editing an existing tenant
      firstName = widget.tenant!.firstName;
      lastName = widget.tenant!.lastName;
      description = widget.tenant!.description;
      rating = widget.tenant!.rating;
      rent = widget.tenant!.rent;
      pathToImage = widget.tenant!.pathToImage;
    }
    fetchTenants();
  }

  Future<void> fetchTenants() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Tenants').get();

    List<Tenant> tenants = [];

    for (var doc in querySnapshot.docs) {
      Tenant tenant = Tenant.fromJson(doc.data());
      tenants.add(tenant);
    }

    setState(() {
      tenantList = tenants;
    });
  }

  void validateInputs() {
    if (firstName.isEmpty || lastName.isEmpty || rent <= 0) {
      Fluttertoast.showToast(
        msg: 'Please enter valid first name, last name, and rent.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (selectedImages == null || selectedImages!.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please select at least one image.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    handleSubmit();
  }

  Future<void> handleSubmit() async {
    setState(() {
      uploading = true;
    });

    await uploadImages();

    // Create a new tenant object or update the existing tenant object
    Tenant tenant = Tenant(
      firstName: firstName,
      lastName: lastName,
      description: description,
      rating: rating,
      rent: rent,
      pathToImage: pathToImage,
      creditPoints: 0,
      cnicNumber: cnicController.text,
      emailOrPhone: emailOrPhoneController.text,
      familyMembers: 0,
      landlordRef: null,
    );

    if (widget.tenant != null) {
      // Update the existing tenant
      await FirebaseFirestore.instance
          .collection('Tenants')
          .doc(widget.tenant!.id)
          .update(tenant.toJson());
    } else {
      // Add a new tenant
      await FirebaseFirestore.instance
          .collection('Tenants')
          .add(tenant.toJson());
    }

    setState(() {
      uploading = false;
    });

    Fluttertoast.showToast(
      msg: widget.tenant != null
          ? 'Tenant updated successfully!'
          : 'Tenant added successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminTenantsInputPage(),
      ),
    );
  }

  Future<void> selectImages() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..multiple = true;
    input.click();

    await input.onChange.first;

    if (input.files != null) {
      setState(() {
        selectedImages = input.files;
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Card(
      child: SingleChildScrollView(
        child: Column(
          children: [
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
                    title: Text('Tenant Details'),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'First Name'),
                    onChanged: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                    controller: TextEditingController(text: firstName),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                    controller: TextEditingController(text: lastName),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                    controller: TextEditingController(text: description),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Rating'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        rating = double.tryParse(value) ?? 0.0;
                      });
                    },
                    controller: TextEditingController(text: rating.toString()),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Rent'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        rent = int.tryParse(value) ?? 0;
                      });
                    },
                    controller: TextEditingController(text: rent.toString()),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectImages,
                    child: const Text('Select Images'),
                  ),
                  const SizedBox(height: 20),
                  AbsorbPointer(
                    absorbing: uploading,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: validateInputs,
                          child:
                              Text(widget.tenant != null ? 'Update' : 'Submit'),
                        ),
                        if (uploading) const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
