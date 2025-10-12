import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:swole_experience/components/weight_tracker/line_options.dart';
import 'package:swole_experience/model/average.dart';
import 'package:swole_experience/util/converter.dart';
import 'package:swole_experience/model/weight.dart';
import 'package:swole_experience/constants/weight_chart_line_colors.dart';

class WeightTrendChart extends StatefulWidget {
  const WeightTrendChart({Key? key, this.context, this.dataSnapshot})
      : super(key: key);

  final BuildContext? context;
  final AsyncSnapshot<List<List<dynamic>>>? dataSnapshot;

  @override
  State<WeightTrendChart> createState() => _WeightTrendChartState();
}

class _WeightTrendChartState extends State<WeightTrendChart> {
  final GlobalKey<_WeightTrendChartState> _weightTrackerChartKey =
      GlobalKey<_WeightTrendChartState>();

  bool? _showMinMax = true;
  bool? _showAverage = true;
  bool? _showThreeDayAverage = true;
  bool? _showSevenDayAverage = true;
  final bool _optionsInitiallyExpanded = false;

  void setShowMinMax(bool? value) {
    _showMinMax = value;
    setState(() {});
  }

  bool? getShowMinMax() {
    return _showMinMax;
  }

  void setShowAverage(bool? value) {
    _showAverage = value;
    setState(() {});
  }

  bool? getShowAverage() {
    return _showAverage;
  }

  void setShowThreeDayAverage(bool? value) {
    _showThreeDayAverage = value;
    setState(() {});
  }

  bool? getShowThreeDayAverage() {
    return _showThreeDayAverage;
  }

  void setShowSevenDayAverage(bool? value) {
    _showSevenDayAverage = value;
    setState(() {});
  }

  bool? getShowSevenDayAverage() {
    return _showSevenDayAverage;
  }

