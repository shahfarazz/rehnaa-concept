// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class readable extends StatelessWidget {
//   const readable({super.key});

//   void readableFunc() {
//     FirebaseFirestore.instance.collection('Notifications').doc(widget.uid).set({
//       'notifications': FieldValue.arrayUnion([
//         {
//           'title':
//               'Withdraw Request by ${'${landlord.firstName} ${landlord.lastName}'}',
//           'amount': 'Rs${withdrawalAmount}',
//         }
//       ]),
//     }, SetOptions(merge: true));
//     FirebaseFirestore.instance.collection('Landlords').doc(widget.uid).set({
//       'isWithdraw': true,
//     }, SetOptions(merge: true));

//     // Generate a random ID
//     final Random random = Random();
//     final String randomID = random.nextInt(999999).toString().padLeft(6, '0');

//     FirebaseFirestore.instance.collection('AdminRequests').doc(widget.uid).set({
//       'withdrawRequest': FieldValue.arrayUnion([
//         {
//           'fullname': '${landlord.firstName} ${landlord.lastName}',
//           'amount': withdrawalAmount,
//           'paymentMethod': selectedOption,
//           'uid': widget.uid,
//           'invoiceNumber': invoiceNumber,
//           'tenantname': '${tenant.firstName} ${tenant.lastName}',
//           'requestID': randomID,
//           'timestamp': Timestamp.now(),
//         }
//       ]),
//     }, SetOptions(merge: true));

//     setState(() {
//       isWithdraw = true;
//     });
//     Navigator.pop(context);
//     Navigator.pop(context);
//     PDFEditorPage pdfinstance = PDFEditorPage();

//     pdfinstance.createState().createPdf(
//         tenant.firstName + ' ' + tenant.lastName,
//         landlord.firstName + ' ' + landlord.lastName,
//         landlord.address,
//         tenant.address,
//         landlord.balance.toDouble(),
//         withdrawalAmount,
//         selectedOption,
//         widget.uid,
//         invoiceNumber);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
