import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehnaa/backend/models/landlordmodel.dart';
import 'package:rehnaa/backend/models/propertymodel.dart';
import 'package:rehnaa/backend/models/rentpaymentmodel.dart';
import 'package:rehnaa/backend/models/tenantsmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rehnaa/frontend/helper/bargraphs/bargraph.dart';

class AdminAnalyticsPage extends StatefulWidget {
  @override
  _AdminAnalyticsPageState createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  Future<List<Landlord>> getLandlords() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Landlords').get();

    List<Landlord> landlordList = [];

    for (var doc in querySnapshot.docs) {
      Landlord landlord = await Landlord.fromJson(doc.data());
      landlordList.add(landlord);
    }

    return landlordList;
  }

  Future<List<Property>> getProperties() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Properties').get();

    List<Property> propertyList = [];

    for (var doc in querySnapshot.docs) {
      Property property = await Property.fromJson(doc.data());
      propertyList.add(property);
    }

    return propertyList;
  }

  Future<List<RentPayment>> getrentPayments() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('rentPayments').get();

    List<RentPayment> rentPaymentsList = [];

    for (var doc in querySnapshot.docs) {
      RentPayment rentPayment = await RentPayment.fromJson(doc.data());
      rentPaymentsList.add(rentPayment);
    }

    return rentPaymentsList;
  }

  double calculateAverageRent(List<RentPayment> rentPayments) {
    double totalRent = 0;
    int count = rentPayments.length;

    for (RentPayment rentPayment in rentPayments) {
      totalRent += rentPayment.amount;
    }

    return totalRent / count;
  }

  Map<String, double> generateLocationAnalytics(List<Property> properties) {
    Map<String, double> locationCountMap = {};

    // Count the number of properties in each location
    for (Property property in properties) {
      String location = property.location;
      locationCountMap[location] = (locationCountMap[location] ?? 0) + 1;
    }

    return locationCountMap;
  }

  List<String> getCommercialResidentialAreas(List<Property> properties) {
    List<String> areas = [];

    // Perform calculations to determine commercial and residential areas

    return areas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics'),
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
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder<List<Landlord>>(
              future: getLandlords(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Landlord> landlords = snapshot.data!;

                  // Perform analytics calculations based on landlords data
                  // For example, calculate average balance across all landlords
                  double averageBalance = landlords
                          .map((landlord) => landlord.balance)
                          .reduce((a, b) => a + b) /
                      landlords.length;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 10,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average Balance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Rs.$averageBalance',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return CircularProgressIndicator();
              },
            ),
            FutureBuilder<List<Property>>(
              future: getProperties(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Property> properties = snapshot.data!;
                  Map<String, double> locationAnalytics =
                      generateLocationAnalytics(properties);

                  return Column(
                    children: [
                      Text(
                        'Location Analytics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                          height: 200,
                          width: 400,
                          child: MyBarGraph(xyValues: locationAnalytics))
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return CircularProgressIndicator();
              },
            ),
            FutureBuilder<List<Property>>(
              future: getProperties(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Property> properties = snapshot.data!;

                  // Perform analytics calculations based on properties data
                  // For example, get commercial and residential areas
                  List<String> areas =
                      getCommercialResidentialAreas(properties);

                  return Text(
                      'Commercial/Residential Areas: ${areas.join(', ')}');
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return CircularProgressIndicator();
              },
            ),
            // Add more FutureBuilders for additional analytics calculations
            FutureBuilder<List<RentPayment>>(
              future: getrentPayments(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<RentPayment> rentPayments = snapshot.data!;

                  // Perform analytics calculations based on rent payments data
                  // For example, calculate average rent
                  double averageRent = calculateAverageRent(rentPayments);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 10,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average Rent',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Rs.$averageRent',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