  ///                       Chart Area Data                                  ///
  static FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 2),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  static FlTitlesData getTitlesData(Map<double, List<double>> weightSeries) {
    return FlTitlesData(
      bottomTitles: getBottomTitles(weightSeries),
      rightTitles: SideTitles(showTitles: false),
      topTitles: SideTitles(showTitles: false),
      leftTitles: leftTitles(
        getTitles: (value) {
          return (value.toInt().toString());
        },
      ),
    );
  }

  static SideTitles getBottomTitles(Map<double, List<double>> weightSeries) {
    double interval = (weightSeries.keys.first / 10).roundToDouble();
    if (interval < 1) {
      interval = 1;
    }

    return SideTitles(
        showTitles: true,
        reservedSize: 22,
        margin: 8,
        interval: interval,
        rotateAngle: -55,
        getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff72719b),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
        getTitles: (value) {
          DateTime now = DateTime.now();
          DateTime longDate =
              DateTime(now.year, now.month, (now.day - 60 + value).toInt());
          return DateFormat('MM/dd').format(longDate);
        });
  }

  static SideTitles leftTitles({required GetTitleFunction getTitles}) =>
      SideTitles(
        getTitles: getTitles,
        showTitles: true,
        margin: 8,
        interval: 2,
        reservedSize: 22,
        getTextStyles: (context, value) => const TextStyle(
          color: Color(0xff75729e),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );

  static FlGridData get gridData =>
      FlGridData(drawHorizontalLine: true, drawVerticalLine: false);

  static LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchSpotThreshold: 50,
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (items) {
              return items.map<LineTooltipItem>((item) {
                DateTime now = DateTime.now();
                DateTime longDate = DateTime(
                    now.year, now.month, (now.day - 60 + item.x).toInt());
                String date = DateFormat('MM/dd').format(longDate);
                Color color =
                    item.bar.colors.first == WeightChartLineColors.minMaxColor
                        ? const Color(
                            0xffd0d0d0) // Cast to lighter grey for visibility
                        : item.bar.colors.first;

                return LineTooltipItem(date + ": " + item.y.toStringAsFixed(2),
                    TextStyle(color: color));
              }).toList();
            }),
      );

  ///                           Data Builder                                ///
  List<LineChartBarData> buildWeightData(
      Map<double, List<double>> weightSeries, List<Average> averageSeries) {
    return [
      LineChartBarData(
          show: _showAverage,
          isCurved: true,
          colors: [WeightChartLineColors.averageColor],
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: getAverageSeries(averageSeries)),
      LineChartBarData(
          dashArray: [1],
          show: _showMinMax,
          isCurved: true,
          colors: [WeightChartLineColors.minMaxColor],
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: getMaxSeries(weightSeries)),
      LineChartBarData(
          dashArray: [1],
          show: _showMinMax,
          isCurved: true,
          colors: [WeightChartLineColors.minMaxColor],
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: getMinSeries(weightSeries)),
      LineChartBarData(
          show: _showThreeDayAverage,
          isCurved: true,
          colors: [WeightChartLineColors.threeDayAverageColor],
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: getThreeDayAverageSeries(averageSeries)),
      LineChartBarData(
          show: _showSevenDayAverage,
          isCurved: true,
          colors: [WeightChartLineColors.sevenDayAverageColor],
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: getSevenDayAverageSeries(averageSeries)),
    ];
  }

  List<FlSpot> getAverageSeries(List<Average> averageSeries) {
    return averageSeries
        .map<FlSpot>((entry) => FlSpot(
            Converter.toDayScale(entry.date).truncateToDouble(),
            double.parse((entry.average).toStringAsFixed(2))))
        .toList();
  }

  List<FlSpot> getThreeDayAverageSeries(List<Average> averageSeries) {
    return averageSeries
        .map<FlSpot>((entry) => FlSpot(
            Converter.toDayScale(entry.date).truncateToDouble(),
            double.parse((entry.threeDayAverage).toStringAsFixed(2))))
        .toList();
  }

  List<FlSpot> getSevenDayAverageSeries(List<Average> averageSeries) {
    return averageSeries
        .map<FlSpot>((entry) => FlSpot(
            Converter.toDayScale(entry.date).truncateToDouble(),
            double.parse((entry.sevenDayAverage).toStringAsFixed(2))))
        .toList();
  }

  List<FlSpot> getMaxSeries(Map<double, List<double>> weightSeries) {
    return weightSeries.entries
        .map<FlSpot>((entry) =>
            FlSpot((entry.key).truncateToDouble(), entry.value.reduce(max)))
        .toList();
  }

  List<FlSpot> getMinSeries(Map<double, List<double>> weightSeries) {
    return weightSeries.entries
        .map<FlSpot>((entry) =>
            FlSpot((entry.key).truncateToDouble(), entry.value.reduce(min)))
        .toList();
  }

  Map<double, List<double>> getWeightGrouping(List<Weight> weightList) {
    Map<double, List<double>> data = <double, List<double>>{};

    for (Weight weight in weightList) {
      double date = Converter.toDayScale(weight.dateTime);
      if (data.containsKey(date)) {
        data[date]?.add(weight.weight);
      } else {
        data[date] = [weight.weight];
      }
    }

    return data;
  }

  ///                             Build                                     ///
  // TODO: ENHANCEMENT scrolling chart to allow showing more than just the 60 day window
  @override
  Widget build(BuildContext context) {
    if (widget.dataSnapshot == null ||
        widget.dataSnapshot!.connectionState == ConnectionState.waiting) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * .4,
          child: const Center(child: Text('Loading...')));
    } else if (!widget.dataSnapshot!.hasData ||
        widget.dataSnapshot!.data == null ||
        widget.dataSnapshot!.data!.isEmpty ||
        widget.dataSnapshot!.data![0].isEmpty ||
        widget.dataSnapshot!.data![1].isEmpty) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * .4,
          child: const Center(child: Text('No weights have been logged')));
    } else if (widget.dataSnapshot!.data![0].length < 2 ||
        widget.dataSnapshot!.data![1].length < 2) {
      // Need two days of data to visualize in the chart
      return SizedBox(
          height: MediaQuery.of(context).size.height * .4,
          child: const Center(
              child: Text('Keep adding weights to see your trends!')));
    } else {
      Map<double, List<double>> weightSeries = getWeightGrouping(
          widget.dataSnapshot!.requireData[0] as List<Weight>);

      List<Average> averageSeries =
          widget.dataSnapshot!.requireData[1] as List<Average>;

      double maxWeight =
          weightSeries.values.map((l) => l.reduce(max)).reduce(max);
      maxWeight = maxWeight % 2 == 0 ? maxWeight + 2 : maxWeight + 3;

      double minWeight =
          weightSeries.values.map((l) => l.reduce(min)).reduce(min);
      minWeight = minWeight % 2 == 0 ? minWeight - 2 : minWeight - 3;

      return Column(children: <Widget>[
        SizedBox(
            key: _weightTrackerChartKey,
            height: MediaQuery.of(context).size.height * .45,
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 8, right: 14, top: 12, bottom: 12),
                child: LineChart(
                  LineChartData(
                    lineTouchData: lineTouchData,
                    gridData: gridData,
                    titlesData: getTitlesData(weightSeries),
                    borderData: borderData,
                    lineBarsData: buildWeightData(weightSeries, averageSeries),
                    maxY: maxWeight,
                    minY: minWeight,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 150),
                  swapAnimationCurve: Curves.linear,
                ))),
        LineOptions(
            getShowMinMax: getShowMinMax,
            setShowMinMax: setShowMinMax,
            getShowAverage: getShowAverage,
            setShowAverage: setShowAverage,
            getShowSevenDayAverage: getShowSevenDayAverage,
            setShowSevenDayAverage: setShowSevenDayAverage,
            getShowThreeDayAverage: getShowThreeDayAverage,
            setShowThreeDayAverage: setShowThreeDayAverage,
            optionsInitiallyExpanded: _optionsInitiallyExpanded)
      ]);
    }
  }
}
