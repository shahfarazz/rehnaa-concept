import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';

class Dealer {
  final String firstName;
  final String lastName;
  final List<DocumentReference<Map<String, dynamic>>>? landlordRef;

  Dealer({
    required this.firstName,
    required this.lastName,
    this.landlordRef,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      firstName: json['firstName'],
      lastName: json['lastName'],
      landlordRef: json['landlordRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['landlordRef'].map((ref) => ref as DocumentReference))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
