import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rehnaa/backend/services/helperfunctions.dart';
import 'dart:typed_data';
import 'admin_contracts.dart';

class ContractEditPage extends StatefulWidget {
  final Map<String, dynamic> contractData;
  final String? id;

  const ContractEditPage({Key? key, required this.contractData, this.id})
      : super(key: key);

  @override
  _ContractEditPageState createState() => _ContractEditPageState();
}

class _ContractEditPageState extends State<ContractEditPage> {
  TextEditingController _landlordNameController = TextEditingController();
  TextEditingController _landlordCnicController = TextEditingController();
  TextEditingController _tenantNameController = TextEditingController();
  TextEditingController _tenantCnicController = TextEditingController();
  TextEditingController _firstWitnessNameController = TextEditingController();
  TextEditingController _firstWitnessCnicController = TextEditingController();
  TextEditingController _firstWitnessContactController =
      TextEditingController();
  TextEditingController _secondWitnessNameController = TextEditingController();
  TextEditingController _secondWitnessCnicController = TextEditingController();
  TextEditingController _secondWitnessContactController =
      TextEditingController();
  TextEditingController _propertyAddressController = TextEditingController();

  TextEditingController _monthlyRentController = TextEditingController();
  DateTime? contractStartDate;
  DateTime? contractEndDate;

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

  TextEditingController _usePurposeController = TextEditingController();
  TextEditingController _subletOptionController = TextEditingController();
  TextEditingController _utilitiesIncludedController = TextEditingController();
  TextEditingController _evictionNoticePeriodController =
      TextEditingController();
  TextEditingController _eStampValueController = TextEditingController();
  TextEditingController _notaryPublicStampController = TextEditingController();
  TextEditingController _bopChallanFormController = TextEditingController();
  TextEditingController _policeVerificationController = TextEditingController();
  TextEditingController _totalSecurityController = TextEditingController();
  TextEditingController _rehnaaSecurityController = TextEditingController();
  TextEditingController _additionalInformationController =
      TextEditingController();

  String pdfUrl = '';

  @override
  void initState() {
    super.initState();

    _landlordNameController =
        TextEditingController(text: widget.contractData['landlordName']);
    _landlordCnicController = TextEditingController(
        text: decryptString(widget.contractData['landlordCnic']));
    _tenantNameController =
        TextEditingController(text: widget.contractData['tenantName']);
    _tenantCnicController = TextEditingController(
        text: decryptString(widget.contractData['tenantCnic']));
    _firstWitnessNameController =
        TextEditingController(text: widget.contractData['firstWitnessName']);
    _firstWitnessCnicController = TextEditingController(
        text: decryptString(widget.contractData['firstWitnessCnic']));
    _firstWitnessContactController = TextEditingController(
        text: decryptString(widget.contractData['firstWitnessContact']));
    _secondWitnessNameController =
        TextEditingController(text: widget.contractData['secondWitnessName']);
    _secondWitnessCnicController = TextEditingController(
        text: decryptString(widget.contractData['secondWitnessCnic']));
    _secondWitnessContactController = TextEditingController(
        text: widget.contractData['secondWitnessContact']);
    _propertyAddressController =
        TextEditingController(text: widget.contractData['propertyAddress']);
    _monthlyRentController =
        TextEditingController(text: widget.contractData['monthlyRent']);
    _usePurposeController =
        TextEditingController(text: widget.contractData['usePurpose']);
    _subletOptionController =
        TextEditingController(text: widget.contractData['subletOption']);
    _utilitiesIncludedController =
        TextEditingController(text: widget.contractData['utilitiesIncluded']);
    _evictionNoticePeriodController = TextEditingController(
        text: widget.contractData['evictionNoticePeriod']);
    _eStampValueController =
        TextEditingController(text: widget.contractData['eStampValue']);
    _notaryPublicStampController =
        TextEditingController(text: widget.contractData['notaryPublicStamp']);
    _bopChallanFormController =
        TextEditingController(text: widget.contractData['bopChallanForm']);
    _policeVerificationController =
        TextEditingController(text: widget.contractData['policeVerification']);
    _totalSecurityController =
        TextEditingController(text: widget.contractData['totalSecurity']);
    _rehnaaSecurityController =
        TextEditingController(text: widget.contractData['rehnaaSecurity']);
    _additionalInformationController = TextEditingController(
        text: widget.contractData['additionalInformation']);

    contractEndDate = widget.contractData['contractEndDate'].toDate();
    contractStartDate = widget.contractData['contractStartDate'].toDate();
  }

