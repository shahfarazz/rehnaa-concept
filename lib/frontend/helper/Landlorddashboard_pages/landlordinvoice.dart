import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class LandlordInvoicePage extends StatefulWidget {
  final String tenantName;
  final int rent;

  LandlordInvoicePage({required this.tenantName, required this.rent});

  @override
  _LandlordInvoicePageState createState() => _LandlordInvoicePageState();
}

class _LandlordInvoicePageState extends State<LandlordInvoicePage> {
  bool showInvoice = false;
  DateTime paymentDateTime = DateTime.now();
  int paymentAmount = 0;
  int amountDue = 0;
  bool showLoading = false;

  void submitPayment(int amount) {
    setState(() {
      showLoading = true;
    });

    // Simulating a delay of 2 seconds for payment processing
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        showInvoice = true;
        paymentAmount = amount;
        amountDue = widget.rent - paymentAmount;
        showLoading = false;
      });
    });
  }

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
      ),
      body: Stack(
        children: [
          if (!showInvoice) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Enter Amount'),
                              content: TextFormField(
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  paymentAmount = int.tryParse(value) ?? 0;
                                },
                              ),
                              actions: [
                                Container(
                                  width: 200,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
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
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (paymentAmount > 0) {
                                        submitPayment(paymentAmount);
                                        Navigator.pop(context);
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Invalid Amount'),
                                              content: Text('Payment amount must be greater than zero.'),
                                              actions: [
                                                Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
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
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('OK'),
                                                    style: ButtonStyle(
                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                      ),
                                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff0FA697)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Text('Submit'),
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff0FA697)),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Make Payment'),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xff0FA697)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (showInvoice) ...[
  Positioned.fill(
    child: Scaffold(
      body: Card(
        margin: EdgeInsets.all(16.0),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Text(
              'Payment to Rehnaa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              'Payment Amount: ${paymentAmount}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Amount Due: ${amountDue}',
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

            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Payment Approval'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Please wait for the Rehnaa to approve your payment and get back to us in 24 hours.'),
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
              child: Text(
                'Check Payment Status',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    ),
  ),
],

if (showLoading) ...[
  Positioned.fill(
    child: Container(
      color: Colors.black54,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  ),
],

        ],
      ),
    );
  }
}
