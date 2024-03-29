import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';
// import 'package:rehnaa/backend/services/helperfunctions.dart';
// import '../../../backend/models/landlordmodel.dart';
import '../../../backend/models/landlordmodel.dart';
import '../../../backend/models/tenantsmodel.dart';

class TenantLandlordInfoPage extends StatelessWidget {
  final Tenant tenant;
  final String uid;
  final Landlord landlord;

  const TenantLandlordInfoPage(
      {Key? key,
      required this.tenant,
      required this.uid,
      required this.landlord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    String formatCNIC(String cnic) {
      if (cnic.length != 13) {
        return cnic; // Return the original CNIC if the length is not as expected
      }

      String part1 = cnic.substring(0, 5);
      String part2 = cnic.substring(5, 12);
      String part3 = cnic.substring(12);

      return '$part1-$part2-$part3';
    }

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
                      child: landlord.pathToImage != null &&
                              landlord.pathToImage!.isNotEmpty
                          ? (landlord.pathToImage!.startsWith('assets')
                              ? Image.asset(
                                  landlord.pathToImage!,
                                  width: 150,
                                  height: 150,
                                )
                              : Image.network(
                                  fit: BoxFit.fill,
                                  landlord.pathToImage!,
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
                    '${landlord.firstName} ${landlord.lastName}',
                    style: GoogleFonts.montserrat(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff33907c),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Landlord Description',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 16.0,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              ),
                              content: SingleChildScrollView(
                                  child: Text(
                                landlord.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  // fontSize: 16.0,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                              )),
                              actions: [
                                TextButton(
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      // fontSize: 16.0,
                                      fontFamily:
                                          GoogleFonts.montserrat().fontFamily,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        landlord.description == '' ||
                                landlord.description == null
                            ? ''
                            : landlord.description!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 16.0,
                          color: const Color(0xff33907c),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.0),
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
                          landlord.creditPoints != ""
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.star,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Credit Score',
                                    value: '${landlord.creditScore}',
                                    points: '${landlord.creditPoints}',
                                    pointsIcon: Icons.star_border,
                                  ),
                                )
                              : const SizedBox.shrink(),
                          // const SizedBox(height: 10.0),

                          Center(
                            child: WhiteBox(
                              icon: Icons.star,
                              iconColor: const Color(0xff33907c),
                              label: 'Tenant Name',
                              value: '${tenant.firstName} ${tenant.lastName}',
                              // points: '${tenant.landlord.creditPoints}',
                            ),
                          ),

                          // const SizedBox(height: 10.0),

                          landlord.cnic != '' && landlord.cnic != null
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.perm_identity,
                                    iconColor: const Color(0xff33907c),
                                    label: 'CNIC Number',
                                    value: formatCNIC(
                                        decryptString(landlord.cnic!)),
                                  ),
                                )
                              : const SizedBox.shrink(),

                          // landlord.cnic != '' && landlord.cnic != null
                          //     ? const SizedBox(height: 10.0)
                          //     : const SizedBox.shrink(),
                          // const SizedBox(height: 10.0),

                          landlord.property != null &&
                                  landlord.property!.length != 0 &&
                                  landlord.property?[0].address != ''
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.home,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Property Address',
                                    value: landlord.property![0].address,
                                  ),
                                )
                              : const SizedBox.shrink(),

                          // landlord.property != null &&
                          //         landlord.property!.length != 0 &&
                          //         landlord.property?[0].address != ''
                          //     ? const SizedBox(height: 10.0)
                          //     : const SizedBox.shrink(),
                          // const SizedBox(height: 10.0),

                          //TODO add new phone number field in landlord model

                          landlord.phoneNumber != '' &&
                                  landlord.phoneNumber != null
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.phone,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Phone Number',
                                    value: landlord.phoneNumber ??
                                        'No Phone Number',
                                  ),
                                )
                              : const SizedBox.shrink(),

                          //TODO add new past tenant testimonial field landlord model

                          landlord.pastTenantTestimonial != '' &&
                                  landlord.pastTenantTestimonial != null
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.rate_review,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Past Tenant Testimonial',
                                    value: landlord.pastTenantTestimonial ??
                                        'No Testimonial',
                                  ),
                                )
                              : const SizedBox.shrink(),

                          landlord.dateJoined != '' &&
                                  landlord.dateJoined != null
                              ? Center(
                                  child: WhiteBox(
                                    icon: Icons.calendar_today,
                                    iconColor: const Color(0xff33907c),
                                    label: 'Date Joined',
                                    value: landlord.dateJoined!
                                        .toDate()
                                        .toString()
                                        .substring(0, 10),
                                  ),
                                )
                              : const SizedBox.shrink(),

                          // const SizedBox(height: 10.0),
                          // landlord.monthlyProfit != '' &&
                          //         landlord.monthlyProfit != null
                          //     ? Center(
                          //         child: WhiteBox(
                          //           icon: Icons.money,
                          //           iconColor: const Color(0xff33907c),
                          //           label: 'Monthly Profit',
                          //           value: landlord.monthlyProfit!,
                          //         ),
                          //       )
                          // : const SizedBox.shrink(),
                          // const SizedBox(height: 10.0),
                          // Center(
                          //   child: WhiteBox(
                          //     icon: Icons.info,
                          //     iconColor: const Color(0xff33907c),
                          //     label: 'Other Information',
                          //     value: 'N/A',
                          //   ),
                          // ),
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
      // height: 90.0,
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
                              pointsIcon,
                              color: iconColor,
                            ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Points',
                            style: GoogleFonts.montserrat(
                              fontSize: 16.0,
                              color: const Color(0xff33907c),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                buttonPadding: const EdgeInsets.all(10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                contentTextStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                                title: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16.0,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                  ),
                                ),
                                content: Text(
                                  value,
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        // fontSize: 16.0,
                                        fontFamily:
                                            GoogleFonts.montserrat().fontFamily,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      points == null
                          ? ''
                          : '                                            ${points ?? ''}',
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
