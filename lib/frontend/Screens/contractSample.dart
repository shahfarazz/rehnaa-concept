import 'package:flutter/material.dart';

class ContractSamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contract'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return ZoomImageScreen(
                      image: 'assets/mainlogo.png',
                    );
                  }));
                },
                child: Hero(
                  tag: 'zoom_image',
                  child: Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: Image.asset(
                      'assets/mainlogo.png',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.6,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              ContractCard(label: 'Property:', data: '123 Main St'),
              SizedBox(height:10),
              ContractCard(label: 'Tenant Name:', data: 'John Doe'),
              SizedBox(height:10),
              ContractCard(label: 'Tenant CNIC:', data: '1234567890'),
              SizedBox(height:10),
              ContractCard(label: 'Contract Start Date:', data: '2023-06-01'),
              SizedBox(height:10),
              ContractCard(label: 'Contract End Date:', data: '2024-05-31'),
              SizedBox(height:10),
              ContractCard(label: 'Police Verified:', data: 'Yes'),
              SizedBox(height:10),
              ContractCard(label: 'Court Regulation:', data: 'ABC123'),
              SizedBox(height:10),
              ContractCard(label: 'Notary Republic Stamp:', data: 'XYZ456'),
            ],
          ),
        ),
      ),
    );
  }
}

class ContractCard extends StatelessWidget {
  final String label;
  final String data;

  ContractCard({required this.label, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              data,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class ZoomImageScreen extends StatelessWidget {
  final String image;

  ZoomImageScreen({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'zoom_image',
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
