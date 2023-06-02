import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'landlordtenantinfo.dart';

class LandlordTenantsPage extends StatefulWidget {
  @override
  _LandlordTenantsPageState createState() => _LandlordTenantsPageState();
}

class _LandlordTenantsPageState extends State<LandlordTenantsPage> {
  PageController _pageController = PageController(initialPage: 0);
  List<Tenant> _tenants = [];
  int _currentPage = 0;
  int _pageSize = 4; // Number of tenants to show per page
  Completer<void> _loadTenantsCompleter =
      Completer<void>(); // Completer for canceling the Future.delayed() call

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  @override
  void dispose() {
    _loadTenantsCompleter
        .complete(); // Complete the Completer to cancel the Future.delayed() call
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  Future<void> _loadTenants() async {
    // Simulate fetching tenants from Firebase
    await Future.delayed(Duration(seconds: 1));

    // Replace this with your Firebase logic to fetch tenants
    List<Tenant> fetchedTenants = [
      Tenant(
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
        // landlord: Landlord(balance: 10000, firstName: 'John', lastName: 'Doe'),
      ),
      Tenant(
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
      Tenant(
        firstName: 'Michael',
        lastName: 'Johnson',
        description: 'Lorem ipsum dolor sit amet',
        rating: 4.8,
        rent: 1800,
        creditPoints: 90,
        propertyDetails: 'Lorem ipsum dolor sit amet',
        cnicNumber: '5678901234',
        contactNumber: '4567890123',
        tasdeeqVerification: true,
        familyMembers: 2,
      ),
      Tenant(
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
    ];

    if (mounted) {
      setState(() {
        _tenants = fetchedTenants;
      });
    }
  }

  void _goToPage(int page) {
    if (mounted) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTenantCard(Tenant tenant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LandlordTenantInfoPage(tenant: tenant),
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
          padding: EdgeInsets.all(16.0),
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
                    '${tenant.firstName} ${tenant.lastName}',
                    style: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff33907c),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
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
                    ' ${tenant.rating}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff33907c),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Text(
                    'Monthly Rent:',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    ' ${tenant.rent}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff33907c),
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

  List<Widget> _buildTenantCards(int startIndex) {
    return _tenants
        .skip(startIndex)
        .take(_pageSize)
        .map((tenant) => _buildTenantCard(tenant))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final int pageCount = (_tenants.length / _pageSize).ceil();

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: size.height * 0.03),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: Text(
              'Tenants',
              style: GoogleFonts.montserrat(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Color(0xff33907c),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pageCount,
              itemBuilder: (context, index) {
                int startIndex = index * _pageSize;
                return Column(
                  children: _buildTenantCards(startIndex),
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: pageCount.isFinite && pageCount > 0 ? pageCount.toInt() : 0,
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
