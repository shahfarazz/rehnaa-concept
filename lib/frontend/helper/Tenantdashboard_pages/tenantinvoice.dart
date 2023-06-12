import 'package:flutter/material.dart';

class TenantInvoicePage extends StatelessWidget {
  final String tenantName;
  final DateTime paymentDateTime;
  final int paymentAmount;

  const TenantInvoicePage({
    required this.tenantName,
    required this.paymentDateTime,
    required this.paymentAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Payment Confirmation Screen',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              'Tenant Name: $tenantName',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment Date: ${paymentDateTime.toString()}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment Amount: $paymentAmount',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

