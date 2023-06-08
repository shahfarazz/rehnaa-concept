import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'propertymodel.dart';
import 'rentpaymentmodel.dart';
import 'tenantsmodel.dart';

class Landlord {
  final String firstName;
  final String lastName;
  final double balance;
  final String? pathToImage;
  final List<DocumentReference<Map<String, dynamic>>>? tenantRef;
  final List<DocumentReference<Map<String, dynamic>>> propertyRef;
  final List<DocumentReference<Map<String, dynamic>>>? rentpaymentRef;
  List<Tenant>? tenant;
  List<Property> property;
  List<RentPayment>? rentpayment;

  Landlord({
    required this.firstName,
    required this.lastName,
    required this.balance,
    this.tenant,
    required this.property,
    this.rentpayment,
    this.pathToImage,
    this.tenantRef,
    required this.propertyRef,
    this.rentpaymentRef,
  });

  static Future<Landlord> fromJson(Map<String, dynamic>? json) async {
    Landlord landlord = Landlord(
      firstName: json!['firstName'],
      lastName: json['lastName'],
      balance: json['balance'] != null ? json['balance'].toDouble() : 0.0,
      tenantRef: json['tenantRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['tenantRef'].map((ref) => ref as DocumentReference))
          : null,
      property: json['property'] != null
          ? List<Property>.from(
              json['property'].map((prop) => Property.fromJson(prop)))
          : [],
      propertyRef: json['propertyRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['propertyRef'].map((ref) => ref as DocumentReference))
          : [],
      rentpaymentRef: json['rentpaymentRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['rentpaymentRef'].map((ref) => ref as DocumentReference))
          : null,
      pathToImage: json['pathToImage'] != null
          ? json['pathToImage']
          : 'assets/defaulticon.png',
    );

    await landlord.fetchData();

    return landlord;
  }

  Future<void> fetchData() async {
    if (kDebugMode) {
      print('Fetching landlord data...');
    }
    await getProperty();
    await fetchTenant();
    await fetchRentPayment();
    if (kDebugMode) {
      print('Landlord data fetched successfully.');
    }
  }

  Future<void> fetchTenant() async {
    if (tenantRef != null) {
      tenant = [];

      for (DocumentReference<Map<String, dynamic>> ref in tenantRef!) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
        tenant!.add(Tenant.fromJson(snapshot.data()!));
      }
    }
  }

  Future<void> getProperty() async {
    property = [];

    for (DocumentReference<Map<String, dynamic>> ref in propertyRef) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
      property.add(await Property.fromJson(snapshot.data()!));
    }
  }

  Future<void> fetchRentPayment() async {
    if (rentpaymentRef != null) {
      rentpayment = [];

      for (DocumentReference<Map<String, dynamic>> ref in rentpaymentRef!) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
        rentpayment!.add(await RentPayment.fromJson(snapshot.data()!));
      }
    }
  }
}
