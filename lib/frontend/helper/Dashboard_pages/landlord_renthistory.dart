import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/propertymodel.dart';
import 'package:rehnaa/backend/models/rentpaymentmodel.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';

import 'landlord_tenants.dart';

class LandlordRentHistoryPage extends StatefulWidget {
  @override
  _LandlordRentHistoryPageState createState() =>
      _LandlordRentHistoryPageState();
}

class _LandlordRentHistoryPageState extends State<LandlordRentHistoryPage> {
  final List<RentPayment> _rentPayments = [
    RentPayment(
      tenant: Tenant(
        firstName: 'John',
        lastName: 'Doe',
        description: 'Lorem ipsum dolor sit amet',
        rating: 4.5,
        rent: 1500,
        creditPoints: 100,
        propertyDetails: 'Lorem ipsum dolor sit amet',
        cnicNumber: '1234567890',
        contactNumber: '9876543210',
        tasdeeqVerification: true,
        familyMembers: 3,
      ),
      amount: '100K',
      date: DateTime(2021, 1, 1),
      paymentType: "app", // Use PaymentType.app for Rehnaa app transactions
      property: Property(
        imagePath: ['assets/image1.jpg'],
        type: 'House',
        beds: 3,
        baths: 2,
        garden: true,
        living: 1,
        floors: 2,
        carspace: 2,
        description: 'Spacious house with a beautiful garden.',
        title: 'Luxury House',
        location: 'City Center',
        price: 3000,
        landlordRef: null,
        rehnaaRating: 4.5,
        tenantRating: 4.2,
        tenantReview: 'Great property! Highly recommended.',
      ),
    ),
    RentPayment(
      tenant: Tenant(
        firstName: 'Jane',
        lastName: 'Smith',
        description: 'Lorem ipsum dolor sit amet',
        rating: 4.2,
        rent: 1200,
        creditPoints: 80,
        propertyDetails: 'Lorem ipsum dolor sit amet',
        cnicNumber: '0987654321',
        contactNumber: '1234567890',
        tasdeeqVerification: false,
        familyMembers: 2,
      ),
      amount: '80K',
      date: DateTime(2021, 2, 1),
      paymentType: "cash", // Use PaymentType.cash for cash transactions
      property: Property(
        imagePath: ['assets/image2.jpg'],
        type: 'Apartment',
        beds: 2,
        baths: 1,
        garden: false,
        living: 1,
        floors: 1,
        carspace: 1,
        description: 'Cozy apartment in a prime location.',
        title: 'Modern Apartment',
        location: 'Suburb',
        price: 2000,
        landlordRef: null,
        rehnaaRating: 4.2,
        tenantRating: 4.5,
        tenantReview: 'Excellent property! Had a wonderful stay.',
      ),
    ),
    RentPayment(
      tenant: Tenant(
        firstName: 'Emily',
        lastName: 'Thompson',
        description: 'Lorem ipsum dolor sit amet',
        rating: 4.7,
        rent: 1600,
        creditPoints: 95,
        propertyDetails: 'Lorem ipsum dolor sit amet',
        cnicNumber: '4321098765',
        contactNumber: '3210987654',
        tasdeeqVerification: false,
        familyMembers: 1,
      ),
      amount: '90K',
      date: DateTime(2021, 3, 1),
      paymentType:
          "jazzcash", // Use PaymentType.bankTransfer for bank transfer transactions
      property: Property(
        imagePath: ['assets/image2.jpg'],
        type: 'House',
        beds: 3,
        baths: 2,
        garden: true,
        living: 1,
        floors: 2,
        carspace: 1,
        description: 'Cozy apartment in a prime location.',
        title: 'Modern Apartment',
        location: 'Suburb',
        price: 2000,
        // landlord: null,
        rehnaaRating: 4.2,
        tenantRating: 4.5,
        tenantReview: 'Excellent property! Had a wonderful stay.',
      ),
    ),
    // Add more RentPayment objects as needed
  ];

  final PageController _pageController = PageController(initialPage: 0);
  int _pageSize = 2; // Number of rent payments to show per page
  String? latestMonth;
  String? previousMonth;

  @override
  void initState() {
    super.initState();
    // _pageController.addListener(_updateLatestMonth);
    // _updateLatestMonth(); // Initialize latestMonth
  }

  // void _updateLatestMonth() {
  //   WidgetsBinding.instance!.addPostFrameCallback((_) {
  //     int currentPage = _pageController.page?.round() ?? 0;
  //     int startIndex = currentPage * _pageSize;
  //     List<RentPayment> visiblePayments =
  //         _rentPayments.skip(startIndex).take(_pageSize).toList();

