import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';

class Tenant {
  String firstName;
  String lastName;
  String description;
  double rating;
  var rent;
  int creditPoints;
  //  String propertyDetails;
  String cnicNumber;
  String emailOrPhone;
  bool tasdeeqVerification;
  bool policeVerification;
  int familyMembers;
  DocumentReference<Map<String, dynamic>>? landlordRef;
  DocumentReference<Map<String, dynamic>>? propertyRef;
  List<DocumentReference<Map<String, dynamic>>>? rentpaymentRef;
  Landlord? landlord;
  String? pathToImage;
  String? tempID;
  Timestamp? dateJoined;
  String? address;

  Tenant(
      {required this.firstName,
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
      this.tempID,
      this.propertyRef,
      this.dateJoined,
      this.rentpaymentRef,
      this.address});

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      firstName: json['firstName'],
      lastName: json['lastName'],
      description: json['description'] ?? 'No description',
      rating: json['rating'] ?? 0.0,
      rent: json['balance'] ?? 0.0,
      creditPoints: json['creditPoints'] ?? 0,
      // propertyDetails: json['propertyDetails'] ?? 'No property details',
      cnicNumber: json['cnicNumber'] ?? 'N/A',
      emailOrPhone: json['emailOrPhone'] ?? 'N/A',
      tasdeeqVerification: json['tasdeeqVerification'] ?? false,
      familyMembers: json['familyMembers'] ?? 0,
      landlordRef: json['landlordRef'],
      pathToImage: json['pathToImage'] ?? 'assets/defaultimage.png',
      policeVerification: json['policeVerification'] ?? false,
      dateJoined: json['dateJoined'],
      rentpaymentRef: json['rentpaymentRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['rentpaymentRef'].map((ref) => ref as DocumentReference))
          : null,
      address: json['address'] ?? '',
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
