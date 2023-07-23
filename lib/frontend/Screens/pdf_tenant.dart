import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pdfWidget;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:rehnaa/backend/services/helperfunctions.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'Tenant/tenant_dashboard.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PDFEditorTenantPage extends StatefulWidget {
  // final String tenantName;
  // final String landlordName;
  // String? landlordAddress;
  // String? tenantAddress;
  // final double balance;
  // final double amount;
  // final String paymentMode;
  // final String uid;
  // final String invoiceNumber;
  // final String cnic;

  // PDFEditorTenantPage({
  //   Key? key,
  //   // required this.tenantName,
  //   // required this.balance,
  //   // required this.landlordName,
  //   // this.landlordAddress,
  //   // this.tenantAddress,
  //   // required this.amount,
  //   // required this.paymentMode,
  //   // required this.uid,
  //   // required this.invoiceNumber,
  //   // required this.cnic,
  // }) : super(key: key);
  @override
  _PDFEditorTenantPageState createState() => _PDFEditorTenantPageState();
}

class _PDFEditorTenantPageState extends State<PDFEditorTenantPage> {
  String? path;

  @override
  void initState() {
    super.initState();
    // createPdf().then((savedPath) {
    //   setState(() {
    //     path = savedPath.path;
    //   });
    // });
  }

  Future<File> getFileFromAssets(String asset) async {
    final byteData = await rootBundle.load(asset);

    final buffer = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp.pdf');

    await tempFile.writeAsBytes(buffer);

    return tempFile;
  }

  String getOrdinal(int value) {
    if (value >= 11 && value <= 13) {
      return "${value}th";
    }
    switch (value % 10) {
      case 1:
        return "${value}st";
      case 2:
        return "${value}nd";
      case 3:
        return "${value}rd";
      default:
        return "${value}th";
    }
  }

