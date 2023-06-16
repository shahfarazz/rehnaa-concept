import 'package:rehnaa/frontend/helper/bargraphs/individual_bar.dart';

class BarData {
  final Map<String, double> xyValues;

  BarData({
    required this.xyValues,
  });

  List<IndividualBar> barData = [];

// initialize the bar data
  void initializeBarData() {
    barData = [];
    //key is the x value and value is the y value
    xyValues.forEach((key, value) {
      barData.add(IndividualBar(
        x: key,
        y: value,
      ));
    });
  }
}
