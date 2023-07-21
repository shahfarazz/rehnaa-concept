import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../backend/models/dealermodel.dart';
import '../../../backend/models/landlordmodel.dart';
import '../../Screens/Admin/admindashboard.dart';
import 'admin_estamps.dart';

class AdminEstampsEditorPage extends StatefulWidget {
  final Landlord landlord;
  final Dealer dealer;

  const AdminEstampsEditorPage({
    Key? key,
    required this.landlord,
    required this.dealer,
  }) : super(key: key);

  @override
  _AdminEstampsEditorPageState createState() => _AdminEstampsEditorPageState();
}

class _AdminEstampsEditorPageState extends State<AdminEstampsEditorPage> {
  TextEditingController eStampAddressController = TextEditingController();
  TextEditingController eStampDateController = TextEditingController();
  TextEditingController eStampChargesController = TextEditingController();
  TextEditingController eStampTenantNameController = TextEditingController();
  TextEditingController eStampValueController = TextEditingController();
  TextEditingController eStampDeliveredDateController = TextEditingController();
  TextEditingController eStampPoliceVerificationController =
      TextEditingController();
  TextEditingController eStampContractStartDateController =
      TextEditingController();
  TextEditingController eStampContractEndDateController =
      TextEditingController();
  TextEditingController eStampPropertyAddressController =
      TextEditingController();
  TextEditingController eStampPropertyRentAmountController =
      TextEditingController();
  TextEditingController eStampUpfrontBonusController = TextEditingController();
  TextEditingController eStampMonthlyProfitController = TextEditingController();
  //estampCost
  TextEditingController eStampCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOldValues();
  }

  void loadOldValues() {
    Map<String, Map<String, dynamic>>? landlordMap = widget.dealer.landlordMap;
    if (landlordMap != null) {
      Map<String, dynamic>? landlordData = landlordMap[widget.landlord.tempID];
      if (landlordData != null) {
        setState(() {
          eStampAddressController.text = landlordData['eStampAddress'] ?? '';
          eStampDateController.text = landlordData['eStampDate'] ?? '';
          eStampChargesController.text = landlordData['eStampCharges'] ?? '';
          eStampTenantNameController.text =
              landlordData['eStampTenantName'] ?? '';
          eStampValueController.text = landlordData['eStampValue'] ?? '';
          eStampDeliveredDateController.text =
              landlordData['eStampDeliveredDate'] ?? '';
          eStampPoliceVerificationController.text =
              landlordData['eStampPoliceVerification'] ?? '';
          eStampContractStartDateController.text =
              landlordData['eStampContractStartDate'] ?? '';
          eStampContractEndDateController.text =
              landlordData['eStampContractEndDate'] ?? '';
          eStampPropertyAddressController.text =
              landlordData['eStampPropertyAddress'] ?? '';
          eStampPropertyRentAmountController.text =
              landlordData['eStampPropertyRentAmount'] ?? '';
          eStampUpfrontBonusController.text =
              landlordData['eStampUpfrontBonus'] ?? '';
          eStampMonthlyProfitController.text =
              landlordData['eStampMonthlyProfit'] ?? '';
          eStampCostController.text =
              landlordData['eStampCost'].toString() ?? '';
        });
      }
    }
  }

  void saveLandlordMap(String dealerId) {
    Dealer dealer = widget.dealer;
    if (dealer.landlordMap == null) {
      dealer.landlordMap = {};
    }

    Map<String, dynamic> landlordData = {
      'eStampAddress': eStampAddressController.text,
      'eStampDate': eStampDateController.text,
      'eStampCharges': eStampChargesController.text,
      'eStampTenantName': eStampTenantNameController.text,
      'eStampValue': eStampValueController.text,
      'eStampDeliveredDate': eStampDeliveredDateController.text,
      'eStampPoliceVerification': eStampPoliceVerificationController.text,
      'eStampContractStartDate': eStampContractStartDateController.text,
      'eStampContractEndDate': eStampContractEndDateController.text,
      'eStampPropertyAddress': eStampPropertyAddressController.text,
      'eStampPropertyRentAmount': eStampPropertyRentAmountController.text,
      'eStampUpfrontBonus': eStampUpfrontBonusController.text,
      'eStampMonthlyProfit': eStampMonthlyProfitController.text,
      'eStampCost': int.tryParse(eStampCostController.text) ?? 0,
    };

    Map<String, Map<String, dynamic>> updatedLandlordMap = {
      widget.landlord.tempID: landlordData,
    };

    // to the dealer.landlordmap add the new map of landlord data mapped to the landlord id
    dealer.landlordMap!.addAll(updatedLandlordMap);

    FirebaseFirestore.instance.collection('rentPayments').add({
      'tenantname': widget.landlord.firstName + ' ' + widget.landlord.lastName,
      'LandlordRef':
          FirebaseFirestore.instance.collection('Dealers').doc(dealer.tempID),
      'amount':
          int.tryParse(eStampCostController.text) ?? 0, //convert to int later
      'date': DateTime.now(),
      'isMinus': true,
      'isNoPdf': true,
      // 'description': 'Balance updated by dealer',
      'paymentType': '',
    }).then((val) {
      FirebaseFirestore.instance.collection('Dealers').doc(dealerId).update({
        'landlordMap': dealer.landlordMap,
        'rentpaymentRef':
            FieldValue.arrayUnion([val]) // key - value pairs Ali Ahmed
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Landlord E-Stamp saved successfully.'),
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save Landlord Map: $error'),
          ),
        );
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AdminEstampsPage();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    Dealer dealer = widget.dealer;
    print('reached herer with dealer  ${dealer.tempID}');

    return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Estamps Editor'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashboard()),
                );
              }),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff0FA697),
                  Color(0xff45BF7A),
                  Color(0xff0DF205),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: eStampAddressController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Address',
                  ),
                ),
                TextField(
                  controller: eStampDateController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Date',
                  ),
                ),
                TextField(
                  controller: eStampChargesController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Charges',
                  ),
                ),
                TextField(
                  controller: eStampTenantNameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Tenant Name',
                  ),
                ),
                TextField(
                  controller: eStampValueController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Value',
                  ),
                ),
                TextField(
                  controller: eStampDeliveredDateController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Delivered Date',
                  ),
                ),
                TextField(
                  controller: eStampPoliceVerificationController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Police Verification',
                  ),
                ),
                TextField(
                  controller: eStampContractStartDateController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Contract Start Date',
                  ),
                ),
                TextField(
                  controller: eStampContractEndDateController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Contract End Date',
                  ),
                ),
                TextField(
                  controller: eStampPropertyAddressController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Property Address',
                  ),
                ),
                TextField(
                  controller: eStampPropertyRentAmountController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Property Rent Amount',
                  ),
                ),
                TextField(
                  controller: eStampUpfrontBonusController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Upfront Bonus',
                  ),
                ),
                TextField(
                  controller: eStampMonthlyProfitController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Monthly Profit',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: eStampCostController,
                  onChanged: (value) {
                    //if alphabet is entered show an error using toast and clear the field and return
                    if (value.contains(RegExp(r'[a-zA-Z]'))) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     backgroundColor: Colors.red,
                      //     content: Text('Please enter digits only'),
                      //   ),
                      // );
                      //replace with a red flutter toast
                      Fluttertoast.showToast(
                          msg: "Please enter digits only",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      eStampCostController.clear();
                      return;
                    }
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Cost',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    saveLandlordMap(dealer.tempID!);
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ));
  }
}
