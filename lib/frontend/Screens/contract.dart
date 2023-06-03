import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContractPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyScreen(),
    );
  }
}

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return ZoomedScreen();
              }));
            },
            child: Hero(
              tag: 'imageTag',
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Image.asset(
                  'assets/image1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Contracts",
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              color: Color(0xff33907c),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24),
                          ContractCard(label: 'Property:', data: '123 Main St'),
                          SizedBox(height: 16),
                          ContractCard(label: 'Tenant Name:', data: 'John Doe'),
                          SizedBox(height: 16),
                          ContractCard(
                            label: 'Tenant CNIC:',
                            data: '1234567890',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            label: 'Contract Start Date:',
                            data: '2023-06-01',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            label: 'Contract End Date:',
                            data: '2024-05-31',
                          ),
                          SizedBox(height: 16),
                          ContractCard(label: 'Police Verified:', data: 'Yes'),
                          SizedBox(height: 16),
                          ContractCard(
                            label: 'Court Regulation:',
                            data: 'ABC123',
                          ),
                          SizedBox(height: 16),
                          ContractCard(
                            label: 'Notary Republic Stamp:',
                            data: 'XYZ456',
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // rounded corners
      ),
      elevation: 5, // shadow
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading:
                  Icon(Icons.description), // an icon next to the contract label
              title: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, // bold contract label
                  fontSize: 18,
                  color: Color(0xff33907c),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                data,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.normal, // normal contract data
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ZoomedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageTag',
            child: Image.asset(
              'assets/image1.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
