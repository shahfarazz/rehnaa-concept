import 'package:flutter/material.dart';
import 'package:rehnaa/frontend/helper/Dealerdashboard_pages/landlordonboardedinfo.dart';

class Landlord {
  final String name;
  final String date;
  final String address;

  Landlord({
    required this.name,
    required this.date,
    required this.address,
  });
}

class LandlordOnboardedPage extends StatefulWidget {
  @override
  _LandlordOnboardedPageState createState() => _LandlordOnboardedPageState();
}

class _LandlordOnboardedPageState extends State<LandlordOnboardedPage> {
  final List<Landlord> landlords = [
    Landlord(
      name: 'Arshad Ali',
      date: '9 June 2022',
      address: '26 J Johar Town',
    ),
    Landlord(
      name: 'Akbar Khan',
      date: '15 June 2022',
      address: '21 H Johar Town',
    ),
    Landlord(
      name: 'John Doe',
      date: '20 June 2022',
      address: '15 X Street',
    ),
    Landlord(
      name: 'Jane Smith',
      date: '30 June 2022',
      address: '10 Y Avenue',
    ),
  ];

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
  }

  void onSearchTextChanged() {
    final query = searchController.text;
    filterLandlords(query);
  }

  void filterLandlords(String query) {
    setState(() {
      filteredLandlords = landlords.where((landlord) {
        final nameLower = landlord.name.toLowerCase();
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
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  focusNode: searchFocusNode,
                  controller: searchController,
                  onChanged: (value) => setState(() {}),
                  style: TextStyle(
                    color:Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLandlords.length,
                  itemBuilder: (context, index) {
                    final landlord = filteredLandlords[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LandlordsOnboardedInfoPage(),
                          ),
                        );
                      },

                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5.0,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        title: Text(landlord.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(landlord.date, style: TextStyle(color: Colors.grey)),
                        subtitle: Text(landlord.address),
                      ),
                    ),
                  );
                },
              ),),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LandlordOnboardedPage(),
    theme: ThemeData(
      primarySwatch: Colors.green,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
