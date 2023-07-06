import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/landlordinvoice.dart';
import 'package:responsive_framework/responsive_scaled_box.dart';
import '../../../backend/models/tenantsmodel.dart';
import '../../Screens/pdf_landlord.dart';
import 'skeleton.dart';

class LandlordDashboardContent extends StatefulWidget {
  final String uid;
  final bool isWithdraw;
  final Function(bool) onUpdateWithdrawState;

  const LandlordDashboardContent({
    Key? key,
    required this.uid,
    required this.isWithdraw,
    required this.onUpdateWithdrawState,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LandlordDashboardContentState createState() =>
      _LandlordDashboardContentState();
}

class _LandlordDashboardContentState extends State<LandlordDashboardContent>
    with AutomaticKeepAliveClientMixin<LandlordDashboardContent> {
  // late Future<Landlord> _landlordFuture;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _landlordStream;

  @override
  bool get wantKeepAlive => true;
  bool isWithdraw = false;

  @override
  void initState() {
    super.initState();
    // Fetch landlord data from Firestore
    // _landlordFuture = getLandlordFromFirestore(widget.uid);
    // Establish the Firestore stream for the landlord document
    print('widget.uid is ${widget.uid}');
    _landlordStream = FirebaseFirestore.instance
        .collection('Landlords')
        .doc(widget.uid)
        .snapshots();
  }

  Future<Landlord> getLandlordFromFirestore(String uid) async {
    // try {
    // Fetch the landlord document from Firestore
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Landlords').doc(uid).get();
    if (kDebugMode) {
      print('Fetched snapshot: ${snapshot.data()}');
    }

    // Convert the snapshot to JSON
    Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;
    if (kDebugMode) {
      print('Landlord JSON: $json');
    }

    // Use the Landlord.fromJson method to create a Landlord instance
    Landlord landlord = await Landlord.fromJson(json);

    if (json['isWithdraw'] != null && json['isWithdraw'] == true) {
      setState(() {
        isWithdraw = true;
      });
    }
    if (kDebugMode) {
      print('Created landlord: $landlord');
    }

    return landlord;
    // } catch (error) {
    //   if (kDebugMode) {
    //     print('Error fetching landlord: $error');
    //   }
    //   rethrow;
    // }
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

  void showOptionDialog(Function callback, Landlord landlord) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // print('Firebase auth id is: ${FirebaseAuth.instance.currentUser!.uid}');
        String selectedOption = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Size size = MediaQuery.of(context).size;
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
              // contentPadding: const EdgeInsets.fromLTRB(.0, 20.0, 16.0, 8.0),
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
                          double withdrawalAmount = 0.0;

                          return AlertDialog(
                            title: Text(
                              'Enter Withdrawal Amount',
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
                                withdrawalAmount =
                                    double.tryParse(value) ?? 0.0;
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
                                onPressed: () {
                                  String invoiceNumber =
                                      generateInvoiceNumber();
                                  if (withdrawalAmount > 0 &&
                                      withdrawalAmount <= landlord.balance) {
                                    //showdialog box let user select particular tenant and then show pdf editor page
                                    // because we have to use landlord.tenantref.get() and then use that snapshot to get tenant data
                                    // first listview of tenantref list then futurebuilder to get each tenantref.get() and then use that snapshot to get tenant data

                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Select Tenant'),
                                            content: Container(
                                              height: 300,
                                              width: 300,
                                              child: ListView.builder(
                                                itemCount:
                                                    landlord.tenantRef?.length,
                                                itemBuilder: (context, index) {
                                                  return FutureBuilder(
                                                    future: landlord
                                                        .tenantRef?[index]
                                                        .get(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        Tenant tenant = Tenant
                                                            .fromJson(snapshot
                                                                    .data
                                                                    ?.data()
                                                                as Map<String,
                                                                    dynamic>);
                                                        return ListTile(
                                                          title: Text(
                                                              '${tenant.firstName} ${tenant.lastName}'),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            Fluttertoast
                                                                .showToast(
                                                              msg:
                                                                  'An admin will contact you soon regarding your payment request via: $selectedOption',
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                              timeInSecForIosWeb:
                                                                  3,
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xff45BF7A),
                                                            );
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Notifications')
                                                                .doc(widget.uid)
                                                                .set(
                                                                    {
                                                                  'notifications':
                                                                      FieldValue
                                                                          .arrayUnion([
                                                                    {
                                                                      'title':
                                                                          'Withdraw Request by ${'${landlord.firstName} ${landlord.lastName}'}',
                                                                      'amount':
                                                                          'Rs${withdrawalAmount}',
                                                                    }
                                                                  ]),
                                                                },
                                                                    SetOptions(
                                                                        merge:
                                                                            true));
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Landlords')
                                                                .doc(widget.uid)
                                                                .set(
                                                                    {
                                                                  'isWithdraw':
                                                                      true,
                                                                },
                                                                    SetOptions(
                                                                        merge:
                                                                            true));

                                                            // Generate a random ID
                                                            final Random
                                                                random =
                                                                Random();
                                                            final String
                                                                randomID =
                                                                random
                                                                    .nextInt(
                                                                        999999)
                                                                    .toString()
                                                                    .padLeft(
                                                                        6, '0');

                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'AdminRequests')
                                                                .doc(widget.uid)
                                                                .set(
                                                                    {
                                                                  'withdrawRequest':
                                                                      FieldValue
                                                                          .arrayUnion([
                                                                    {
                                                                      'fullname':
                                                                          '${landlord.firstName} ${landlord.lastName}',
                                                                      'amount':
                                                                          withdrawalAmount,
                                                                      'paymentMethod':
                                                                          selectedOption,
                                                                      'uid': widget
                                                                          .uid,
                                                                      'invoiceNumber':
                                                                          invoiceNumber,
                                                                      'tenantname':
                                                                          '${tenant.firstName} ${tenant.lastName}',
                                                                      'requestID':
                                                                          randomID,
                                                                    }
                                                                  ]),
                                                                  'timestamp':
                                                                      Timestamp
                                                                          .now(),
                                                                },
                                                                    SetOptions(
                                                                        merge:
                                                                            true));

                                                            setState(() {
                                                              isWithdraw = true;
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                            PDFEditorPage
                                                                pdfinstance =
                                                                PDFEditorPage();

                                                            pdfinstance.createState().createPdf(
                                                                tenant.firstName +
                                                                    ' ' +
                                                                    tenant
                                                                        .lastName,
                                                                landlord.firstName +
                                                                    ' ' +
                                                                    landlord
                                                                        .lastName,
                                                                landlord
                                                                    .address,
                                                                tenant.address,
                                                                landlord.balance
                                                                    .toDouble(),
                                                                withdrawalAmount,
                                                                selectedOption,
                                                                widget.uid,
                                                                invoiceNumber);

                                                            // Navigator.push(
                                                            //   context,
                                                            //   MaterialPageRoute(
                                                            //       builder:
                                                            //           (context) =>
                                                            //               PDFEditorPage(
                                                            //                 tenantName:
                                                            //                     '${tenant.firstName} ${tenant.lastName}',
                                                            //                 balance:
                                                            //                     tenant.rent.toDouble(),
                                                            //                 landlordName:
                                                            //                     '${landlord.firstName} ${landlord.lastName}',
                                                            //                 amount:
                                                            //                     withdrawalAmount,
                                                            //                 paymentMode:
                                                            //                     selectedOption,
                                                            //                 uid:
                                                            //                     widget.uid,
                                                            //                 landlordAddress:
                                                            //                     landlord.address,
                                                            //                 tenantAddress:
                                                            //                     tenant.address,
                                                            //                 invoiceNumber:
                                                            //                     invoiceNumber,
                                                            //               )),
                                                            // );
                                                          },
                                                        );
                                                      } else {
                                                        return const Center(
                                                          child:
                                                              SpinKitFadingCube(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    30,
                                                                    197,
                                                                    83),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        });

                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => PDFEditorPage(
                                    //             tenantName:
                                    //                 '${tenant.firstName} ${tenant.lastName}',
                                    //             balance: tenant.rent.toDouble(),
                                    //             landlordName:
                                    //                 '${landlord.firstName} ${landlord.lastName}',
                                    //             amount: withdrawalAmount,
                                    //             paymentMode: selectedOption,
                                    //             uid: widget.uid,
                                    //             landlordAddress:
                                    //                 landlord.address,
                                    //             tenantAddress: tenant.address,
                                    //             invoiceNumber: invoiceNumber,
                                    //           )),
                                    // );
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

  void someFunction(Landlord landlord) {
    showOptionDialog(() {
      // setState(() {
      //   isWithdraw = true;
      // });
      widget.onUpdateWithdrawState(isWithdraw);
    }, landlord);
  }

  Widget buildOptionTile({
    String selectedOption = "",
    String optionImage = "",
    String optionName = "",
    VoidCallback? onTap,
    Size? size,
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the state is kept alive
    final Size size = MediaQuery.of(context).size;

    if (kDebugMode) {
      // print('UID: ${widget.uid}');
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _landlordStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LandlordDashboardContentSkeleton();
        } else if (snapshot.hasError) {
          // Handle any error that occurred while fetching the data
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // Convert the snapshot to JSON
          // print('Snapshot: ${snapshot.data!.data()}');
          Map<String, dynamic> json =
              snapshot.data!.data() as Map<String, dynamic>;
          if (kDebugMode) {
            // print('Landlord JSON: $json');
          }
          // Use the Landlord.fromJson method to create a Landlord instance
          Landlord landlord = Landlord.fromJson(json);

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
          String formattedBalance =
              NumberFormat('#,##0').format(landlord.balance);

          // Return the widget tree with the fetched data
          return ResponsiveScaledBox(
              width: size.width,
              child: SingleChildScrollView(
                  // child: AnimatedContainer(
                  //     duration: Duration(milliseconds: 500),
                  //     curve: Curves.easeInOut,
                  //     height:
                  //         _showContent ? size.height : 0, // Show/hide the content
                  child: Column(
                children: <Widget>[
                  SizedBox(height: size.height * 0.05),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Welcome ${landlord.firstName}!',
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
                            child: landlord.pathToImage != null &&
                                    landlord.pathToImage!.isNotEmpty
                                ? (landlord.pathToImage!.startsWith('assets')
                                    ? Image.asset(
                                        landlord.pathToImage!,
                                        width: 150,
                                        height: 150,
                                      )
                                    : Image.network(
                                        fit: BoxFit.fill,
                                        landlord.pathToImage!,
                                        width: 150,
                                        height: 150,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: const SpinKitFadingCube(
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
                      SizedBox(height: size.height * 0.05),
                    ],
                  ),
                  Center(
                    child: Container(
                      width: size.width * 0.8,
                      height: size.height * 0.3, // Adjust the height as needed
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
                                    'Available Balance',
                                    style: GoogleFonts.montserrat(
                                      fontSize: size.width * 0.05,
                                      fontWeight: FontWeight.w400,
                                      color: const Color.fromARGB(150, 0, 0, 0),
                                    ),
                                  ),
                                  Text(
                                    'PKR $formattedBalance',
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
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          isWithdraw
                                              ? null
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             PDFEditorPage()))
                                              : someFunction(
                                                  landlord); // Show the option dialog
                                        },
                                        child: Center(
                                          child: Text(
                                            isWithdraw
                                                ? "Withdraw Requested"
                                                : "Withdraw",
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
                ],
              )));
          // )));
        }

        // By default, return an empty container if no data is available
        return Container();
      },
    );
  }
}

class LandlordDashboardContentSkeleton extends StatelessWidget {
  const LandlordDashboardContentSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: size.height * 0.05),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Skeleton(width: size.width * 0.5, height: 30),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: CircleSkeleton(
                  size: 150,
                ),
              ),
              SizedBox(height: size.height * 0.05),
            ],
          ),
          Center(
            child: Container(
              width: size.width * 0.8,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Skeleton(width: size.width * 0.5, height: 20),
                        const SizedBox(height: 16),
                        Skeleton(width: size.width * 0.5, height: 30),
                        SizedBox(height: size.height * 0.05),
                        Skeleton(width: size.width * 0.5, height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
