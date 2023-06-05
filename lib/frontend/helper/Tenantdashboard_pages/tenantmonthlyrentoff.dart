import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class TenantMonthlyRentOffPage extends StatefulWidget {
  @override
  _TenantMonthlyRentOffPageState createState() =>
      _TenantMonthlyRentOffPageState();
}

class _TenantMonthlyRentOffPageState extends State<TenantMonthlyRentOffPage>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  double _currentRotation = 0;
  bool _animationFinished = false; // New state variable

  final List<String> _userImages = const [
    'assets/defaulticon.png',
    'assets/image1.jpg',
    'assets/image2.jpg',
    // Add more user images...
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _animationController.addListener(() {
      setState(() {
        _currentRotation = _animationController.value * 2 * pi;
      });
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animationFinished =
              true; // Set the state variable when the animation finishes
        });
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    // _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset confetti controller when the screen is reloaded
    _confettiController.stop();
    _confettiController.dispose();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      // _animationController.forward();
    });
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background gradient with diagonal clip
            ClipPath(
              clipper: DiagonalClipper(),
              child: Container(
                height: size.height * 0.5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff0FA697),
                      Color(0xff45BF7A),
                      Color(0xff0DF205), // Change to F6F9FF
                    ],
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.1),
                // Display "Monthly Rent OFF Winner" text
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection:
                        -1.5708, // Upward direction in radians (90 degrees)
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    maxBlastForce: 20,
                    minBlastForce: 10,
                    gravity: 0.2,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.orange,
                      Colors.yellow,
                    ],
                  ),
                ),
                Text(
                  'Monthly Rent OFF Winner',
                  style: GoogleFonts.montserrat(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20.0),
                // Replace your CircleAvatar widget with the revolving images
                _animationFinished
                    ? CircleAvatar(
                        radius: size.width * 0.2,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/defaulticon.png'),
                      )
                    : Transform.rotate(
                        angle: _currentRotation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: _userImages
                              .asMap()
                              .entries
                              .map(
                                (entry) => Transform(
                                  transform:
                                      Matrix4.rotationX(_currentRotation),
                                  alignment: Alignment.center,
                                  child: Transform.translate(
                                    offset: Offset(
                                      100 *
                                          cos(_currentRotation +
                                              (2 *
                                                  pi *
                                                  entry.key /
                                                  _userImages.length)),
                                      0.0, // No vertical translation along the Y-axis
                                    ),
                                    child: Transform(
                                      transform:
                                          Matrix4.rotationZ(_currentRotation),
                                      child: Transform.scale(
                                        scale: _animationController.value,
                                        child: CircleAvatar(
                                          radius: 30.0,
                                          backgroundColor: Colors.white,
                                          backgroundImage:
                                              AssetImage(entry.value),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                const SizedBox(height: 10.0),
                // Display dummy description
                Center(
                  child: Text(
                    'Asad Khan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 20.0,
                      color: const Color(0xff33907c),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Credit Score',
                            value: '9.6',
                            points: '120',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Location',
                            value: 'Johar Town',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Rent Off:',
                            value: '15%',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Property Address',
                            value: 'Property Address goes here',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: WhiteBox(
                            label: 'Join Date:',
                            value: '01/01/2021',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WhiteBox extends StatelessWidget {
  final String label;
  final String value;
  final String? points;

  const WhiteBox({
    Key? key,
    required this.label,
    required this.value,
    this.points,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0, // Set the desired height of the white boxes
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (points != null)
                    Text(
                      'Credit Points',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff33907c),
                    ),
                  ),
                  Text(
                    points ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff33907c),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
