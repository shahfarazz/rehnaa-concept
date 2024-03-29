import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/skeleton.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'landlordtenantinfo.dart';

class LandlordTenantsPage extends StatefulWidget {
  final String uid; // UID of the landlord

  const LandlordTenantsPage({super.key, required this.uid});

  @override
  // ignore: library_private_types_in_public_api
  _LandlordTenantsPageState createState() => _LandlordTenantsPageState();
}

class _LandlordTenantsPageState extends State<LandlordTenantsPage>
    with AutomaticKeepAliveClientMixin<LandlordTenantsPage> {
  final PageController _pageController = PageController(initialPage: 0);
  List<Tenant> _tenants = [];
  List<dynamic>? refs = [];
  bool shouldDisplayContent = false;

  // int _currentPage = 0;
  final int _pageSize = 4; // Number of tenants to show per page
  final Completer<void> _loadTenantsCompleter = Completer<void>();

  bool _isLoading = false; // Completer for canceling the Future.delayed() call

  @override
  bool get wantKeepAlive => true;

  bool firstCall = true;

  @override
  void initState() {
    super.initState();
    _loadTenants();
    // _startPeriodicFetching();
  }

  // void _startPeriodicFetching() {
  //   _timer = Timer.periodic(
  //     const Duration(seconds: 30),
  //     (_) => _loadTenants(),
  //   );
  // }

  // void _stopPeriodicFetching() {
  //   _timer?.cancel();
  // }

  Future<void> _refreshUserProfile() async {
    setState(() {
      _tenants = [];
      refs = [];
      shouldDisplayContent = false;
      _isLoading = true;
      _loadTenants();
    });
  }

  @override
  void dispose() {
    _loadTenantsCompleter
        .complete(); // Complete the Completer to cancel the Future.delayed() call
    _pageController.dispose(); // Dispose the PageController
    _tenants.clear();
    super.dispose();
    // _stopPeriodicFetching();
  }

  // Fetch tenant data from Firestore
  Future<void> _loadTenants() async {
    // print('called');

    DocumentSnapshot<Map<String, dynamic>> landlordSnapshot =
        await FirebaseFirestore.instance
            .collection('Landlords')
            .doc(widget.uid)
            .get();

    if (landlordSnapshot.exists) {
      setState(() {
        shouldDisplayContent = true;
      });

      // print('reached here');
      Map<String, dynamic>? landlordData = landlordSnapshot.data();
      if (landlordData != null && landlordData['tenantRef'] != null) {
        // Extract tenant references from landlord data
        List<DocumentReference<Map<String, dynamic>>> tenantRefs =
            (landlordData['tenantRef'] as List<dynamic>)
                .cast<DocumentReference<Map<String, dynamic>>>();

        if (refs!.isEmpty) {
          // print('refs was empty');
          refs = tenantRefs;
        }

        //check if refs and tenantRefs are equal by mapping each element
        // and also checking if each elements data is the same as well
        // if (refs!.every((element) => tenantRefs.contains(element)) &&
        //     !firstCall) {
        //   print('refs was equal');
        //   // refs = tenantRefs;
        //   return;
        // }

        // firstCall = false;

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
              Tenant tenant = Tenant.fromJson(tenantData);

              if (tenant.contractIDs.isNotEmpty) {
                for (var value in tenant.contractIDs) {
                  print('setting state for loop called');
                  if (landlordData['contractIDs'].contains(value)) {
                    try {
                      var contractSnapshot = await FirebaseFirestore.instance
                          .collection('Contracts')
                          .doc(value)
                          .get();

                      if (contractSnapshot.exists) {
                        Map<String, dynamic>? contractData =
                            contractSnapshot.data();
                        if (contractData != null) {
                          print(
                              'reached here setting state now value is $value');
                          tenant.monthlyRent = contractData['monthlyRent'];
                          tenant.contractStartDate =
                              contractData['contractStartDate'].toDate();
                          tenant.contractEndDate =
                              contractData['contractEndDate'].toDate();
                          tenant.propertyAddress =
                              contractData['propertyAddress'];
                        }
                      }
                    } catch (e) {
                      print('Failed to get contract with id $value: $e');
                    }
                  } else {
                    // tenant.monthlyRent = '';
                    // tenant.contractStartDate = null;
                    // tenant.contractEndDate = null;
                    // tenant.propertyAddress = '';
                  }
                }
              } else {
                // tenant.monthlyRent = '';
                // tenant.contractStartDate = null;
                // tenant.contractEndDate = null;
                // tenant.propertyAddress = '';
              }

              print('setting state and adding tenants');

              fetchedTenants.add(tenant);
            }
          }
        }

        if (mounted) {
          print('setting state now');
          setState(() {
            _tenants = fetchedTenants;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
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
            builder: (context) => LandlordTenantInfoPage(
              tenant: tenant,
              uid: widget.uid,
            ),
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
          padding: const EdgeInsets.all(16.0),
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
                      color: const Color(0xff33907c),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
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
                      color: const Color(0xff33907c),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
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
                  tenant.monthlyRent == null || tenant.monthlyRent!.isEmpty
                      ? Text(
                          ' N/A',
                          style: GoogleFonts.montserrat(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff33907c),
                          ),
                        )
                      : Text(
                          ' PKR ' +
                              NumberFormat('#,##0')
                                  .format(double.tryParse(tenant.monthlyRent!)),
                          style: GoogleFonts.montserrat(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff33907c),
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
    super.build(context);
    final Size size = MediaQuery.of(context).size;
    final int pageCount = (_tenants.length / _pageSize).ceil();

    Widget buildTenantsList() {
      print(
          '_tenants length is ${_tenants.isEmpty} & shouldDisplayContent is $shouldDisplayContent');
      if (_tenants.isEmpty && !shouldDisplayContent) {
        return const LandlordTenantSkeleton();
      } else if (_tenants.isEmpty && shouldDisplayContent) {
        return _isLoading
            ? Center(
                child: SpinKitFadingCube(
                  color: Color.fromARGB(255, 30, 197, 83),
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshUserProfile,
                child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 48.0,
                                  color: Color(0xff33907c),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'No tenants to show',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20.0,
                                    // fontWeight: FontWeight.bold,
                                    color: const Color(0xff33907c),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.35),
                      ],
                    )),
              );
      } else {
        return Container(
          height:
              size.height * 0.69, // Adjust this value according to your needs
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
        );
      }
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: size.height * 0.03),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: Text(
              'Tenants',
              style: GoogleFonts.montserrat(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xff33907c),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshUserProfile,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildTenantsList(),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: max(1, pageCount.isFinite ? pageCount.toInt() : 0),
                      effect: const WormEffect(
                        dotColor: Colors.grey,
                        activeDotColor: Color(0xff33907c),
                        dotHeight: 10.0,
                        dotWidth: 10.0,
                        spacing: 8.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // SizedBox(height: size.height * 0.03),
        ],
      ),
    );
  }
}

class LandlordTenantSkeleton extends StatelessWidget {
  const LandlordTenantSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: size.height * 0.03),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: Skeleton(
              width: size.width * 0.4,
              height: 30,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CardSkeleton(height: size.height * 0.3),
          ),
        ],
      ),
    );
  }
}
