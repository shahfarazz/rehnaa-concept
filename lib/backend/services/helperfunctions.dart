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
