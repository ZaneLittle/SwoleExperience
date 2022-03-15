import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:swole_experience/constants/ChartDemoData.dart';

class WeightTrendChart extends StatefulWidget {
  const WeightTrendChart({Key? key}) : super(key: key);

  @override
  State<WeightTrendChart> createState() => _WeightTrendChartState();
}

class _WeightTrendChartState extends State<WeightTrendChart> {
  final GlobalKey<_WeightTrendChartState> _weightTrackerChartKey = GlobalKey<_WeightTrendChartState>();
  bool _weightTrendExpanded = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 363,
        child: Padding(
            padding:
                const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 32),
            child: LineChart(
              LineChartData(
                // TODO: log and store user data
                lineTouchData: DemoData.lineTouchData1,
                gridData: DemoData.gridData,
                titlesData: DemoData.titlesData1,
                borderData: DemoData.borderData,
                lineBarsData: DemoData.lineBarsData1,
                minX: 0,
                maxX: 14,
                maxY: 4,
                minY: 0,
              ),
              swapAnimationDuration: const Duration(milliseconds: 150),
              // Optional
              swapAnimationCurve: Curves.linear, // Optional
            )));
  }
}
