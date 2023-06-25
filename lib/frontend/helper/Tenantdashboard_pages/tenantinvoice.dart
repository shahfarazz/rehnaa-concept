import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:printing/printing.dart';
import 'package:rehnaa/frontend/Screens/faq.dart';
import '../../../backend/models/landlordmodel.dart';
import '../../Screens/Tenant/tenant_dashboard.dart';
import 'package:flutter/services.dart';

class TenantInvoicePage extends StatefulWidget {
  final String tenantName;
  final int rent;
  final double amount;
  final String selectedOption;
  final String id;
  final Landlord landlord;

  TenantInvoicePage({
    required this.tenantName,
    required this.rent,
    required this.amount,
    required this.selectedOption,
    required this.id,
    required this.landlord,
  });

  @override
  _TenantInvoicePageState createState() => _TenantInvoicePageState();
}

class _TenantInvoicePageState extends State<TenantInvoicePage> {
  bool showInvoice = false;
  DateTime paymentDateTime = DateTime.now();
  int paymentAmount = 0;
  int amountDue = 0;
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff0FA697),
                Color(0xff45BF7A),
                Color(0xff0DF205),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle the navigation to the desired page here
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TenantDashboardPage(
                  uid: widget.id,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final pdf = pdfWidgets.Document();

              final imageBytes = (await rootBundle.load('assets/mainlogo.png'))
                  .buffer
                  .asUint8List();
              final image = pdfWidgets.MemoryImage(imageBytes);

              pdf.addPage(
                pdfWidgets.Page(
                  build: (pdfWidgets.Context context) => pdfWidgets.Column(
                    crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                    children: [
                      pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.Row(
                            children: [
                              pdfWidgets.Image(
                                image,
                                width: 80,
                                height: 80,
                                fit: pdfWidgets.BoxFit.contain,
                              ),
                              pdfWidgets.Padding(
                                padding: pdfWidgets.EdgeInsets.only(left: 6.0),
                                child: pdfWidgets.Text(
                                  'REHNAA.PK',
                                  style: pdfWidgets.TextStyle(
                                    fontSize: 20,
                                    color: PdfColors.green,
                                    fontWeight: pdfWidgets.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          pdfWidgets.Column(
                            children: [
                              pdfWidgets.Padding(
                                padding: pdfWidgets.EdgeInsets.only(
                                    top: 100.0, left: 50),
                                child: pdfWidgets.Text(
                                  'INVOICE',
                                  style: pdfWidgets.TextStyle(
                                    fontSize: 60,
                                    color: PdfColors
                                        .green500, // 50% opaque green color
                                    fontWeight: pdfWidgets.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          //   pdfWidgets.Text(
                          //   'INVOICE',
                          //   style: pdfWidgets.TextStyle(
                          //     fontSize: 60,
                          //     color: PdfColors.green500,  // 50% opaque green color
                          //     fontWeight: pdfWidgets.FontWeight.bold,
                          //   ),
                          // ),
                        ],
                      ),
                      pdfWidgets.Padding(
                        padding:
                            pdfWidgets.EdgeInsets.only(left: 300.0, top: 40),
                        child: pdfWidgets.Text(
                          'Invoice Date: ${DateFormat('MM/dd/yyyy').format(paymentDateTime)}\nInvoice Time: ${DateFormat('hh:mm   a').format(paymentDateTime)}\n\nEmail: \nPhone:',
                          style: pdfWidgets.TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      pdfWidgets.Padding(
                        padding: pdfWidgets.EdgeInsets.only(top: -80),
                        child: pdfWidgets.Text(
                          'BILLING TO:',
                          style: pdfWidgets.TextStyle(
                            fontSize: 20,
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        ),
                      ),
                      pdfWidgets.Padding(
                        padding: pdfWidgets.EdgeInsets.only(top: -50),
                        child: pdfWidgets.Text(
                          '${widget.tenantName}',
                          style: pdfWidgets.TextStyle(
                              fontSize: 25,
                              fontWeight: pdfWidgets.FontWeight.bold),
                        ),
                      ),
                      pdfWidgets.Padding(
                        padding: pdfWidgets.EdgeInsets.only(bottom: 20.0),
                        child: pdfWidgets.Text(
                          'Cnic: \nAddress:',
                          style: pdfWidgets.TextStyle(fontSize: 15),
                        ),
                      ),

                      pdfWidgets.Padding(
                        padding: pdfWidgets.EdgeInsets.only(bottom: 20.0),
                        child: pdfWidgets.Text(
                          'Property Rented Address:',
                          style: pdfWidgets.TextStyle(
                              fontSize: 15,
                              fontWeight: pdfWidgets.FontWeight.bold),
                        ),
                      ),

                      pdfWidgets.Padding(
                        padding: pdfWidgets.EdgeInsets.only(bottom: 20.0),
                        child: pdfWidgets.Text(
                          'Mode of Payment : ${widget.selectedOption}',
                          style: pdfWidgets.TextStyle(
                              fontSize: 15,
                              fontWeight: pdfWidgets.FontWeight.bold),
                        ),
                      ),
                      // pdfWidgets.Padding(
                      //   padding: pdfWidgets.EdgeInsets.only(top: 20.0),
                      //   child: pdfWidgets.Center(
                      //     child: pdfWidgets.Text(
                      //       'Payment to Rehnaa',
                      //       style: pdfWidgets.TextStyle(fontSize: 20),
                      //     ),
                      //   ),
                      // ),
                      // pdfWidgets.Padding(
                      //   padding: pdfWidgets.EdgeInsets.only(top: 20.0),
                      //   child: pdfWidgets.Text(
                      //     'Tenant Name: ${widget.tenantName}',
                      //     style: pdfWidgets.TextStyle(
                      //       fontSize: 20,
                      //       fontWeight: pdfWidgets.FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      // pdfWidgets.Padding(
                      //   padding: pdfWidgets.EdgeInsets.only(top: 10.0),
                      //   child: pdfWidgets.Text(
                      //     'Invoice Date: ${DateFormat('MM/dd/yyyy').format(DateTime.now())}',
                      //     style: pdfWidgets.TextStyle(
                      //       fontSize: 20,
                      //       color: PdfColors.black,
                      //     ),
                      //   ),
                      // ),
                      // pdfWidgets.Padding(
                      //   padding: pdfWidgets.EdgeInsets.only(top: 10.0),
                      //   child: pdfWidgets.Text(
                      //     'Payment Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(paymentDateTime)}',
                      //     style: pdfWidgets.TextStyle(fontSize: 20),
                      //   ),
                      // ),
                      pdfWidgets.Center(
                        child: pdfWidgets.Container(
                          width: 500,
                          height: 55,
                          decoration: pdfWidgets.BoxDecoration(
                            // borderRadius: 10,
                            color: PdfColors.green400,
                          ),
                          child: pdfWidgets.Padding(
                            padding: const pdfWidgets.EdgeInsets.all(10),
                            child: pdfWidgets.Column(
                              crossAxisAlignment:
                                  pdfWidgets.CrossAxisAlignment.start,
                              children: [
                                // pdfWidgets.Text('Card Title', style: pdfWidgets.TextStyle(fontSize: 20, fontWeight: pdfWidgets.FontWeight.bold, )),
                                pdfWidgets.SizedBox(height: 10),
                                pdfWidgets.Row(
                                  mainAxisAlignment:
                                      pdfWidgets.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pdfWidgets.Text('Landlord Name',
                                        style: pdfWidgets.TextStyle(
                                          fontSize: 20,
                                          fontWeight:
                                              pdfWidgets.FontWeight.bold,
                                          color: PdfColors.white,
                                        )),
                                    pdfWidgets.Text('Month',
                                        style: pdfWidgets.TextStyle(
                                          fontSize: 20,
                                          fontWeight:
                                              pdfWidgets.FontWeight.bold,
                                          color: PdfColors.white,
                                        )),
                                    pdfWidgets.Text('Amount',
                                        style: pdfWidgets.TextStyle(
                                          fontSize: 20,
                                          fontWeight:
                                              pdfWidgets.FontWeight.bold,
                                          color: PdfColors.white,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      pdfWidgets.SizedBox(height: 20),

                      pdfWidgets.Center(
                        child: pdfWidgets.Container(
                          width: 500,
                          height: 70,
                          decoration: pdfWidgets.BoxDecoration(
                            // borderRadius: 10,
                            color: PdfColors.grey200,
                          ),
                          child: pdfWidgets.Padding(
                            padding: const pdfWidgets.EdgeInsets.all(10),
                            child: pdfWidgets.Column(
                              crossAxisAlignment:
                                  pdfWidgets.CrossAxisAlignment.start,
                              children: [
                                // pdfWidgets.Text('Card Title', style: pdfWidgets.TextStyle(fontSize: 20, fontWeight: pdfWidgets.FontWeight.bold, )),
                                pdfWidgets.SizedBox(height: 15),
                                pdfWidgets.Row(
                                  mainAxisAlignment:
                                      pdfWidgets.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pdfWidgets.Text(
                                        '${widget.landlord.firstName} ${widget.landlord.lastName}',
                                        style: pdfWidgets.TextStyle(
                                          fontSize: 20,
                                          color: PdfColors.black,
                                        )),
                                    pdfWidgets.Text(
                                        '${DateFormat('MMMM').format(paymentDateTime)}',
                                        style: pdfWidgets.TextStyle(
                                          fontSize: 20,
                                          color: PdfColors.black,
                                        )),
                                    pdfWidgets.Text('${widget.amount}',
                                        style: pdfWidgets.TextStyle(
                                          fontSize: 20,
                                          color: PdfColors.black,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      pdfWidgets.SizedBox(height: 110),

                      pdfWidgets.Align(
                        alignment: pdfWidgets.Alignment.bottomRight,
                        child: pdfWidgets.Column(
                          crossAxisAlignment: pdfWidgets.CrossAxisAlignment.end,
                          children: <pdfWidgets.Widget>[
                            pdfWidgets.Text('Signature'),
                            pdfWidgets.SizedBox(height: 20),
                            pdfWidgets.Container(
                              height: 1.0,
                              width: 100.0,
                              color: PdfColors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

              await Printing.sharePdf(
                bytes: await pdf.save(),
                filename: 'invoice.pdf',
              );
            },
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              body: Card(
                margin: EdgeInsets.all(16.0),
                child: ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    Text(
                      'Payment to Rehnaa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tenant Name: ${widget.tenantName}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Payment Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(paymentDateTime)}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Payment Amount: ${widget.amount}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Amount Due: ${widget.rent - widget.amount}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Request Mode: ${widget.selectedOption}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Payment Made To: Rehnaa',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 60),
                    Text(
                      'Your request has been made',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Payment Approval'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text(
                                      'Please wait for Rehnaa to approve your payment and get back to us in 24 hours.',
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff0FA697),
                              const Color(0xff45BF7A),
                              const Color(0xff0DF205),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                          ),
                          child: const Text(
                            'Check Status',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
