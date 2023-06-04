import 'package:flutter/material.dart';
import 'package:rehnaa/frontend/Screens/Landlord/contract.dart';
import 'package:rehnaa/frontend/Screens/Landlord/vouchers.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_dashboard_content';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_profile.dart';

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
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: <Widget>[
                TenantDashboardContent(
                  uid: widget.uid,
                ),
                const TenantProfilePage(),
              ],
            ),
          ),
          if (_isSidebarOpen) _sidebar(size),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  // AppBar widget for the dashboard
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
                onPressed: () {
                  // TODO: Implement notifications handling here
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

// Sidebar widget
// Sidebar widget
Widget _sidebar(Size size) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: _isSidebarOpen ? size.width * 0.6 : 0,
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
            Container(
              padding: const EdgeInsets.only(left: 16, top: 64, bottom: 16),
              child: const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                        fontSize: 12.0, // adjust the size to fit your needs
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
            // Add more list items if needed
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
  );
}


  // BottomNavigationBar widget
  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
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
        BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'Property'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history), label: 'Rent History'),
        BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: 'Profile'),
      ],
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
