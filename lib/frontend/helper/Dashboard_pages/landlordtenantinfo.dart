import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';

import 'landlord_tenants.dart';

class LandlordTenantInfoPage extends StatelessWidget {
  final Tenant tenant;

  LandlordTenantInfoPage({required this.tenant});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ClipPath(
              clipper: DiagonalClipper(),
              child: Container(
                height: size.height * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff0FA697),
                      Color(0xff45BF7A),
                      Color(0xff0DF205), // Change to F6F9FF
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.1),
                CircleAvatar(
                  radius: size.width * 0.2,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                    tenant.pathToImage ?? 'assets/defaulticon.png',
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  '${tenant.firstName} ${tenant.lastName}',
                  style: GoogleFonts.montserrat(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff33907c),
                  ),
                ),
                SizedBox(height: 10.0),
                Center(
                  child: Text(
                    tenant.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      color: Color(0xff33907c),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Rating',
                            value: '${tenant.rating}',
                            points: '${tenant.creditPoints}',
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Property Details',
                            value: tenant.propertyDetails,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'CNIC Number',
                            value: tenant.cnicNumber,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Contact Number',
                            value: tenant.contactNumber,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Tasdeeq Verification',
                            value: tenant.tasdeeqVerification
                                ? 'Verified'
                                : 'Not Verified',
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Family Members',
                            value: tenant.familyMembers.toString(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WhiteBox extends StatelessWidget {
  final String label;
  final String value;
  final String? points;

  WhiteBox({required this.label, required this.value, this.points});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0, // Set the desired height of the white boxes
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (points != null)
                    Text(
                      'Points',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$value',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff33907c),
                    ),
                  ),
                  Text(
                    points ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff33907c),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
