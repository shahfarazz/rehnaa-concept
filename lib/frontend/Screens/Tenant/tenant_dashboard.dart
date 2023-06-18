import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/Screens/contract.dart';
import 'package:rehnaa/frontend/Screens/faq.dart';
import 'package:rehnaa/frontend/Screens/vouchers.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_profile.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_properties.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_rentaccrual.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_renthistory.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_dashboard_content.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenantmonthlyrentoff.dart';

import '../privacypolicy.dart';
import '../login_page.dart';

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
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _notificationStream;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _notificationStream2;

  bool _isWithdraw = false;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _notificationStream = FirebaseFirestore.instance
        .collection('Notifications')
        .doc(widget.uid)
        .snapshots();
    _notificationStream2 = FirebaseFirestore.instance
        .collection('Notifications')
        .doc(widget.uid)
        .snapshots();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sidebarController.dispose(); // Dispose the AnimationController
    super.dispose();
    // _getNotifs();
    _notificationStream.drain();
    _notificationStream2.drain();
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

  void updateWithdrawState(bool isWithdraw) {
    setState(() {
      _isWithdraw = isWithdraw;
    });
  }

// Method to check if the keyboard is visible
  bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    super.build(context);
    return Scaffold(
      appBar: _buildAppBar(size),
      resizeToAvoidBottomInset:
          false, // Prevent resizing when the keyboard is shown
      body: StatefulBuilder(
        builder: (BuildContext context, setState) {
          return GestureDetector(
            onTap: () {
              if (_isSidebarOpen) {
                _closeSidebar();
              }
              // Close the keyboard
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(_isSidebarOpen ? size.width * 0.7 : 0, 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          physics: isKeyboardVisible(context)
                              ? NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          itemCount: 5, // Number of pages
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return TenantDashboardContent(
                                  uid: widget.uid,
                                  isWithdraw: _isWithdraw,
                                  onUpdateWithdrawState: updateWithdrawState,
                                );
                              case 1:
                                return TenantRentAccrualPage(
                                  uid: widget.uid,
                                );
                              case 2:
                                return TenantPropertiesPage(
                                  uid: widget.uid,
                                  isWithdraw: _isWithdraw,
                                );
                              case 3:
                                return TenantRentHistoryPage(uid: widget.uid);
                              case 4:
                                return TenantProfilePage(uid: widget.uid);
                              default:
                                return Container();
                            }
                          },
                        ),
                      ),
                      _buildBottomNavigationBar(),
                    ],
                  ),
                ),
                if (_isSidebarOpen) _buildSidebar(size),
              ],
            ),
          );
        },
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
                    fit: BoxFit.cover,
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
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _notificationStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    int notificationsCount = 0;

                    if (snapshot.hasData && snapshot.data != null) {
                      Map<String, dynamic>? data =
                          snapshot.data!.data() as Map<String, dynamic>?;

                      if (data != null && data.containsKey('notifications')) {
                        List<dynamic> notificationstemp = data['notifications'];
                        notificationsCount = notificationstemp.length;
                      }
                    }

                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: notificationsCount == 0
                            ? Colors.transparent
                            : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                      child: Text(
                        notificationsCount == 0
                            ? ''
                            : notificationsCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
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
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFF0FA697),
                                      Color(0xFF45BF7A),
                                      Color(0xFF0DF205),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'REHNAA.PK',
                                    style: GoogleFonts.belleza(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.75,
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
                            builder: (context) => const ContractPage(
                              identifier: 'Tenant',
                            ),
                          ),
                        );
                        // _closeSidebar();
                      },
                    ),
                    _buildSidebarItem(
                      icon: Icons.discount,
                      label: 'Discounts',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TenantMonthlyRentOffPage(),
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
                            builder: (context) => const VouchersPage(),
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
                            builder: (context) => const PrivacyPolicyPage(),
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
                            builder: (context) => const FAQPage(),
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
              style: const TextStyle(
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
            height: MediaQuery.of(context).size.height * 0.37,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: StreamBuilder<DocumentSnapshot>(
              stream: _notificationStream2,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                print('snapshot: $snapshot');
                if (snapshot.hasData && snapshot.data != null) {
                  Map<String, dynamic>? data =
                      snapshot.data!.data() as Map<String, dynamic>?;

                  if (data != null && data.containsKey('notifications')) {
                    List<dynamic> notificationstemp = data['notifications'];
                    Size size = MediaQuery.of(context).size;

                    return Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
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
                              padding: const EdgeInsets.only(
                                top: 0.0,
                                left: 20.0,
                                right: 20.0,
                                bottom: 0.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const Hero(
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
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 0,
                              color: Colors.grey,
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                ),
                                child: Container(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    color: Colors.white,
                                    child: Scrollbar(
                                        thumbVisibility: true,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: notificationstemp.reversed
                                                .map((notification) {
                                              String title =
                                                  notification['title'] ?? '';
                                              var amount =
                                                  notification['amount'] ?? '';

                                              // Generate a unique key for each notification using its index
                                              Key dismissibleKey = UniqueKey();

                                              return Dismissible(
                                                key: dismissibleKey,
                                                direction:
                                                    DismissDirection.horizontal,
                                                confirmDismiss: (_) async {
                                                  return await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Delete Notification"),
                                                        content: const Text(
                                                            "Are you sure you want to delete this notification?"),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false),
                                                            child: const Text(
                                                                "Cancel"),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true),
                                                            child: const Text(
                                                                "Delete"),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                onDismissed: (_) {
                                                  // Remove the notification from the list
                                                  setState(() {
                                                    notificationstemp
                                                        .remove(notification);
                                                  });

                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'Notifications')
                                                      .doc(widget.uid)
                                                      .update({
                                                    'notifications':
                                                        FieldValue.arrayRemove(
                                                            [notification])
                                                  });

                                                  // Show a snackbar! This snackbar could also contain "Undo" actions
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.green[400],
                                                      content: Text(
                                                          'Notification dismissed'),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    ),
                                                  );
                                                },
                                                background: Container(
                                                  color: Colors.red,
                                                  child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.white),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8.0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          const SizedBox(
                                                            width: 24.0,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          8.0),
                                                              child: Text(
                                                                '\u2022',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      24.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                      0xFF45BF7A),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12.0),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  title,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        18.0,
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                  ),
                                                                ),
                                                                if (amount
                                                                    .isNotEmpty)
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                      left:
                                                                          24.0,
                                                                      top: 4.0,
                                                                    ),
                                                                    child:
                                                                        RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16.0,
                                                                          fontFamily:
                                                                              'Montserrat',
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        children: [
                                                                          const TextSpan(
                                                                            text:
                                                                                'Amount: ',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Montserrat',
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                amount,
                                                                            style:
                                                                                const TextStyle(
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
                                                    ),
                                                    const Divider(
                                                      height: 0,
                                                      color: Colors.grey,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                }

                return Container(); // Placeholder for loading state or empty state
              },
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
          BottomNavigationBarItem(
              icon: Icon(Icons.real_estate_agent), label: 'Accrual'),
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

// Custom Clipper for hexagonal shape
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double controlPointOffset = size.height / 6;

    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2 - controlPointOffset);
    path.lineTo(size.width, size.height / 2 + controlPointOffset);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2 + controlPointOffset);
    path.lineTo(0, size.height / 2 - controlPointOffset);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
