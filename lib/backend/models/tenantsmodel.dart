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
  final String contactNumber;
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
    required this.contactNumber,
    required this.tasdeeqVerification,
    required this.familyMembers,
    this.landlordRef,
    this.landlord,
    this.pathToImage,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    Tenant tenant = Tenant(
      firstName: json['firstName'],
      lastName: json['lastName'],
      description: json['description'],
      rating: json['rating'],
      rent: json['rent'],
      creditPoints: json['creditPoints'],
      propertyDetails: json['propertyDetails'],
      cnicNumber: json['cnicNumber'],
      contactNumber: json['contactNumber'],
      tasdeeqVerification: json['tasdeeqVerification'],
      familyMembers: json['familyMembers'],
      landlordRef: json['landlordRef'],
      pathToImage: json['pathToImage'],
    );

    // tenant
    //     .getLandlord(); // Call getLandlord method to fetch and populate landlord asynchronously

    return tenant;
  }

  Future<void> getLandlord() async {
    if (landlordRef != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await landlordRef!.get();
      landlord = await Landlord.fromJson(snapshot.data());
    }
  }
}
