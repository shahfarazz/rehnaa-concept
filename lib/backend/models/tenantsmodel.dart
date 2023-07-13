import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';

class Tenant {
  String firstName;
  String lastName;
  String? description;
  num rating;
  num balance;
  //  String propertyDetails;
  String? cnicNumber;
  String? emailOrPhone;
  bool? tasdeeqVerification;
  bool? policeVerification;
  num? familyMembers;
  DocumentReference<Map<String, dynamic>>? landlordRef;
  DocumentReference<Map<String, dynamic>>? propertyRef;
  List<DocumentReference<Map<String, dynamic>>>? rentpaymentRef;
  Landlord? landlord;
  String? pathToImage;
  String? tempID;
  Timestamp? dateJoined;
  String? address;
  Timestamp? contractStartDate;
  Timestamp? contractEndDate;
  String? propertyAddress;
  String? monthlyRent;
  // ignore: prefer_typing_uninitialized_variables
  // var upfrontBonus;
  // ignore: prefer_typing_uninitialized_variables
  // var monthlyProfit;
  var discount;
  bool? isGhost;
  var securityDeposit;
  var creditScore;
  var creditPoints;
  var otherInfo;

  Tenant({
    required this.firstName,
    required this.lastName,
    required this.description,
    required this.rating,
    required this.balance,
    required this.creditPoints,
    // required this.propertyDetails,
    required this.cnicNumber,
    required this.emailOrPhone,
    required this.tasdeeqVerification,
    required this.familyMembers,
    required this.policeVerification,
    this.landlordRef,
    this.landlord,
    this.pathToImage,
    this.tempID,
    this.propertyRef,
    this.dateJoined,
    this.rentpaymentRef,
    this.address,
    this.contractStartDate,
    this.contractEndDate,
    this.propertyAddress,
    this.monthlyRent,
    // this.upfrontBonus,
    // this.monthlyProfit,
    this.discount,
    this.isGhost,
    this.securityDeposit,
    this.creditScore,
    this.otherInfo,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      firstName: json['firstName'],
      lastName: json['lastName'],
      description: json['description'] ?? 'No description',
      rating: json['rating'] ?? 0.0,
      balance: json['balance'] ?? 0.0,
      creditPoints: json['creditPoints'] ?? "",
      // propertyDetails: json['propertyDetails'] ?? 'No property details',
      cnicNumber: json['cnicNumber'] ?? 'N/A',
      emailOrPhone: json['emailOrPhone'] ?? 'N/A',
      tasdeeqVerification: json['tasdeeqVerification'] ?? null,
      familyMembers: json['familyMembers'] ?? 0,
      landlordRef: json['landlordRef'],
      pathToImage: json['pathToImage'] ?? 'assets/defaulticon.png',
      policeVerification: json['policeVerification'] ?? null,
      dateJoined: json['dateJoined'],
      rentpaymentRef: json['rentpaymentRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['rentpaymentRef'].map((ref) => ref as DocumentReference))
          : null,
      address: json['address'] ?? '',
      contractStartDate: json['contractStartDate'],
      contractEndDate: json['contractEndDate'],
      propertyAddress: json['propertyAddress'] ?? 'No address found',
      monthlyRent: json['monthlyRent'] ?? '',
      // upfrontBonus: json['upfrontBonus'] ?? '',
      // monthlyProfit: json['monthlyProfit'] ?? '',
      discount: json['discount'] ?? 0.24234234,
      isGhost: json['isGhost'] ?? false,
      securityDeposit: json['securityDeposit'] ?? '',
      creditScore: json['creditScore'] ?? '',
      otherInfo: json['otherInfo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'description': description,
      'rating': rating,
      'balance': balance,
      'creditPoints': creditPoints,
      // 'propertyDetails': propertyDetails,
      'cnicNumber': cnicNumber,
      'emailOrPhone': emailOrPhone,
      'tasdeeqVerification': tasdeeqVerification,
      'familyMembers': familyMembers,
      'landlordRef': landlordRef,
      'pathToImage': pathToImage,
      'policeVerification': policeVerification,
    };
  }

  Future<Landlord?> getLandlord() async {
    if (landlordRef != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await landlordRef!.get();

      landlord = Landlord.fromJson(snapshot.data());
      landlord?.tempID = snapshot.id;
      return landlord;
    }
    return null;
  }

  static void addDummyTenant() async {
    // Create a new instance of Firestore
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Create a dummy tenant object with all the required values
    Tenant dummyTenant = Tenant(
      firstName: 'Dummy',
      lastName: 'Tenant',
      description: 'This is a dummy tenant',
      rating: 4.5,
      balance: 1000,
      creditPoints: 100,
      // propertyDetails: 'Dummy property',
      cnicNumber: '123456789',
      emailOrPhone: 'dummy@example.com',
      tasdeeqVerification: true,
      familyMembers: 2,
      pathToImage: 'assets/defaulticon.png',
      policeVerification: true,
    );

    try {
      // Add the dummy tenant to the "Tenants" collection
      DocumentReference<Map<String, dynamic>> tenantDocRef =
          await firestore.collection('Tenants').add(dummyTenant.toJson());

      // Get the landlord document reference
      DocumentReference<Map<String, dynamic>> landlordDocRef =
          firestore.collection('Landlords').doc('R88XI7AqrOZBtGZzQwgyX2Wr7Yz1');

      // Update the "tenantRef" field in the landlord document
      landlordDocRef.update({
        'tenantRef': FieldValue.arrayUnion([tenantDocRef])
      });

      print('Dummy tenant added successfully!');
    } catch (error) {
      print('Error adding dummy tenant: $error');
    }
  }
}
