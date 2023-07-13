import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Screens/Admin/admindashboard.dart';
import 'admin_contractsedit.dart';

class AdminContractsViewPage extends StatefulWidget {
  const AdminContractsViewPage({super.key});

  @override
  State<AdminContractsViewPage> createState() => _AdminContractsEditPageState();
}

class _AdminContractsEditPageState extends State<AdminContractsViewPage> {
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> fetchContracts() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Contracts').get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Contracts'),
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
      body: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        future: fetchContracts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingCube(
                color: Color.fromARGB(255, 30, 197, 83),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final contracts = snapshot.data;
            if (contracts?.isEmpty ?? true) {
              return Center(
                child: Text(
                  'No Contracts Found',
                  style: TextStyle(
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    fontSize: 20,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: contracts?.length,
              itemBuilder: (context, index) {
                return ContractCard(
                  contractData: contracts?[index].data(),
                  id: contracts?[index].id,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ContractCard extends StatefulWidget {
  final Map<String, dynamic>? contractData;
  final id;

  const ContractCard({Key? key, this.contractData, this.id}) : super(key: key);

  @override
  _ContractCardState createState() => _ContractCardState();
}

class _ContractCardState extends State<ContractCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSelection() {
    setState(() {
      _isSelected = !_isSelected;
      if (_isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contractData = widget.contractData;
    final landlordName = contractData?['landlordName'] as String;
    final tenantName = contractData?['tenantName'] as String;
    final propertyAddress = contractData?['propertyAddress'] as String;
    final allFields = contractData?.entries.map((entry) {
      final fieldName = entry.key;
      final fieldValue = entry.value.toString();
      return ListTile(
        title: Text(fieldName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(fieldValue),
      );
    }).toList();

    return GestureDetector(
      onTap: _toggleSelection,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(_isSelected ? 16.0 : 8.0),
        height: _isSelected ? 220.0 : 120.0,
        decoration: BoxDecoration(
          color: _isSelected ? Colors.green[200] : Colors.green[50],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: _isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6.0,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Contract'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Landlord: $landlordName'),
                      contractData?['pdfUrl'] != null
                          ? IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.picture_as_pdf),
                            )
                          : Container(),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContractEditPage(
                                        contractData: contractData!,
                                        id: widget.id,
                                      )));
                        },
                        child: Text('Edit',
                            style: TextStyle(
                                color: Colors.blue,
                                fontFamily:
                                    GoogleFonts.montserrat().fontFamily)),
                      ),
                    ],
                  ),
                  Text('Tenant: $tenantName'),
                  Text('Address: $propertyAddress'),
                ],
              ),
            ),
            if (_isSelected)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: allFields!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
