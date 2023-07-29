import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/Landlord/landlord_dashboard.dart';
import 'package:rehnaa/frontend/Screens/contract.dart';

import '../../backend/services/helperfunctions.dart';
import 'Tenant/tenant_dashboard.dart';

// import '../helper/Landlorddashboard_pages/landlord_advance_rent.dart';

class AllContractsPage extends StatefulWidget {
  final String uid;
  final String callerType;
  const AllContractsPage(
      {super.key, required this.uid, required this.callerType});

  @override
  State<AllContractsPage> createState() => _AllContractsPageState();
}

class _AllContractsPageState extends State<AllContractsPage> {
  List<Widget> contractWidgets = [];
  var oneTime = false;
  // Declare a text editing controller for the search field.
  final TextEditingController _searchController = TextEditingController();
  List<Contract> contracts = [];
  List<Contract> filteredContracts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterContracts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // List<Widget> contractWidgets = [];
  List<Widget> filteredContractWidgets = [];
  Future<List<Contract>> getContracts() async {
    if (widget.callerType == 'Tenants') {
      // similar logic to getContracts for Landlords
      return await FirebaseFirestore.instance
          .collection('Tenants')
          .doc(widget.uid)
          .get()
          .then((value) async {
        var contractIDs = value.data()?['contractIDs'];
        if (contractIDs == null) {
          return [];
        }
        List<Future> contractFutures = [];
        for (var contractID in contractIDs) {
          contractFutures.add(FirebaseFirestore.instance
              .collection('Contracts')
              .doc(contractID)
              .get());
        }
        return await Future.wait(contractFutures).then((value) {
          List<Contract> contracts = [];
          for (var contract in value) {
            contracts.add(Contract(
              id: contract.id,
              landlordName: contract.data()?['landlordName'] ?? '',
              tenantName: contract.data()?['tenantName'] ?? '',
              allFields: contract.data(),
            ));
          }

          return contracts;
        });
      });
    } else if (widget.callerType == 'Landlords') {
      //get list of contractIDs from contractIDs field in landlord document
      return await FirebaseFirestore.instance
          .collection('Landlords')
          .doc(widget.uid)
          .get()
          .then((value) async {
        var contractIDs = value.data()?['contractIDs'];
        if (contractIDs == null) {
          return [];
        }
        //iterate over each contractIDs and add its future to a list
        List<Future> contractFutures = [];
        for (var contractID in contractIDs) {
          contractFutures.add(FirebaseFirestore.instance
              .collection('Contracts')
              .doc(contractID)
              .get());
        }
        //when all futures are complete, get the data from each future and add it to a list
        return await Future.wait(contractFutures).then((value) {
          List<Contract> contracts = [];
          for (var contract in value) {
            contracts.add(Contract(
              id: contract.id,
              landlordName: contract.data()?['landlordName'] ?? '',
              tenantName: contract.data()?['tenantName'] ?? '',
              allFields: contract.data(),
            ));
          }

          return contracts;
        });
      });
    }
    return [];
  }

  @override
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _buildAppBar(size, context, widget.callerType, widget.uid),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _filterContracts(value);
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.green,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.green),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Contract>>(
              future: getContracts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  contracts = snapshot.data ?? [];
                  // _filterContracts(_searchController.text);

                  if (filteredContracts.isEmpty && !oneTime) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        filteredContracts = contracts;
                      });
                    });
                    oneTime = true;
                  }

                  if (contracts.isEmpty) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                // const SizedBox(height: 50),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height * 0.1)),
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
                                          'No Contracts to show',
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
                      ],
                    );
                  }

                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 40),
                      ),
                      Text(
                        'Contracts',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 26.0,
                          color: const Color(0xff33907c),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredContracts.length,
                          itemBuilder: (context, index) {
                            //reverse the list so that the latest contract is shown first
                            final contract = filteredContracts[
                                filteredContracts.length - index - 1];
                            // final contract = filteredContracts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ContractPage(
                                    contractFields: contract.allFields,
                                    callerType: widget.callerType,
                                    uid: widget.uid,
                                  );
                                }));
                              },
                              child: Card(
                                elevation: 4.0,
                                margin: const EdgeInsets.all(20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    title: Text(
                                      'Landlord Name: ${contract.landlordName}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    subtitle: Text(
                                      'Tenant Name: ${contract.tenantName}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: SpinKitFadingCube(
                      color: Color.fromARGB(255, 30, 197, 83),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _filterContracts(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        filteredContracts = contracts;
      });
    } else {
      var strToCompare = '';

      List<Contract> temp = [];
      for (Contract contract in contracts) {
        if (widget.callerType == 'Tenants') {
          strToCompare = contract.landlordName;
        } else if (widget.callerType == 'Landlords') {
          strToCompare = contract.tenantName;
        }
        if (strToCompare.toLowerCase().contains(searchText.toLowerCase())) {
          temp.add(contract);
        }
      }
      setState(() {
        filteredContracts = temp;
      });
    }
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

class Contract {
  final String id;
  final String landlordName;
  final String tenantName;
  final allFields;

  Contract(
      {required this.id,
      required this.landlordName,
      required this.tenantName,
      required this.allFields});
}
