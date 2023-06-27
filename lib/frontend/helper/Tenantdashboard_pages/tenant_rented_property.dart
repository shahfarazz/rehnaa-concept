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
      
      body: StreamBuilder(
          stream: stream,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !isStreamLoaded) {
              //return skeleton ui
              return const LandlordPropertiesSkeleton();
            } 
            else if (snapshot.data!.docs.isEmpty || !snapshot.hasData) {
            
        final Size size = MediaQuery.of(context).size;

    
    return Scaffold(
      appBar: _buildAppBar(size, context),
    body: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Padding(
          padding: EdgeInsets.only(left: 65,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(height: 50),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.house,
                            size: 48.0,
                            color: Color(0xff33907c),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'No rented property yet',
                            style: GoogleFonts.montserrat(
                              fontSize: 20.0,
                              color: const Color(0xff33907c),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    ),
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

PreferredSizeWidget _buildAppBar(Size size, context) {
    return AppBar(
      toolbarHeight: 70,
      
      title: Padding(
        padding: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.14, // 55% of the page width
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
            // const SizedBox(width: 8),
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Stack(
            children: [
              
              
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