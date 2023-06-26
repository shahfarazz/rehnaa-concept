import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/landlord_propertyinfo.dart';

import '../../../backend/models/propertymodel.dart';
// import '../../Screens/Admin/admindashboard.dart';
import '../Landlorddashboard_pages/landlordproperties.dart';
import 'Tenant_propertyinfo.dart';

class TenantRentedPropertyPage extends StatefulWidget {
  String uid;
  TenantRentedPropertyPage({super.key, required this.uid});

  @override
  State<TenantRentedPropertyPage> createState() =>
      _TenantRentedPropertyPageState();
}

class _TenantRentedPropertyPageState extends State<TenantRentedPropertyPage> {
  late Stream stream;
  bool isStreamLoaded = false;
  String firstName = '';
  String lastName = '';
  String pathToImage = 'assets/defaulticon.png';
  String emailOrPhone = '';

  void _initStream() async {
    //use uid to generate reference to tenant document

    DocumentReference<Map<String, dynamic>> tenantRef =
        FirebaseFirestore.instance.collection('Tenants').doc(widget.uid);

    stream = FirebaseFirestore.instance
        .collection('Properties')
        .where('tenantRef', isEqualTo: tenantRef)
        .snapshots();

    // get landlordRef from the property document
    // use landlordRef to generate reference to landlord document
    // get landlord's first name, last name and path to image

    stream.listen((event) {
      if (event.docs.isNotEmpty) {
        var propertyData = event.docs[0].data();
        var landlordRef = propertyData['landlordRef'];
        DocumentReference<Map<String, dynamic>> landlordRefDoc =
            landlordRef as DocumentReference<Map<String, dynamic>>;

        landlordRefDoc.get().then((value) {
          var landlordData = value.data();
          if (landlordData != null) {
            firstName = landlordData['firstName'];
            lastName = landlordData['lastName'];
            pathToImage = landlordData['pathToImage'];
            emailOrPhone = landlordData['emailOrPhone'];
          }

          setState(() {});
        });
      }
    });

    setState(() {
      isStreamLoaded = true;
    });
  }

  @override
  void initState() {
    _initStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: //add a gradient app bar with gradient backhround with a white back button
          AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
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
            ),
          ),
        ),
        title: Text(
          'Rented Property',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: stream,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !isStreamLoaded) {
              //return skeleton ui
              return const LandlordPropertiesSkeleton();
            } else if (!snapshot.hasData) {
              //return no properties rented
              return Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
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
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.house,
                              color: Colors.green,
                              size: 50,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No rented property yet',
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else if (snapshot.data!.docs.isEmpty) {
              //return no properties rented
              return Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
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
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.house,
                              color: Colors.green,
                              size: 50,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No rented property yet',
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              //get data from snapshot

              // print('data is ${snapshot.data!.docs[0].data()}}}');
              var propData = snapshot.data!.docs[0].data();
              Property property =
                  Property.fromJson(propData as Map<String, dynamic>);

              // var propertyID = snapshot.data!.docs[0].id;
              // var uid = widget.uid;
              var location = property.location;
              var address = property.address;
              // var isWithdraw = false;

              return PropertyPage(
                property: property,
                firstName: firstName,
                lastName: lastName,
                pathToImage: pathToImage,
                location: location,
                address: address,
                emailOrPhone: emailOrPhone,
                isTenantCall: true,
              );
            }
          })),
    );

    // TenantPropertyPage(property: property, firstName: firstName, lastName: lastName, pathToImage: pathToImage, location: location, address: address, uid: uid, isWithdraw: isWithdraw, propertyID: propertyID)
  }
}
