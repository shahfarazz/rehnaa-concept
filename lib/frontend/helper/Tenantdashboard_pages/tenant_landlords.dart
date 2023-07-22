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

  Future<Tenant> _fetchTenants() async {
    tenant = await FirebaseFirestore.instance
        .collection('Tenants')
        .doc(widget.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        tenant = Tenant.fromJson(value.data()!);
        // print('tenant.landlordRef: ${tenant!.landlordRef?.id}');
        tenant?.landlord = await tenant?.getLandlord();
        // print('Landlord: ${tenant!.landlord?.firstName}');
        tenant?.landlord?.property = (await tenant?.landlord?.getProperty())!;
        // print('landlord.property: ${tenant!.landlord?.property[0].address}');
        return tenant!;
      }
    });
    return tenant!;
  }

  Future<void> _refreshLandlords() async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchTenants();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    'Tenant Name: ',
                    style: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${landlord.firstName} ${landlord.lastName}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff33907c),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Text(
                    'Rating:',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    ' ${landlord.rating}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff33907c),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Text(
                    'Properties owned: ',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  landlord.property != null
                      ? Expanded(
                          child: Wrap(
                          direction: Axis.horizontal,
                          spacing: 8.0,
                          children: landlord.property!.map((property) {
                            return
                                // Row(
                                // children: [
                                // SizedBox()
                                Text(
                              property.title,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff33907c),
                              ),
                            );
                            // ],
                            // );
                          }).toList(),
                        ))
                      : Text(
                          'No properties',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff33907c),
                          ),
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: _buildAppBar(MediaQuery.sizeOf(context), context),
      body: FutureBuilder(
        future: _fetchTenants(),
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
                    Container(
                      width: size.width,
                      height: size.height * 0.2,
                      child: _buildLandlordCard(data!.landlord!),
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