  //     setState(() {
  //       latestMonth = visiblePayments.isNotEmpty
  //           ? visiblePayments
  //               .map((payment) => payment.month.split(' ')[0])
  //               .reduce((a, b) => a.compareTo(b) > 0 ? a : b)
  //           : null;
  //     });
  //   });
  // }

  Widget _buildRentPaymentCard(RentPayment rentPayment) {
    final Size size = MediaQuery.of(context).size;
    final double whiteBoxHeight = size.height * 0.17;
    final double whiteBoxWidth = size.width * 0.75;

    String iconAsset = 'assets/mainlogo.png'; // Default icon

    // Update the iconAsset based on paymentType
    switch (rentPayment.paymentType) {
      case "cash":
        iconAsset = 'assets/cashicon.png';
        break;
      case "banktransfer":
        iconAsset = 'assets/banktransfer.png';
        break;
      case "easypaisa":
        iconAsset = 'assets/easypaisa.png';
        break;
      case "jazzcash":
        iconAsset = 'assets/jazzcash.png';
        break;
      default:
        iconAsset = 'assets/mainlogo.png';
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.02, vertical: size.height * 0.015),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        child: Container(
          height: whiteBoxHeight,
          width: whiteBoxWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * 0.04),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(size.width * 0.04),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // monthWidget, // Display the month widget
                Row(
                  children: [
                    Image.asset(
                      iconAsset,
                      width: size.width * 0.2,
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${rentPayment.tenant.firstName} ${rentPayment.tenant.lastName}',
                            style: GoogleFonts.montserrat(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff33907c),
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            rentPayment.property.location,
                            style: GoogleFonts.montserrat(
                              fontSize: size.width * 0.03,
                              color: Color(0xff33907c),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              //display in format day/month/year
                              '${rentPayment.date.day}/${rentPayment.date.month}/${rentPayment.date.year}',
                              style: GoogleFonts.montserrat(
                                fontSize: size.width * 0.03,
                                color: Color(0xff33907c),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.07),
                        //add a padding so that the next row is pushed further down
                        Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.02),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              rentPayment.tenant.firstName == 'Withdraw'
                                  ? '-'
                                  : '+',
                              style: GoogleFonts.montserrat(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff33907c),
                              ),
                            ),
                            Text(
                              rentPayment.amount,
                              style: GoogleFonts.montserrat(
                                fontSize: size.width * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff33907c),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  List<Widget> _buildRentPaymentCards(int startIndex) {
    return _rentPayments
        .skip(startIndex)
        .take(_pageSize)
        .map((rentPayment) => _buildRentPaymentCard(rentPayment))
        .toList();
  }

  Widget _buildLatestMonthWidget() {
    final Size size = MediaQuery.of(context).size;

    if (latestMonth != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: size.height * 0.02),
        child: Text(
          latestMonth!,
          style: GoogleFonts.montserrat(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
            color: const Color(0xff33907c),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final int pageCount = (_rentPayments.length / _pageSize).ceil();

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: size.height * 0.03),
          Text('Payment History',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.05,
                  color: const Color(0xff33907c))),
          SizedBox(height: size.height * 0.03),
          Text('All Tenant Property',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.045,
                  color: const Color(0xff33907c))),
          SizedBox(height: size.height * 0.01),
          Center(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),
                Container(
                  width: 300,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border:
                        Border.all(width: 1, color: const Color(0xff33907c)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Search",
                      suffixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                _buildLatestMonthWidget(),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pageCount,
              itemBuilder: (context, index) {
                int startIndex = index * _pageSize;
                List<RentPayment> visiblePayments =
                    _rentPayments.skip(startIndex).take(_pageSize).toList();

                // _updateLatestMonth(); // Call _updateLatestMonth here

                // if (visiblePayments.isNotEmpty) {
                //   latestMonth = DateFormat.MMM().format(
                //     DateFormat('MMMM yyyy').parse(visiblePayments[0].month),
                //   );
                // }

                return ListView(
                  children: _buildRentPaymentCards(startIndex),
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: pageCount,
            effect: WormEffect(
              dotColor: Colors.grey,
              activeDotColor: Color(0xff33907c),
              dotHeight: 10.0,
              dotWidth: 10.0,
              spacing: 8.0,
            ),
          ),
          SizedBox(height: size.height * 0.03),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // pageController.dispose();
    super.dispose();
  }
}
