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
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        color: const Color.fromARGB(255, 235, 235, 235),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "FAQs",
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xff33907c),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question: 'What is Rehnaa?',
                              answer:
                              'Rehnaa is Pakistan’s first digital rental platform that connects property owners and tenants in Pakistan. Our platform allows property owners to list their properties for rent and tenants to search and find suitable rental accommodations. Additionally, Rehnaa provides a seamless experience for its users through features such as KYC, guaranteed rent, loyalty points, advance rent, rent accrual, vouchers, legal support and much more.  Our aim is to instill trust and transparency in the rental market of Pakistan.'
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question: 'Does Rehnaa share our data further?',
                              answer:
                              'Rehnaa does not share its users data with anyone except the users itself for better KYC profiling and user experience.'
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Is Rehnaa available in all cities of Pakistan?',
                              answer:
                              'Rehnaa is continually expanding its reach, but currently, our services are available in Lahore only. We aim to expand to more cities in the future, so stay tuned for updates.'
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'How much does it cost to use Rehnaa?',
                              answer:
                                  'Registering an account and searching for properties on Rehnaa is free of charge for tenants. For property owners, there is subscription charges of 1% of monthly rent if they opt to use Rehnaa services till the end of the contract. For tenants, an upfront 15 days’ worth of rent is charged when a deal is brokered by Rehnaa. No other hidden charges exist. The specific fees and pricing details can be found by contacting our support team.'                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'How can I contact the property owner or tenant?',
                              answer:
                              'Once you find a property or tenant of interest on Rehnaa, you can click the request button on the listing so our support team can contact you directly through the platform to initiate further communication.'
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Can I negotiate the rental terms with the property owner?',
                              answer:
                              'Yes, Rehnaa encourages communication between tenants and property owners. You can negotiate rental terms, such as rent amount, duration, and any additional requirements directly with the property owner through our platforms messaging system'
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Is my personal information safe on Rehnaa?',
                              answer:
                              'At Rehnaa, we take privacy and data security seriously. We have implemented robust security measures to protect your personal information. Please refer to our Privacy Policy for detailed information on how we collect, use, and safeguard your data.'
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'How can I report a problem or issue with a property or user?',
                              answer:
                              'If you encounter any problems or have concerns about a property or user on Rehnaa, please contact our support team immediately. We will investigate the issue and take appropriate action to resolve it.'
                            ),
                            SizedBox(height: 16),
                            FAQCard(
                              question:
                                  'Can I list commercial properties for rent on Rehnaa?',
                              answer:
                              'Yes, Rehnaa deals in commercial properties as well.'
                            ),
                            SizedBox(height: 30),
                            
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
                        decoration: TextDecoration.underline,
                        // fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.visible,
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
                  child: Text(
                    widget.answer,
                    overflow: TextOverflow.visible,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
