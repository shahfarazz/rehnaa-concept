import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PrivacyPolicyPage(),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 40.0,
            left: 10.0,
            child: GestureDetector(
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
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 20,
                  ),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Image.asset(
                  'assets/mainlogo.png',
                  // fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Card(
                        color: const Color.fromARGB(255, 235, 235, 235),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff33907c),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              buildTextCard(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextCard() {
    const String privacyPolicyText =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
        "Vestibulum ac cursus velit. Sed rhoncus consequat tortor, "
        "quis fringilla nisi consectetur a. Sed commodo mauris in "
        "erat varius commodo. Nam ultrices facilisis nunc a interdum. "
        "Fusce interdum placerat orci, in fringilla arcu fringilla id. "
        "Suspendisse potenti. Aenean lobortis sagittis lorem at ultrices. "
        "Fusce lacinia felis sit amet nunc luctus, ac hendrerit metus "
        "luctus. Suspendisse rhoncus, mi nec feugiat convallis, mauris "
        "tellus varius purus, ac mattis massa ligula id metus. Nullam "
        "ut ligula eu sem interdum auctor nec sed est. Suspendisse "
        "eget interdum odio. Nullam rhoncus volutpat tellus, id sagittis "
        "augue dictum id. Nam bibendum id ex et tincidunt. Donec maximus "
        "dictum risus, vitae posuere enim sollicitudin sed. Nullam "
        "tristique, dui vel viverra eleifend, lorem nisl sagittis odio, "
        "quis facilisis arcu odio id ex.";

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          privacyPolicyText,
          style: TextStyle(
            fontSize: 16,
            height: 1.8, // Increase line spacing (adjust the value as needed)
            fontFamily: 'Roboto', // Set your desired font family
            color: Colors.black87,
          ),
          textAlign: TextAlign.justify, // Justify the text
        ),
      ),
    );
  }
}
