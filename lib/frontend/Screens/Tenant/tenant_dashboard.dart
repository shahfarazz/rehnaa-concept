import 'package:flutter/material.dart';
import 'package:rehnaa/frontend/Screens/contract.dart';
import 'package:rehnaa/frontend/Screens/vouchers.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_profile.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_properties.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_rentaccrual.dart';
import 'dart:ui';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_renthistory.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_dashboard_content.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenantmonthlyrentoff.dart';

class TenantDashboardPage extends StatefulWidget {
  final String uid; // UID of the tenant

  const TenantDashboardPage({super.key, required this.uid});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<TenantDashboardPage>
    with
        AutomaticKeepAliveClientMixin<TenantDashboardPage>,
        TickerProviderStateMixin {
  int _currentIndex = 0;
  final _pageController = PageController();
  bool _isSidebarOpen = false;
  // Declare the AnimationController
  late AnimationController _sidebarController;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sidebarController.dispose(); // Dispose the AnimationController
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    super.build(context); // Ensure the state is kept alive
    return Scaffold(
      appBar: _appBar(size),
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
                            TenantDashboardContent(uid: widget.uid),
                            TenantRentAccrualPage(),
                            TenantPropertiesPage(uid: widget.uid),
                            TenantMonthlyRentOffPage(),
                            TenantRentHistoryPage(uid: widget.uid),
                            TenantProfilePage(uid: widget.uid),
                          ],
                        ),
                      ),
                      _bottomNavigationBar(),
                    ],
                  ),
                ),
                if (_isSidebarOpen) _sidebar(size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> notifications = [
    {
      'title': 'Rent paid by Tenant: Michelle',
      'amount': '\$30000',
    },
    {
      'title': 'Maintenance request by Tenant: John',
      'amount': '',
    },
    {
      'title': 'Contract renewal notice for Property: ABC Apartment',
      'amount': '',
    },
    {
      'title': 'Notification 4',
      'amount': '',
    },
    // Add more notifications here
  ]; // AppBar widget for the dashboard

  PreferredSizeWidget? _appBar(Size size) {
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
        padding: const EdgeInsets.only(top: 2.0),
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
                onPressed: () {
                  // Show notifications panel
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <Widget>[
                                                                SizedBox(
                                                                  width: 24.0,
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                8.0),
                                                                    child: Text(
                                                                      '\u2022', // Bullet point character
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            24.0,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Color(
                                                                            0xFF45BF7A),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        12.0),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        notification[
                                                                            'title']!,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18.0,
                                                                          fontFamily:
                                                                              'Montserrat',
                                                                        ),
                                                                      ),
                                                                      if (notification[
                                                                              'amount']!
                                                                          .isNotEmpty)
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 24.0),
                                                                          child:
                                                                              RichText(
                                                                            text:
                                                                                TextSpan(
                                                                              style: TextStyle(
                                                                                fontSize: 16.0,
                                                                                fontFamily: 'Montserrat',
                                                                                color: Colors.black,
                                                                              ),
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: 'Amount: ',
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Montserrat',
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: notification['amount']!,
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color(0xFF45BF7A),
                                                                                    fontFamily: 'Montserrat',
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
                                                          ))
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
                },
              ),
              Positioned(
                right: 13,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 10,
                    minHeight: 10,
                  ),
                  child: const Text(
                    '9',
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

  Widget _sidebar(Size size) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          // Swipe right, open the sidebar
          setState(() {
            _isSidebarOpen = true;
          });
        } else if (details.delta.dx < 0) {
          // Swipe left, close the sidebar
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
                // Close the sidebar when tapping on the shadow
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              child: Container(
                color: Colors
                    .black54, // Adjust the color and opacity of the shadow here
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
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text(
                        'Contract',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContractPage(),
                          ),
                        );
                        _closeSidebar(); // Close the sidebar after navigation
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.receipt),
                      title: Row(
                        children: <Widget>[
                          Expanded(
                            child: const Text(
                              'Vouchers',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0), // add some spacing
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Text(
                              'new',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    12.0, // adjust the size to fit your needs
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VouchersPage(),
                          ),
                        );
                        _closeSidebar(); // Close the sidebar after navigation
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        // Handle Privacy Policy button tap
                        _closeSidebar(); // Close the sidebar after action
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.question_answer),
                      title: const Text(
                        'FAQs',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        // Handle FAQs button tap
                        _closeSidebar(); // Close the sidebar after action
                      },
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.grey[400],
                      thickness: 0.5,
                    ),
                    // Add any additional widgets or content at the bottom of the sidebar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!, // Set the color of the gray line
            width: 1.0, // Set the width of the gray line
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
          BottomNavigationBarItem(
              icon: Icon(Icons.real_estate_agent), label: 'Accrual'),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_work), label: 'Property'),
          BottomNavigationBarItem(
            icon: Icon(Icons.discount_sharp),
            label: 'Discounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for hexagonal shape
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
