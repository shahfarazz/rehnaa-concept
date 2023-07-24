import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/propertymodel.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenant_form.dart';
import 'package:rehnaa/frontend/helper/Tenantdashboard_pages/tenantinvoice.dart';

import 'package:responsive_framework/responsive_framework.dart';
import '../../../backend/models/landlordmodel.dart';
// import '../../Screens/pdf_landlord.dart';
import '../../../backend/services/firebase_notifications_api.dart';
import '../../Screens/pdf_tenant.dart';
import '../Landlorddashboard_pages/landlord_dashboard_content.dart';

class TenantDashboardContent extends StatefulWidget {
  final String uid; // UID of the tenant
  final bool isWithdraw;
  final Function(bool) onUpdateWithdrawState;

  const TenantDashboardContent(
      {Key? key,
      required this.uid,
      required this.isWithdraw,
      required this.onUpdateWithdrawState})
      : super(key: key);

  @override
  _TenantDashboardContentState createState() => _TenantDashboardContentState();
}

class _TenantDashboardContentState extends State<TenantDashboardContent>
    with AutomaticKeepAliveClientMixin<TenantDashboardContent> {
  late Future<Tenant> _tenantFuture;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _tenantStream;

  @override
  bool get wantKeepAlive => true;
  bool isWithdraw = false;
  final _firebaseApi = FirebaseApi();

  @override
  void initState() {
    super.initState();
    // Fetch tenant data from Firestore
    _tenantStream = FirebaseFirestore.instance
        .collection('Tenants')
        .doc(widget.uid)
        .snapshots();
    _firebaseApi.initNotifications();
  }

  String generateInvoiceNumber() {
    var rng = Random();
    // Generate a random number between 10000 and 99999.
    int randomNumber = rng.nextInt(90000) + 10000;
    // Combine the prefix and the random number to form the invoice number.
    String invoiceNumber =
        'INV' + DateTime.now().year.toString() + randomNumber.toString();
    return invoiceNumber;
  }

  void showOptionDialog(Function callback, Tenant tenant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedOption = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Your AlertDialog code goes here...
            return AlertDialog(
              title: Padding(
                padding:
                    EdgeInsets.only(top: 16.0), // Adjust the value as needed
                child: Text(
                  'Withdraw Options',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                      fontFamily: GoogleFonts.montserrat().fontFamily),
                ),
              ),

              // titlePadding: const EdgeInsets.fromLTRB(
              //     20.0, 16.0, 16.0, 0.0), // padding above title
              // contentPadding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Divider(
                    color: Colors.grey,
                  ), // added grey line
                  buildOptionTile(
                    selectedOption: selectedOption,
                    optionImage: 'assets/cashicon.png',
                    optionName: 'Cash',
                    onTap: () {
                      setState(() {
                        selectedOption = 'Cash';
                      });
                    },
                  ),
                  // buildOptionTile(
                  //   selectedOption: selectedOption,
                  //   optionImage: 'assets/easypaisa.png',
                  //   optionName: 'Easy Paisa',
                  //   onTap: () {
                  //     setState(() {
                  //       selectedOption = 'Easy Paisa';
                  //     });
                  //   },
                  // ),
                  // buildOptionTile(
                  //   selectedOption: selectedOption,
                  //   optionImage: 'assets/jazzcash.png',
                  //   optionName: 'Jazz Cash',
                  //   onTap: () {
                  //     setState(() {
                  //       selectedOption = 'Jazz Cash';
                  //     });
                  //   },
                  // ),
                  buildOptionTile(
                    selectedOption: selectedOption,
                    optionImage: 'assets/banktransfer.png',
                    optionName: 'Bank Transfer',
                    onTap: () {
                      setState(() {
                        selectedOption = 'Bank Transfer';
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedOption.isNotEmpty ? Colors.grey : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedOption.isNotEmpty ? Colors.green : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                  ),
                  onPressed: () {
                    if (selectedOption.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          double amount = 0.0;

                          return AlertDialog(
                            title: Text(
                              'Enter Payment Amount',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.normal,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                                color: Colors.green,
                              ),
                            ),
                            content: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                amount = double.tryParse(value) ?? 0.0;
                              },
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                  ),
                                ),
                                onPressed: () async {
                                  if (amount > 0 && amount <= tenant.balance) {
                                    FirebaseFirestore.instance
                                        .collection('Notifications')
                                        .doc(widget.uid)
                                        .set({
                                      'notifications': FieldValue.arrayUnion([
                                        {
                                          'title':
                                              'Payment Request by ${'${tenant.firstName} ${tenant.lastName}'}',
                                          'amount': 'Rs${amount}',
                                        }
                                      ]),
                                    }, SetOptions(merge: true));

                                    // _firebaseApi.showNotification(
                                    //   title:
                                    //       'Payment Request by ${'${tenant.firstName} ${tenant.lastName}'}',
                                    //   body: 'Rs${amount}',
                                    // );

                                    FirebaseFirestore.instance
                                        .collection('Tenants')
                                        .doc(widget.uid)
                                        .set({
                                      'isWithdraw': true,
                                    }, SetOptions(merge: true));

                                    String invoiceNumber =
                                        generateInvoiceNumber();

                                    // Generate a random ID
                                    final Random random = Random();
                                    final String randomID = random
                                        .nextInt(999999)
                                        .toString()
                                        .padLeft(6, '0');

                                    setState(() {
                                      isWithdraw = true;
                                    });

                                    //showdialog box let user select particular landlord and then show pdf editor page
                                    // because we have to use tenant.landlordref.get() and then use that snapshot to get tenant data
                                    // first listview of landlordref list then futurebuilder to get each landlordref.get() and then use that snapshot to get landlord data
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              title: Text('Select Landlord'),
                                              content: Container(
                                                  width: 300,
                                                  height: 300,
                                                  child: ListView.builder(
                                                      itemCount: tenant
                                                          .landlordRef?.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return FutureBuilder(
                                                            future: tenant
                                                                .landlordRef?[
                                                                    index]
                                                                .get(),
                                                            builder: (context,
                                                                snapshot) {
                                                              Property?
                                                                  property;
                                                              if (snapshot
                                                                  .hasData) {
                                                                Landlord
                                                                    landlord =
                                                                    Landlord.fromJson(snapshot
                                                                            .data
                                                                            ?.data()
                                                                        as Map<
                                                                            String,
                                                                            dynamic>);
                                                                landlord.tempID =
                                                                    snapshot
                                                                        .data!
                                                                        .id;
                                                                return ListTile(
                                                                    title: Text(
                                                                        '${landlord.firstName} ${landlord.lastName}'),
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      //show dialog generating pdf...
                                                                      PDFEditorTenantPage
                                                                          pdfinstance =
                                                                          PDFEditorTenantPage();

                                                                      //find the property where landlordref is equal to the landlordref of the tenant
                                                                      // and tenantref is equal to the tenantref of the tenant
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Properties')
                                                                          .get()
                                                                          .then(
                                                                              (value) {
                                                                        // String propertyID = '';

                                                                        value
                                                                            .docs
                                                                            .forEach((element) {
                                                                          // print(
                                                                          //     '222element landlord ref is ${element.data()['landlordRef'].path}');
                                                                          // print(
                                                                          //     '222element tenant ref is ${element.data()['tenantRef'].path}');
                                                                          // print(
                                                                          //     '222my landlord ref is ${FirebaseFirestore.instance.collection('Landlords').doc(landlord.tempID).path}');

                                                                          // print(
                                                                          //     '222my tenant ref is ${FirebaseFirestore.instance.collection('Tenants').doc(tenant.tempID).path}');
                                                                          var landlordRef =
                                                                              element.data()['landlordRef'];
                                                                          var tenantRef =
                                                                              element.data()['tenantRef'];
                                                                          if (landlordRef != null &&
                                                                              landlordRef.path == FirebaseFirestore.instance.collection('Landlords').doc(landlord.tempID).path &&
                                                                              tenantRef != null &&
                                                                              tenantRef.path == FirebaseFirestore.instance.collection('Tenants').doc(tenant.tempID).path) {
                                                                            // propertyID = element.id;
                                                                            // print('222foundrpoperty');
                                                                            property =
                                                                                Property.fromJson(element.data() as Map<String, dynamic>);
                                                                            return;
                                                                          }
                                                                        });
                                                                      }).then(
                                                                              (_) {
                                                                        // print(
                                                                        //     '222idheragayabhaii');
                                                                        if (property ==
                                                                            null) {
                                                                          // print(
                                                                          //     '222 property was null');
                                                                          Fluttertoast
                                                                              .showToast(
                                                                            msg:
                                                                                'No property found with this landlord',
                                                                            toastLength:
                                                                                Toast.LENGTH_SHORT,
                                                                            gravity:
                                                                                ToastGravity.BOTTOM,
                                                                            timeInSecForIosWeb:
                                                                                3,
                                                                            backgroundColor:
                                                                                Colors.red,
                                                                          );
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pop(
                                                                              context);
                                                                          return;
                                                                        }

                                                                        print(
                                                                            '222 reaached herer proeprty adress is ${property?.address}');

                                                                        pdfinstance
                                                                            .createState()
                                                                            .createPdf(
                                                                                '${tenant.firstName} ${tenant.lastName}',
                                                                                '${landlord.firstName} ${landlord.lastName}',
                                                                                landlord.address,
                                                                                property?.address,
                                                                                tenant.balance.toDouble(),
                                                                                amount,
                                                                                selectedOption,
                                                                                widget.uid,
                                                                                invoiceNumber,
                                                                                landlord.cnic ?? 'No cnic provided')
                                                                            .then((_) {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('AdminRequests')
                                                                              .doc(widget.uid)
                                                                              .set({
                                                                            'paymentRequest':
                                                                                FieldValue.arrayUnion([
                                                                              {
                                                                                'fullname': '${tenant.firstName} ${tenant.lastName}',
                                                                                'amount': amount,
                                                                                'paymentMethod': selectedOption,
                                                                                'uid': widget.uid,
                                                                                'invoiceNumber': invoiceNumber,
                                                                                'requestID': randomID,
                                                                                'timestamp': Timestamp.now(),
                                                                              }
                                                                            ]),
                                                                          }, SetOptions(merge: true));

                                                                          print(
                                                                              '222 we reached till here where we pop');
                                                                        });
                                                                      }).catchError(
                                                                              (error) {
                                                                        print(
                                                                            'error222 is $error');
                                                                        return;
                                                                      });
                                                                      Fluttertoast
                                                                          .showToast(
                                                                        msg:
                                                                            'An admin will contact you soon regarding your payment via: $selectedOption',
                                                                        toastLength:
                                                                            Toast.LENGTH_SHORT,
                                                                        gravity:
                                                                            ToastGravity.BOTTOM,
                                                                        timeInSecForIosWeb:
                                                                            3,
                                                                        backgroundColor:
                                                                            const Color(0xff45BF7A),
                                                                      );
                                                                      Navigator.pop(
                                                                          context);
                                                                      Navigator.pop(
                                                                          context);
                                                                    });
                                                              } else {
                                                                return const Center(
                                                                  child:
                                                                      SpinKitFadingCube(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            30,
                                                                            197,
                                                                            83),
                                                                  ),
                                                                );
                                                              }
                                                            });
                                                      })));
                                        });
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: 'Invalid withdrawal amount',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      if (kDebugMode) {
                        print('Please select an option');
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) => callback());
  }

  void someFunction(Tenant tenant) {
    if (tenant.landlordRef == null) {
      Fluttertoast.showToast(
        msg: 'No landlord found',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
      );
      return;
    }
    showOptionDialog(() {
      // setState(() {
      isWithdraw = true;
      // });
      widget.onUpdateWithdrawState(false);
    }, tenant);
  }

  Widget buildOptionTile({
    String selectedOption = "",
    String optionImage = "",
    String optionName = "",
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: selectedOption == optionName
          ? const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 10,
            )
          : const Icon(Icons.circle, size: 20),
      title: Row(
        children: [
          Image.asset(
            optionImage,
            width: 50,
            height: 30,
          ),
          const SizedBox(width: 8.0), // Add some spacing
          Expanded(
            child: Text(
              optionName,
              style: TextStyle(fontFamily: GoogleFonts.montserrat().fontFamily),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  dispose() {
    _tenantStream.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the state is kept alive
    final Size size = MediaQuery.of(context).size;

    // if (kDebugMode) {
    //   print('UID: ${widget.uid}');
    // }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _tenantStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the data
          return const LandlordDashboardContentSkeleton();
        } else if (snapshot.hasError) {
          // Handle any error that occurred while fetching the data
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // print('snapshot: ${snapshot.data?.data()}');
          Map<String, dynamic> json =
              snapshot.data?.data() as Map<String, dynamic>;
          // Fetch tenant
          Tenant tenant = Tenant.fromJson(json);
          tenant.tempID = snapshot.data!.id;
          if (json['isWithdraw'] != null && json['isWithdraw'] == true) {
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  isWithdraw = true;
                });
              }
            });
          } else {
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  isWithdraw = false;
                });
              }
            });
          }
          // Format the balance for display
          String formattedRent = NumberFormat('#,##0').format(tenant.balance);
          var isDetailsFilled = json['isDetailsFilled'] as bool? ?? false;
          // if (isDetailsFilled) {
          //   WidgetsBinding.instance?.addPostFrameCallback((_) {
          //     //show Fluttertoast saying 'How can we help you?'
          //     Fluttertoast.showToast(
          //       msg: 'How can we help you?',
          //       toastLength: Toast.LENGTH_LONG,
          //       gravity: ToastGravity.BOTTOM,
          //       timeInSecForIosWeb: 2,
          //       backgroundColor: Colors.green,
          //       textColor: Colors.white,
          //       fontSize: 16.0,
          //     );
          //   });
          // }

          Size size = MediaQuery.of(context).size;

          // Return the widget tree with the fetched data
          return ResponsiveScaledBox(
              width: size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: size.height * 0.05),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Welcome ${tenant.firstName}!',
                            style: GoogleFonts.montserrat(
                              fontSize: 26,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: CircleAvatar(
                            radius: 75,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: tenant.pathToImage != null &&
                                      tenant.pathToImage!.isNotEmpty
                                  ? (tenant.pathToImage!.startsWith('assets')
                                      ? Image.asset(
                                          tenant.pathToImage!,
                                          width: 150,
                                          height: 150,
                                        )
                                      : Image.network(
                                          tenant.pathToImage!,
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 150,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child: SpinKitFadingCube(
                                                color: Color.fromARGB(
                                                    255, 30, 197, 83),
                                              ),
                                            );
                                          },
                                        ))
                                  : Image.asset(
                                      'assets/defaulticon.png',
                                      width: 150,
                                      height: 150,
                                    ),
                            ),
                          ),
                        ),
                        // SizedBox(height: size.height * 0.02),
                      ],
                    ),
                    Center(
                      child: Container(
                        width: size.width * 0.8,
                        height:
                            size.height * 0.3, // Adjust the height as needed
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(
                                  0, 4), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Rent Accrue',
                                      style: GoogleFonts.montserrat(
                                        fontSize: size.width * 0.05,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            const Color.fromARGB(150, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
                                      'PKR $formattedRent',
                                      style: GoogleFonts.montserrat(
                                        fontSize: size.width * 0.07,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.05),
                                    Container(
                                      width: size.width *
                                          0.6, // Increase the width as needed
                                      height: size.height * 0.06,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: isWithdraw
                                              ? [
                                                  Colors.grey,
                                                  Colors.grey,
                                                  Colors.grey,
                                                ]
                                              : [
                                                  const Color(0xff0FA697),
                                                  const Color(0xff45BF7A),
                                                  const Color(0xff0DF205),
                                                ],
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: () {
                                            isWithdraw
                                                ? null
                                                : someFunction(tenant);
                                            // Show the option dialog
                                          },
                                          child: Center(
                                            child: Text(
                                              isWithdraw
                                                  ? "Payment Requested"
                                                  : "Pay",
                                              style: GoogleFonts.montserrat(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    !isDetailsFilled
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //show tooltip that "How can we help you?"
                              Tooltip(
                                message: 'How can we help you?',
                                child: Material(
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28.0),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TenantForms(
                                            uid: widget.uid,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(28.0),
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xff0FA697),
                                            const Color(0xff45BF7A),
                                            const Color(0xff0DF205),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(28.0),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ));
        }

        // By default, return an empty container if no data is available
        return Container();
      },
    );
  }
}
