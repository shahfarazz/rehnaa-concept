import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helper/Dealerdashboard_pages/lordsonboarded_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ContractPage(),
    );
  }
}

class ContractPage extends StatelessWidget {
  const ContractPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MyScreen(),
    );
  }
}

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Stack(
          alignment: Alignment.topLeft,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return const ZoomedScreen();
                }));
              },
              child: Hero(
                tag: 'imageTag',
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'assets/image1.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Stack(
              children: [
                SafeArea(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(16.0),
                    // child: Text('Your Content'),
                  ),
                ),
                Positioned(
                  top: 10.0,
                  left: 10.0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    //  onTap: () { // changeeeeeeeeeeeeeeeeee
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => LandlordsOnboardedPage()),
                    //   );
                    // },
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
          ],
        ),
        const SizedBox(height: 20),
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
      color: const Color(0xff33907c),
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 24),
  ContractCard(
    icon: Icons.home,
    label: 'Property:',
    data: '123 Main St',
  ),
  const SizedBox(height: 16),
  ContractCard(
    icon: Icons.person,
    label: 'Tenant Name:',
    data: 'John Doe',
  ),
  const SizedBox(height: 16),
  ContractCard(
    icon: Icons.credit_card,
    label: 'Tenant CNIC:',
    data: '1234567890',
  ),
  const SizedBox(height: 16),
  ContractCard(
    icon: Icons.calendar_today,
    label: 'Contract Start Date:',
    data: '2023-06-01',
  ),
  const SizedBox(height: 16),
  ContractCard(
    icon: Icons.calendar_today,
    label: 'Contract End Date:',
    data: '2024-05-31',
  ),
  const SizedBox(height: 16),
  ContractCard(
    icon: Icons.verified_user,
    label: 'Police Verified:',
    data: 'Yes',
  ),
  const SizedBox(height: 16),
  ContractCard(
    icon: Icons.gavel,
    label: 'Court Regulation:',
    data: 'ABC123',
  ),
  const SizedBox(height: 16),
  ContractCard(
    icon: Icons.assignment,
    label: 'Notary Republic Stamp:',
    data: 'XYZ456',
  ),
  const SizedBox(height: 24),
],

                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ContractCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String data;

  const ContractCard({Key? key, required this.icon, required this.label, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // rounded corners
      ),
      elevation: 5, // shadow
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              size: 24,
              color: const Color(0xff33907c),
            ),
            SizedBox(width: 10),
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
                  SizedBox(height: 5),
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

class ZoomedScreen extends StatefulWidget {
  const ZoomedScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ZoomedScreenState createState() => _ZoomedScreenState();
}

class _ZoomedScreenState extends State<ZoomedScreen> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _previousOffset = Offset.zero;
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            onScaleStart: (ScaleStartDetails details) {
              _previousScale = _scale;
              _previousOffset = details.focalPoint - _offset;
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
                _offset = details.focalPoint - _previousOffset;
              });
            },
            child: Center(
              child: Hero(
                tag: 'imageTag',
                child: Transform.scale(
                  scale: _scale,
                  child: Transform.translate(
                    offset: _offset,
                    child: Image.asset(
                      'assets/image1.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Stack(
            children: [
              SafeArea(
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(16.0),
                  // child: Text('Your Content'),
                ),
              ),
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
            ],
          ),
        ],
      ),
    );
  }
}
