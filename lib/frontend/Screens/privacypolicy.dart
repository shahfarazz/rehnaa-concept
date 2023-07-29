import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/services/helperfunctions.dart';
import 'Dealer/dealer_dashboard.dart';
import 'Landlord/landlord_dashboard.dart';
import 'Tenant/tenant_dashboard.dart';

class MyApp extends StatelessWidget {
  final String uid;
  final String callerType;
  const MyApp({Key? key, required this.uid, required this.callerType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PrivacyPolicyPage(
        callerType: callerType,
        uid: uid,
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  final String uid;
  final String callerType;
  const PrivacyPolicyPage(
      {Key? key, required this.uid, required this.callerType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(size, context, callerType, uid),
      body: Stack(
        children: [
          // Positioned(
          //   top: 65.0,
          //   left: 10.0,
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.pop(context);
          //     },
          //     child: Container(
          //       width: 40,
          //       height: 40,
          //       decoration: const BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: Color(0xFF33907C),
          //         gradient: LinearGradient(
          //           begin: Alignment.topLeft,
          //           end: Alignment.bottomRight,
          //           colors: [
          //             Color(0xff0FA697),
          //             Color(0xff45BF7A),
          //             Color(0xff0DF205),
          //           ],
          //         ),
          //       ),
          //       child: IconButton(
          //         onPressed: () {
          //           Navigator.pop(context);
          //         },
          //         icon: const Icon(
          //           Icons.arrow_back,
          //           size: 20,
          //         ),
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
          Column(
            children: [
              const SizedBox(height: 30),
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.1,
              //   child: Image.asset(
              //     'assets/mainlogo.png',
              //     // fit: BoxFit.cover,
              //   ),
              // ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        color: const Color.fromARGB(255, 235, 235, 235),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                "Privacy Policy",
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xff33907c),
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily),
                              ),
                              const SizedBox(height: 16),
                              buildTextCard(),
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
        ],
      ),
    );
  }

  Widget buildTextCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText.rich(
          TextSpan(
            children: <TextSpan>[
              // TextSpan(
              //   text: 'Privacy Policy Rehnaa.pk\n\n',
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 16,
              //   ),
              // ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    'At Rehnaa, we are committed to protecting the privacy and personal information of our users. This Privacy Policy outlines how we collect, use, disclose, and safeguard the information you provide when using our rental platform ("Platform"). By accessing or using the Platform, you agree to the terms of this Privacy Policy.\n\n',
              ),
              TextSpan(
                text: 'Information Collection\n',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '1.1 Personal Information: When you create an account on Rehnaa, we may collect personal information, including but not limited to your name, email address, phone number, and location.\n\n',
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '1.2 Property Listings: To facilitate the rental process, we collect information about the properties you list on the Platform, including property details, rental rates, availability, and any additional information you choose to provide.\n\n',
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '1.3 Payment Information: If you choose to make or receive payments through our Platform, we may collect payment information, such as credit card details or bank account information, to process these transactions securely. Please note that we do not store complete payment information on our servers.\n\n',
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '1.4 Usage Information: We may collect information about your interactions with the Platform, such as your IP address, device information, browser type, and usage patterns. This information helps us analyze trends, administer the Platform, and improve user experience.\n\n',
              ),
              TextSpan(
                text: 'Information Use\n',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '2.1 Providing Services: We use the information we collect to provide and improve our services, facilitate property listings and rental transactions, verify user identity, respond to inquiries and requests, and personalize your experience on the Platform.\n\n',
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '2.2 Communication: We may use your contact information to send you important notices, updates, promotional materials, and other communications related to the Platform. You can opt-out of receiving these communications at any time.\n\n',
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '2.3 Aggregated Data: We may aggregate and anonymize the collected information to generate statistical or analytical insights that help us understand trends, preferences, and user behavior. This aggregated data does not identify any individual and may be used for research or marketing purposes.\n\n',
              ),
              TextSpan(
                text: 'Information Sharing\n',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '3.1 Service Providers: We may engage trusted third-party service providers to perform functions on our behalf, such as hosting, data analysis, payment processing, customer support, and marketing activities. These providers have access to personal information solely for the purpose of performing their duties and are obligated to maintain its confidentiality.\n\n',
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '3.2 Legal Compliance: We may disclose your personal information if required to do so by law or in response to valid legal requests, such as subpoenas, court orders, or government regulations. We may also disclose information when we believe in good faith that it is necessary to protect our rights, enforce our terms and policies, or investigate and prevent potential fraud or security breaches.\n\n',
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '3.3 Business Transfers: In the event of a merger, acquisition, or sale of our business assets, your personal information may be transferred as part of the transaction. We will notify you via email or a prominent notice on the Platform if such a change in ownership occurs, as well as any choices you may have regarding your information.\n\n',
              ),
              TextSpan(
                text: 'Data Security\n',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    'We employ industry-standard security measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction. However, please note that no method of transmission over the Internet or electronic storage is entirely secure, and we cannot guarantee absolute security.\n\n',
              ),
              TextSpan(
                text: 'User Rights and Choices\n',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '5.1 Account Management: You have the right to review, update, or delete your account information at any time. You may also edit or remove property listings or adjust your communication preferences. Please note that certain information may be retained as required by law or for legitimate business purposes.\n\n',
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    '5.2 Cookies and Tracking Technologies: We use cookies and similar tracking technologies to enhance your user experience, analyze usage patterns, and deliver personalized content. You can modify your browser settings to manage cookies or opt-out of certain tracking technologies, but this may limit the functionality of the Platform.\n\n',
              ),
              TextSpan(
                text: 'Children\'s Privacy\n',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    'Rehnaa is not intended for use by individuals under the age of 18. We do not knowingly collect personal information from children. If you believe we have inadvertently collected information from a child, please contact us to request deletion.\n\n',
              ),
              TextSpan(
                text: 'Changes to the Privacy Policy\n',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    'We reserve the right to modify or update this Privacy Policy at any time. We will notify you of significant changes by posting a prominent notice on the Platform or sending you an email. Your continued use of the Platform after such modifications indicate your acknowledgment and acceptance of the updated Privacy Policy.\n\n',
              ),
              TextSpan(
                text: 'Contact Us\n',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    'If you have any questions, concerns, or suggestions regarding this Privacy Policy or our privacy practices, please contact us at [insert contact information].\n\n',
              ),
              TextSpan(
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                text:
                    'By using the Rehnaa Rental Platform, you consent to the collection, use, disclosure, and processing of your information as described in this Privacy Policy.',
              ),
            ],
          ),
          textAlign: TextAlign.justify, // Justify the text
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(Size size, context, callerType, uid) {
  return AppBar(
    toolbarHeight: 70,
    title: Padding(
      padding: EdgeInsets.only(
        right:
            MediaQuery.of(context).size.width * 0.14, // 55% of the page width
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                // Add your desired logic here
                // print('tapped');

                if (callerType == 'Tenants') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TenantDashboardPage(
                              uid: uid,
                            )),
                  );
                } else if (callerType == 'Landlords') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LandlordDashboardPage(
                              uid: uid,
                            )),
                  );
                } else if (callerType == 'Dealers') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DealerDashboardPage(
                              uid: uid,
                            )),
                  );
                }
              },
              child: Stack(
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
              )),
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
