import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehnaa/backend/models/rentpaymentmodel.dart';

class RentPaymentInfoPage extends StatelessWidget {
  final RentPayment rentPayment;
  final String firstName;
  final String lastName;

  const RentPaymentInfoPage({
    Key? key,
    required this.rentPayment,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Rent Payment',
      //     style: GoogleFonts.montserrat(
      //       fontWeight: FontWeight.bold,
      //       fontSize: 24.0,
      //       color: const Color(0xff33907c),
      //     ),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      //   iconTheme: IconThemeData(
      //     color: const Color(0xff33907c),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
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
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.08),
                    const SizedBox(height: 20.0),
                    Text(
                      '$firstName $lastName',
                      style: GoogleFonts.montserrat(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff33907c),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Center(
                      child: Text(
                        rentPayment.property?.title ?? 'Withdrawal',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 16.0,
                          color: const Color(0xff33907c),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.grey[200],
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Center(
                        child: WhiteBox(
                          icon: _getPaymentIcon(rentPayment.paymentType),
                          iconColor: const Color(0xff33907c),
                          label: 'Payment Type',
                          value: rentPayment.paymentType,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: WhiteBox(
                          icon: Icons.calendar_today,
                          iconColor: const Color(0xff33907c),
                          label: 'Payment Date',
                          value:
                              '${rentPayment.date.day}/${rentPayment.date.month}/${rentPayment.date.year}',
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: WhiteBox(
                          icon: Icons.attach_money,
                          iconColor: const Color(0xff33907c),
                          label: 'Payment Amount',
                          value: rentPayment.amount.toString(),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String paymentType) {
    switch (paymentType) {
      case "cash":
        return Icons.money;
      case "banktransfer":
        return Icons.account_balance;
      case "easypaisa":
        return Icons.phone_android;
      case "jazzcash":
        return Icons.phone_android;
      default:
        return Icons.money;
    }
  }
}

class WhiteBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const WhiteBox({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.0,
      width: 280,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        color: iconColor,
                      ),
                    const SizedBox(width: 8.0),
                    Text(
                      label,
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff33907c),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
