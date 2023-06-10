import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyListingPage extends StatefulWidget {
  const PropertyListingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PropertyListingPageState createState() => _PropertyListingPageState();
}

class _PropertyListingPageState extends State<PropertyListingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _buildYearController = TextEditingController();
  final TextEditingController _gradingController = TextEditingController();
  final TextEditingController _kitchensController = TextEditingController();
  final TextEditingController _floorsController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _utilitiesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Listing'),
        backgroundColor: const Color(0xFF33907C),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            buildIntegerFormField(_rentController, 'Rent Expectations'),
            buildIntegerFormField(_bedroomsController, 'Bedrooms'),
            buildIntegerFormField(_bathroomsController, 'Bathrooms'),
            buildIntegerFormField(_buildYearController, 'Build Year'),
            buildIntegerFormField(_gradingController, 'Rehnaa Grading'),
            buildIntegerFormField(_kitchensController, 'Kitchens'),
            buildIntegerFormField(_floorsController, 'Floors'),
            buildIntegerFormField(_areaController, 'Area'),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
              ),
            ),
            TextFormField(
              controller: _utilitiesController,
              decoration: const InputDecoration(
                labelText: 'Utilities Available',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process data, send to Firebase or your server...
                  if (kDebugMode) {
                    print('Processing data...');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF33907C), // button color
                fixedSize: const Size(314, 48), // button width and height
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(24), // button corner radius
                ),
                textStyle: GoogleFonts.montserrat(), // button text style
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildIntegerFormField(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && int.tryParse(value) == null) {
          return 'Please enter a number';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Listing',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const PropertyListingPage(),
    );
  }
}
