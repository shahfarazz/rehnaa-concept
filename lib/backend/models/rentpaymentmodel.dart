import 'landlordmodel.dart';
import 'propertymodel.dart';
import 'tenantsmodel.dart';

class RentPayment {
  // final String month;
  final String amount; // TODO change to double/integer 100,000 = 100K
  final DateTime date;
  final String paymentType;
  final Property property;
  final Tenant tenant; // if tenant.Firstname == 'Withdraw' rest will be blank
  final Landlord? landlord;

  RentPayment({
    // required this.month,
    required this.amount,
    required this.date,
    required this.paymentType,
    required this.property,
    required this.tenant,
    this.landlord,
  });
}
