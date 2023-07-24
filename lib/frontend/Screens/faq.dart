import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/services/helperfunctions.dart';
import 'Dealer/dealer_dashboard.dart';
import 'Landlord/landlord_dashboard.dart';
import 'Tenant/tenant_dashboard.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: FAQPage(),
//     );
//   }
// }

class FAQPage extends StatefulWidget {
  final String callerType;
  final String uid;
  const FAQPage({Key? key, required this.callerType, required this.uid})
      : super(key: key);

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  int? currentlyExpandedIndex;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(size, context, widget.callerType, widget.uid),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 30),
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
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "FAQs",
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xff33907c),
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                              ),
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question: 'What is Rehnaa?',
                              answer:
                                  'Rehnaa is Pakistan’s first digital rental platform that connects property owners and tenants in Pakistan. Our platform allows property owners to list their properties for rent and tenants to search and find suitable rental accommodations. Additionally, Rehnaa provides a seamless experience for its users through features such as KYC, guaranteed rent, loyalty points, advance rent, rent accrual, vouchers, legal support and much more.  Our aim is to instill trust and transparency in the rental market of Pakistan.',
                              index: 0,
                              isExpanded: currentlyExpandedIndex == 0,
                              onTap: () {
                                setState(() {
                                  currentlyExpandedIndex = 0;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question: 'Does Rehnaa share our data further?',
                              answer:
                                  'Rehnaa does not share its users data with anyone except the users itself for better KYC profiling and user experience.',
                              index: 1,
                              isExpanded: currentlyExpandedIndex == 1,
                              onTap: () {
                                setState(() {
                                  currentlyExpandedIndex = 1;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Is Rehnaa available in all cities of Pakistan?',
                              answer:
                                  'Rehnaa is continually expanding its reach, but currently, our services are available in Lahore only. We aim to expand to more cities in the future, so stay tuned for updates.',
                              index: 2,
                              isExpanded: currentlyExpandedIndex == 2,
                              onTap: () {
                                setState(() {
                                  currentlyExpandedIndex = 2;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question: 'How much does it cost to use Rehnaa?',
                              answer:
                                  'Registering an account and searching for properties on Rehnaa is free of charge for tenants. For property owners, there is subscription charges of 1% of monthly rent if they opt to use Rehnaa services till the end of the contract. For tenants, an upfront 15 days’ worth of rent is charged when a deal is brokered by Rehnaa. No other hidden charges exist. The specific fees and pricing details can be found by contacting our support team.',
                              index: 3,
                              isExpanded: currentlyExpandedIndex == 3,
                              onTap: () {
                                setState(() {
                                  currentlyExpandedIndex = 3;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'How can I contact the property owner or tenant?',
                              answer:
                                  'Once you find a property or tenant of interest on Rehnaa, you can click the request button on the listing so our support team can contact you directly through the platform to initiate further communication.',
                              index: 4,
                              isExpanded: currentlyExpandedIndex == 4,
                              onTap: () {
                                setState(() {
                                  currentlyExpandedIndex = 4;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Can I negotiate the rental terms with the property owner?',
                              answer:
                                  'Yes, Rehnaa encourages communication between tenants and property owners. You can negotiate rental terms, such as rent amount, duration, and any additional requirements directly with the property owner through our platforms messaging system',
                              index: 5,
                              isExpanded: currentlyExpandedIndex == 5,
                              onTap: () {
                                setState(() {
                                  currentlyExpandedIndex = 5;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Is my personal information safe on Rehnaa?',
                              answer:
                                  'At Rehnaa, we take privacy and data security seriously. We have implemented robust security measures to protect your personal information. Please refer to our Privacy Policy for detailed information on how we collect, use, and safeguard your data.',
                              index: 6,
                              isExpanded: currentlyExpandedIndex == 6,
                              onTap: () {
                                setState(() {
                                  currentlyExpandedIndex = 6;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'How can I report a problem or issue with a property or user?',
                              answer:
                                  'If you encounter any problems or have concerns about a property or user on Rehnaa, please contact our support team immediately. We will investigate the issue and take appropriate action to resolve it.',
                              index: 7,
                              isExpanded: currentlyExpandedIndex == 7,
                              onTap: () {
                                setState(() {
                                  currentlyExpandedIndex = 7;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Can I list commercial properties for rent on Rehnaa?',
                              answer:
                                  'Yes, Rehnaa deals in commercial properties as well.',
                              index: 8,
                              isExpanded: currentlyExpandedIndex == 8,
                              onTap: () {
                                setState(() {
                                  currentlyExpandedIndex = 8;
                                });
                              },
                            ),
                            SizedBox(height: 30),
                          ],
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
}

class FAQCard extends StatefulWidget {
  final String question;
  final String answer;
  final int index;
  final bool isExpanded; // Add isExpanded parameter
  final VoidCallback onTap; // Add onTap parameter

  const FAQCard({
    Key? key,
    required this.question,
    required this.answer,
    required this.index,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  _FAQCardState createState() => _FAQCardState();
}

class _FAQCardState extends State<FAQCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // Use widget.onTap
      child: Card(
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
                  Flexible(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey,
                    ),
                    onPressed: widget.onTap, // Use widget.onTap
                  ),
                ],
              ),
              if (widget.isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.answer,
                    style: TextStyle(
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
            ],
          ),
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
