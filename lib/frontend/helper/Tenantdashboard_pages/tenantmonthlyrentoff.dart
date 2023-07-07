import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

import '../../../backend/models/tenantsmodel.dart';

class TenantMonthlyRentOffPage extends StatefulWidget {
  final String uid;
  const TenantMonthlyRentOffPage({Key? key, required this.uid})
      : super(key: key);
  @override
  _TenantMonthlyRentOffPageState createState() =>
      _TenantMonthlyRentOffPageState();
}

class _TenantMonthlyRentOffPageState extends State<TenantMonthlyRentOffPage>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  double _currentRotation = 0;
  bool _animationFinished = false; // New state variable
  bool _isPageVisible = false;
  bool _isContentDimensionsEstablished = false;
  bool _isPageReady = false;

  final PageController _pageController = PageController();
  final List<String> _userImages = const [
    'assets/defaulticon.png',
    'assets/image1.jpg',
    'assets/image2.jpg',
    'assets/mainlogo.png',
    'assets/image2.jpg'
    // Add more user images...
  ];

  List<Tenant> winnerTenants = [];

  Future<List<Tenant>> fetchWinnerTenants() async {
    if (winnerTenants.length > 0) {
      return winnerTenants;
    }

    var value = await FirebaseFirestore.instance.collection('Tenants').get();

    for (var element in value.docs) {
      // print('did this');
      // print(element.data());
      if (element.data()['isRentOffWinner'] == true) {
        // print(element.data());
        Tenant tempWinner = Tenant.fromJson(element.data());
        tempWinner.tempID = element.id;
        // tempWinner.pathToImage = 'assets/defaulticon.png';
        winnerTenants.add(tempWinner);
      }
    }
    return winnerTenants;
  }

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
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

    // fetchWinnerTenants();
  }

  @override
  void dispose() {
    _confettiController.dispose();
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
    _animationController.reset();
    _animationController.dispose();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _animationFinished = false;
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animationFinished =
              true; // Set the state variable when the animation finishes
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        height: size.height * 1,
        child: FutureBuilder(
            future: fetchWinnerTenants(),
            builder: (context, snapshot) {
              List<Tenant> winnerTenants = snapshot.data ?? [];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SpinKitFadingCube(
                    color: Color.fromARGB(255, 30, 197, 83),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (winnerTenants.length > 0) {
                // WidgetsBinding.instance!.addPostFrameCallback((_) {
                //   _animationController.forward();
                // });
                return PageView.builder(
                  controller: _pageController,
                  itemCount: winnerTenants.length,
                  // onPageChanged: (index) {
                  //   setState(() {
                  //     _isPageReady = false;
                  //   });
                  // },

                  itemBuilder: (context, index) {
                    // print('winnerTenants: ${winnerTenants.length}}');
                    // if (!_animationFinished) {
                    //   print('reached here');
                    //   _animationController.forward();
                    // }
                    // final isCurrentPage =
                    //     index == _pageController.page?.round();

                    // _animationFinished = true;
                    return SingleChildScrollView(
                      child: Stack(
                        children: [
                          Container(
                            height: size.height * 0.5,
                            child: ClipPath(
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
                                      Color(0xff0DF205),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 65.0,
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
                                  )),
                            ),
                          ),
                          Positioned(
                              top: size.height *
                                  0.4, // adjust this according to your layout
                              right: 9,
                              child: index + 1 < winnerTenants.length
                                  ? Icon(Icons.arrow_forward_ios,
                                      color: Colors.black)
                                  : SizedBox.shrink()),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: size.height * 0.05),
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
                              SizedBox(height: size.height * 0.105),

                              Text(
                                'Monthly Rent OFF Winner',
                                style: GoogleFonts.montserrat(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: size.height * 0.03),
                              // Replace your CircleAvatar widget with the revolving images
                              _animationFinished
                                  ? CircleAvatar(
                                      radius: size.width * 0.2,
                                      backgroundColor: Colors.white,
                                      backgroundImage: winnerTenants[index]
                                              .pathToImage!
                                              .contains('assets')
                                          ? AssetImage(
                                              winnerTenants[index].pathToImage!)
                                          : CachedNetworkImageProvider(
                                              winnerTenants[index].pathToImage!,
                                            ) as ImageProvider,
                                    )
                                  : AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Transform.rotate(
                                          angle: _animationController.value *
                                              2 *
                                              pi,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: winnerTenants
                                                .asMap()
                                                .entries
                                                .map(
                                                  (entry) => Transform(
                                                    transform: Matrix4.rotationY(
                                                            _animationController
                                                                    .value *
                                                                2 *
                                                                pi) *
                                                        Matrix4.rotationZ(
                                                            _animationController
                                                                    .value *
                                                                2 *
                                                                pi),
                                                    alignment: Alignment.center,
                                                    child: Transform.translate(
                                                      offset: Offset(
                                                        100 *
                                                            cos(_animationController
                                                                        .value *
                                                                    2 *
                                                                    pi +
                                                                (2 *
                                                                    pi *
                                                                    entry.key /
                                                                    winnerTenants
                                                                        .length)),
                                                        0.0,
                                                      ),
                                                      child: Transform.scale(
                                                        scale:
                                                            _animationController
                                                                .value,
                                                        child: CircleAvatar(
                                                          radius: 30.0,
                                                          backgroundColor:
                                                              Colors.white,
                                                          backgroundImage: entry
                                                                  .value
                                                                  .pathToImage!
                                                                  .contains(
                                                                      'assets')
                                                              ? AssetImage(entry
                                                                  .value
                                                                  .pathToImage!)
                                                              : CachedNetworkImageProvider(
                                                                  entry.value
                                                                      .pathToImage!,
                                                                ) as ImageProvider,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        );
                                      },
                                    ),
                              SizedBox(height: size.height * 0.03),
                              // Display dummy description
                              Center(
                                child: Text(
                                  '${winnerTenants[index].firstName} ${winnerTenants[index].lastName}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20.0,
                                    color: const Color(0xff33907c),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.03),
                              Padding(
                                padding:
                                    EdgeInsets.only(bottom: size.height * 0.07),
                                child: Column(
                                  children: [
                                    SizedBox(height: size.height * 0.03),
                                    Center(
                                      child: FractionallySizedBox(
                                        widthFactor: 0.8,
                                        child: WhiteBox(
                                          label: 'Credit Score',
                                          value: winnerTenants[index]
                                              .creditPoints
                                              .toString(),
                                          // points: '120',
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: size.height * 0.03),
                                    SizedBox(height: 10.0),
                                    Center(
                                      child: FractionallySizedBox(
                                        widthFactor: 0.8,
                                        child: WhiteBox(
                                          label: 'Rent Off:',
                                          value: winnerTenants[index]
                                                      .discount
                                                      .toString() ==
                                                  '0.24234234'
                                              ? 'old document'
                                              : winnerTenants[index]
                                                  .discount
                                                  .toString(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Center(
                                      child: FractionallySizedBox(
                                        widthFactor: 0.8,
                                        child: WhiteBox(
                                          label: 'Property Address',
                                          value: winnerTenants[index]
                                                  .propertyAddress ??
                                              'No address found',
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Center(
                                      child: FractionallySizedBox(
                                        widthFactor: 0.8,
                                        child: WhiteBox(
                                          label: 'Join Date:',
                                          value: winnerTenants[index]
                                              .dateJoined!
                                              .toDate()
                                              .toString()
                                              .substring(0, 10),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: SpinKitFadingCube(
                    color: Color.fromARGB(255, 30, 197, 83),
                  ),
                );
              }
            }),
      ),
    ));
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