  Future<File> createPdf(
    String tenantName,
    String landlordName,
    String? landlordAddress,
    String? tenantAddress,
    double balance,
    double amount,
    String paymentMode,
    String uid,
    String invoiceNumber,
    String cnic,
  ) async {
    //Load the existing document.
    try {
      final File file = await getFileFromAssets('assets/template2.pdf');
      final document = PdfDocument(inputBytes: file.readAsBytesSync());

      //Get the first page.
      final PdfPage page = document.pages[0];

      //Create a PDF graphics for the page.
      final PdfGraphics graphics = page.graphics;

      //Set the standard font.

      final fontData =
          await rootBundle.load('assets/fonts/Montserrat-Regular.ttf');
      final PdfFont font_main = PdfTrueTypeFont(
          fontData.buffer.asByteData().buffer.asUint8List(), 22);
      final PdfFont font = PdfTrueTypeFont(
          fontData.buffer.asByteData().buffer.asUint8List(), 14);

      final PdfFont font_small = PdfTrueTypeFont(
          fontData.buffer.asByteData().buffer.asUint8List(), 12);

      final PdfFont font_medium = PdfTrueTypeFont(
          fontData.buffer.asByteData().buffer.asUint8List(), 18);

      //Billing To
      graphics.drawString(
          tenantName.length >= 20 ? tenantName.substring(0, 20) : tenantName,
          font_main,
          brush: PdfBrushes.black,
          pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          bounds: Rect.fromLTWH(
              58, 174, page.getClientSize().width, page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      //CNIC number
      String formatCNIC(String cnic) {
        if (cnic.length != 13) {
          //snackbar error
          // Fluttertoast.showToast(msg: 'Invalid CNIC');
          return cnic; // Return the original CNIC if the length is not as expected
        }

        String part1 = cnic.substring(0, 5);
        String part2 = cnic.substring(5, 12);
        String part3 = cnic.substring(12);

        return '$part1-$part2-$part3';
      }

      var formattedCNIC = decryptString(cnic);

      try {
        formattedCNIC = formatCNIC(decryptString(cnic));
      } catch (e) {}

      graphics.drawString(formattedCNIC, font_small,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(100, 205.5, page.getClientSize().width,
              page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      //Address
      graphics.drawString(decryptString(landlordAddress!) ?? '', font_small,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(
              60, 220, page.getClientSize().width, page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      //Invoice number
      graphics.drawString(invoiceNumber, font,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(442, 162, page.getClientSize().width,
              page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      var date = DateTime.now();
      String day = getOrdinal(date.day);
      var formatter = DateFormat('MMMM y');
      String formatted = '$day ${formatter.format(date)}';

      //Invoice date
      graphics.drawString(formatted, font,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(445, 183, page.getClientSize().width,
              page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      // Due date of invoice

      //due date should be 30th of current month
      var dueDate = DateTime(date.year, date.month, 30);
      String dueDay = getOrdinal(dueDate.day);
      var dueFormatter = DateFormat('MMMM y');
      String dueFormatted = '$dueDay ${dueFormatter.format(dueDate)}';

      graphics.drawString(dueFormatted, font,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(445, 205, page.getClientSize().width,
              page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      //Property Rented Address
      //check if address is above 25
      graphics.drawString(
          tenantAddress!.length >= 25
              ? tenantAddress.substring(0, 25)
              : tenantAddress,
          font_small,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(250, 295, page.getClientSize().width,
              page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      //Mode of payment
      graphics.drawString(paymentMode, font_small,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(200, 315, page.getClientSize().width,
              page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      //landlord Name
      graphics.drawString(
          landlordName.length >= 16
              ? landlordName.substring(0, 16)
              : landlordName,
          font_main,
          brush: PdfBrushes.black,
          // pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          bounds: Rect.fromLTWH(
              70, 440, page.getClientSize().width, page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      var date2 = DateTime.now();
      var monthFormatter = DateFormat('MMMM');
      var yearFormatter = DateFormat('y');

      String formattedMonth = monthFormatter.format(date2);
      String formattedYear = yearFormatter.format(date2);

      String formatted2 = "$formattedMonth' $formattedYear";

      //Tenant Month+Year
      graphics.drawString(formatted2, font_medium,
          brush: PdfBrushes.black,
          // pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          bounds: Rect.fromLTWH(250, 440, page.getClientSize().width,
              page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      //Tenant Amount
      graphics.drawString("PKR ${amount}", font_medium,
          brush: PdfBrushes.black,
          // pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          bounds: Rect.fromLTWH(390, 440, page.getClientSize().width,
              page.getClientSize().height),
          format: PdfStringFormat(alignment: PdfTextAlignment.left));

      //Save the document.
      final List<int> bytes = await document.save();

      //Dispose the document.
      document.dispose();

      //Get the external storage directory
      final Directory directory = await getApplicationDocumentsDirectory();

      //Get the directory path
      final String path = directory.path;

      //Create an empty file to write PDF data.
      final File outputFile = File('$path/Output.pdf');

      //Write PDF data.
      await outputFile.writeAsBytes(bytes, flush: true);

      //Open the PDF document in mobile
      // OpenFile.open('$path/Output.pdf');

      // upload the pdf to firebase storage
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("invoice_${invoiceNumber}.pdf");
      UploadTask uploadTask = ref.putFile(outputFile);
      uploadTask.then((res) {
        res.ref.getDownloadURL().then((value) {
          print("Uploaded File URL: $value");
          FirebaseFirestore.instance
              .collection('invoices')
              .doc(invoiceNumber)
              .set({
            // 'invoiceNumber': invoiceNumber,
            // 'landlordName': landlordName,
            // 'landlordAddress': landlordAddress,
            // 'tenantName': tenantName,
            // 'tenantAddress': tenantAddress,
            // 'amount': amount,
            // 'paymentMode': paymentMode,
            // 'date': formatted,
            'url': value,
          });
        });
      });

      return outputFile;
    } catch (e) {
      print('error in pdf is $e');
      // return File('');
      rethrow;
    }
  }

  //funcion which takes the created pdf as input and saves it to the device
  Future<File> savePdf(File file) async {
    print("savePdf called");

    //Get the external storage directory
    final Directory directory = await getApplicationDocumentsDirectory();
    print("Directory obtained: $directory");

    //Get the directory path
    final String path = directory.path;
    print("Path: $path");

    //Create an empty file to write PDF data.
    final File outputFile = File('$path/Output.pdf');
    print("Output file: $outputFile");

    //Write PDF data.
    await outputFile.writeAsBytes(file.readAsBytesSync(), flush: true);
    print("PDF data written to output file");

    //Open the PDF document in mobile
    // OpenFile.open('$path/Output.pdf');
    return outputFile;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // return Scaffold(
    //   appBar: _buildAppBar(size, context),
    //   body: Center(
    //     child: FutureBuilder<File>(
    //       future: (path == null) ? createPdf() : Future.value(File(path!)),
    //       builder: (context, snapshot) {
    //         if (snapshot.connectionState == ConnectionState.done &&
    //             snapshot.hasData) {
    //           final file = snapshot.data!;
    //           return Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Text(
    //                 'Generated Invoice:',
    //                 style: TextStyle(
    //                   fontSize: 20,
    //                   fontWeight: FontWeight.bold,
    //                   color: Colors.green,
    //                   fontFamily: GoogleFonts.montserrat().fontFamily,
    //                 ),
    //               ),
    //               SizedBox(height: size.height * 0.03),
    //               Container(
    //                 height: 300, // Adjust the height and width as needed
    //                 width: 300,
    //                 child: ClipRRect(
    //                   borderRadius: BorderRadius.circular(20.0),
    //                   child: ColorFiltered(
    //                     colorFilter: ColorFilter.mode(
    //                       Colors.black.withOpacity(
    //                           0.7), // Adjust the color and opacity as needed
    //                       BlendMode.srcOver,
    //                     ),
    //                     child: SfPdfViewer.file(
    //                       file,
    //                       canShowScrollHead: false,
    //                       canShowScrollStatus: false,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               Align(
    //                 alignment: Alignment.bottomCenter,
    //                 child: Padding(
    //                   padding: EdgeInsets.all(16.0),
    //                   child: Ink(
    //                     decoration: BoxDecoration(
    //                       gradient: LinearGradient(
    //                         colors: [
    //                           const Color(0xff0FA697),
    //                           const Color(0xff45BF7A),
    //                           const Color(0xff0DF205),
    //                         ],
    //                       ),
    //                       borderRadius: BorderRadius.circular(30.0),
    //                     ),
    //                     child: InkWell(
    //                       borderRadius: BorderRadius.circular(30.0),
    //                       onTap: () {
    //                         OpenFile.open(file.path);
    //                       },
    //                       child: Padding(
    //                         padding: EdgeInsets.symmetric(
    //                             vertical: 10.0, horizontal: 20.0),
    //                         child: Text('View PDF',
    //                             style: TextStyle(color: Colors.white)),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           );
    //         } else if (snapshot.connectionState == ConnectionState.waiting) {
    //           return CircularProgressIndicator();
    //         } else {
    //           return Text('Error: ${snapshot.error}');
    //         }
    //       },
    //     ),
    //   ),
    // );
    return Container();
  }

//   PreferredSizeWidget _buildAppBar(Size size, context) {
//     return AppBar(
//       toolbarHeight: 70,
//       leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => TenantDashboardPage(
//                         uid: uid,
//                       )),
//             );
//           }),
//       title: Padding(
//         padding: EdgeInsets.only(
//           right:
//               MediaQuery.of(context).size.width * 0.14, // 55% of the page width
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Stack(
//               children: [
//                 ClipPath(
//                   clipper: HexagonClipper(),
//                   child: Transform.scale(
//                     scale: 0.87,
//                     child: Container(
//                       color: Colors.white,
//                       width: 60,
//                       height: 60,
//                     ),
//                   ),
//                 ),
//                 ClipPath(
//                   clipper: HexagonClipper(),
//                   child: Image.asset(
//                     'assets/mainlogo.png',
//                     width: 60,
//                     height: 60,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ],
//             ),
//             // const SizedBox(width: 8),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         Padding(
//           padding: const EdgeInsets.only(top: 15.0),
//           child: Stack(
//             children: [],
//           ),
//         ),
//       ],
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xff0FA697),
//               Color(0xff45BF7A),
//               Color(0xff0DF205),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
}
