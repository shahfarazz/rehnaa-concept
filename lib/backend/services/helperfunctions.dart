import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
