import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';
import 'package:rehnaa/frontend/Screens/rentpayment_info.dart';

import '../../backend/models/tenantsmodel.dart';

import '../helper/Landlorddashboard_pages/landlord_tenants.dart';
import 'Landlord/landlord_dashboard.dart';
import 'Tenant/tenant_dashboard.dart';
import 'new_vouchers.dart';

class ContractPage extends StatelessWidget {
  // final String identifier;
  final contractFields;
  final String uid;
  final String callerType;

  const ContractPage(
      {Key? key,
      this.contractFields,
      required this.uid,
      required this.callerType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyScreen(
        // identifier: identifier,
        contractFields: contractFields, callerType: callerType, uid: uid,
      ),
    );
  }
}

class MyScreen extends StatelessWidget {
  // final String identifier;
  final contractFields;
  final String uid;
  final String callerType;

  const MyScreen(
      {Key? key,
      this.contractFields,
      required this.uid,
      required this.callerType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // DocumentSnapshot<Map<String, dynamic>> data = snapshot.data!;
    // Map<String, dynamic>? contractFields = data.data();
    // print('contractFields: $contractFields');
    String? pdfUrl = contractFields?['pdfUrl'];
    print('pdfUrl: $pdfUrl');

    if (contractFields == null) {
      final Size size = MediaQuery.of(context).size;

      return Scaffold(
        appBar: _buildAppBar(size, context, callerType, uid),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(top: size.height * 0.1)),
                // const SizedBox(height: 50),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.description,
                          size: 48.0,
                          color: Color(0xff33907c),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'No contracts to show',
                          style: GoogleFonts.montserrat(
                            fontSize: 20.0,
                            color: const Color(0xff33907c),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }

    Size size = MediaQuery.of(context).size;
    String formatCNIC(String cnic) {
      if (cnic.length != 13) {
        //snackbar error
        // Fluttertoast.showToast(msg: 'Invalid CNIC');
        return cnic; // Return the original CNIC if the length is not as expected
      }

      String part1 = cnic.substring(0, 5);
      String part2 = cnic.substring(5, 12);
      String part3 = cnic.substring(12);

      return '$part1-$part2-$part3';
    }

    // PDFScreen pdfScreen
    // print('pdfUrl: $pdfUrl');
    PDFScreen pdfScreen = PDFScreen(
      displayAppBar: false,
    );
    if (pdfUrl != null) {
      pdfScreen = PDFScreen(
        path: pdfUrl,
        displayAppBar: false,
      );
    }

    return Scaffold(
      appBar:
          _buildAppBar(MediaQuery.of(context).size, context, callerType, uid),
      body: Column(
        children: [
          (pdfUrl != null)
              ? Expanded(
                  child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFScreen(
                          path: pdfUrl,
                          displayAppBar: true,
                        ),
                      ),
                    );
                  },
                  child: InteractiveViewer(
                    child: pdfScreen,
                  ),
                  // pdfScreen,
                ))
              : Container(),
          SizedBox(height: size.height * 0.05),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "Contract",
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                color: const Color(0xff33907c),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          ContractCard(
                            icon: Icons.person,
                            label: 'Landlord Name:',
                            data: contractFields?['landlordName'] ?? '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.credit_card,
                            label: 'Landlord CNIC:',
                            data: formatCNIC(
                                decryptString(contractFields['landlordCnic'])),
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.person,
                            label: 'Tenant Name:',
                            data: contractFields?['tenantName'] ?? '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.credit_card,
                            label: 'Tenant CNIC:',
                            data: formatCNIC(
                                decryptString(contractFields['tenantCnic'])),
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.person,
                            label: 'First Witness Name:',
                            data: contractFields?['firstWitnessName'] ?? '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.credit_card,
                            label: 'First Witness CNIC:',
                            data: formatCNIC(decryptString(
                                contractFields['firstWitnessCnic'])),
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.phone,
                            label: 'First Witness Contact Number:',
                            data: contractFields?['firstWitnessContact'] ?? '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.person,
                            label: 'Second Witness Name:',
                            data: contractFields?['secondWitnessName'] ?? '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.credit_card,
                            label: 'Second Witness CNIC:',
                            data: formatCNIC(decryptString(
                                contractFields?['secondWitnessCnic'] ?? '')),
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.phone,
                            label: 'Second Witness Contact Number:',
                            data: contractFields['secondWitnessContact'],
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.home,
                            label: 'Property:',
                            data: contractFields?['propertyAddress'] ?? '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.payments_outlined,
                            label: 'Monthly Rent:',
                            data: contractFields?['monthlyRent'] ?? '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Contract Start Date:',
                            data: contractFields?['contractStartDate']
                                    .toDate()
                                    .toString() ??
                                '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Contract End Date:',
                            data: contractFields?['contractEndDate']
                                    .toDate()
                                    .toString()
                                    .substring(0, 10) ??
                                '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Contract End Date:',
                            data: contractFields?['contractEndDate']
                                    .toDate()
                                    .toString()
                                    .substring(0, 10) ??
                                '',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Use Purpose:',
                            data: contractFields?['usePurpose'] ?? '',
                          ),
                          //subletOption
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Sublet Option:',
                            data: contractFields?['subletOption'] ?? '',
                          ),
                          //utilitiesIncluded
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Utilities Included:',
                            data: contractFields?['utilitiesIncluded'] ?? '',
                          ),
                          //evictionNoticePeriod
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Eviction Notice Period:',
                            data: contractFields?['evictionNoticePeriod']
                                    .toString() ??
                                '',
                          ),
                          //eStampValue
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'E-Stamp Value:',
                            data:
                                contractFields?['eStampValue'].toString() ?? '',
                          ),
                          //notaryPublicStamp
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Notary Public Stamp:',
                            data: contractFields?['notaryPublicStamp']
                                    .toString() ??
                                '',
                          ),
                          //bopChallanForm
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'BOP Challan Form:',
                            data:
                                contractFields?['bopChallanForm'].toString() ??
                                    '',
                          ),
                          //policeVerification
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Police Verification:',
                            data: contractFields?['policeVerification']
                                    .toString() ??
                                '',
                          ),
                          //totalSecurity
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Total Security:',
                            data: contractFields?['totalSecurity'].toString() ??
                                '',
                          ),
                          //rehnaaSecurity
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Rehnaa Security:',
                            data:
                                contractFields?['rehnaaSecurity'].toString() ??
                                    '',
                          ),
                          //additionalInformation
                          SizedBox(height: 16),
                          ContractCard(
                            icon: Icons.calendar_today,
                            label: 'Additional Information:',
                            data: contractFields?['additionalInformation']
                                    .toString() ??
                                '',
                          ),

                          // Rest of the ContractCard widgets...
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContractCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String data;

  const ContractCard(
      {Key? key, required this.icon, required this.label, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300, // Set the desired width of the card
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // rounded corners
          ),
          elevation: 2, // shadow
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  icon,
                  size: 24,
                  color: const Color(0xff33907c),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, // bold contract label
                          fontSize: 17,
                          color: const Color(0xff33907c),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.normal, // normal contract data
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZoomedScreen extends StatefulWidget {
  const ZoomedScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ZoomedScreenState createState() => _ZoomedScreenState();
}

class _ZoomedScreenState extends State<ZoomedScreen> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _previousOffset = Offset.zero;
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            onScaleStart: (ScaleStartDetails details) {
              _previousScale = _scale;
              _previousOffset = details.focalPoint - _offset;
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
                _offset = details.focalPoint - _previousOffset;
              });
            },
            child: Center(
              child: Hero(
                tag: 'imageTag',
                child: Transform.scale(
                  scale: _scale,
                  child: Transform.translate(
                    offset: _offset,
                    child: Image.asset(
                      'assets/image1.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Stack(
            children: [
              SafeArea(
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(16.0),
                  // child: Text('Your Content'),
                ),
              ),
              Positioned(
                top: 65.0,
                left: 10.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF33907C),
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
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(Size size, context, callerType, uid) {
  return AppBar(
    toolbarHeight: 70,
    title: Padding(
      padding: EdgeInsets.only(
        right:
            MediaQuery.of(context).size.width * 0.14, // 55% of the page width
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                // Add your desired logic here
                // print('tapped');

                if (callerType == 'Tenants') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TenantDashboardPage(
                              uid: uid,
                            )),
                  );
                } else if (callerType == 'Landlords') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LandlordDashboardPage(
                              uid: uid,
                            )),
                  );
                }
              },
              child: Stack(
                children: [
                  ClipPath(
                    clipper: HexagonClipper(),
                    child: Transform.scale(
                      scale: 0.87,
                      child: Container(
                        color: Colors.white,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: HexagonClipper(),
                    child: Image.asset(
                      'assets/mainlogo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              )),
          // const SizedBox(width: 8),
        ],
      ),
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Stack(
          children: [],
        ),
      ),
    ],
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
  );
}
