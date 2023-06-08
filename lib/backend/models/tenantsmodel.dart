import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';

class Tenant {
  final String firstName;
  final String lastName;
  final String description;
  final double rating;
  final int rent;
  final int creditPoints;
  final String propertyDetails;
  final String cnicNumber;
  final String emailOrPhone;
  final bool tasdeeqVerification;
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
    required this.propertyDetails,
    required this.cnicNumber,
    required this.emailOrPhone,
    required this.tasdeeqVerification,
    required this.familyMembers,
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
      propertyDetails: json['propertyDetails'] ?? 'No property details',
      cnicNumber: json['cnicNumber'] ?? 'N/A',
      emailOrPhone: json['emailOrPhone'] ?? 'N/A',
      tasdeeqVerification: json['tasdeeqVerification'] ?? false,
      familyMembers: json['familyMembers'] ?? [],
      landlordRef: json['landlordRef'],
      pathToImage: json['pathToImage'] ?? 'assets/defaultimage.png',
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
      'propertyDetails': propertyDetails,
      'cnicNumber': cnicNumber,
      'emailOrPhone': emailOrPhone,
      'tasdeeqVerification': tasdeeqVerification,
      'familyMembers': familyMembers,
      'landlordRef': landlordRef,
      'pathToImage': pathToImage,
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
      propertyDetails: 'Dummy property',
      cnicNumber: '123456789',
      emailOrPhone: 'dummy@example.com',
      tasdeeqVerification: true,
      familyMembers: 2,
      pathToImage: 'assets/defaulticon.png',
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
