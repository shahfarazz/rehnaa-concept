import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rehnaa/frontend/helper/Admindashboard_pages/admin_requests.dart';
import 'package:rehnaa/frontend/helper/Admindashboard_pages/admin_tenantinput.dart';

import '../../../backend/services/helperfunctions.dart';
import '../../helper/Admindashboard_pages/admin_accounts.dart';
import '../../helper/Admindashboard_pages/admin_analytics.dart';
import '../../helper/Admindashboard_pages/admin_contracts.dart';
import '../../helper/Admindashboard_pages/admin_dealerinput.dart';
import '../../helper/Admindashboard_pages/admin_estamps.dart';
import '../../helper/Admindashboard_pages/admin_landlord_tenant_info.dart';
import '../../helper/Admindashboard_pages/admin_landlordinput.dart';
import '../../helper/Admindashboard_pages/admin_propertyinput.dart';
import '../../helper/Admindashboard_pages/admin_rentoffwinner.dart';
import '../../helper/Admindashboard_pages/admin_requests_property_contracts.dart';
import '../../helper/Admindashboard_pages/admin_reviews.dart';
import '../../helper/Admindashboard_pages/admin_vouchers.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Timer? _timer;
  StreamSubscription<QuerySnapshot>? _notifsSubscription;

  @override
  void initState() {
    super.initState();
    _getNotifs();
    // _startPeriodicFetch();
  }

  @override
  void dispose() {
    super.dispose();
    _notifsSubscription?.cancel();
  }

  List<Map<String, String>> notifications = [];
  // List<Map<String, String>> notificationsAlreadyRead = [];
  //mapping which maps senderid to a list of notifications
  Map<String, List<Map<String, String>>>
      notificationsAndAlreadyReadNotifications = {};

  void _getNotifs() {
    _notifsSubscription?.cancel(); // Cancel the previous subscription if any

    _notifsSubscription = FirebaseFirestore.instance
        .collection('AdminRequests')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.size > 0) {
        List<Map<String, String>> tempNotifications = [];
        notificationsAndAlreadyReadNotifications.clear();

        for (var notificationsnapshot in snapshot.docs) {
          var notificationData =
              notificationsnapshot.data() as Map<String, dynamic>;

          try {
            notificationData.forEach((key, value) {
              if (key == 'withdrawRequest' || key == 'paymentRequest') {
                value.forEach((item) {
                  Map<String, String> notification = {
                    'title': key,
                    'amount': item['amount'].toString(),
                    'fullname': item['fullname'],
                    'paymentMethod': item['paymentMethod'],
                    'senderid': notificationsnapshot.id,
                    'requestID': item['requestID'],
                  };
                  notificationsAndAlreadyReadNotifications[
                          notification['senderid']!] =
                      List.from(notificationsAndAlreadyReadNotifications[
                              notification['senderid']!] ??
                          [])
                        ..add(notification);

                  if (!item.containsKey('read') || !item['read']) {
                    tempNotifications.add(notification);
                  }
                });
              } else if (key == 'rentalRequest') {
                value.forEach((item) {
                  Map<String, String> notification = {
                    'title': key,
                    'fullname': item['fullname'],
                    'uid': item['uid'],
                    'property name': item['property']['title'],
                    'senderid': notificationsnapshot.id,
                    'requestID': item['requestID'],
                  };
                  notificationsAndAlreadyReadNotifications[
                          notification['senderid']!] =
                      List.from(notificationsAndAlreadyReadNotifications[
                              notification['senderid']!] ??
                          [])
                        ..add(notification);
                  if (!item.containsKey('read') || !item['read']) {
                    tempNotifications.add(notification);
                  }
                });
              } else if (key == 'timestamp') {
                // Do nothing
              } else {
                // Leave other cases blank for now
                value.forEach((item) {
                  Map<String, String> notification = {
                    'title': key,
                    'fullname': '',
                    // 'uid': item['uid'],
                    'senderid': notificationsnapshot.id,
                    'requestID': item['requestID'],
                  };
                  notificationsAndAlreadyReadNotifications[
                          notification['senderid']!] =
                      List.from(notificationsAndAlreadyReadNotifications[
                              notification['senderid']!] ??
                          [])
                        ..add(notification);
                  if (!item.containsKey('read') || !item['read']) {
                    tempNotifications.add(notification);
                  }
                });
              }
            });
          } catch (e) {
            // print('error is $e');
          }
        }
        setState(() {
          notifications = tempNotifications;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void showNotificationsDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            // Dialog content
            child: Column(
              children: <Widget>[
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];

                      return Dismissible(
                        key: Key(notification.toString()),
                        onDismissed: (direction) {
                          // print('registered dimsiss at index ');
                          setState(() {
                            notifications.removeAt(index);
                          });

                          String notificationTitle =
                              notification['title'] ?? '';
                          print(
                              'notification senderId is ${notification['senderid']}');

                          //find the index of the notification in the list of notificationsAndAlreadyReadNotifications
                          // however the index of a particular senderid should start when that senderid starts appearing
                          // and not from the beginning of the list and incremented with every occurence of that senderid

                          int newIndexforSenderID = 0;
                          // print(
                          //     'notificationsAndAlreadyReadNotifications is $notificationsAndAlreadyReadNotifications');
                          //use the mapping to find the index of the notification in the list of notificationsAndAlreadyReadNotifications

                          int test = 0;
                          notificationsAndAlreadyReadNotifications
                              .forEach((key, value) {
                            if (key == notification['senderid']) {
                              newIndexforSenderID = value
                                  .indexWhere((element) =>
                                      element['requestID'] ==
                                      notification['requestID'])
                                  .toInt();
                            }
                          });
                          print('newIndexforSenderID is $newIndexforSenderID');

                          FirebaseFirestore.instance
                              .collection('AdminRequests')
                              .doc(notification['senderid'])
                              .get()
                              .then((docSnapshot) {
                            if (docSnapshot.exists) {
                              Map<String, dynamic>? data = docSnapshot.data();
                              // print(
                              //     'docsnapshot exists and notificationtitle is $notificationTitle and data is ${data?['notificationTitle']}');
                              if (data!.containsKey(notificationTitle) &&
                                  data[notificationTitle] is List) {
                                List<dynamic> notificationList =
                                    List.from(data[notificationTitle]);
                                if (index >= 0 &&
                                    index < notificationList.length) {
                                  print('reached here with index $index');
                                  print(
                                      'reached here with newIndex $newIndexforSenderID');
                                  // notificationList[index]['read'] = true;
                                  notificationList[newIndexforSenderID]
                                      ['read'] = true;
                                  FirebaseFirestore.instance
                                      .collection('AdminRequests')
                                      .doc(notification['senderid'])
                                      .update({
                                    notificationTitle: notificationList,
                                  });
                                }
                              }
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${notification['title']} dismissed'),
                            ),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(
                                width: 24.0,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.0),
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
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: notification.entries.map(
                                    (entry) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 24.0),
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '${entry.key}: ',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: entry.value,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xff0FA697),
                              Color(0xff45BF7A),
                              Color(0xff0DF205),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    }

    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          leading: Container(),
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
                    Row(
                      children: [
                        IconButton(
                          icon: Stack(
                            children: [
                              Icon(Icons.notifications_active),
                              if (notifications.length > 0)
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      notifications.length.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: showNotificationsDialog,
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              _getNotifs();
                            });
                          },
                        ),
                      ],
                    )
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
                padding: const EdgeInsets.only(top: 2.0),
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
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    color: Colors.orange,
                    icon: Icons.admin_panel_settings_rounded,
                    text: 'Admin Requests',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminRequestsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    color: Colors.purple,
                    icon: Icons.apartment,
                    text: 'Property Input',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminPropertyInputPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    color: Colors.red,
                    icon: Icons.edit,
                    text: 'Contracts Edit',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminContractsViewPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    color: Colors.teal,
                    icon: Icons.input,
                    text: 'Landlord Input',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminLandlordInputPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    color: Colors.indigo,
                    icon: Icons.local_offer,
                    text: 'Add and Delete\nVouchers',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminVouchersPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    color: Colors.deepPurpleAccent,
                    icon: Icons.person_add_alt_1,
                    text: 'Tenant Input',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminTenantsInputPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    color: Colors.cyan,
                    icon: Icons.analytics,
                    text: 'Data Analytics',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminAnalyticsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    color: Colors.indigoAccent,
                    icon: Icons.person_add_alt_1,
                    text: 'Dealer Input',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminDealerInputPage(),
                        ),
                      );
                    },
                  ),
                  // CustomButton(
                  //   color: Colors.grey,
                  //   icon: Icons.visibility_off,
                  //   text: 'Hide Profiles\nfrom Each Other',
                  //   onPressed: () {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   MaterialPageRoute(
                  //     //     builder: (context) => AdminPropertyContractsPage(
                  //     //       landlordID: '',
                  //     //       tenantID: '',
                  //     //     ),
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    color: const Color.fromARGB(255, 197, 79, 177),
                    icon: Icons.person,
                    text: 'Monthly rent off winner\nDiscount',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminRentOffWinnerPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    color: Colors.deepOrange,
                    icon: Icons.star,
                    text: 'Add Reviews\nand Testimonials',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminReviewsTestimonialsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    color: Colors.grey,
                    icon: Icons.pending,
                    text: 'Dealer Landlord\nE-stamp Creator',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminEstampsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    color: Colors.brown,
                    icon: Icons.auto_fix_high_outlined,
                    text: 'Enable/Disable\nUser Accounts',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminAccountsControlPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
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
