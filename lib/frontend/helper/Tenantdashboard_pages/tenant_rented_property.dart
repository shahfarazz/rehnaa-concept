import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/frontend/helper/Landlorddashboard_pages/landlord_propertyinfo.dart';

import '../../../backend/models/propertymodel.dart';
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
      var propertyData = event.docs[0].data();
      var landlordRef = propertyData['landlordRef'];
      DocumentReference<Map<String, dynamic>> landlordRefDoc =
          landlordRef as DocumentReference<Map<String, dynamic>>;

      landlordRefDoc.get().then((value) {
        var landlordData = value.data();
        firstName = landlordData!['firstName'];
        lastName = landlordData['lastName'];
        pathToImage = landlordData['pathToImage'];
        setState(() {});
      });
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
    return StreamBuilder(
        stream: stream,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !isStreamLoaded) {
            //return skeleton ui
            return const LandlordPropertiesSkeleton();
          } else if (!snapshot.hasData && isStreamLoaded) {
            //return no properties rented
            return Center(
              child: Card(
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
                        'No Properties rented yet',
                        style: GoogleFonts.montserrat(
                          fontSize: 20.0,
                          // fontWeight: FontWeight.bold,
                          color: const Color(0xff33907c),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            //get data from snapshot
            try {
              print('data is ${snapshot.data!.docs[0].data()}}}');
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
                  address: address);
            } catch (e) {
              print('error is $e');
            }

            //return list of properties rented
            // return TenantPropertyPage(property: property, firstName: firstName, lastName: lastName, pathToImage: pathToImage, location: location, address: address, uid: uid, isWithdraw: isWithdraw, propertyID: propertyID)
            return Container();
          }
        }));

    // TenantPropertyPage(property: property, firstName: firstName, lastName: lastName, pathToImage: pathToImage, location: location, address: address, uid: uid, isWithdraw: isWithdraw, propertyID: propertyID)
  }
}
