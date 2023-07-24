import 'package:cloud_firestore/cloud_firestore.dart';

class Dealer {
  String firstName;
  String lastName;
  double balance;
  String? pathToImage;
  String? tempID;
  String? agencyName;
  String? agencyAddress;
  var description;

  final List<DocumentReference<Map<String, dynamic>>>? landlordRef;
  Map<String, Map<String, dynamic>>? landlordMap;
  bool? isGhost;

  Dealer(
      {required this.firstName,
      required this.lastName,
      required this.balance,
      this.landlordRef,
      this.pathToImage,
      this.tempID,
      this.agencyName,
      this.agencyAddress,
      this.landlordMap,
      this.isGhost,
      this.description});

  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      firstName: json['firstName'],
      lastName: json['lastName'],
      balance: json['balance'] != null ? json['balance'].toDouble() : 0.0,
      pathToImage: json['pathToImage'] ?? 'assets/defaulticon.png',
      landlordRef: json['landlordRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['landlordRef'].map((ref) => ref as DocumentReference))
          : null,
      tempID: json['tempID'],
      agencyName: json['agencyName'] ?? '',
      agencyAddress: json['agencyAddress'] ?? '',
      landlordMap: json['landlordMap'] != null && json['landlordMap'].length > 0
          ? Map<String, Map<String, dynamic>>.from(json['landlordMap'])
          : null,
      isGhost: json['isGhost'] ?? false,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
