import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Screens/Admin/admindashboard.dart';

class AdminReviewsTestimonialsPage extends StatefulWidget {
  const AdminReviewsTestimonialsPage({Key? key}) : super(key: key);

  @override
  _AdminReviewsTestimonialsPageState createState() =>
      _AdminReviewsTestimonialsPageState();
}

class _AdminReviewsTestimonialsPageState
    extends State<AdminReviewsTestimonialsPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _propertiesStream;
  TextEditingController _reviewController = TextEditingController();
  bool _addingReview = false;

  @override
  void initState() {
    super.initState();

    _propertiesStream =
        FirebaseFirestore.instance.collection('Properties').snapshots();
  }

  Future<void> _addReview(String propertyId) async {
    setState(() {
      _addingReview = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Properties')
          .doc(propertyId)
          .set({
        'tenantReview': _reviewController.text,
      }, SetOptions(merge: true));

      Fluttertoast.showToast(
        msg: 'Review added successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to add review',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _addingReview = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Reviews and Testimonials'),
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AdminDashboard(),
            ),
          );
        },
      ),
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _propertiesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Container(
            color: Colors.red,
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        } else {
          final properties = snapshot.data?.docs;

          if (properties == null || properties.isEmpty) {
            return Center(child: Text('No properties found'));
          }

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> property = properties[index];
              final propertyData = property.data();
              String title = propertyData?['title'] ?? 'No title';
              String address = propertyData?['address'] ?? 'No address';
              String tenantReview = propertyData?['tenantReview'] ?? '';

              return Card(
                child: ListTile(
                  leading: Icon(Icons.house),
                  title: Text(
                    title,
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: Text(address),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Add a review'),
                          content: TextField(
                            controller: _reviewController..text = tenantReview,
                            decoration: InputDecoration(
                              hintText: 'Enter your review',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _addingReview ? null : () => _addReview(property.id),
                              child: Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        }
      },
    ),
  );
}


}
