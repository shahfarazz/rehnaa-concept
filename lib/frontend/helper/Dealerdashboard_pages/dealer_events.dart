import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../backend/services/helperfunctions.dart';
import '../../Screens/Dealer/dealer_dashboard.dart';

class DealerEventsPage extends StatefulWidget {
  final String uid;
  const DealerEventsPage({super.key, required this.uid});

  @override
  State<DealerEventsPage> createState() => _DealerEventsPageState();
}

class _DealerEventsPageState extends State<DealerEventsPage> {
  var defaultText =
      'Rehnaa plans to hold annual Dealer Dinner Convention for strengthening dealer relationships and for appraising the dealers with exceptional performance. Stay affliated for upcoming events. Thanks';

  Future getDealerEvents() async {
    FirebaseFirestore.instance
        .collection('Dealers')
        .doc(widget.uid)
        .get()
        .then((value) {
      // setState(() {
      defaultText = value['events'];
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(MediaQuery.of(context).size, context, widget.uid),
      body: Container(
          child: FutureBuilder(
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(20.0),
              //     side: const BorderSide(color: Colors.grey, width: 0.1),
              //   ),
              //   child: Container(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Column(

              //return a card like the above to display the events
              future: getDealerEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      Text(
                        'Events',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                            color: Colors.green),
                      ),
                      Card(
                          elevation: 4.0,
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(
                                color: Colors.grey, width: 0.1),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      // const SizedBox(height: 20),

                                      const SizedBox(height: 30),
                                      styledText(defaultText),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  );
                }
              })),
    );
  }

  Widget styledText(String defaultText) {
    String target = "Dealer Dinner Convention";
    List<InlineSpan> textSpans = [];

    TextStyle defaultStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      color: Colors.black,
    );

    if (defaultText.contains(target)) {
      List<String> parts = defaultText.split(target);

      for (int i = 0; i < parts.length; i++) {
        textSpans.add(TextSpan(
          text: parts[i],
          style: defaultStyle,
        ));

        if (i < parts.length - 1) {
          // add target styled text
          textSpans.add(TextSpan(
            text: target,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.montserrat().fontFamily,
              color: Colors.green,
            ),
          ));
        }
      }
    } else {
      textSpans.add(TextSpan(
        text: defaultText,
        style: defaultStyle,
      ));
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: defaultStyle,
        children: textSpans,
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(Size size, context, uid) {
  return AppBar(
    toolbarHeight: 70,
    title: Padding(
      padding: EdgeInsets.only(
        right:
            MediaQuery.of(context).size.width * 0.14, // 55% of the page width
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                // Add your desired logic here
                // print('tapped');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DealerDashboardPage(
                            uid: uid,
                          )),
                );
              },
              child: Stack(
                children: [
                  ClipPath(
                    clipper: HexagonClipper(),
                    child: Transform.scale(
                      scale: 0.87,
                      child: Container(
                        color: Colors.white,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: HexagonClipper(),
                    child: Image.asset(
                      'assets/mainlogo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              )),
          // const SizedBox(width: 8),
        ],
      ),
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Stack(
          children: [],
        ),
      ),
    ],
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
  );
}
