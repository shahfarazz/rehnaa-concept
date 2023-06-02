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
  final Landlord? landlord;
  final String? pathToImage;

  Tenant(
      {required this.firstName,
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
      this.landlord,
      this.pathToImage});
}
