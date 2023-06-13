import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helper/Dealerdashboard_pages/dealerlandlordonboarded.dart';
import '../helper/Dealerdashboard_pages/landlordonboardedinfo.dart';

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
  const MyScreen({Key? key}) : super(key: key);

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
                    //     MaterialPageRoute(builder: (context) => LandlordOnboardedPage(uid: '',)),
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
                padding: const EdgeInsets.all(20.0),
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
                        Center(
                          child: Text(
                            "Contract",
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              color: const Color(0xff33907c),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const ContractCard(
                          icon: Icons.person,
                          label: 'Landlord Name:',
                          data: 'Jane Smith',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.credit_card,
                          label: 'Landlord CNIC:',
                          data: '0987654321',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.person,
                          label: 'Tenant Name:',
                          data: 'John Doe',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.credit_card,
                          label: 'Tenant CNIC:',
                          data: '1234567890',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.person,
                          label: 'First Witness Name:',
                          data: 'Mark Johnson',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.credit_card,
                          label: 'First Witness CNIC:',
                          data: '1357924680',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.phone,
                          label: 'First Witness Contact Number:',
                          data: '+1 123-456-7890',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.person,
                          label: 'Second Witness Name:',
                          data: 'Emily Davis',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.credit_card,
                          label: 'Second Witness CNIC:',
                          data: '2468135790',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.phone,
                          label: 'Second Witness Contact Number:',
                          data: '+1 987-654-3210',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.home,
                          label: 'Property:',
                          data: '123 Main St',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.monetization_on,
                          label: 'Security Amount:',
                          data: '10000',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.monetization_on,
                          label: 'Monthly Rent:',
                          data: '1500',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.calendar_today,
                          label: 'Contract Start Date:',
                          data: '2023-06-01',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.calendar_today,
                          label: 'Contract End Date:',
                          data: '2024-05-31',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.home_work,
                          label: 'Use Purpose:',
                          data: 'Residential',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.home_work,
                          label: 'Sublet Option:',
                          data: 'No',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.electrical_services,
                          label: 'Utilities Included in Rent:',
                          data: 'Yes',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.access_time,
                          label: 'Eviction Notice Period:',
                          data: '30 days',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.receipt,
                          label: 'E-Stamp Value:',
                          data: '500',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.assignment,
                          label: 'Notary Public Stamp:',
                          data: 'XYZ456',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.folder,
                          label: 'BOP Challan Form:',
                          data: 'ABC789',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.verified_user,
                          label: 'Police Verification:',
                          data: 'Yes',
                        ),
                        const SizedBox(height: 16),
                        const ContractCard(
                          icon: Icons.info,
                          label: 'Additional Information:',
                          data: 'Lorem ipsum dolor sit amet',
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

  const ContractCard(
      {Key? key, required this.icon, required this.label, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300, // Set the desired width of the card
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // rounded corners
          ),
          elevation: 2, // shadow
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                          fontSize: 17,
                          color: const Color(0xff33907c),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.normal, // normal contract data
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
