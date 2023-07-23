import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/contract.dart';

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
  Future<List<Widget>> getContracts() async {
    if (widget.callerType == 'Tenants') {
      //similar logic to getContracts for Landlords
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
          contractWidgets = [];
          for (var contract in value) {
            // print('contract is ${contract.data()}');
            contractWidgets.add(
              GestureDetector(
                onTap: () {
                  print('tapped');
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ContractPage(contractFields: contract.data());
                  }));
                },
                child: Card(
                  elevation: 5.0, // set the elevation
                  margin: EdgeInsets.all(10.0), // set the margin
                  child: Padding(
                    // add padding to ListTile
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0), // set content padding
                      title: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // central alignment
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Landlord Name: ${contract.data()?['landlordName'] ?? ''}',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left, // align text to the left
                          ),
                        ],
                      ),
                      subtitle: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // central alignment
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Tenant Name: ${contract.data()?['tenantName'] ?? ''}',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left, // align text to the left
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return contractWidgets;
        });
        // return contractWidgets;
      });
    } else if (widget.callerType == 'Landlords') {
      //get list of contractIDs from contractIDs field in landlord document
      return await FirebaseFirestore.instance
          .collection('Landlords')
          .doc(widget.uid)
          .get()
          .then((value) async {
        // print('reached here');
        var contractIDs = value.data()?['contractIDs'];
        // print('value data is ${value.data()}');
        print('contractIds are $contractIDs');
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
          contractWidgets = [];
          for (var contract in value) {
            // print('contract is ${contract.data()}');
            contractWidgets.add(
              GestureDetector(
                onTap: () {
                  print('tapped');
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ContractPage(contractFields: contract.data());
                  }));
                },
                child: Card(
                  elevation: 5.0, // set the elevation
                  margin: EdgeInsets.all(10.0), // set the margin
                  child: Padding(
                    // add padding to ListTile
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0), // set content padding
                      title: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // central alignment
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Landlord Name: ${contract.data()?['landlordName'] ?? ''}',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left, // align text to the left
                          ),
                        ],
                      ),
                      subtitle: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // central alignment
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Tenant Name: ${contract.data()?['tenantName'] ?? ''}',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left, // align text to the left
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return contractWidgets;
        });
        // return contractWidgets;
      });
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _buildAppBar(size, context),
      body: FutureBuilder(
        future: getContracts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            contractWidgets = snapshot.data as List<Widget>;
            if (contractWidgets.isEmpty) {
              return Scaffold(
                body: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.only(top: 40)),
                        Text(
                          'Contracts: ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 30.0,
                            color: const Color(0xff33907c),
                          ),
                        ),
                        const SizedBox(height: 30),
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
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 40),
                ),
                Text(
                  'Contracts: ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 26.0,
                    color: const Color(0xff33907c),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: contractWidgets,
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
    );
  }
}

PreferredSizeWidget _buildAppBar(Size size, context) {
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
          Stack(
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
          ),
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
