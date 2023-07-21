import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../backend/models/dealermodel.dart';
import '../../../backend/models/landlordmodel.dart';
import '../../Screens/contract.dart';
import 'dealer_estamp_info.dart';

class DealerEstampPage extends StatefulWidget {
  final String uid;

  const DealerEstampPage({super.key, required this.uid});

  @override
  State<DealerEstampPage> createState() => _DealerEstampPageState();
}

class _DealerEstampPageState extends State<DealerEstampPage> {
  late FocusNode searchFocusNode;
  final searchController = TextEditingController();
  bool isTyping = false;
  List<Landlord> filteredLandlords = [];
  List<Landlord> landlords = [];
  bool isLoading = true;
  Dealer? dealer;
  bool _noEstamp = true;
  @override
  void initState() {
    super.initState();
    filteredLandlords = List.from(landlords);
    searchFocusNode = FocusNode();
    searchController.addListener(onSearchTextChanged);
    fetchLandlords();
  }

  void onSearchTextChanged() {
    final query = searchController.text;
    filterLandlords(query);
  }

  void filterLandlords(String query) {
    setState(() {
      filteredLandlords = landlords.where((landlord) {
        final nameLower = landlord.firstName.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();
      isTyping = query.isNotEmpty;
    });
  }

  Future<void> _refreshFunction() async {
    setState(() {
      isLoading = true;
      fetchLandlords();
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

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
        landlord.tempID = landlordID.id;
        landlord.hasEstamp = (dealer?.landlordMap?[landlord.tempID]
                ?['eStampTenantName'] !=
            null);
        if (landlord.hasEstamp) {
          print('reached hereree');
          setState(() {
            _noEstamp = false;
          });
        }
        landlordList.add(landlord);
        // print('dealer landlordmap: ${dealer.landlordMap?[landlord.tempID]}');
      }

      setState(() {
        landlords = landlordList;
        filteredLandlords = List.from(landlords);
        isLoading = false;
      });
      return landlords;
    } catch (e) {
      print('error is $e');
      // setState(() {
      isLoading = false;
      // });

      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(size, context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),
              Container(
                child: Text(
                  "E-Stamp Papers Services",
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
                child: filteredLandlords.isEmpty || _noEstamp
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
                                          'No E-Stamp Papers Found.',
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
                              ],
                            )))
                    : RefreshIndicator(
                        onRefresh: _refreshFunction,
                        child: ListView.builder(
                          itemCount: filteredLandlords.length,
                          itemBuilder: (context, index) {
                            final landlord = filteredLandlords[index];
                            return GestureDetector(
                              onTap: () {
                                if (!(landlord.hasEstamp)) {
                                  //flutter toast no estamp found
                                  Fluttertoast.showToast(
                                      msg: "No E-Stamp Papers Found",
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
                                    builder: (context) => DealerEstampInfoPage(
                                      landlord: landlord,
                                      dealer: dealer!,
                                    ),
                                  ),
                                );
                              },
                              child: landlord.hasEstamp
                                  ? Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      elevation: 5.0,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 10.0),
                                        title: Text(
                                          landlord.firstName +
                                              " " +
                                              landlord.lastName,
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontFamily:
                                                  GoogleFonts.montserrat()
                                                      .fontFamily,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          dealer?.landlordMap?[landlord.tempID]
                                              ?['eStampAddress'],
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontFamily:
                                                  GoogleFonts.montserrat()
                                                      .fontFamily,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: Text(
                                          '${dealer?.landlordMap?[landlord.tempID]?['eStampDate']}\n\nRs.${dealer?.landlordMap?[landlord.tempID]?['eStampCharges']}',
                                          // landlord.contractStartDate == ''
                                          //     ? 'No Contract\n\n${landlord.monthlyRent == "" ? "No Rent" : landlord.monthlyRent}'
                                          //     : '${landlord.contractStartDate!}\n ${landlord.monthlyRent == "" ? "No Rent" : landlord.monthlyRent}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: GoogleFonts.montserrat()
                                                .fontFamily,
                                          ),
                                        ),

                                        // subtitle: Text('dummy'),
                                      ),
                                    )
                                  : Container(),
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

PreferredSizeWidget _buildAppBar(Size size, context) {
  return AppBar(
    toolbarHeight: 70,
    title: Padding(
      padding: EdgeInsets.only(
        // top: MediaQuery.of(context).size.height * 0.02, // 2% of the page height
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
