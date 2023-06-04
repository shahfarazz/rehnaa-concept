import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContractPage(),
    );
  }
}

class ContractPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyScreen(),
    );
  }
}

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Stack(
          alignment: Alignment.topLeft,
          children: [
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
          Stack(
  children: [
    SafeArea(
      child: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(16.0),
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
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
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
          child: Icon(
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
                        ContractCard(
                            label: 'Police Verified:', data: 'Yes'),
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
class ZoomedScreen extends StatefulWidget {
  @override
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
                  padding: EdgeInsets.all(16.0),
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
                    decoration: BoxDecoration(
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
                      icon: Icon(
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
