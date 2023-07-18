import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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
                DocumentSnapshot<Map<String, dynamic>> property =
                    properties[index];
                final propertyData = property.data();
                String title = propertyData?['title'] ?? 'No title';
                String address = propertyData?['address'] ?? 'No address';
                String tenantReview = propertyData?['tenantReview'] ?? '';
                double? rehnaaRating = propertyData?['rehnaaRating'];
                double? tenantRating = propertyData?['tenantRating'];

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
                    trailing: tenantReview.isNotEmpty
                        ? rehnaaRating != 0.0 && tenantRating != 0.0
                            ? Text(
                                'Review added and Rehnaa rating: $rehnaaRating and Tenant rating: $tenantRating',
                                textAlign: TextAlign.end,
                              )
                            : Text(
                                'Review added',
                                textAlign: TextAlign.end,
                              )
                        : null,
                    subtitle: Text(address),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ReviewDialog(
                            tenantReview: tenantReview,
                            tenantRating: tenantRating,
                            rehnaaRating: rehnaaRating,
                            propertyId: property.id,
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

class ReviewDialog extends StatefulWidget {
  String? tenantReview;
  double? tenantRating;
  double? rehnaaRating;
  String propertyId = '';

  ReviewDialog({
    super.key,
    this.tenantReview,
    this.tenantRating,
    this.rehnaaRating,
    required this.propertyId,
  });

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double? tenantRating;
  double? rehnaaRating;
  TextEditingController _reviewController = TextEditingController();
  String propertyId = '';

  @override
  void initState() {
    super.initState();
    tenantRating = widget.tenantRating;
    rehnaaRating = widget.rehnaaRating;
    _reviewController = TextEditingController(text: widget.tenantReview);
    propertyId = widget.propertyId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add a review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _reviewController,
            decoration: InputDecoration(
              hintText: 'Enter your review',
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Tenant Rating: '),
              RatingBar.builder(
                initialRating: tenantRating ?? 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 10,
                itemSize: 24,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    tenantRating = rating;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Rehnaa Rating: '),
              RatingBar.builder(
                initialRating: rehnaaRating ?? 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 10,
                itemSize: 24,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    rehnaaRating = rating;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // You would need to modify _addReview to use the state from here.
            _addReview(propertyId, tenantRating, rehnaaRating);
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Future<void> _addReview(
      String propertyId, double? tenantRating, double? rehnaaRating) async {
    // setState(() {
    //   _addingReview = true;
    // });

    try {
      print('tenantRating: $tenantRating');
      print('rehnaaRating: $rehnaaRating');
      await FirebaseFirestore.instance
          .collection('Properties')
          .doc(propertyId)
          .set({
        'tenantReview': _reviewController.text,
        'tenantRating': tenantRating,
        'rehnaaRating': rehnaaRating,
      }, SetOptions(merge: true));

      Fluttertoast.showToast(
        msg: 'Changes saved',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      //reload the page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AdminReviewsTestimonialsPage(),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to add review',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      // setState(() {
      //   _addingReview = false;
      // });
    }
  }
}
