import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/rentpaymentmodel.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';
import 'package:responsive_framework/responsive_scaled_box.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../Screens/rentpayment_info.dart';
import '../Landlorddashboard_pages/skeleton.dart';

class TenantRentHistoryPage extends StatefulWidget {
  final String uid; // UID of the landlord
  final String callerType;

  const TenantRentHistoryPage(
      {Key? key, required this.uid, required this.callerType})
      : super(key: key);

  @override
  _TenantRentHistoryPageState createState() => _TenantRentHistoryPageState();
}

class _TenantRentHistoryPageState extends State<TenantRentHistoryPage>
    with AutomaticKeepAliveClientMixin<TenantRentHistoryPage> {
  List<RentPayment> _rentPayments = [];
  String firstName = '';
  String lastName = '';
  bool shouldDisplay = false;
  String searchText = ''; // Variable to store the search query
  String invoiceNumber = '';
  String pdfUrl = '';
  Timer? _timer;
  bool isMinus = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tenantRentPayments(); // Call method to load rent payments when the state is initialized
    _startPeriodicFetch(); // Start periodic fetching of new data
  }

  @override
  void dispose() {
    _stopPeriodicFetch(); // Stop periodic fetching when the widget is disposed
    super.dispose();
  }

  // Periodically fetch new data every 5 seconds
  void _startPeriodicFetch() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _tenantRentPayments();
    });
  }

  // Stop periodic fetching
  void _stopPeriodicFetch() {
    _timer?.cancel();
  }

  Future<void> _tenantRentPayments() async {
    // Fetch landlord data from Firestore
    DocumentSnapshot<Map<String, dynamic>> landlordSnapshot =
        await FirebaseFirestore.instance
            .collection(widget.callerType)
            .doc(widget.uid)
            .get();

    Map<String, dynamic>? data = landlordSnapshot.data();
    List<dynamic> rentPaymentRefs = data!['rentpaymentRef'] ?? [];
    if (widget.callerType == "Tenants") {
      firstName = data['firstName'];
      lastName = data['lastName'];
    } else {
      // firstName = data['tenantname'] ?? 'Old doc no tenantname';
      lastName = '';
    }

    if (rentPaymentRefs.isEmpty) {
      setState(() {
        shouldDisplay = true;
      });
      // shouldDisplay = true;
    }

    // print('reached here with landlord data as $data');

    List<RentPayment> newRentPayments = []; // Store the new rent payments

    // Fetch each rent payment document using the document references
    // try {
    // int count = 0;
    for (DocumentReference<Map<String, dynamic>> rentPaymentRef
        in rentPaymentRefs) {
      // count++;

      DocumentSnapshot<Map<String, dynamic>> rentPaymentSnapshot =
          await rentPaymentRef.get();

      Map<String, dynamic>? data = rentPaymentSnapshot.data();
      // if (count == 2) {
      // print('rentpayment ref  $rentPaymentRef');
      //   // print('reached here with rent payments as $data');
      // }
      if (data != null) {
        RentPayment rentPayment = await RentPayment.fromJson(data);
        // print('rentpayment ref is $rentPaymentRef')
        // print('rentpayment found and is ${data}');

        // if(rentPayment.pdfUrl != null){

        // }

        if (rentPayment.isMinus != null) {
          // print('idher rehnaa');
          isMinus = rentPayment.isMinus!;
        } else {
          rentPayment.isMinus =
              data['landlordRef'] != null || data['dealerRef'] != null;
          // print('bhai idher mat ajanan');
          rentPayment.pdfUrl = await FirebaseFirestore.instance
              .collection('invoices')
              .doc(rentPayment.invoiceNumber)
              .get()
              .then((value) => value.data()!['url']);
        }

        // if (widget.callerType == 'Landlords') {
        //   // firstName = data['tenantname'] ?? 'Old doc no tenantname';
        // }

        // print('rentpayment found and is ${rentPayment}');
        // setState(() {
        //   shouldDisplay = true;
        // });

        // print('now adding $count to new rent payments');

        newRentPayments.add(rentPayment); // Add the new rent payment
      }
    }
    // print('count after loop: $count');

    // for (var e in _rentPayments) {
    //   print('e.amount is ${e.amount}');
    // }

    // Check for changes in rent payments
    if (!listEquals(_rentPayments, newRentPayments)) {
      setState(() {
        _rentPayments = newRentPayments; // Update the rent payments list
        shouldDisplay = true;
      });
    }

    // if (kDebugMode) {
    //   print('Rent payments: $_rentPayments');
    // }
    // }
    // catch (e) {
    //   if (mounted) {
    //     setState(() {
    //       shouldDisplay = false;
    //     });
    //   }

    //   if (kDebugMode) {
    //     print('Error fetching rent payments: $e');
    //   }
    // }
  }

  final PageController _pageController = PageController(initialPage: 0);
  final int _pageSize = 2; // Number of rent payments to show per page
  String? latestMonth;
  String? previousMonth;

  Widget _buildRentPaymentCard(RentPayment rentPayment) {
    // print('called with amount ${rentPayment.amount}');
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
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RentPaymentInfoPage(
                rentPayment: rentPayment,
                firstName: widget.callerType == 'Tenants'
                    ? rentPayment.tenantname == 'Old document'
                        ? firstName
                        : rentPayment.tenantname!
                    : rentPayment.tenantname!,
                lastName: lastName,
                receiptUrl: rentPayment.pdfUrl ?? 'No pdf',
              ),
            ),
          );
        },
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
                            widget.callerType == 'Tenants'
                                ? rentPayment.tenantname == 'Old document'
                                    ? '$firstName $lastName'
                                    : rentPayment.tenantname!
                                : rentPayment.tenantname!,
                            style: GoogleFonts.montserrat(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff33907c),
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            rentPayment.property?.location ?? '',
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
                              rentPayment.isMinus! ? '-' : '+',
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
      ),
    );
  }

  List<Widget> _buildRentPaymentCards(int startIndex) {
    // print('called with start index $startIndex');
    final List<RentPayment> filteredRentPayments = _filteredRentPayments();

    // filteredRentPayments.forEach((element) {
    //   // print('element amount: ${element.amount}');
    // });

    return filteredRentPayments
        .skip(startIndex)
        .take(_pageSize)
        .map((rentPayment) => _buildRentPaymentCard(rentPayment))
        .toList();
  }

  List<RentPayment> _filteredRentPayments() {
    // Filter rent payments based on search query

    return _rentPayments
        .where((rentPayment) => '${firstName} ${lastName}'
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();
  }

  // Widget _buildLatestMonthWidget() {
  //   final Size size = MediaQuery.of(context).size;

  //   if (latestMonth != null) {
  //     return Padding(
  //       padding: EdgeInsets.only(bottom: size.height * 0.02),
  //       child: Text(
  //         latestMonth!,
  //         style: GoogleFonts.montserrat(
  //           fontSize: size.width * 0.04,
  //           fontWeight: FontWeight.bold,
  //           color: const Color(0xff33907c),
  //         ),
  //       ),
  //     );
  //   } else {
  //     return Container();
  //   }
  // }

  Widget _rentPaymentSelectorWidget(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (_rentPayments.isEmpty && shouldDisplay) {
      // print('here because rent payments empty is ${_rentPayments.isEmpty}');
      // print('here because should display is $shouldDisplay');
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
                const Icon(
                  Icons.error_outline_outlined,
                  size: 48.0,
                  color: Color(0xff33907c),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'No transactions to show',
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
      );
    } else if (_rentPayments.isEmpty && !shouldDisplay) {
      return const TenantRentSkeleton();
    } else {
      return SizedBox(height: size.height * 0.02);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the mixin's build method is called

    Size size = MediaQuery.of(context).size;
    int pageCount = (_filteredRentPayments().length / _pageSize).ceil();
    // print('length count is ${_filteredRentPayments().length}');

    return ResponsiveScaledBox(
      width: size.width,
      child: Scaffold(
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Payment History',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: const Color(0xff33907c),
                  ),
                ),
                SizedBox(width: size.width * 0.04),
                // _buildRefreshButton(),
              ],
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              'All ${widget.callerType} Rentals',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                // fontStyle: FontStyle.italic,
                fontSize: size.width * 0.045,
                color: const Color(0xff33907c),
              ),
              textAlign: TextAlign.center,
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
                      border: Border.all(
                        width: 1,
                        color: const Color(0xff33907c),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Search",
                        labelStyle: TextStyle(color: Colors.green),
                        suffixIcon: Icon(Icons.search, color: Colors.green),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value; // Update the search query
                        });
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  // _buildLatestMonthWidget(),
                ],
              ),
            ),
            _rentPaymentSelectorWidget(context),
            StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Expanded(
                  // Wrap the Column with Expanded
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          height:
                              size.height * 0.5, // Replace with desired height
                          child: PageView.builder(
                            itemCount: pageCount,
                            controller: _pageController,
                            itemBuilder: (context, index) {
                              // print('index is $index');
                              // print('page count is $pageCount');

                              return SingleChildScrollView(
                                child: Column(
                                  children:
                                      _buildRentPaymentCards(index * _pageSize),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: _filteredRentPayments().isEmpty
                                  ? 1
                                  : (_filteredRentPayments().length / _pageSize)
                                      .ceil(),
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
                        SizedBox(height: size.height * 0.03),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TenantRentSkeleton extends StatelessWidget {
  const TenantRentSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Column(
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
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 1,
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
                      const SizedBox(height: 8.0),
                      Skeleton(
                        width: size.width * 0.7,
                        height: 16.0,
                      ),
                      const SizedBox(height: 16.0),
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
    );
  }
}
