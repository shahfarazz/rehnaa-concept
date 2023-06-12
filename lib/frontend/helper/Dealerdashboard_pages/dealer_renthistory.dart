import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/rentpaymentmodel.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Landlorddashboard_pages/skeleton.dart';

class DealerRentHistoryPage extends StatefulWidget {
  final String uid; // UID of the landlord

  const DealerRentHistoryPage({Key? key, required this.uid}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DealerRentHistoryPageState createState() => _DealerRentHistoryPageState();
}

class _DealerRentHistoryPageState extends State<DealerRentHistoryPage>
    with AutomaticKeepAliveClientMixin<DealerRentHistoryPage> {
  List<RentPayment> _rentPayments = [];
  String firstName = '';
  String lastName = '';
  bool shouldDisplay = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tenantRentPayments(); // Call method to load rent payments when the state is initialized
  }

  Future<void> _tenantRentPayments() async {
    try {
      // Fetch landlord data from Firestore
      DocumentSnapshot<Map<String, dynamic>> landlordSnapshot =
          await FirebaseFirestore.instance
              .collection('Tenants')
              .doc(widget.uid)
              .get();

      Map<String, dynamic>? data = landlordSnapshot.data();
      List<dynamic> rentPaymentRefs = data!['rentPaymentRef'] ?? [];
      firstName = data['firstName'];
      lastName = data['lastName'];

      // Fetch each rent payment document using the document references
      for (DocumentReference<Map<String, dynamic>> rentPaymentRef
          in rentPaymentRefs) {
        DocumentSnapshot<Map<String, dynamic>> rentPaymentSnapshot =
            await rentPaymentRef.get();

        Map<String, dynamic>? data = rentPaymentSnapshot.data();
        if (data != null) {
          RentPayment rentPayment = await RentPayment.fromJson(data);
          _rentPayments.add(rentPayment);
          setState(() {
            shouldDisplay = true;
          });
        }
      }

      if (kDebugMode) {
        print('Rent payments: $_rentPayments');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching rent payments: $e');
      }
    }

    setState(() {
      // Update the state to trigger a rebuild with the fetched rent payments
      _rentPayments = _rentPayments;
    });
  }

  final PageController _pageController = PageController(initialPage: 0);
  final int _pageSize = 2; // Number of rent payments to show per page
  String? latestMonth;
  String? previousMonth;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          '$firstName $lastName',
                          style: GoogleFonts.montserrat(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff33907c),
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          rentPayment.property!.location,
                          style: GoogleFonts.montserrat(
                            fontSize: size.width * 0.03,
                            color: const Color(0xff33907c),
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
                              color: const Color(0xff33907c),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.05),
                      //add a padding so that the next row is pushed further down
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.02),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '-',
                            style: GoogleFonts.montserrat(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff33907c),
                            ),
                          ),
                          Text(
                            formatNumber(rentPayment.amount),
                            style: GoogleFonts.montserrat(
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff33907c),
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

  Widget _rentPaymentSelectorWidget(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // if rentPayments is empty and shouldDisplay is true , show center widget
    // if rentpayments is empty and shouldDisplay is true, show Skeleton
    // if rentpayments is not empty and shouldDisplay is true, show Sizedbox

    // print('_rentPayments.isEmpty: ${_rentPayments.isEmpty}');

    if (_rentPayments.isEmpty && shouldDisplay) {
      return Center(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.0,
                  color: const Color(0xff33907c),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Oops! Nothing to show here...',
                  style: GoogleFonts.montserrat(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff33907c),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_rentPayments.isEmpty && !shouldDisplay) {
      return Expanded(
        child: TenantRentSkeleton(),
      );
    } else
      return SizedBox(height: size.height * 0.02);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the mixin's build method is called

    final Size size = MediaQuery.of(context).size;
    final int pageCount = (_rentPayments.length / _pageSize).ceil();

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: size.height * 0.03),
          Text(
            'Payment History',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.05,
              color: const Color(0xff33907c),
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Text(
            'All Tenant Rentals',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.045,
              color: const Color(0xff33907c),
            ),
          ),
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
          _rentPaymentSelectorWidget(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _buildRentPaymentCards(0),
              ),
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: pageCount,
            effect: const WormEffect(
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
    super.dispose();
  }
}

class TenantRentSkeleton extends StatelessWidget {
  const TenantRentSkeleton({Key? key}) : super(key: key);

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
              width: size.width * 0.5,
              height: 30,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                      children: [
                        Skeleton(
                          width: size.width * 0.4,
                          height: 20.0,
                        ),
                        SizedBox(height: 8.0),
                        Skeleton(
                          width: size.width * 0.7,
                          height: 16.0,
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            Skeleton(
                              width: size.width * 0.12,
                              height: 20.0,
                            ),
                            SizedBox(width: size.width * 0.04),
                            Skeleton(
                              width: size.width * 0.6,
                              height: 20.0,
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.05),
                        Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.02),
                          child: Row(
                            children: [
                              Skeleton(
                                width: size.width * 0.04,
                                height: 20.0,
                              ),
                              SizedBox(width: size.width * 0.02),
                              Skeleton(
                                width: size.width * 0.2,
                                height: 20.0,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Skeleton(
                              width: size.width * 0.06,
                              height: 20.0,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Skeleton(
                              width: size.width * 0.2,
                              height: 20.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}