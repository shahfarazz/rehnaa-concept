import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/helper/Dealerdashboard_pages/landlordonboardedinfo.dart';

import '../../../backend/models/landlordmodel.dart';

class DealerLandlordOnboardedPage extends StatefulWidget {
  final String uid;

  const DealerLandlordOnboardedPage({Key? key, required this.uid})
      : super(key: key);
  @override
  _DealerLandlordOnboardedPageState createState() =>
      _DealerLandlordOnboardedPageState();
}

class _DealerLandlordOnboardedPageState
    extends State<DealerLandlordOnboardedPage> {
  List<Landlord> landlords = [];

  bool isLoading = true;

  Future<List<Landlord>> fetchLandlords() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('Dealers')
              .doc(widget.uid)
              .get();

      Map<String, dynamic>? data = documentSnapshot.data()!;
      List<dynamic>? landlordRef = data['landlordRef'];

      List<Landlord> landlordList = [];

      for (var landlordID in landlordRef!) {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await landlordID.get();
        Landlord landlord = Landlord.fromJson(documentSnapshot.data());
        landlordList.add(landlord);
      }

      setState(() {
        landlords = landlordList;
        filteredLandlords = List.from(landlords);
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

  List<Landlord> filteredLandlords = [];
  late FocusNode searchFocusNode;
  final searchController = TextEditingController();
  bool isTyping = false;

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

  @override
  void dispose() {
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
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
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Container(
                child: Text("Landlords Onboarded",
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      color: const Color(0xff33907c),
                      fontWeight: FontWeight.bold,
                    )),
              ),
              // const SizedBox(height: 40),
              // if (isLoading)
              //   const Center(
              //     child: CircularProgressIndicator(
              //       color: Colors.green,
              //     ),
              //   ),
              Expanded(
                child: filteredLandlords.isEmpty
                    ? Center(
                        child: Card(
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
                                  'Oops! Nothing to show here...',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff33907c),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredLandlords.length,
                        itemBuilder: (context, index) {
                          final landlord = filteredLandlords[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LandlordsOnboardedInfoPage(
                                    landlord: landlord,
                                  ),
                                ),
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
                                    landlord.firstName +
                                        " " +
                                        landlord.lastName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                trailing: Text(landlord.balance.toString(),
                                    style: const TextStyle(color: Colors.grey)),
                                subtitle: Text('dummy'),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