  @override
  void dispose() {
    _landlordNameController.dispose();
    _landlordCnicController.dispose();
    _tenantNameController.dispose();
    _tenantCnicController.dispose();
    _firstWitnessNameController.dispose();
    _firstWitnessCnicController.dispose();
    _firstWitnessContactController.dispose();
    _secondWitnessNameController.dispose();
    _secondWitnessCnicController.dispose();
    _secondWitnessContactController.dispose();
    _propertyAddressController.dispose();
    _monthlyRentController.dispose();
    _usePurposeController.dispose();
    _subletOptionController.dispose();
    _utilitiesIncludedController.dispose();
    _evictionNoticePeriodController.dispose();
    _eStampValueController.dispose();
    _notaryPublicStampController.dispose();
    _bopChallanFormController.dispose();
    _policeVerificationController.dispose();
    _totalSecurityController.dispose();
    _rehnaaSecurityController.dispose();
    _additionalInformationController.dispose();
    super.dispose();
  }

  void _saveContract() {
    final updatedContractData = {
      'landlordName': _landlordNameController.text,
      'landlordCnic': encryptString(_landlordCnicController.text),
      'tenantName': _tenantNameController.text,
      'tenantCnic': encryptString(_tenantCnicController.text),
      'firstWitnessName': _firstWitnessNameController.text,
      'firstWitnessCnic': encryptString(_firstWitnessCnicController.text),
      'firstWitnessContact': _firstWitnessContactController.text,
      'secondWitnessName': _secondWitnessNameController.text,
      'secondWitnessCnic': encryptString(_secondWitnessCnicController.text),
      'secondWitnessContact': _secondWitnessContactController.text,
      'propertyAddress': _propertyAddressController.text,
      'monthlyRent': _monthlyRentController.text,
      if (contractStartDate != null)
        'contractStartDate': Timestamp.fromDate(contractStartDate!),
      if (contractEndDate != null)
        'contractEndDate': Timestamp.fromDate(contractEndDate!),
      'usePurpose': _usePurposeController.text,
      'subletOption': _subletOptionController.text,
      'utilitiesIncluded': _utilitiesIncludedController.text,
      'evictionNoticePeriod': _evictionNoticePeriodController.text,
      'eStampValue': _eStampValueController.text,
      'notaryPublicStamp': _notaryPublicStampController.text,
      'bopChallanForm': _bopChallanFormController.text,
      'policeVerification': _policeVerificationController.text,
      'totalSecurity': _totalSecurityController.text,
      'rehnaaSecurity': _rehnaaSecurityController.text,
      'additionalInformation': _additionalInformationController.text,
      if (pdfUrl != '') 'pdfUrl': pdfUrl
    };

    try {
      showDialog(
        context: context,
        barrierDismissible:
            true, // Prevents dismissing the dialog by tapping outside
        builder: (context) =>
            //   WillPopScope(
            // onWillPop: () async =>
            //     false, // Prevents dismissing the dialog with the back button
            const AlertDialog(
          title: Text('Processing',
              style: TextStyle(
                color: Colors.green,
                // fontFamily: GoogleFonts.montserrat().fontFamily
              ),
              textAlign: TextAlign.center),
          // content:
          // CircularProgressIndicator(),
        ),
        // ),
      );

      FirebaseFirestore.instance
          .collection('Contracts')
          .doc(widget.id)
          .update(updatedContractData)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contract updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        String? landlordID = widget.contractData['landlordID'];
        String? tenantID = widget.contractData['tenantID'];

        if (landlordID != null) {
          FirebaseFirestore.instance
              .collection('Landlords')
              .doc(landlordID)
              .update({
            if (contractStartDate != null)
              'contractStartDate': Timestamp.fromDate(contractStartDate!),
            if (contractEndDate != null)
              'contractEndDate': Timestamp.fromDate(contractEndDate!),
            'propertyAddress': _propertyAddressController.text,
            'monthlyRent': _monthlyRentController.text,
          });
        }

        if (tenantID != null) {
          FirebaseFirestore.instance
              .collection('Tenants')
              .doc(tenantID)
              .update({
            if (contractStartDate != null)
              'contractStartDate': Timestamp.fromDate(contractStartDate!),
            if (contractEndDate != null)
              'contractEndDate': Timestamp.fromDate(contractEndDate!),
            'propertyAddress': _propertyAddressController.text,
            'monthlyRent': _monthlyRentController.text,
          });
        }

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const AdminContractsViewPage();
        }));
      });
    } catch (e) {
      print('uploading contract failed $e');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<String> _addPDF() async {
      // Open a file picker to select the PDF file
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;

        if (fileBytes != null) {
          // Generate a unique file name for the PDF
          String fileName = result.files.first.name;

          // Upload the file to Firebase Storage
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('contractpdfs/$fileName');
          firebase_storage.UploadTask uploadTask = ref.putData(fileBytes);

          // Wait for the upload to complete and get the download URL
          firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
          String downloadURL = await taskSnapshot.ref.getDownloadURL();

          return downloadURL;
        }
      }

      return '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contract'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Landlord Information'),
            _buildTextField(
              controller: _landlordNameController,
              labelText: 'Landlord Name',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _landlordCnicController,
              labelText: 'Landlord CNIC',
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader('Tenant Information'),
            _buildTextField(
              controller: _tenantNameController,
              labelText: 'Tenant Name',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _tenantCnicController,
              labelText: 'Tenant CNIC',
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader('Witness Information'),
            _buildTextField(
              controller: _firstWitnessNameController,
              labelText: 'First Witness Name',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _firstWitnessCnicController,
              labelText: 'First Witness CNIC',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _firstWitnessContactController,
              labelText: 'First Witness Contact Number',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _secondWitnessNameController,
              labelText: 'Second Witness Name',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _secondWitnessCnicController,
              labelText: 'Second Witness CNIC',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _secondWitnessContactController,
              labelText: 'Second Witness Contact Number',
            ),
            const SizedBox(height: 24.0),
            _buildSectionHeader('Property Information'),
            _buildTextField(
              controller: _propertyAddressController,
              labelText: 'Property Address',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _monthlyRentController,
              labelText: 'Monthly Rent',
            ),
            const SizedBox(height: 16.0),
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
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _usePurposeController,
              labelText: 'Use Purpose',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _subletOptionController,
              labelText: 'Sublet Option',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _utilitiesIncludedController,
              labelText: 'Utilities Included',
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
              controller: _evictionNoticePeriodController,
              labelText: 'Eviction Notice Period',
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
              controller: _eStampValueController,
              labelText: 'E-stamp Value',
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
              controller: _notaryPublicStampController,
              labelText: 'Notary Public Stamp',
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
              controller: _bopChallanFormController,
              labelText: 'BOP Challan Form',
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
              controller: _policeVerificationController,
              labelText: 'Police Verification',
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
              controller: _totalSecurityController,
              labelText: 'Total Security Amount',
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
              controller: _rehnaaSecurityController,
              labelText: 'Rehnaa Security Amount',
            ),
            const SizedBox(height: 24.0),
            _buildTextField(
              controller: _additionalInformationController,
              labelText: 'Additional Information',
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible:
                      true, // Prevents dismissing the dialog by tapping outside
                  builder: (context) =>
                      //   WillPopScope(
                      // onWillPop: () async =>
                      //     false, // Prevents dismissing the dialog with the back button
                      const AlertDialog(
                    title: Text('Processing',
                        style: TextStyle(
                          color: Colors.green,
                          // fontFamily: GoogleFonts.montserrat().fontFamily
                        ),
                        textAlign: TextAlign.center),
                    // content:
                    // CircularProgressIndicator(),
                  ),
                  // ),
                );

                _addPDF().then((value) {
                  pdfUrl = value;
                  Navigator.pop(context);
                  if (pdfUrl != '') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF Added'),
                      ),
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('Add PDF'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _saveContract,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Save Contract',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
