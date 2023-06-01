import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LandlordRentHistoryPage extends StatefulWidget {
  @override
  _LandlordRentHistoryPageState createState() =>
      _LandlordRentHistoryPageState();
}

class _LandlordRentHistoryPageState extends State<LandlordRentHistoryPage> {
  PageController _pageController = PageController(initialPage: 0);
  final List<RentPayment> _rentPayments = [
    RentPayment(
      tenant: Tenant(name: 'John Doe', rating: 4.5, rent: 100000),
      month: 'January 2023',
      amount: '100K',
      date: 'Jan 1, 2023',
    ),
    RentPayment(
      tenant: Tenant(name: 'Jane Smith', rating: 4.2, rent: 80000),
      month: 'December 2022',
      amount: '80K',
      date: 'Dec 1, 2022',
    ),
    RentPayment(
      tenant: Tenant(name: 'Michael Johnson', rating: 4.8, rent: 90000),
      month: 'November 2022',
      amount: '90K',
      date: 'Nov 1, 2022',
    ),
    // Add more RentPayment objects as needed
    RentPayment(
      tenant: Tenant(name: 'Michael Johnson', rating: 4.8, rent: 90000),
      month: 'November 2022',
      amount: '90K',
      date: 'Nov 1, 2022',
    ),
  ];
  int _currentPage = 0;
  int _pageSize = 3; // Number of rent payments to show per page

  Widget _buildRentPaymentCard(RentPayment rentPayment) {
    final Size size = MediaQuery.of(context).size;
    final double whiteBoxHeight = size.height * 0.2;
    final double whiteBoxWidth = size.width * 0.8;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
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
                Row(
                  children: [
                    Image.asset(
                      'assets/mainlogo.png',
                      width: size.width * 0.2,
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            rentPayment.tenant.name,
                            style: GoogleFonts.montserrat(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff33907c),
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            'Dummy property address for now',
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
                              rentPayment.date,
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
                              '+',
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final int pageCount = (_rentPayments.length / _pageSize).ceil();

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: size.height * 0.03),
          Text('Rent History',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.05,
                  color: const Color(0xff33907c))),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pageCount,
              itemBuilder: (context, index) {
                int startIndex = index * _pageSize;
                return SingleChildScrollView(
                  child: Column(
                    children: _buildRentPaymentCards(startIndex),
                  ),
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
}

class RentPayment {
  final Tenant tenant;
  final String month;
  final String amount;
  final String date;

  RentPayment({
    required this.tenant,
    required this.month,
    required this.amount,
    required this.date,
  });
}

class Tenant {
  final String name;
  final double rating;
  final int rent;

  Tenant({required this.name, required this.rating, required this.rent});
}
