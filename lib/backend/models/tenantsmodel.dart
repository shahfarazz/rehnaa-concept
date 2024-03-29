import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/backend/models/propertymodel.dart';

class Tenant {
  String firstName;
  String lastName;
  String? description;
  num rating;
  num balance;
  //  String propertyDetails;
  String? cnic;
  String? emailOrPhone;
  bool? tasdeeqVerification;
  bool? policeVerification;
  num? familyMembers;
  List<DocumentReference<Map<String, dynamic>>>? landlordRef;
  List<DocumentReference<Map<String, dynamic>>>? propertyRef;
  List<DocumentReference<Map<String, dynamic>>>? rentpaymentRef;
  List<Landlord>? landlord;
  String? pathToImage;
  String? tempID;
  Timestamp? dateJoined;
  String? address;
  DateTime? contractStartDate;
  DateTime? contractEndDate;
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
  var isRentoffWinner;
  var phoneNumber;
  var pastLandlordTestimonial;
  Property? property;
  var contractIDs;
  var whatAreYouLookingFor;
  var estimatedTimetoShift;
  var estimatedBudget;
  var isDetailsFilled;
  var isFormDeleted;

  Tenant({
    required this.firstName,
    required this.lastName,
    required this.description,
    required this.rating,
    required this.balance,
    required this.creditPoints,
    // required this.propertyDetails,
    required this.cnic,
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
    this.isRentoffWinner,
    this.phoneNumber,
    this.pastLandlordTestimonial,
    this.property,
    this.contractIDs,
    this.whatAreYouLookingFor,
    this.estimatedTimetoShift,
    this.estimatedBudget,
    this.isDetailsFilled,
    this.isFormDeleted,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    //check if json['landlordRef'] is a single reference or a list of references
    //if it is a single reference, convert it to a list of references
    if (json['landlordRef'] != null &&
        json['landlordRef'] is DocumentReference) {
      json['landlordRef'] = [json['landlordRef']];
    }

    //similarly for propertyRef
    if (json['propertyRef'] != null &&
        json['propertyRef'] is DocumentReference) {
      json['propertyRef'] = [json['propertyRef']];
    }

    return Tenant(
      firstName: json['firstName'],
      lastName: json['lastName'],
      description: json['description'] ?? 'No description',
      rating: json['rating'] ?? 0.0,
      balance: json['balance'] ?? 0.0,
      creditPoints: json['creditPoints'] ?? "",
      // propertyDetails: json['propertyDetails'] ?? 'No property details',
      cnic: json['cnic'],
      emailOrPhone: json['emailOrPhone'] ?? 'N/A',
      tasdeeqVerification: json['tasdeeqVerification'] ?? null,
      familyMembers: json['familyMembers'] ?? 0,
      landlordRef: json['landlordRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['landlordRef'].map((ref) => ref as DocumentReference))
          : null,
      pathToImage: json['pathToImage'] ?? 'assets/defaulticon.png',
      policeVerification: json['policeVerification'] ?? null,
      dateJoined: json['dateJoined'],
      rentpaymentRef: json['rentpaymentRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['rentpaymentRef'].map((ref) => ref as DocumentReference))
          : null,
      address: json['address'],
      contractStartDate: json['contractStartDate'] != null
          ? json['contractStartDate'].toDate()
          : null,
      contractEndDate: json['contractEndDate'] != null
          ? json['contractEndDate'].toDate()
          : null,
      propertyAddress: json['propertyAddress'] ?? 'No address found',
      monthlyRent: json['monthlyRent'] ?? '',
      // upfrontBonus: json['upfrontBonus'] ?? '',
      // monthlyProfit: json['monthlyProfit'] ?? '',
      discount: json['discount'] ?? 0.24234234,
      isGhost: json['isGhost'] ?? false,
      securityDeposit: json['securityDeposit'] ?? '',
      creditScore: json['creditScore'] ?? '',
      otherInfo: json['otherInfo'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      pastLandlordTestimonial: json['pastLandlordTestimonial'] ?? '',
      contractIDs: json['contractIDs'] ?? '',
      whatAreYouLookingFor: json['whatAreYouLookingFor'] ?? '',
      estimatedTimetoShift: json['estimatedTimetoShift'] ?? '',
      estimatedBudget: json['estimatedBudget'] ?? '',
      isDetailsFilled: json['isDetailsFilled'] ?? false,
      isFormDeleted: json['isFormDeleted'] ?? false,
      propertyRef: json['propertyRef'] != null
          ? List<DocumentReference<Map<String, dynamic>>>.from(
              json['propertyRef'].map((ref) => ref as DocumentReference))
          : [],
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
      'cnic': cnic,
      'emailOrPhone': emailOrPhone,
      'tasdeeqVerification': tasdeeqVerification,
      'familyMembers': familyMembers,
      'landlordRef': landlordRef,
      'pathToImage': pathToImage,
      'policeVerification': policeVerification,
    };
  }

  // Future<Landlord?> getLandlord() async {
  //   if (landlordRef != null) {
  //     DocumentSnapshot<Map<String, dynamic>> snapshot =
  //         await landlordRef!.get();

  //     landlord = Landlord.fromJson(snapshot.data());
  //     landlord?.tempID = snapshot.id;
  //     return landlord;
  //   }
  //   return null;
  // }

  // Future<Property?> getProperty() async {
  //   print('propertyRef: $propertyRef');
  //   if (propertyRef != null) {
  //     DocumentSnapshot<Map<String, dynamic>> snapshot =
  //         await propertyRef!.get();

  //     property = Property.fromJson(snapshot.data()!);
  //     // property!.tempID = snapshot.id;
  //     return property!;
  //   }
  //   return null;
  // }

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
      cnic: '123456789',
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
