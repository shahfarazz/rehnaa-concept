import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/helper/Dealerdashboard_pages/landlordonboardedinfo.dart';

import '../../../backend/models/dealermodel.dart';
import '../../../backend/models/landlordmodel.dart';
// import '../Admindashboard_pages/admin_estamps.dart';

class DealerLandlordOnboardedPage extends StatefulWidget {
  final String uid;

  const DealerLandlordOnboardedPage({Key? key, required this.uid})
      : super(key: key);
  @override
  _DealerLandlordOnboardedPageState createState() =>
      _DealerLandlordOnboardedPageState();
}

class Estamp {
  final String id;
  final landlordData;

  Estamp({required this.id, required this.landlordData});
}

class _DealerLandlordOnboardedPageState
    extends State<DealerLandlordOnboardedPage> {
  List<Landlord> landlords = [];
  Dealer? dealer;
  List<Estamp> estampList = [];

  bool isLoading = true;

  Future<List<Landlord>> fetchLandlords() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('Dealers')
              .doc(widget.uid)
              .get();

      Map<String, dynamic>? data = documentSnapshot.data()!;
      // print('data: ${data['landlordRef'][0].id}');
      List<dynamic> landlordRef = data['landlordRef'];
      dealer = Dealer.fromJson(data);

      List<Landlord> landlordList = [];

      for (var landlordID in landlordRef!) {
        print('landlordID: ${landlordID.id}');
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await landlordID.get();
        Landlord landlord = Landlord.fromJson(documentSnapshot.data());
        landlord.tempID = documentSnapshot.id;
        landlordList.add(landlord);
      }

      setState(() {
        landlords = landlordList;
        // filteredLandlords = List.from(landlords);
        isLoading = false;
      });
      return landlords;
    } catch (e) {
      print(e);
      // setState(() {
      isLoading = false;
      // });

      return [];
    }
  }

  Future<List<Estamp>> fetchEstamps() async {
    estampList = [];
    try {
      await FirebaseFirestore.instance
          .collection('Dealers')
          .doc(widget.uid)
          .collection('Estamps')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          estampList.add(Estamp(id: element.id, landlordData: element.data()));
        });
      });

      return estampList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  // List<Landlord> filteredLandlords = [];
  List<Estamp> filteredEstamps = [];
  late FocusNode searchFocusNode;
  final searchController = TextEditingController();
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    // filteredLandlords = List.from(landlords);
    filteredEstamps = List.from(estampList);
    searchFocusNode = FocusNode();
    searchController.addListener(onSearchTextChanged);
    // fetchLandlords();
    fetchEstamps().then((_) {
      setState(() {
        filteredEstamps = List.from(estampList);
      });
    });
  }

  void onSearchTextChanged() {
    final query = searchController.text;
    // filterLandlords(query);
    filterEstamps(query);
  }

  // void filterLandlords(String query) {
  //   setState(() {
  //     filteredLandlords = landlords.where((landlord) {
  //       final nameLower = landlord.firstName.toLowerCase();
  //       final queryLower = query.toLowerCase();
  //       return nameLower.contains(queryLower);
  //     }).toList();
  //     isTyping = query.isNotEmpty;
  //   });
  // }

  void filterEstamps(String query) {
    setState(() {
      filteredEstamps = estampList.where((estamp) {
        final nameLower =
            estamp.landlordData['landlordData']['landlordName'].toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();
      isTyping = query.isNotEmpty;
    });
  }

  Future<void> _refreshFunction() async {
    setState(() {
      isLoading = true;
      // fetchLandlords();
      fetchEstamps().then((_) {
        setState(() {
          filteredEstamps = List.from(estampList);
        });
      });
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),
              Container(
                child: Text(
                  "Landlords Onboarded",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    color: const Color(0xff33907c),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  focusNode: searchFocusNode,
                  controller: searchController,
                  onChanged: (value) => setState(() {}),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.green,
                    ),
                    hintText: 'Search by name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              Expanded(
                child: filteredEstamps.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _refreshFunction,
                        child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                SizedBox(height: size.height * 0.05),
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
                                          Icons.error_outline,
                                          size: 48.0,
                                          color: Color(0xff33907c),
                                        ),
                                        const SizedBox(height: 16.0),
                                        Text(
                                          'No Landlords onboarded yet',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 20.0,
                                            // fontWeight: FontWeight.bold,
                                            color: const Color(0xff33907c),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 200),
                              ],
                            )))
                    : RefreshIndicator(
                        onRefresh: _refreshFunction,
                        child: ListView.builder(
                          itemCount: estampList.length,
                          itemBuilder: (context, index) {
                            // final landlord = filteredLandlords[index];
                            //reverse
                            // final landlord = filteredLandlords[
                            //     filteredLandlords.length - index - 1];
                            // final estamp = estampList[index];//reverse
                            final estamp = filteredEstamps[
                                filteredEstamps.length - index - 1]; //reverse
                            return GestureDetector(
                              onTap: () {
                                if (estamp.landlordData?['landlordData']
                                        ?['eStampTenantName'] ==
                                    null) {
                                  //flutter toast here
                                  Fluttertoast.showToast(
                                      msg:
                                          "Landlord has not onboarded any tenant yet, wait for estamp",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LandlordsOnboardedInfoPage(
                                            landlordData: estamp
                                                .landlordData?['landlordData'],
                                          )),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 5.0,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 10.0),
                                  title: Text(
                                    estamp.landlordData['landlordData']
                                        ['landlordName'],
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontFamily:
                                            GoogleFonts.montserrat().fontFamily,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Text(
                                    estamp.landlordData?['landlordData']
                                                ?['eStampContractStartDate'] !=
                                            null
                                        ? estamp.landlordData?['landlordData']
                                                    ?['eStampContractStartDate']
                                                .toDate()
                                                .toString()
                                                .substring(0, 10) ??
                                            ''
                                        : '',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily:
                                          GoogleFonts.montserrat().fontFamily,
                                    ),
                                  ),
                                  // subtitle: Text('dummy'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
