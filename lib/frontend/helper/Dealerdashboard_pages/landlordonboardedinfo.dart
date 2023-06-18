import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../backend/models/landlordmodel.dart';

class ContractCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String data;

  const ContractCard(
      {Key? key, required this.icon, required this.label, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // rounded corners
      ),
      elevation: 5, // shadow
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              size: 24,
              color: const Color(0xff33907c),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, // bold contract label
                      fontSize: 18,
                      color: const Color(0xff33907c),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.normal, // normal contract data
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LandlordsOnboardedInfoPage extends StatelessWidget {
  final Landlord landlord;
  const LandlordsOnboardedInfoPage({super.key, required this.landlord});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 40.0,
            left: 10.0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF33907C),
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
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 20,
                  ),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Image.asset(
                  'assets/mainlogo.png',
                  // fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        color: const Color.fromARGB(255, 235, 235, 235),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Text(
                                "LandLord",
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Color(0xff33907c),
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Arshad Ali",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff33907c),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              ContractCard(
                                icon: Icons.person,
                                label: 'LandLords Name:',
                                data:
                                    "${landlord.firstName} ${landlord.lastName}",
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.person,
                                label: 'Tenant Name:',
                                data: landlord.tenant == null || landlord.tenant!.isEmpty
                                ? 'No tenant yet'
                                : landlord.tenant![0].firstName ?? '',

                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.calendar_today,
                                label: 'Contract Start Date:',
                                data: '2023-06-01',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.calendar_today,
                                label: 'Contract End Date:',
                                data: '2024-05-31',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.place,
                                label: 'Property Address:',
                                data: landlord.property.isEmpty
                                    ? ''
                                    : landlord.property[0].address ?? '',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.request_page,
                                label: 'Upfront Bonus:',
                                data: '5000',
                              ),
                              SizedBox(height: 16),
                              ContractCard(
                                icon: Icons.request_page,
                                label: 'Monthly Profit:',
                                data: '500',
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
        ],
      ),
    );
  }

  Widget buildRoundedImageCard(BuildContext context, String imagePath) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ExpandedImageDialog(imagePath: imagePath);
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Card(
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandedImageDialog extends StatelessWidget {
  final String imagePath;

  const ExpandedImageDialog({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            left: 10.0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF33907C),
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
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
