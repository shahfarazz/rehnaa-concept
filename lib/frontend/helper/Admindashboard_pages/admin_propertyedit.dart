import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../backend/models/propertymodel.dart';

class PropertyEditPage extends StatefulWidget {
  final Property property;

  const PropertyEditPage({required this.property});

  @override
  _PropertyEditPageState createState() => _PropertyEditPageState();
}

class _PropertyEditPageState extends State<PropertyEditPage> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController typeController;
  late TextEditingController bedsController;
  late TextEditingController bathsController;
  late TextEditingController descriptionController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.property.title);
    locationController = TextEditingController(text: widget.property.location);
    typeController = TextEditingController(text: widget.property.type);
    bedsController =
        TextEditingController(text: widget.property.beds.toString());
    bathsController =
        TextEditingController(text: widget.property.baths.toString());
    descriptionController =
        TextEditingController(text: widget.property.description);
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    typeController.dispose();
    bedsController.dispose();
    bathsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Update property data in Firestore
      await FirebaseFirestore.instance
          .collection('Properties')
          .doc(widget.property.propertyID)
          .update({
        'title': titleController.text,
        'location': locationController.text,
        'type': typeController.text,
        'beds': int.tryParse(bedsController.text) ?? 0,
        'baths': int.tryParse(bathsController.text) ?? 0,
        'description': descriptionController.text,
      });

      // Update property object with edited values
      widget.property.title = titleController.text;
      widget.property.location = locationController.text;
      widget.property.type = typeController.text;
      widget.property.beds = int.tryParse(bedsController.text) ?? 0;
      widget.property.baths = int.tryParse(bathsController.text) ?? 0;
      widget.property.description = descriptionController.text;

      Fluttertoast.showToast(
        msg: 'Changes saved successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to save changes. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
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
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: isLoading ? null : saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: bedsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Beds'),
            ),
            TextField(
              controller: bathsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Baths'),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              )
            : null,
      ),
    );
  }
}