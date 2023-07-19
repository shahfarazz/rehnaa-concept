import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'propertymodel.dart';
import 'rentpaymentmodel.dart';
import 'tenantsmodel.dart';

class Landlord {
  final String firstName;
  final String lastName;
  final num balance;
  final String? pathToImage;
  final List<DocumentReference<Map<String, dynamic>>>? tenantRef;
  final List<DocumentReference<Map<String, dynamic>>> propertyRef;
  final List<DocumentReference<Map<String, dynamic>>>? rentpaymentRef;
  List<Tenant>? tenant = [];
  List<Property>? property = [];
  List<RentPayment>? rentpayment = [];
  String tempID;
  List<DocumentReference<Map<String, dynamic>>>? dealerRef;
  String? cnic;
  String? bankName;
  String? raastId;
  String? accountNumber;
  String? iban;
  String? emailOrPhone;
  Timestamp? dateJoined;
  String? address;
  String? rating;
  var contractStartDate;
  var contractEndDate;
  var monthlyRent;
  var upfrontBonus;
  var monthlyProfit;
  bool? isGhost;
  var securityDeposit;
  var creditPoints;
  var creditScore;
  var hasEstamp;

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
    this.tempID = '',
    this.dealerRef,
    this.cnic,
    this.bankName,
    this.raastId,
    this.accountNumber,
    this.iban,
    this.emailOrPhone,
    this.dateJoined,
    this.address,
    this.rating,
    this.contractStartDate,
    this.contractEndDate,
    this.monthlyRent,
    this.upfrontBonus,
    this.monthlyProfit,
    this.isGhost,
    this.securityDeposit,
    this.creditPoints,
    this.creditScore,
    this.hasEstamp,
  });

  static Landlord fromJson(Map<String, dynamic>? json) {
    Landlord landlord = Landlord(
      firstName: json!['firstName'],
      lastName: json['lastName'],
      balance: json['balance'] ?? 0.0,
      tenantRef: json['tenantRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['tenantRef'].map((ref) => ref as DocumentReference))
          : null,
      dealerRef: json['dealerRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['dealerRef'].map((ref) => ref as DocumentReference))
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
      pathToImage: json['pathToImage'] ?? 'assets/defaulticon.png',
      emailOrPhone: json['emailOrPhone'] ?? '',
      dateJoined: json['dateJoined'],
      address: json['address'] ?? '',
      rating: json['rating'] ?? '0.0',
      contractStartDate: json['contractStartDate'] != null
          ? json['contractStartDate'].toDate()
          : null,
      contractEndDate: json['contractEndDate'] != null
          ? json['contractEndDate'].toDate()
          : null,
      monthlyRent: json['monthlyRent'] ?? '',
      upfrontBonus: json['upfrontBonus'] ?? '',
      monthlyProfit: json['monthlyProfit'] ?? '',
      isGhost: json['isGhost'] ?? false,
      securityDeposit: json['securityDeposit'] ?? '',
      creditPoints: json['creditPoints'] ?? '',
      creditScore: json['creditScore'] ?? '',
      cnic: json['cnic'] ?? '',
    );

    // await landlord.fetchData();

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

  Future<List<Property>?> getProperty() async {
    List<Property>? propertiesList = [];

    try {
      for (DocumentReference<Map<String, dynamic>> ref in propertyRef) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
        propertiesList.add(Property.fromJson(snapshot.data()!));
      }
      return propertiesList;
    } catch (e) {
      // TODO
      return propertiesList;
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
