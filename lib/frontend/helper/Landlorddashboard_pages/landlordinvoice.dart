import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class LandlordInvoicePage extends StatefulWidget {
  final String landlordName;
  final double balance;
  final double amount;
  final String transactionMode;

  LandlordInvoicePage({required this.landlordName, required this.balance , required this.amount , required this.transactionMode});

  @override
  _LandlordInvoicePageState createState() => _LandlordInvoicePageState();
}

class _LandlordInvoicePageState extends State<LandlordInvoicePage> {
  bool showInvoice = false;
  DateTime paymentDateTime = DateTime.now();
  double paymentAmount = 0;
  double amountDue = 0;
  bool showLoading = false;

  // void submitPayment(double amount) {
  //   setState(() {
  //     showLoading = true;
  //   });

  //   // Simulating a delay of 2 seconds for payment processing
  //   Future.delayed(Duration(seconds: 1), () {
  //     setState(() {
  //       showInvoice = true;
  //       paymentAmount = amount;
  //       amountDue = widget.balance - paymentAmount;
  //       showLoading = false;
  //     });
  //   });
  // }

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
          // if (!showInvoice) ...[
          //   Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Container(
          //           width: 200,
          //           height: 50,
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(20),
          //             gradient: LinearGradient(
          //               begin: Alignment.topLeft,
          //               end: Alignment.bottomRight,
          //               colors: [
          //                 Color(0xff0FA697),
          //                 Color(0xff45BF7A),
          //                 Color(0xff0DF205),
          //               ],
          //             ),
          //           ),
                    // child: ElevatedButton(
                    //   onPressed: () {
                    //     showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return AlertDialog(
                    //           title: Text('Enter Amount'),
                    //           content: TextFormField(
                    //             keyboardType: TextInputType.number,
                    //             onChanged: (value) {
                    //               paymentAmount = double.tryParse(value) ?? 0;
                    //             },
                    //           ),
                              // actions: [
                              //   Container(
                              //     width: 200,
                              //     height: 50,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(20),
                              //       gradient: LinearGradient(
                              //         begin: Alignment.topLeft,
                              //         end: Alignment.bottomRight,
                              //         colors: [
                              //           Color(0xff0FA697),
                              //           Color(0xff45BF7A),
                              //           Color(0xff0DF205),
                              //         ],
                              //       ),
                              //     ),
                                  // child: ElevatedButton(
                                  //   onPressed: () {
                                  //     if (paymentAmount > 0) {
                                  //       submitPayment(paymentAmount);
                                  //       Navigator.pop(context);
                                  //     } else {
                                  //       showDialog(
                                  //         context: context,
                                  //         builder: (BuildContext context) {
                                  //           return AlertDialog(
                                  //             title: Text('Invalid Amount'),
                                  //             content: Text('Payment amount must be greater than zero.'),
                                  //             actions: [
                                  //               Container(
                                  //                 width: 200,
                                  //                 height: 50,
                                  //                 decoration: BoxDecoration(
                                  //                   borderRadius: BorderRadius.circular(20),
                                  //                   gradient: LinearGradient(
                                  //                     begin: Alignment.topLeft,
                                  //                     end: Alignment.bottomRight,
                                  //                     colors: [
                                  //                       Color(0xff0FA697),
                                  //                       Color(0xff45BF7A),
                                  //                       Color(0xff0DF205),
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //                 child: ElevatedButton(
                                  //                   onPressed: () {
                                  //                     Navigator.pop(context);
                                  //                   },
                                  //                   child: Text('OK'),
                                  //                   style: ButtonStyle(
                                  //                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  //                       RoundedRectangleBorder(
                                  //                         borderRadius: BorderRadius.circular(20),
                                  //                       ),
                                  //                     ),
                                  //                     backgroundColor: MaterialStateProperty.all<Color>(Color(0xff0FA697)),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           );
                                  //         },
                                  //       );
                                  //     }
                                  //   },
                                  //   child: Text('Submit'),
                                  //   style: ButtonStyle(
                                  //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  //       RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.circular(20),
                                  //       ),
                                  //     ),
                                  //     backgroundColor: MaterialStateProperty.all<Color>(Color(0xff0FA697)),
                                  //   ),
                                  // ),
                                // ),
                              // ],+
                    //         );
                    //       },
                    //     );
                    //   },
                    //   child: Text('Make Payment'),
                    //   style: ButtonStyle(
                    //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    //       RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(20),
                    //       ),
                    //     ),
                    //     backgroundColor: MaterialStateProperty.all<Color>(Color(0xff0FA697)),
                    //   ),
                    // ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
          // if (showInvoice) ...[
  Positioned.fill(
    child: Scaffold(
      body: Card(
        margin: EdgeInsets.all(16.0),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Text(
              'Payment from Rehnaa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Landlord Name: ${widget.landlordName}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
  'Request Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(paymentDateTime)}',
  style: TextStyle(fontSize: 18),
),
            SizedBox(height: 8),
            Text(
              'Withdraw Amount: ${widget.amount}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Balance: ${widget.balance - widget.amount}',

              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Balance: ${widget.transactionMode}',


              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Request Made To: Rehnaa',
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
                                title: Text('Withdraw Request'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                          'Please wait for Rehnaa to approve your withdraw request and get back to us in 24 hours.'),
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
