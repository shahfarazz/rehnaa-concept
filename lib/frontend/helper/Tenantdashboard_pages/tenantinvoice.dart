import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:printing/printing.dart';
import 'package:rehnaa/frontend/Screens/faq.dart';
import '../../Screens/Tenant/tenant_dashboard.dart';

class TenantInvoicePage extends StatefulWidget {
  final String tenantName;
  final int rent;
  final double amount;
  final String selectedOption;
  final String id;

  TenantInvoicePage({required this.tenantName, required this.rent, required this.amount, required this.selectedOption, required this.id});

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
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TenantDashboardPage(uid: widget.id,),
            ));
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final pdf = pdfWidgets.Document();

              pdf.addPage(
                pdfWidgets.Page(
                  build: (pdfWidgets.Context context) => pdfWidgets.Center(
                    child: pdfWidgets.Text(
                      "Payment to Rehnaa\n"
                      "Tenant Name: ${widget.tenantName}\n"
                      "Payment Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(paymentDateTime)}\n"
                      "Payment Amount: ${widget.amount}\n"
                      "Amount Due: ${widget.rent - widget.amount}\n"
                      "Request Mode: ${widget.selectedOption}\n"
                      "Payment Made To: Rehnaa",
                      style: pdfWidgets.TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );

              await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice.pdf');
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
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                                          'Please wait for Rehnaa to approve your payment and get back to us in 24 hours.'),
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
          // ],
          // if (showLoading) ...[
          //   Positioned.fill(
          //     child: Container(
          //       color: Colors.black54,
          //       child: Center(
          //         child: CircularProgressIndicator(),
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
}
      // Rest of your code...
  