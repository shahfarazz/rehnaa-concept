import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/tenantsmodel.dart';

import '../helper/Landlorddashboard_pages/landlord_tenants.dart';

class ContractPage extends StatelessWidget {
  final String identifier;

  const ContractPage({Key? key, required this.identifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyScreen(
        identifier: identifier,
      ),
    );
  }
}

class MyScreen extends StatelessWidget {
  final String identifier;

  const MyScreen({Key? key, required this.identifier}) : super(key: key);

  Future<DocumentSnapshot<Map<String, dynamic>>> _getLandlordRef(
      String id) async {
    // print('reached here with tenant');

    // String id = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> tenantSnapshot =
        await FirebaseFirestore.instance.collection('Tenants').doc(id).get();

    DocumentReference<Map<String, dynamic>> landlordRef =
        tenantSnapshot.data()?['landlordRef'];

    String contractID = landlordRef.id;

    DocumentReference<Map<String, dynamic>> contractRef =
        await FirebaseFirestore.instance
            .collection('Contracts')
            .doc(contractID);

    return contractRef.get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getContractData(
      String documentId) async {
    return FirebaseFirestore.instance
        .collection('Contracts')
        .doc(documentId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    String id = 'FirebaseAuth.instance.currentUser!.uid';
    // String id = 'K55YzmkUXt09OgFwnDuT'; //TODO isko hatao

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future:
          identifier == 'Landlord' ? _getContractData(id) : _getLandlordRef(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while fetching data
          return LandlordTenantSkeleton();
        } else if (snapshot.hasData) {
          DocumentSnapshot<Map<String, dynamic>> data = snapshot.data!;
          Map<String, dynamic>? contractFields = data.data();
          print('contractFields: $contractFields');

          return Column(
            children: [
              SizedBox(height: 30),
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return const ZoomedScreen();
                      }));
                    },
                    child: Hero(
                      tag: 'imageTag',
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/image1.jpg',
                          fit: BoxFit.cover,
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
                        top: 10.0,
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
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                                data: contractFields?['landlordCnic'] ?? '',
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
                                data: contractFields?['tenantCnic'] ?? '',
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
                                data: contractFields?['firstWitnessCnic'] ?? '',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.phone,
                                label: 'First Witness Contact Number:',
                                data: contractFields?['firstWitnessContact'] ??
                                    '',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.person,
                                label: 'Second Witness Name:',
                                data:
                                    contractFields?['secondWitnessName'] ?? '',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.credit_card,
                                label: 'Second Witness CNIC:',
                                data:
                                    contractFields?['secondWitnessCnic'] ?? '',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.phone,
                                label: 'Second Witness Contact Number:',
                                data: contractFields?['secondWitnessContact'] ??
                                    '',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.home,
                                label: 'Property:',
                                data: contractFields?['propertyAddress'] ?? '',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.monetization_on,
                                label: 'Monthly Rent:',
                                data: contractFields?['monthlyRent'] ?? '',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.calendar_today,
                                label: 'Contract Start Date:',
                                data:
                                    contractFields?['contractStartDate'] ?? '',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.calendar_today,
                                label: 'Contract End Date:',
                                data: contractFields?['contractEndDate'] ?? '',
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
          );
        } else if (snapshot.hasError) {
          // Handle error case
          return Text('Error: ${snapshot.error}');
        }

        return Container(); // Return an empty container if no data or error
      },
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
                top: 40.0,
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
