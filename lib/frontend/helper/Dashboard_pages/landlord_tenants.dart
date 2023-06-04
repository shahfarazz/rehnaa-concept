import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'landlordtenantinfo.dart';

class LandlordTenantsPage extends StatefulWidget {
  final String uid; // UID of the landlord

  const LandlordTenantsPage({required this.uid});

  @override
  _LandlordTenantsPageState createState() => _LandlordTenantsPageState();
}

class _LandlordTenantsPageState extends State<LandlordTenantsPage>
    with AutomaticKeepAliveClientMixin<LandlordTenantsPage> {
  PageController _pageController = PageController(initialPage: 0);
  List<Tenant> _tenants = [];
  int _currentPage = 0;
  int _pageSize = 4; // Number of tenants to show per page
  Completer<void> _loadTenantsCompleter =
      Completer<void>(); // Completer for canceling the Future.delayed() call

  @override
  bool get wantKeepAlive => true;

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

  // Fetch tenant data from Firestore
  Future<void> _loadTenants() async {
    DocumentSnapshot<Map<String, dynamic>> landlordSnapshot =
        await FirebaseFirestore.instance
            .collection('Landlords')
            .doc(widget.uid)
            .get();

    if (landlordSnapshot.exists) {
      Map<String, dynamic>? landlordData = landlordSnapshot.data();
      if (landlordData != null && landlordData['tenantRef'] != null) {
        // Extract tenant references from landlord data
        List<DocumentReference<Map<String, dynamic>>> tenantRefs =
            (landlordData['tenantRef'] as List<dynamic>)
                .cast<DocumentReference<Map<String, dynamic>>>();

        // Fetch tenant documents from Firestore
        List<Future<DocumentSnapshot<Map<String, dynamic>>>> tenantSnapshots =
            tenantRefs.map((ref) => ref.get()).toList();

        List<DocumentSnapshot<Map<String, dynamic>>> tenantsSnapshots =
            await Future.wait(tenantSnapshots);

        List<Tenant> fetchedTenants = [];

        // Convert tenant documents to Tenant objects
        for (var tenantSnapshot in tenantsSnapshots) {
          if (tenantSnapshot.exists) {
            Map<String, dynamic>? tenantData = tenantSnapshot.data();

            if (tenantData != null) {
              fetchedTenants.add(Tenant.fromJson(
                  tenantData)); // Create a TenantModel object from the tenantData
            }
          }
        }

        if (mounted) {
          setState(() {
            _tenants = fetchedTenants;
          });
        }
      }
    }
  }

  // Navigate to a specific page
  void _goToPage(int page) {
    if (mounted) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Build a card widget for a tenant
  Widget _buildTenantCard(Tenant tenant) {
    return GestureDetector(
      onTap: () {
        // Navigate to tenant info page
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

  // Build a list of tenant cards for a given starting index
  List<Widget> _buildTenantCards(int startIndex) {
    return _tenants
        .skip(startIndex)
        .take(_pageSize)
        .map((tenant) => _buildTenantCard(tenant))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the parent's build method is called
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
            count: max(1, pageCount.isFinite ? pageCount.toInt() : 0),
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
