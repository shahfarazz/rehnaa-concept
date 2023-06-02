import 'landlordmodel.dart';

class Property {
  final List<String> imagePath;
  final String type;
  final int beds;
  final int baths;
  final bool garden;
  final int living;
  final int floors;
  final int carspace;
  final String description;
  final String title;
  final String location;
  final double price;
  // final String owner;
  // final String pathToOwnerImage;
  // final String ownerPhoneNumber;
  final Landlord? landlord;
  final double rehnaaRating;
  final double tenantRating;
  final String tenantReview;

  Property({
    required this.imagePath,
    required this.type,
    required this.beds,
    required this.baths,
    required this.garden,
    required this.living,
    required this.floors,
    required this.carspace,
    required this.description,
    required this.title,
    required this.location,
    required this.price,
    this.landlord,
    required this.rehnaaRating,
    required this.tenantRating,
    required this.tenantReview,
  });
}
