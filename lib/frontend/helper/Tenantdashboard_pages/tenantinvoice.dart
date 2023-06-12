import 'package:flutter/material.dart';

class TenantInvoicePage extends StatelessWidget {
  final String tenantName;
  final DateTime paymentDateTime;
  final int paymentAmount;

  TenantInvoicePage({
    required this.tenantName,
    required this.paymentDateTime,
    required this.paymentAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Payment Confirmation Screen',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Tenant Name: $tenantName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Payment Date: ${paymentDateTime.toString()}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Payment Amount: $paymentAmount',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

