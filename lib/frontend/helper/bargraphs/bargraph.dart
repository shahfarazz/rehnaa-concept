import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rehnaa/frontend/helper/bargraphs/bar_data.dart';

class MyBarGraph extends StatelessWidget {
  final Map<String, double> xyValues;

  const MyBarGraph({super.key, required this.xyValues});

  @override
  Widget build(BuildContext context) {
    //initalize bar data
    BarData myBarData = BarData(xyValues: xyValues);
    myBarData.initializeBarData();

    return BarChart(BarChartData(
      maxY: 20,
      minY: 0,
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: myBarData.barData
          .map((data) => BarChartGroupData(
                // convert string data.x to int based on unique values
                x: myBarData.barData.indexOf(data),
                barRods: [BarChartRodData(toY: data.y)],
              ))
          .toList(),
      titlesData: FlTitlesData(
          // leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: //return a Widget Function(double, TitleMeta)
                (double value, TitleMeta titleMeta) {
              // get the x value from the bar data
              String xValue = myBarData.barData[value.toInt()].x;
              // return a Text Widget
              return Text(
                xValue,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              );
            },
          ))),
    ));
  }
}
