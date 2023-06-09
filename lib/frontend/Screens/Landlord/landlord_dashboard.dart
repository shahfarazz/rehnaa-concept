import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:rehnaa/frontend/Screens/contract.dart';
import 'package:rehnaa/frontend/Screens/privacypolicy.dart';
import 'package:rehnaa/frontend/Screens/faq.dart';
import 'package:rehnaa/frontend/Screens/login_page.dart';
import 'package:rehnaa/frontend/Screens/vouchers.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/landlord_dashboard_content.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/landlord_profile.dart';
import '../../helper/Landlorddashboard_pages/landlord_renthistory.dart';
import '../../helper/Landlorddashboard_pages/landlord_tenants.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../helper/Landlorddashboard_pages/landlordproperties.dart';

class LandlordDashboardPage extends StatefulWidget {
  final String uid; // UID of the landlord

  const LandlordDashboardPage({Key? key, required this.uid}) : super(key: key);

  @override
  _LandlordDashboardPageState createState() => _LandlordDashboardPageState();
}

class _LandlordDashboardPageState extends State<LandlordDashboardPage>
    with
        AutomaticKeepAliveClientMixin<LandlordDashboardPage>,
        TickerProviderStateMixin {
  int _currentIndex = 0;
  final _pageController = PageController();
  bool _isSidebarOpen = false;
  late AnimationController _sidebarController;
  bool _isWithdraw = false;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _getNotifs();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // List<Map<String, String>> notifications =

  // = [
  //   // {
  //   //   'title': 'Rent paid by Tenant: Michelle',
  //   //   'amount': '\$30000',
  //   // },
  //   // {
  //   //   'title': 'Maintenance request by Tenant: John',
  //   //   'amount': '',
  //   // },
  //   // {
  //   //   'title': 'Contract renewal notice for Property: ABC Apartment',
  //   //   'amount': '',
  //   // },
  //   // {
  //   //   'title': 'Notification 4',
  //   //   'amount': '',
  //   // },
  //   // Add more notifications here
  // ];

  List<Map<String, String>> notifications = [];

  Future<void> _getNotifs() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Notifications')
        .doc(widget.uid)
        .get();

    if (snapshot.data() != null) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      if (data.containsKey('notifications')) {
        List<dynamic> notificationstemp = data['notifications'];

        for (var i = 0; i < notificationstemp.length; i++) {
          Map<String, dynamic> notification = notificationstemp[i];

          String title = notification['title'] ?? '';
          String amount = notification['amount'] ?? 0.0;

          print('Title: $title');
          print('Amount: $amount');

          // Add the notification to a list or perform other operations
          setState(() {
            notifications.add({'title': title, 'amount': amount});
          });
        }
      }
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      if (_isSidebarOpen) {
        _sidebarController.forward();
      } else {
        _sidebarController.reverse();
      }
    });
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarOpen = false;
      _sidebarController.reverse();
    });
  }

  void updateWithdrawState(bool isWithdraw) {
    setState(() {
      _isWithdraw = isWithdraw;
      _getNotifs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    super.build(context);
    return Scaffold(
      appBar: _buildAppBar(size),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_isSidebarOpen) {
                _closeSidebar();
              }
            },
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(_isSidebarOpen ? size.width * 0.7 : 0, 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          children: <Widget>[
                            LandlordDashboardContent(
                              uid: widget.uid,
                              isWithdraw: _isWithdraw,
                              onUpdateWithdrawState: updateWithdrawState,
                            ),
                            LandlordTenantsPage(uid: widget.uid),
                            LandlordPropertiesPage(uid: widget.uid),
                            LandlordRentHistoryPage(uid: widget.uid),
                            LandlordProfilePage(uid: widget.uid),
                          ],
                        ),
                      ),
                      _buildBottomNavigationBar(),
                    ],
                  ),
                ),
                if (_isSidebarOpen) _buildSidebar(size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Size size) {
    return AppBar(
      toolbarHeight: 70,
      leading: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 0) {
              _toggleSidebar();
            } else if (details.delta.dx < 0) {
              _closeSidebar();
            }
          },
          child: IconButton(
            iconSize: 30.0,
            icon: const Icon(Icons.menu),
            onPressed: _toggleSidebar,
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(
          top: 2.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: [
                ClipPath(
                  clipper: HexagonClipper(),
                  child: Transform.scale(
                    scale: 0.87,
                    child: Container(
                      color: Colors.white,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                ClipPath(
                  clipper: HexagonClipper(),
                  child: Image.asset(
                    'assets/mainlogo.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_active),
                onPressed: _showNotificationsDialog,
              ),
              Positioned(
                right: 13,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color:
                        notifications.isEmpty ? Colors.transparent : Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 10,
                    minHeight: 10,
                  ),
                  child: Text(
                    notifications.isEmpty
                        ? ''
                        : notifications.length.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: Container(
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
    );
  }

  Widget _buildSidebar(Size size) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          setState(() {
            _isSidebarOpen = true;
          });
        } else if (details.delta.dx < 0) {
          setState(() {
            _isSidebarOpen = false;
          });
        }
      },
      child: Stack(
        children: [
          if (_isSidebarOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              child: Container(
                color: Colors.black54,
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarOpen ? size.width * 0.7 : 0,
            height: _isSidebarOpen ? size.height : 0,
            color: Colors.white,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: const Offset(0, 0),
              ).animate(CurvedAnimation(
                parent: _sidebarController,
                curve: Curves.easeInOut,
              )),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 0, top: 30, bottom: 16),
                              child: InkWell(
                                onTap: () {
                                  // Add your onTap functionality here
                                },
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      Color(0xFF0FA697),
                                      Color(0xFF45BF7A),
                                      Color(0xFF0DF205),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'Rehnaa',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey[400],
                      thickness: 0.5,
                    ),
                    _buildSidebarItem(
                      icon: Icons.description,
                      label: 'Contract',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContractPage(),
                          ),
                        );
                        // _closeSidebar();
                      },
                    ),
                    _buildSidebarItem(
                      icon: Icons.receipt,
                      label: 'Vouchers',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VouchersPage(),
                          ),
                        );
                        // _closeSidebar();
                      },
                      showBadge: true,
                    ),
                    _buildSidebarItem(
                      icon: Icons.lock,
                      label: 'Privacy Policy',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPolicyPage(),
                          ),
                        );
                        // _closeSidebar();
                      },
                    ),
                    _buildSidebarItem(
                      icon: Icons.question_answer,
                      label: 'FAQs',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FAQPage(),
                          ),
                        );
                        // _closeSidebar();
                      },
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.grey[400],
                      thickness: 0.5,
                    ),
                    _buildSidebarItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      onTap: () {
                        // Implement sign-out functionality here
                        // For example, clear user session, navigate to login page, etc.
                        _signOutUser();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signOutUser() async {
    // Implement your sign-out logic here
    // For example, clear user session, navigate to login page, etc.
    // Sign out the user using Firebase Authentication
    await FirebaseAuth.instance.signOut();

    // Navigate to login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
              ),
            ),
          ),
          if (showBadge)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text(
                'new',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0FA697),
                          Color(0xFF45BF7A),
                          Color(0xFF0DF205),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Hero(
                            tag: 'notificationTitle',
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(bottom: 4.0),
                          color: Colors.white,
                          child: Scrollbar(
                            isAlwaysShown: true,
                            child: SingleChildScrollView(
                              child: Column(
                                children: notifications
                                    .map(
                                      (notification) => Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 24.0,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: Text(
                                                  '\u2022',
                                                  style: TextStyle(
                                                    fontSize: 24.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF45BF7A),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    notification['title']!,
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                  if (notification['amount']!
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 24.0),
                                                      child: RichText(
                                                        text: TextSpan(
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                'Montserrat',
                                                            color: Colors.black,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: 'Amount: ',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: notification[
                                                                  'amount']!,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xFF45BF7A),
                                                                fontFamily:
                                                                    'Montserrat',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
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
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tenant'),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_work), label: 'Property'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin), label: 'Profile'),
        ],
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 4);
    path.lineTo(size.width, size.height * 3 / 4);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height * 3 / 4);
    path.lineTo(0, size.height / 4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
