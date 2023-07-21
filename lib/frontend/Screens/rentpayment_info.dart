import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/rentpaymentmodel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../helper/Landlorddashboard_pages/landlord_advance_rent.dart';

class RentPaymentInfoPage extends StatelessWidget {
  final RentPayment rentPayment;
  final String firstName;
  final String lastName;
  final String receiptUrl;

  const RentPaymentInfoPage({
    Key? key,
    required this.rentPayment,
    required this.firstName,
    required this.lastName,
    required this.receiptUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Rent Payment',
      //     style: GoogleFonts.montserrat(
      //       fontWeight: FontWeight.bold,
      //       fontSize: 24.0,
      //       color: const Color(0xff33907c),
      //     ),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      //   iconTheme: IconThemeData(
      //     color: const Color(0xff33907c),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 65.0,
                  left: 10.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
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
                    const SizedBox(height: 20.0),
                    Text(
                      ' $firstName $lastName',
                      style: GoogleFonts.montserrat(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff33907c),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Center(
                      child: Text(
                        rentPayment.property?.title ??
                            (rentPayment.isMinus ?? false
                                ? 'Withdrawal'
                                : 'Payment'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 16.0,
                          color: const Color(0xff33907c),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.grey[200],
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Center(
                        child: WhiteBox(
                          icon: _getPaymentIcon(rentPayment.paymentType),
                          iconColor: const Color(0xff33907c),
                          label: 'Payment Type',
                          value: firstName == 'Rehnaa.pk'
                              ? 'N/A'
                              : rentPayment.paymentType,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: WhiteBox(
                          icon: Icons.calendar_today,
                          iconColor: const Color(0xff33907c),
                          label: 'Payment Date',
                          value:
                              '${rentPayment.date.day}/${rentPayment.date.month}/${rentPayment.date.year}',
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: WhiteBox(
                          icon: Icons.payments_outlined,
                          iconColor: const Color(0xff33907c),
                          label: 'Payment Amount',
                          value: rentPayment.amount.toString(),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // make a box where pdf will be shown
                      firstName == 'Rehnaa.pk'
                          ? Container()
                          : GestureDetector(
                              onTap: () {
                                // print('receiptUrl: $receiptUrl');
                                if (receiptUrl != 'No pdf') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFScreen(
                                        path: receiptUrl,
                                        displayAppBar: true,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Center(
                                child: WhiteBox(
                                  icon: Icons.picture_as_pdf,
                                  iconColor: const Color(0xff33907c),
                                  label: 'Payment Receipt',
                                  value: 'Click to view',
                                ),
                              ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String paymentType) {
    switch (paymentType) {
      case "cash":
        return Icons.money;
      case "banktransfer":
        return Icons.account_balance;
      case "easypaisa":
        return Icons.phone_android;
      case "jazzcash":
        return Icons.phone_android;
      default:
        return Icons.money;
    }
  }
}

class PDFScreen extends StatefulWidget {
  final String? path;
  bool displayAppBar;

  PDFScreen({Key? key, this.path, required this.displayAppBar})
      : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  String localPath = '';

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    // Download the PDF from Firebase and save it to the local file system
    var file;
    try {
      final pdfUrl = widget.path;
      final pdfRef = FirebaseStorage.instance.refFromURL(pdfUrl!);
      final bytes = await pdfRef.getData();
      final dir = await getApplicationDocumentsDirectory();
      file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(bytes!);
    } catch (e) {
      print('error was $e');
      print('pdf url was ${widget.path}');
    }

    // Update the local path state
    if (mounted) {
      setState(() {
        localPath = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.displayAppBar
          ? _buildAppBar(MediaQuery.of(context).size, context)
          : null,
      body: localPath.isEmpty
          ? Center(
              child: const SpinKitFadingCube(
                color: Color.fromARGB(255, 30, 197, 83),
              ),
            )
          : SfPdfViewer.file(
              File(localPath),
              scrollDirection: PdfScrollDirection.vertical,
              canShowScrollHead: false,
              canShowScrollStatus: false,
              enableTextSelection: false,
              pageLayoutMode: PdfPageLayoutMode.single,
            ),
    );
  }
}

PreferredSizeWidget _buildAppBar(Size size, context) {
  return AppBar(
    toolbarHeight: 70,
    title: Padding(
      padding: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
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
          ),
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
            Color(0xFF0FA697),
            Color(0xFF45BF7A),
            Color(0xFF0DF205),
          ],
        ),
      ),
    ),
  );
}

class WhiteBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const WhiteBox({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.0,
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
                const SizedBox(height: 10.0),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
