import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../models/tenantsmodel.dart';

String formatNumber(double num) {
  if (num >= 1000000000000) {
    return '${(num / 1000000000000).toStringAsFixed(1)}T';
  }
  if (num >= 1000000000) {
    return '${(num / 1000000000).toStringAsFixed(1)}B';
  }
  if (num >= 1000000) {
    return '${(num / 1000000).toStringAsFixed(1)}M';
  }
  if (num >= 1000) {
    return '${(num / 1000).toStringAsFixed(1)}K';
  }
  if (num % 1 != 0) {
    return num.floor().toString();
  }
  return num.toString();
}

class CustomButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    required this.color,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String encryptString(String input) {
  try {
    final key = encrypt.Key.fromUtf8("aixgru@@djnjd#%d");
    final iv =
        encrypt.IV.fromUtf8('abcdefghijklmnop'); // Example 16-character IV

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(input, iv: iv);

    return encrypted.base64;
  } catch (e) {
    return 'error';
    // TODO
  }
}

String decryptString(String input) {
  //TODO fix this bad practice of hardcoding the key
  String decrypted = "";
  try {
    final key = encrypt.Key.fromUtf8("aixgru@@djnjd#%d");
    final iv =
        encrypt.IV.fromUtf8('abcdefghijklmnop'); // Example 16-character IV

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    decrypted = encrypter.decrypt64(input, iv: iv);
  } catch (e) {
    print('error with decrypting string is $e');
    decrypted = "";
  }

  return decrypted;
}

Future<Tenant> getTenantFromUid(String uid) async {
  return FirebaseFirestore.instance.collection('Tenants').doc(uid).get().then(
    (value) {
      return Tenant.fromJson(value.data()!);
    },
  );
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double controlPointOffset = size.height / 6;

    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2 - controlPointOffset);
    path.lineTo(size.width, size.height / 2 + controlPointOffset);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2 + controlPointOffset);
    path.lineTo(0, size.height / 2 - controlPointOffset);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
