import 'package:flutter/material.dart';

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
                  // fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Card(
                    color: Color.fromARGB(255, 235, 235, 235),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                            "Contracts",
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xff33907c),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ContractCard(label: 'Property:', data: '123 Main St'),
                          SizedBox(height: 10),
                          ContractCard(label: 'Tenant Name:', data: 'John Doe'),
                          SizedBox(height: 10),
                          ContractCard(label: 'Tenant CNIC:', data: '1234567890'),
                          SizedBox(height: 10),
                          ContractCard(
                            label: 'Contract Start Date:',
                            data: '2023-06-01',
                          ),
                          SizedBox(height: 10),
                          ContractCard(
                            label: 'Contract End Date:',
                            data: '2024-05-31',
                          ),
                          SizedBox(height: 10),
                          ContractCard(label: 'Police Verified:', data: 'Yes'),
                          SizedBox(height: 10),
                          ContractCard(
                            label: 'Court Regulation:',
                            data: 'ABC123',
                          ),
                          SizedBox(height: 10),
                          ContractCard(
                            label: 'Notary Republic Stamp:',
                            data: 'XYZ456',
                          ),
                          SizedBox(height: 16.0),
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

  const ContractCard({required this.label, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(data),
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
