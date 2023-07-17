import 'package:cloud_firestore/cloud_firestore.dart';
import 'landlordmodel.dart';

class Property {
  List<String> imagePath;
  String type;
  int beds;
  int baths;
  bool garden;
  int living;
  int floors;
  int carspace;
  String description;
  String title;
  String location;
  String address;
  double? price;
  DocumentReference<Map<String, dynamic>>? landlordRef;
  DocumentReference<Map<String, dynamic>>? tenantRef;
  Landlord? landlord;
  double rehnaaRating;
  double tenantRating;
  String tenantReview;
  String? propertyID;
  num? area;
  bool? shouldShow;

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
    this.tenantRef,
    this.area,
    this.shouldShow,
  });

  static Property fromJson(Map<String, dynamic> json) {
    // print("json is $json");
    Property property = Property(
      imagePath: List<String>.from(json['imagePath']).isEmpty
          ? ['']
          : List<String>.from(json['imagePath']),
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
      price: json['price'].toDouble() ?? 0.0,
      landlordRef: json['landlordRef'],
      rehnaaRating:
          json['rehnaaRating'] == null ? 0.0 : json['rehnaaRating'].toDouble(),
      tenantRating:
          json['tenantRating'] == null ? 0.0 : json['tenantRating'].toDouble(),
      tenantReview: json['tenantReview'] ?? 'No review provided',
      address: json['address'] ?? 'No address provided',
      tenantRef: json['tenantRef'],
      area: json['area'] ?? 0.0,
      // landlord: Landlord.fromJson(json['landlord']),
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
