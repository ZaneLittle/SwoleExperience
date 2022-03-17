import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:swole_experience/util/Converter.dart';

import '../model/Weight.dart';
import '../service/WeightService.dart';

class WeightTrendChart extends StatefulWidget {
  const WeightTrendChart({Key? key}) : super(key: key);

  @override
  State<WeightTrendChart> createState() => _WeightTrendChartState();
}

class _WeightTrendChartState extends State<WeightTrendChart> {
  final GlobalKey<_WeightTrendChartState> _weightTrackerChartKey =
      GlobalKey<_WeightTrendChartState>();
  final ScrollController _scrollController = ScrollController();
  bool? _showMinMax = true;
  bool? _showAverage = true;
  bool _optionsInitiallyExpanded = false;

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
              DateTime(now.year, now.month, (now.day - value).toInt());
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
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  ///                           Data Builder                                ///
  // TODO: 3 day and 7 day average
  List<LineChartBarData> buildWeightData(
      Map<double, List<double>> weightSeries) {
    return [
      LineChartBarData(
          show: _showAverage,
          isCurved: true,
          colors: [const Color(0xff4af699)],
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: getAverageSeries(weightSeries)),
      LineChartBarData(
          show: _showMinMax,
          isCurved: true,
          colors: [const Color(0x69999999)],
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: getMaxSeries(weightSeries)),
      LineChartBarData(
          show: _showMinMax,
          isCurved: true,
          colors: [const Color(0x69999999)],
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: getMinSeries(weightSeries))
    ];
  }

  List<FlSpot> getAverageSeries(Map<double, List<double>> weightSeries) {
    return weightSeries.entries
        .map<FlSpot>((entry) => FlSpot((entry.key).truncateToDouble(),
            entry.value.reduce((a, b) => a + b) / entry.value.length))
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
      double date = Converter().toDayScale(weight.dateTime);
      if (data.containsKey(date)) {
        data[date]?.add(weight.weight);
      } else {
        data[date] = [weight.weight];
      }
    }

    return data;
  }

  ///                             Helpers                                   ///
  Color getFillColor(Set<MaterialState> states, Color active) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.selected,
    };
    if (states.any(interactiveStates.contains)) {
      return active;
    }
    return const Color(0xff75729e);
  }

  Color getMinMaxFillColor(Set<MaterialState> states) {
    return getFillColor(states, const Color(0x69999999));
  }

  Color getAverageFillColor(Set<MaterialState> states) {
    return getFillColor(states, const Color(0xff4af699));
  }

  ///                             Build                                     ///
  // TODO: Chart does not reload when adding weight - reload is required
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Weight>>(
        future: WeightService.svc.getWeights(),
        builder: (BuildContext context, AsyncSnapshot<List<Weight>> snapshot) {
          // TODO: Proper dead states
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                height: MediaQuery.of(context).size.height * .4,
                child: const Center(child: Text('Loading...')));
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return SizedBox(
                height: MediaQuery.of(context).size.height * .4,
                child:
                    const Center(child: Text('No weights have been logged')));
          } else {
            Map<double, List<double>> weightSeries =
                getWeightGrouping(snapshot.requireData);

            double maxWeight =
                weightSeries.values.map((l) => l.reduce(max)).reduce(max);
            maxWeight = maxWeight % 2 == 0 ? maxWeight + 2 : maxWeight + 3;

            double minWeight =
                weightSeries.values.map((l) => l.reduce(min)).reduce(min);
            minWeight = minWeight % 2 == 0 ? minWeight - 2 : minWeight - 3;

            return Column(children: <Widget>[
              SizedBox(
                  height: MediaQuery.of(context).size.height * .4,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 14, bottom: 18),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: lineTouchData,
                          gridData: gridData,
                          titlesData: getTitlesData(weightSeries),
                          borderData: borderData,
                          lineBarsData: buildWeightData(weightSeries),
                          maxY: maxWeight,
                          minY: minWeight,
                        ),
                        swapAnimationDuration:
                            const Duration(milliseconds: 150),
                        swapAnimationCurve: Curves.linear,
                      ))),
              ExpansionTile(
                  title: const Text('Line Options'),
                  initiallyExpanded: _optionsInitiallyExpanded,
                  onExpansionChanged: (bool expanded) {
                    setState(() => _optionsInitiallyExpanded = expanded);
                  },
                  children: <Widget>[
                    SizedBox(
                        height: MediaQuery.of(context).size.height * .2,
                        child: ListView(
                            controller: _scrollController,
                            children: <Widget>[
                              Row(
                                children: [
                                  Checkbox(
                                    value: _showMinMax,
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            getMinMaxFillColor),
                                    onChanged: (value) {
                                      setState(() {
                                        _showMinMax = value;
                                        build(context);
                                      });
                                    },
                                  ),
                                  const Text('Min/Max'),
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _showAverage,
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            getAverageFillColor),
                                    onChanged: (value) {
                                      setState(() {
                                        _showAverage = value;
                                        build(context);
                                      });
                                    },
                                  ),
                                  const Text('Average'),
                                ],
                              ),
                            ]))
                  ])
            ]);
          }
        });
  }
}
