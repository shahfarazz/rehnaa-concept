import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../backend/models/dealermodel.dart';
import '../../../backend/models/landlordmodel.dart';
import '../../Screens/Admin/admindashboard.dart';
import 'admin_estamps.dart';

class AdminEstampsEditorPage extends StatefulWidget {
  // final Landlord landlord;
  final Dealer dealer;
  final String docID;

  const AdminEstampsEditorPage({
    Key? key,
    // required this.landlord,
    required this.dealer,
    required this.docID,
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
  // TextEditingController eStampContractStartDateController =
  //     TextEditingController();
  // TextEditingController eStampContractEndDateController =
  //     TextEditingController();
  TextEditingController eStampPropertyAddressController =
      TextEditingController();
  TextEditingController eStampPropertyRentAmountController =
      TextEditingController();
  TextEditingController eStampUpfrontBonusController = TextEditingController();
  TextEditingController eStampMonthlyProfitController = TextEditingController();
  //estampCost
  TextEditingController eStampCostController = TextEditingController();

  DateTime? contractStartDate;
  DateTime? contractEndDate;
  bool? isFilled;
  //eStampLanldordName
  TextEditingController eStampLandlordNameController = TextEditingController();
  Future<void> _selectDate(bool isStartDate, StateSetter setState1) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      setState1(() {
        if (isStartDate) {
          contractStartDate = picked;
        } else {
          contractEndDate = picked;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadOldValues();
  }

  Future<void> loadOldValues() async {
    if (widget.docID == 'empty') {
      return;
    }
    var dealerId = widget.dealer.tempID;
    var landlordData = await FirebaseFirestore.instance
        .collection('Dealers')
        .doc(dealerId)
        .collection('Estamps')
        .doc(widget.docID)
        .get()
        .then((value) {
      return value.data()!['landlordData'];
    });

    setState(() {
      eStampAddressController.text = landlordData['eStampAddress'];
      eStampDateController.text = landlordData['eStampDate'];
      eStampChargesController.text = landlordData['eStampCharges'];
      eStampTenantNameController.text = landlordData['eStampTenantName'];
      eStampValueController.text = landlordData['eStampValue'];
      eStampDeliveredDateController.text = landlordData['eStampDeliveredDate'];
      eStampPoliceVerificationController.text =
          landlordData['eStampPoliceVerification'];
      // eStampContractStartDateController.text =
      //     landlordData['eStampContractStartDate'];
      // eStampContractEndDateController.text =
      //     landlordData['eStampContractEndDate'];
      eStampPropertyAddressController.text =
          landlordData['eStampPropertyAddress'];
      eStampPropertyRentAmountController.text =
          landlordData['eStampPropertyRentAmount'];
      eStampUpfrontBonusController.text = landlordData['eStampUpfrontBonus'];
      eStampMonthlyProfitController.text = landlordData['eStampMonthlyProfit'];
      eStampCostController.text = landlordData['eStampCost'].toString();
      isFilled = landlordData['isFilled'];
      eStampLandlordNameController.text = landlordData['landlordName'];
    });
  }

  void saveLandlordMap(String dealerId) {
    Dealer dealer = widget.dealer;
    if (dealer.landlordMap == null) {
      dealer.landlordMap = {};
    }

    if (eStampLandlordNameController.text == '') {
      //show snackbar that its a required field
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please enter eStamp Landlord Name'),
        ),
      );
      return;
    }

    Map<String, dynamic> landlordData = {
      'eStampAddress': eStampAddressController.text,
      'eStampDate': eStampDateController.text,
      'eStampCharges': eStampChargesController.text,
      'eStampTenantName': eStampTenantNameController.text,
      'eStampValue': eStampValueController.text,
      'eStampDeliveredDate': eStampDeliveredDateController.text,
      'eStampPoliceVerification': eStampPoliceVerificationController.text,
      // 'eStampContractStartDate': eStampContractStartDateController.text,
      // 'eStampContractEndDate': eStampContractEndDateController.text,
      'eStampPropertyAddress': eStampPropertyAddressController.text,
      'eStampPropertyRentAmount': eStampPropertyRentAmountController.text,
      'eStampUpfrontBonus': eStampUpfrontBonusController.text,
      'eStampMonthlyProfit': eStampMonthlyProfitController.text,
      'eStampCost': int.tryParse(eStampCostController.text) ?? 0,
      if (contractStartDate != null)
        'eStampContractStartDate': Timestamp.fromDate(contractStartDate!),
      if (contractEndDate != null)
        'eStampContractEndDate': Timestamp.fromDate(contractEndDate!),
      'isFilled': true,
      'landlordName':
          eStampLandlordNameController.text, // key - value pairs Ali Ahmed
    };

    // Map<String, Map<String, dynamic>> updatedLandlordMap = {
    //   widget.landlord.tempID: landlordData,
    // };

    // to the dealer.landlordmap add the new map of landlord data mapped to the landlord id
    // dealer.landlordMap!.addAll(updatedLandlordMap);

    //show spinkitfadingcube loading indicator as dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(
        child: SpinKitFadingCube(
          color: Color.fromARGB(255, 30, 197, 83),
        ),
      ),
    );

    if (!(isFilled ?? false)) {
      // //check if cost has changed from old value
      // if(eStampCostController.text != oldCost){
      //   //if yes then add the new cost to the balance
      //   dealer.balance = dealer.balance! + (int.tryParse(eStampCostController.text) ?? 0);
      // }

      FirebaseFirestore.instance.collection('rentPayments').add({
        'tenantname': eStampLandlordNameController.text,
        'LandlordRef':
            FirebaseFirestore.instance.collection('Dealers').doc(dealer.tempID),
        'amount': int.tryParse(eStampMonthlyProfitController.text) ??
            0, //convert to int later
        'date': DateTime.now(),
        'isMinus': true,
        'isNoPdf': true,
        'isEstamp': true,
        'eStampType': 'Monthly Profit',
        'paymentType': '',
      }).then((newval1) {
        int monthlyProfit =
            int.tryParse(eStampMonthlyProfitController.text) ?? 0;
        FirebaseFirestore.instance.collection('rentPayments').add({
          'tenantname': eStampLandlordNameController.text,
          'LandlordRef': FirebaseFirestore.instance
              .collection('Dealers')
              .doc(dealer.tempID),
          'amount': int.tryParse(eStampUpfrontBonusController.text) ??
              0, //convert to int later
          'date': DateTime.now(),
          'isMinus': true,
          'isNoPdf': true,
          'isEstamp': true,
          'eStampType': 'Upfront Bonus',
          'paymentType': '',
        }).then((newval2) {
          int upfrontBonus =
              int.tryParse(eStampUpfrontBonusController.text) ?? 0;

          FirebaseFirestore.instance.collection('rentPayments').add({
            'tenantname': eStampLandlordNameController.text,
            'LandlordRef':
                FirebaseFirestore.instance.collection('Dealers').doc(dealerId),
            'amount': int.tryParse(eStampCostController.text) ??
                0, //convert to int later
            'date': DateTime.now(),
            'isMinus': true,
            'isNoPdf': true,
            'isEstamp': true,
            'eStampType': 'Estamp Charges',
            'paymentType': '',
          }).then((val) {
            int eStampCost = int.tryParse(eStampCostController.text) ?? 0;

            List<DocumentReference> paymentRefs = [];
            if (monthlyProfit != 0) {
              paymentRefs.add(newval1);
            }
            if (upfrontBonus != 0) {
              paymentRefs.add(newval2);
            }
            if (eStampCost != 0) {
              paymentRefs.add(val);
            }

            // FirebaseFirestore.instance.collection('Estamps').doc(dealerId).set({
            //   'landlordMap': dealer.landlordMap,
            //   'landlordName':
            //       widget.landlord.firstName + ' ' + widget.landlord.lastName,
            // }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection('Contracts')
                .doc(dealerId)
                .collection('Estamps')
                .doc('LandlordMap')
                .set({
              'landlordMap': dealer.landlordMap,
            }, SetOptions(merge: true));

            FirebaseFirestore.instance
                .collection('Dealers')
                .doc(dealerId)
                .update({
              // 'landlordMap': dealer.landlordMap,
              // 'balance': //subtract amount from balance
              //     FieldValue.increment(
              //         -(int.tryParse(eStampCostController.text) ?? 0)),
              //change the balance based on estampcost estampmonthlyprofit and estampupfrontbonus
              'balance': FieldValue.increment(
                  -(((int.tryParse(eStampCostController.text) ?? 0) +
                      (int.tryParse(eStampMonthlyProfitController.text) ?? 0) +
                      (int.tryParse(eStampUpfrontBonusController.text) ?? 0)))),

              // 'rentpaymentRef':
              //     FieldValue.arrayUnion([val])
              //add val newval1 and newval2 to rentpaymentref
              //check if estamp cost estamp monthly profit and estamp upfront bonus are 0 individually and that way set the array union
              'rentpaymentRef': FieldValue.arrayUnion(
                  paymentRefs) // key - value pairs Ali Ahmed
            }).then((_) {
              FirebaseFirestore.instance
                  .collection('Dealers')
                  .doc(dealerId)
                  .collection('Estamps')
                  .add({
                // 'landlordMap': dealer.landlordMap,
                'landlordData': landlordData,
              });

              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AdminEstampsPage();
              }));
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
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection('Dealers')
          .doc(dealerId)
          .collection('Estamps')
          .add({
        // 'landlordMap': dealer.landlordMap,
        'landlordData': landlordData,
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AdminEstampsPage();
      }));
    }
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
                  MaterialPageRoute(builder: (context) => AdminEstampsPage()),
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
                  controller: eStampLandlordNameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'eStamp Landlord Name',
                  ),
                ),
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
                StatefulBuilder(builder: (context, setState) {
                  return TextButton(
                    onPressed: () => _selectDate(true, setState),
                    child: Text(
                      contractStartDate != null
                          ? 'Contract Start Date: ${contractStartDate.toString()}'
                          : 'Select Contract Start Date',
                    ),
                  );
                }),
                StatefulBuilder(builder: (context, setState) {
                  return TextButton(
                    onPressed: () => _selectDate(false, setState),
                    child: Text(
                      contractEndDate != null
                          ? 'Contract End Date: ${contractEndDate.toString()}'
                          : 'Select Contract End Date',
                    ),
                  );
                }),
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
                (isFilled ?? false)
                    ? Text(
                        'eStamp Upfront Bonus: ${eStampUpfrontBonusController.text}')
                    : TextField(
                        controller: eStampUpfrontBonusController,
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
                            eStampUpfrontBonusController.clear();
                            return;
                          }
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'eStamp Upfront Bonus',
                        ),
                      ),
                (isFilled ?? false)
                    ? Text(
                        'eStamp Monthly Profit: ${eStampMonthlyProfitController.text}')
                    : TextField(
                        controller: eStampMonthlyProfitController,
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
                            eStampMonthlyProfitController.clear();
                            return;
                          }
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'eStamp Monthly Profit',
                        ),
                      ),
                SizedBox(height: 16.0),
                (isFilled ?? false)
                    ? Text('eStamp Cost: ${eStampCostController.text}')
                    : TextField(
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
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            )),
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
