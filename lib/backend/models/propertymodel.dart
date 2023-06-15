import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String address;
  final double price;
  final DocumentReference<Map<String, dynamic>>? landlordRef;
  Landlord? landlord;
  final double rehnaaRating;
  final double tenantRating;
  final String tenantReview;
  String? propertyID;

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
    required this.address,
    required this.price,
    this.landlordRef,
    this.landlord,
    required this.rehnaaRating,
    required this.tenantRating,
    required this.tenantReview,
    this.propertyID,
  });

  static Property fromJson(Map<String, dynamic> json) {
    Property property = Property(
      imagePath: List<String>.from(json['imagePath']),
      type: json['type'],
      beds: json['beds'],
      baths: json['baths'],
      garden: json['garden'],
      living: json['living'],
      floors: json['floors'],
      carspace: json['carspace'],
      description: json['description'],
      title: json['title'],
      location: json['location'],
      price: json['price'].toDouble(),
      landlordRef: json['landlordRef'],
      rehnaaRating: json['rehnaaRating'].toDouble(),
      tenantRating: json['tenantRating'].toDouble(),
      tenantReview: json['tenantReview'],
      address: json['address'] ?? 'No address provided',
    );

    return property;
  }

  Future<Landlord> fetchLandlord() async {
    print('Fetching landlord.. with ref: $landlordRef');
    if (landlordRef != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await landlordRef!.get();
      return Landlord.fromJson(snapshot.data());
    }

    throw Exception('Landlord reference is null');
  }

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'type': type,
      'beds': beds,
      'baths': baths,
      'garden': garden,
      'living': living,
      'floors': floors,
      'carspace': carspace,
      'description': description,
      'title': title,
      'location': location,
      'address': address,
      'price': price,
      'landlordRef': landlordRef,
      'rehnaaRating': rehnaaRating,
      'tenantRating': tenantRating,
      'tenantReview': tenantReview,
    };
  }
}
