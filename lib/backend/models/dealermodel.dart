import 'package:cloud_firestore/cloud_firestore.dart';

class Dealer {
  String firstName;
  String lastName;
  double balance;
  String? pathToImage;
  String? tempID;
  String? agencyName;
  String? agencyAddress;

  final List<DocumentReference<Map<String, dynamic>>>? landlordRef;

  Dealer({
    required this.firstName,
    required this.lastName,
    required this.balance,
    this.landlordRef,
    this.pathToImage,
    this.tempID,
    this.agencyName,
    this.agencyAddress,
  });

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
