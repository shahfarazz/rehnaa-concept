import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FAQPage(),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

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
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              "FAQs",
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xff33907c),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FAQCard(
                              question: 'What is Flutter?',
                              answer:
                                  'Flutter is a UI toolkit for building fast, natively compiled applications for mobile, web, and desktop from a single codebase.',
                            ),
                            const SizedBox(height: 16),
                            FAQCard(
                              question: 'How can I get started with Flutter?',
                              answer:
                                  'You can get started with Flutter by installing Flutter SDK, setting up your development environment, and creating a new Flutter project.',
                            ),
                            const SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Can I use Flutter for web development?',
                              answer:
                                  'Yes, you can use Flutter for web development. Flutter provides support for building web applications in addition to mobile and desktop platforms.',
                            ),
                            const SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Can I use Flutter for web development?',
                              answer:
                                  'Yes, you can use Flutter for web development. Flutter provides support for building web applications in addition to mobile and desktop platforms.',
                            ),
                            const SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Can I use Flutter for web development?',
                              answer:
                                  'Yes, you can use Flutter for web development. Flutter provides support for building web applications in addition to mobile and desktop platforms.',
                            ),
                            const SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Can I use Flutter for web development?',
                              answer:
                                  'Yes, you can use Flutter for web development. Flutter provides support for building web applications in addition to mobile and desktop platforms.',
                            ),
                            // Add more FAQs
                          ],
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
}

class FAQCard extends StatefulWidget {
  final String question;
  final String answer;

  const FAQCard({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  _FAQCardState createState() => _FAQCardState();
}

class _FAQCardState extends State<FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ],
              ),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(widget.answer),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
