import 'package:cloud_firestore/cloud_firestore.dart';

import 'landlordmodel.dart';
import 'propertymodel.dart';
import 'tenantsmodel.dart';

class RentPayment {
  final String amount;
  final DateTime date;
  final String paymentType;
  final DocumentReference<Map<String, dynamic>>? propertyRef;
  final DocumentReference<Map<String, dynamic>>? tenantRef;
  final DocumentReference<Map<String, dynamic>>? landlordRef;
  Property? property;
  Tenant? tenant;
  Landlord? landlord;

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
  });

  static Future<RentPayment> fromJson(Map<String, dynamic> json) async {
    print('RentPayment.fromJson: $json');

    final propertyRef =
        json['propertyRef'] as DocumentReference<Map<String, dynamic>>;
    final tenantRef =
        json['tenantRef'] as DocumentReference<Map<String, dynamic>>;
    final landlordRef =
        json['landlordRef'] as DocumentReference<Map<String, dynamic>>;

    RentPayment rentPayment = RentPayment(
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      paymentType: json['paymentType'],
      propertyRef: propertyRef,
      tenantRef: tenantRef,
      landlordRef: landlordRef,
    );

    await rentPayment.fetchData();

    return rentPayment;
  }

  Future<void> fetchData() async {
    await getProperty();
    await getTenant();
    await getLandlord();
  }

  Future<void> getProperty() async {
    if (propertyRef != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await propertyRef!.get();
      property = await Property.fromJson(snapshot.data()!);
    }
  }

  Future<void> getTenant() async {
    if (tenantRef != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await tenantRef!.get();
      tenant = Tenant.fromJson(snapshot.data()!);
    }
  }

  Future<void> getLandlord() async {
    if (landlordRef != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await landlordRef!.get();
      property?.landlord = await property?.fetchLandlord();
    }
  }
}
