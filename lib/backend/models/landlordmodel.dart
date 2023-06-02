import 'propertymodel.dart';
import 'rentpaymentmodel.dart';
import 'tenantsmodel.dart';

class Landlord {
  final String firstName;
  final String lastName;
  final double balance;
  final List<Tenant>? tenant; // can be 0 or more
  final List<Property> property; // can be 1 or more
  final List<RentPayment>? rentpayment; // can be 0 or more
  final String? pathToImage;
  // final String propertyDetails;
  // final String cnicNumber;
  // final String contactNumber;
  // final bool tasdeeqVerification;
  // final int familyMembers;

  Landlord({
    required this.firstName,
    required this.lastName,
    required this.balance,
    this.tenant,
    required this.property,
    this.rentpayment,
    this.pathToImage,
  });
}
