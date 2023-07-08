import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';

class AdminPropertyContractsPage extends StatefulWidget {
  final String tenantID;
  final String landlordID;
  const AdminPropertyContractsPage(
      {Key? key, required this.tenantID, required this.landlordID})
      : super(key: key);

  @override
  State<AdminPropertyContractsPage> createState() =>
      _AdminPropertyContractsPageState();
}

class _AdminPropertyContractsPageState
    extends State<AdminPropertyContractsPage> {
  final TextEditingController _landlordNameController = TextEditingController();
  final TextEditingController _landlordCnicController = TextEditingController();
  final TextEditingController _tenantNameController = TextEditingController();
  final TextEditingController _tenantCnicController = TextEditingController();
  final TextEditingController _firstWitnessNameController =
      TextEditingController();
  final TextEditingController _firstWitnessCnicController =
      TextEditingController();
  final TextEditingController _firstWitnessContactController =
      TextEditingController();
  final TextEditingController _secondWitnessNameController =
      TextEditingController();
  final TextEditingController _secondWitnessCnicController =
      TextEditingController();
  final TextEditingController _secondWitnessContactController =
      TextEditingController();
  final TextEditingController _propertyAddressController =
      TextEditingController();

  final TextEditingController _monthlyRentController = TextEditingController();
  final TextEditingController _contractStartDateController =
      TextEditingController();
  final TextEditingController _contractEndDateController =
      TextEditingController();
  final TextEditingController _usePurposeController = TextEditingController();
  final TextEditingController _subletOptionController = TextEditingController();
  final TextEditingController _utilitiesIncludedController =
      TextEditingController();
  final TextEditingController _evictionNoticePeriodController =
      TextEditingController();
  final TextEditingController _eStampValueController = TextEditingController();
  final TextEditingController _notaryPublicStampController =
      TextEditingController();
  final TextEditingController _bopChallanFormController =
      TextEditingController();
  final TextEditingController _policeVerificationController =
      TextEditingController();
  final TextEditingController _totalSecurityController =
      TextEditingController();
  final TextEditingController _rehnaaSecurityController =
      TextEditingController();
  final TextEditingController _additionalInformationController =
      TextEditingController();

  void _addContractToDatabase() {
    // Retrieve the values from the text controllers
    final String landlordName = _landlordNameController.text;
    final String landlordCnic = _landlordCnicController.text;
    final String tenantName = _tenantNameController.text;
    final String tenantCnic = _tenantCnicController.text;
    final String firstWitnessName = _firstWitnessNameController.text;
    final String firstWitnessCnic = _firstWitnessCnicController.text;
    final String firstWitnessContact = _firstWitnessContactController.text;
    final String secondWitnessName = _secondWitnessNameController.text;
    final String secondWitnessCnic = _secondWitnessCnicController.text;
    final String secondWitnessContact = _secondWitnessContactController.text;
    final String propertyAddress = _propertyAddressController.text;
    // final String securityAmount = _securityAmountController.text;
    final String monthlyRent = _monthlyRentController.text;
    final String contractStartDate = _contractStartDateController.text;
    final String contractEndDate = _contractEndDateController.text;
    final String usePurpose = _usePurposeController.text;
    final String subletOption = _subletOptionController.text;
    final String utilitiesIncluded = _utilitiesIncludedController.text;
    final String evictionNoticePeriod = _evictionNoticePeriodController.text;
    final String eStampValue = _eStampValueController.text;
    final String notaryPublicStamp = _notaryPublicStampController.text;
    final String bopChallanForm = _bopChallanFormController.text;
    final String policeVerification = _policeVerificationController.text;
    final String totalSecurity = _totalSecurityController.text;
    final String rehnaaSecurity = _rehnaaSecurityController.text;
    final String additionalInformation = _additionalInformationController.text;

    //Make a new document in the Contracts collection for the new contract
    FirebaseFirestore.instance
        .collection('Contracts')
        .doc(widget.landlordID)
        .set({
      //add all the fields to the document
      'landlordName': landlordName,
      'landlordCnic': encryptString(landlordCnic),
      'tenantName': tenantName,
      'tenantCnic': encryptString(tenantCnic),
      'firstWitnessName': firstWitnessName,
      'firstWitnessCnic': encryptString(firstWitnessCnic),
      'firstWitnessContact': firstWitnessContact,
      'secondWitnessName': secondWitnessName,
      'secondWitnessCnic': encryptString(secondWitnessCnic),
      'secondWitnessContact': secondWitnessContact,
      'propertyAddress': propertyAddress,
      'monthlyRent': monthlyRent,
      'contractStartDate': contractStartDate,
      'contractEndDate': contractEndDate,
      'usePurpose': usePurpose,
      'subletOption': subletOption,
      'utilitiesIncluded': utilitiesIncluded,
      'evictionNoticePeriod': evictionNoticePeriod,
      'eStampValue': eStampValue,
      'notaryPublicStamp': notaryPublicStamp,
      'bopChallanForm': bopChallanForm,
      'policeVerification': policeVerification,
      'totalSecurity': totalSecurity,
      'rehnaaSecurity': rehnaaSecurity,
      'additionalInformation': additionalInformation,
      'landlordID': widget.landlordID,
      'tenantID': widget.tenantID,
    });

    FirebaseFirestore.instance
        .collection('Tenants')
        .doc(widget.tenantID)
        .update({
      'contractStartDate': contractStartDate,
      'contractEndDate': contractEndDate,
      'propertyAddress': propertyAddress,
      'monthlyRent': monthlyRent,
    });

    FirebaseFirestore.instance
        .collection('Landlords')
        .doc(widget.landlordID)
        .update({
      'contractStartDate': contractStartDate,
      'contractEndDate': contractEndDate,
      'propertyAddress': propertyAddress,
      'monthlyRent': monthlyRent,
    });

    //Navigate to the home page
    Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Contracts'),
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
            _buildTextField(
              controller: _contractStartDateController,
              labelText: 'Contract Start Date',
            ),
            const SizedBox(height: 16.0),
            _buildTextField(
              controller: _contractEndDateController,
              labelText: 'Contract End Date',
            ),
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
              onPressed: _addContractToDatabase,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
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
