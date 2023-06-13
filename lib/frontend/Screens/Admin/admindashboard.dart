import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rehnaa/frontend/helper/Admindashboard_pages/admin_landlord_requests.dart';
import 'package:rehnaa/frontend/helper/Admindashboard_pages/admin_tenantinput.dart';

import '../../helper/Admindashboard_pages/admin_landlord_tenant_info.dart';
import '../../helper/Admindashboard_pages/admin_landlordinput.dart';
import '../../helper/Admindashboard_pages/admin_propertyinput.dart';
import '../../helper/Admindashboard_pages/admin_rentoffwinner.dart';
import '../../helper/Admindashboard_pages/admin_vouchers.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _getNotifs();
  }

  List<Map<String, String>> notifications = [];

  Future<void> _getNotifs() async {
    QuerySnapshot<Map<String, dynamic>> propertiesSnapshot =
        await FirebaseFirestore.instance.collection('AdminRequests').get();

    if (propertiesSnapshot.size > 0) {
      List<Map<String, String>> tempNotifications = [];
      propertiesSnapshot.docs.forEach((propertysnapshot) {
        propertysnapshot.data().forEach((key, value) {
          if (key == 'withdrawRequest' || key == 'paymentRequest') {
            value.forEach((item) {
              Map<String, String> notification = {
                'title': key,
                'amount': item['amount'].toString(),
                'fullname': item['fullname'],
                'paymentMethod': item['paymentMethod'],
              };
              tempNotifications.add(notification);
            });
          } else {
            // Leave other cases blank for now
            Map<String, String> notification = {
              'title': key,
              'amount': '',
              'fullname': '',
              'paymentMethod': '',
            };
            tempNotifications.add(notification);
          }
        });
      });
      setState(() {
        notifications = tempNotifications;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              child: Scrollable(
                                axisDirection: AxisDirection.down,
                                controller: ScrollController(), // Add this line
                                viewportBuilder: (BuildContext context,
                                    ViewportOffset offset) {
                                  return SingleChildScrollView(
                                    controller:
                                        ScrollController(), // Add this line
                                    physics:
                                        const AlwaysScrollableScrollPhysics(), // Add this line
                                    child: Column(
                                      children: notifications
                                          .map(
                                            (notification) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    width: 24.0,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8.0),
                                                      child: Text(
                                                        '\u2022',
                                                        style: TextStyle(
                                                          fontSize: 24.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFF45BF7A),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12.0),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          notification[
                                                                  'title']! +
                                                              ' ' +
                                                              notification[
                                                                  'fullname']! +
                                                              ' ' +
                                                              notification[
                                                                  'paymentMethod']!,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18.0,
                                                            fontFamily:
                                                                'Montserrat',
                                                          ),
                                                        ),
                                                        if (notification[
                                                                'amount']!
                                                            .isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 24.0),
                                                            child: RichText(
                                                              text: TextSpan(
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: [
                                                                  const TextSpan(
                                                                    text:
                                                                        'Amount: ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: notification[
                                                                        'amount']!,
                                                                    style:
                                                                        const TextStyle(
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
                                  );
                                },
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

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Container(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: EdgeInsets.only(
                  left: 0.0), // Adjust the left padding as needed
              child: Column(
                children: [
                  Text(
                    'Rehnaa ',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Montserrat',
                      // fontWeight: FontWeight.bold,
                      color: Colors.white,
                      // letterSpacing: 3.0, // Adjust the value as needed
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_active),
                    onPressed: _showNotificationsDialog,
                  ),
                ],
              )),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            // borderRadius: BorderRadius.circular(24),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.03),
            Padding(
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
                          scale: 0.96,
                          child: Container(
                            color: Colors.white,
                            width: 120,
                            height: 120,
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: HexagonClipper(),
                        child: Image.asset(
                          'assets/mainlogo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(width:),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdmninRequestsPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Payments and Transactions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Property pictures button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminPropertyInputPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apartment,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Property Input',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Information about landlord and tenant button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminLandlordTenantInfoPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Information about\nLandlord and Tenant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Landlord input in Dealers dashboard button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminLandlordInputPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.input,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Landlord Input\nin Dealers Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Add and Delete Vouchers button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminVouchersPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Add and Delete\nVouchers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Create more unlimited user profiles button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminTenantsInputPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'More\nTenant Profiles',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Data storage of everything for trend and analytics button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storage,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Data Storage of\nEverything',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Hide profiles from each other button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility_off,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Hide Profiles\nfrom Each Other',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 197, 79, 177),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminRentOffWinnerPage(),
                        ),
                      );
                      // Handle Add and Delete Vouchers button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Monthly rent off winner\nDiscount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Add reviews and testimonials button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Add Reviews\nand Testimonials',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
