import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';

class LandlordTenantInfoPage extends StatelessWidget {
  final Tenant tenant;
  final String uid;

  const LandlordTenantInfoPage(
      {Key? key, required this.tenant, required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
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
                        Color(0xff0DF205),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 65.0,
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
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 75,
                    child: ClipOval(
                      child: tenant.pathToImage != null &&
                              tenant.pathToImage!.isNotEmpty
                          ? (tenant.pathToImage!.startsWith('assets')
                              ? Image.asset(
                                  tenant.pathToImage!,
                                  width: 150,
                                  height: 150,
                                )
                              : Image.network(
                                  fit: BoxFit.cover,
                                  tenant.pathToImage!,
                                  width: 150,
                                  height: 150,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: SpinKitFadingCube(
                                        color: Color.fromARGB(255, 30, 197, 83),
                                      ),
                                    );
                                  },
                                ))
                          : Image.asset(
                              'assets/defaulticon.png',
                              width: 150,
                              height: 150,
                            ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    '${tenant.firstName} ${tenant.lastName}',
                    style: GoogleFonts.montserrat(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff33907c),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      tenant.description ?? 'No Description',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0,
                        color: const Color(0xff33907c),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              heightFactor: 1.2,
              child: Transform.translate(
                offset: const Offset(0, -40),
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
                          // Rest of your card's content...

                          tenant.creditScore != ""
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.star,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Rating',
                                    value: '${tenant.creditScore}',
                                    points: '${tenant.creditPoints}',
                                    pointsIcon: Icons.star,
                                    // tenant.credit
                                  ),
                                )
                              : Container(),

                          tenant.address == ''
                              ? Container()
                              : Center(
                                  child: WhiteBox(
                                      icon: Icons.email,
                                      iconColor: const Color(0xff33907c),
                                      label: 'Personal Address',
                                      value: tenant.address!),
                                ),
                          const SizedBox(height: 10.0),

                          const SizedBox(height: 10.0),
                          tenant.cnicNumber != null
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.numbers,
                                    iconColor: const Color(0xff33907c),
                                    label: 'CNIC Number',
                                    value: decryptString(tenant.cnicNumber!),
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 10.0),
                          tenant.emailOrPhone != ''
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.email,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Email/Phone Number',
                                    value: tenant.emailOrPhone!,
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 10.0),
                          tenant.contractStartDate == null
                              ? Container()
                              : Center(
                                  child: WhiteBox(
                                    icon: Icons.email,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Contract Start Date',
                                    value: tenant.contractStartDate!
                                        .toDate()
                                        .toString()
                                        .substring(0, 10),
                                  ),
                                ),
                          const SizedBox(height: 10.0),
                          tenant.contractEndDate == null
                              ? Container()
                              : Center(
                                  child: WhiteBox(
                                    icon: Icons.email,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Contract End Date',
                                    value: tenant.contractEndDate!
                                        .toDate()
                                        .toString()
                                        .substring(0, 10),
                                  ),
                                ),
                          const SizedBox(height: 10.0),
                          tenant.propertyAddress == 'No address found'
                              ? Container()
                              : Center(
                                  child: WhiteBox(
                                    icon: Icons.email,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Rented Property Address',
                                    value: tenant.propertyAddress!,
                                  ),
                                ),
                          const SizedBox(height: 10.0),

                          tenant.tasdeeqVerification != null
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.verified_user,
                                    label: 'Tasdeeq Verification',
                                    iconColor: const Color(0xff33907c),
                                    value: tenant.tasdeeqVerification!
                                        ? 'Verified'
                                        : 'Not Verified',
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 10.0),
                          Center(
                            child: WhiteBox(
                              icon: Icons.family_restroom,
                              iconColor: const Color(0xff33907c),
                              label: 'Family Members',
                              value: tenant.familyMembers.toString(),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          tenant.policeVerification != null
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.local_police,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Police Verification',
                                    value: tenant.policeVerification!
                                        ? 'Verified'
                                        : 'Not Verified',
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 10.0),
                          Center(
                            child: WhiteBox(
                              icon: Icons.info,
                              iconColor: const Color(0xff33907c),
                              label: 'Other Information',
                              value: tenant.otherInfo ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhiteBox extends StatelessWidget {
  final String label;
  final String value;
  final String? points;
  final IconData? icon;
  final Color? iconColor;
  final IconData? pointsIcon;

  const WhiteBox({
    Key? key,
    required this.label,
    required this.value,
    this.points,
    this.icon,
    this.iconColor,
    this.pointsIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.0,
      width: 280,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (icon != null)
                          Icon(
                            icon,
                            color: iconColor,
                          ),
                        const SizedBox(width: 8.0),
                        Text(
                          label,
                          style: GoogleFonts.montserrat(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff33907c),
                          ),
                        ),
                      ],
                    ),
                    if (points != null)
                      Row(
                        children: [
                          if (icon != null)
                            Icon(
                              icon,
                              color: iconColor,
                            ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Points',
                            style: GoogleFonts.montserrat(
                              fontSize: 16.0,
                              color: const Color(0xff33907c),
                            ),
                          ),
                        ],
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
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      points ?? '',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.0,
                        color: Colors.black,
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
