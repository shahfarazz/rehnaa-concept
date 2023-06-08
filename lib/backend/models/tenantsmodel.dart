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

  Future<void> getLandlord() async {
    if (landlordRef != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await landlordRef!.get();
      landlord = await Landlord.fromJson(snapshot.data());
    }
  }
}
