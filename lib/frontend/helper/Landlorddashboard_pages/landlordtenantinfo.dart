import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';

class LandlordTenantInfoPage extends StatelessWidget {
  final Tenant tenant;

  const LandlordTenantInfoPage({Key? key, required this.tenant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      
      body: SingleChildScrollView(
        child: Stack(
          children: [
            
            // Background gradient with diagonal clip
            ClipPath(
              clipper: DiagonalClipper(),
              
              child: Container(
                height: size.height * 0.5,
                decoration: const BoxDecoration(
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
            Positioned(
            top: 40.0,
            left: 10.0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF33907C),
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
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
            Column(
              
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                SizedBox(height: size.height * 0.08),
                
                // Display tenant's avatar
                CircleAvatar(
                  radius: size.width * 0.2,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                    tenant.pathToImage ?? 'assets/defaulticon.png',
                  ),
                ),
                const SizedBox(height: 20.0),
                // Display tenant's name
                Text(
                  '${tenant.firstName} ${tenant.lastName}',
                  style: GoogleFonts.montserrat(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff33907c),
                  ),
                ),
                const SizedBox(height: 10.0),
                // Display tenant's description
                Center(
                  child: Text(
                    tenant.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      color: const Color(0xff33907c),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
               FractionallySizedBox(
  widthFactor: 0.8,
  child: Card(
    color: Colors.grey[200],
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25.0),
    ),
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Center(
              child: WhiteBox(
                label: 'Rating',
                value: '${tenant.rating}',
                points: '${tenant.creditPoints}',
              ),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: WhiteBox(
                label: 'Property Details',
                value: tenant.propertyDetails,
              ),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: WhiteBox(
                label: 'CNIC Number',
                value: tenant.cnicNumber,
              ),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: WhiteBox(
                label: 'Contact Number',
                value: tenant.emailOrPhone,
              ),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: WhiteBox(
                label: 'Tasdeeq Verification',
                value: tenant.tasdeeqVerification ? 'Verified' : 'Not Verified',
              ),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: WhiteBox(
                label: 'Family Members',
                value: tenant.familyMembers.toString(),
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    ),
  ),
)

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

  const WhiteBox({
    Key? key,
    required this.label,
    required this.value,
    this.points,
  }) : super(key: key);

  @override
 Widget build(BuildContext context) {
  return SizedBox(
    height: 100.0, // Set the desired height of the white boxes
    child: Container(
      width: MediaQuery.of(context).size.width,
       // Set the desired width of the outer card
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff33907c),
                    ),
                  ),
                  Text(
                    points ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff33907c),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
