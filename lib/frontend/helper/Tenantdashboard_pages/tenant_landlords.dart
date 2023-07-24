import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_landlord_info.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_renthistory.dart';

import '../../../backend/models/tenantsmodel.dart';
import '../../Screens/Landlord/landlord_dashboard.dart';

class TenantLandlordsPage extends StatefulWidget {
  final String uid;
  const TenantLandlordsPage({super.key, required this.uid});

  @override
  State<TenantLandlordsPage> createState() => _TenantLandlordsPageState();
}

class _TenantLandlordsPageState extends State<TenantLandlordsPage> {
  Tenant? tenant;
  List<Landlord?> landlords = [];
  Future<Tenant>? fetchTenantFuture;

  Future<Tenant> _fetchTenants() async {
    landlords.clear();

    tenant = await FirebaseFirestore.instance
        .collection('Tenants')
        .doc(widget.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        tenant = Tenant.fromJson(value.data()!);
        //iterate over tenant.landlordref and set landlords
        print('lenght of landlord ref is ${tenant!.landlordRef!.length}');

        for (var landlordRef in tenant!.landlordRef!) {
          Landlord landlord = await landlordRef.get().then((value) {
            return Landlord.fromJson(value.data()!);
          });
          print('landlord is ${landlord.firstName}');
          if (landlords.contains(landlord) == false) {
            landlords.add(landlord);
          }
          print('landlord length is ${landlords.length}');
          // landlords.add(landlord);
        }

        return tenant!;
      }
    });
    return tenant!;
  }

  Future<void> _refreshLandlords() async {
    // setState(() {});
    // await Future.delayed(Duration(seconds: 2));
    setState(() {
      fetchTenantFuture = _fetchTenants();
    });
  }

  @override
  void initState() {
    super.initState();
    // _fetchTenants();
    fetchTenantFuture = _fetchTenants();
  }

  // Build a card widget for a landlord
  Widget _buildLandlordCard(Landlord landlord) {
    return GestureDetector(
        onTap: () {
          // Navigate to tenant info page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TenantLandlordInfoPage(
                tenant: tenant!,
                uid: widget.uid,
                landlord: landlord,
              ),
            ),
          );
        },
        child: Card(
          elevation: 4.0,
          margin: const EdgeInsets.all(20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff0FA697),
                      Color(0xff45BF7A),
                      Color(0xff0DF205),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Landlord Name ',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${landlord.firstName} ${landlord.lastName}',
                          style: GoogleFonts.montserrat(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff33907c),
                          ),
                        ),
                      ],
                    ),
                    // additional fields go here
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: _buildAppBar(MediaQuery.sizeOf(context), context),
      body: FutureBuilder(
        future: fetchTenantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is being fetched, show a loading indicator or placeholder.
            return const Center(
              child: SpinKitFadingCube(
                color: Color.fromARGB(255, 30, 197, 83),
              ),
            );
          } else if (snapshot.hasError) {
            // If an error occurs during data fetching, display an error message.
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            var data = snapshot.data;
            if (data?.landlordRef == null) {
              // If no landlord data is available, show a specific message or widget.
              return RefreshIndicator(
                  onRefresh: _refreshLandlords,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Card(
                          margin: const EdgeInsets.all(16.0),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48.0,
                                  color: Color(0xff33907c),
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  'No landlord found',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20.0,
                                    color: const Color(0xff33907c),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ));
            } else {
              // If landlord data is available, display the landlord card.
              return RefreshIndicator(
                onRefresh: _refreshLandlords,
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: size.height * 0.05),
                    Text(
                      'Landlord',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    //listview.builder on landlords
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: landlords.length,
                      itemBuilder: (context, index) {
                        return _buildLandlordCard(landlords[index]!);
                      },
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
