import 'package:cloud_firestore/cloud_firestore.dart';

import 'landlordmodel.dart';
import 'propertymodel.dart';
import 'tenantsmodel.dart';

class RentPayment {
  final double amount;
  final DateTime date;
  final String paymentType;
  final DocumentReference<Map<String, dynamic>>? propertyRef;
  final DocumentReference<Map<String, dynamic>>? tenantRef;
  final DocumentReference<Map<String, dynamic>>? landlordRef;
  final DocumentReference<Map<String, dynamic>>? dealerRef;
  Property? property;
  Tenant? tenant;
  Landlord? landlord;
  String? pdfUrl;
  String? invoiceNumber;
  String? tenantname;
  bool? isMinus;
  var isEstamp;
  var eStampType;
  var isNoPdf;

  RentPayment({
    required this.amount,
    required this.date,
    required this.paymentType,
    required this.propertyRef,
    required this.tenantRef,
    required this.landlordRef,
    this.property,
    this.tenant,
    this.landlord,
    this.pdfUrl,
    this.invoiceNumber,
    this.tenantname,
    this.isMinus,
    this.dealerRef,
    this.isEstamp,
    this.eStampType,
    this.isNoPdf,
  });

  static Future<RentPayment> fromJson(Map<String, dynamic> json) async {
    final propertyRef =
        json['propertyRef'] as DocumentReference<Map<String, dynamic>>?;
    final tenantRef =
        json['tenantRef'] as DocumentReference<Map<String, dynamic>>?;
    final landlordRef =
        json['landlordRef'] as DocumentReference<Map<String, dynamic>>?;
    final dealerRef =
        json['dealerRef'] as DocumentReference<Map<String, dynamic>>?;

    try {
      RentPayment rentPayment = RentPayment(
        amount: json['amount'].toDouble(),
        date: (json['date'] as Timestamp).toDate(),
        paymentType: json['paymentType'],
        propertyRef: propertyRef,
        tenantRef: tenantRef,
        landlordRef: landlordRef,
        invoiceNumber: json['invoiceNumber'],
        tenantname: json['tenantname'] ?? 'Old document',
        isMinus: json['isMinus'],
        isEstamp: json['isEstamp'],
        eStampType: json['eStampType'],
        isNoPdf: json['isNoPdf'] ?? false,
      );

      if (propertyRef != null) {
        DocumentSnapshot<Map<String, dynamic>> propertySnapshot =
            await propertyRef.get();
        rentPayment.property = Property.fromJson(propertySnapshot.data()!);
      }

      // if (tenantRef != null) {
      //   DocumentSnapshot<Map<String, dynamic>> tenantSnapshot = await tenantRef.get();
      //   rentPayment.tenant = Tenant.fromJson(tenantSnapshot.data()!);
      // }

      // if (landlordRef != null) {
      //   DocumentSnapshot<Map<String, dynamic>> landlordSnapshot = await landlordRef.get();
      //   rentPayment.landlord = await rentPayment.property?.fetchLandlord();
      // }

      return rentPayment;
    } catch (e) {
      // Handle the exception according to your app's needs
      throw Exception('Error parsing RentPayment: $e');
    }
  }
}
