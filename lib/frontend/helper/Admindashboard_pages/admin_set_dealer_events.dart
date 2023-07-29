import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../Screens/Admin/admindashboard.dart';

class AdminSetsDealerEventsPage extends StatefulWidget {
  const AdminSetsDealerEventsPage({Key? key}) : super(key: key);

  @override
  State<AdminSetsDealerEventsPage> createState() =>
      _AdminSetsDealerEventsPageState();
}

class _AdminSetsDealerEventsPageState extends State<AdminSetsDealerEventsPage> {
  final _formKey = GlobalKey<FormState>();
  final _eventsController = TextEditingController();

  @override
  void dispose() {
    _eventsController.dispose();
    // loadOldEvents();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadOldEvents();
  }

  void _saveEvents() async {
    // showDialog(context: context, builder: builder)
    //laoding indicator dialog
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: SpinKitFadingCube(
                color: Color.fromARGB(255, 30, 197, 83),
              ),
            ));

    if (_formKey.currentState!.validate()) {
      String events = _eventsController.text;

      CollectionReference dealers =
          FirebaseFirestore.instance.collection('Dealers');
      var allDealersSnapshot = await dealers.get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      allDealersSnapshot.docs.forEach((dealer) {
        batch.set(
            dealer.reference, {'events': events}, SetOptions(merge: true));
      });

      await batch.commit();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const AdminSetsDealerEventsPage();
      }));
    } else {
      //show snackbar error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter some text'),
      ));
      Navigator.pop(context);
    }
  }

  void loadOldEvents() async {
    //take a random dealer and get its events
    CollectionReference dealers =
        FirebaseFirestore.instance.collection('Dealers');
    var allDealersSnapshot = await dealers.get();
    var dealer = allDealersSnapshot.docs[0];
    var eventsData = dealer.data() as Map<String, dynamic>;
    var events = eventsData['events'];
    _eventsController.text = events;
    setState(() {
      print('reached here with events: $events');
      _eventsController.text = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dealer Events'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          },
        ),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _eventsController,
                decoration: const InputDecoration(
                  labelText: 'Events',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _saveEvents,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
