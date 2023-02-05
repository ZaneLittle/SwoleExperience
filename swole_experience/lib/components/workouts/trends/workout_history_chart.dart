import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout_history.dart';
import 'package:swole_experience/util/converter.dart';
import 'package:swole_experience/util/util.dart';

class WorkoutHistoryChart extends StatefulWidget {
  const WorkoutHistoryChart({Key? key, required this.workouts})
      : super(key: key);

  final List<WorkoutHistory> workouts;

  @override
  State<WorkoutHistoryChart> createState() => _WorkoutHistoryChartState();
}

class _WorkoutHistoryChartState extends State<WorkoutHistoryChart> {
  final GlobalKey<_WorkoutHistoryChartState> _workoutHistoryChartKey =
      GlobalKey<_WorkoutHistoryChartState>();

  Map<double, List<double>> chartData = <double, List<double>>{};
  double maxWeight = 0;
  double minWeight = 0;

  void init() {
    // Convert list of workouts to map = { Date: [1RM] }
    for (WorkoutHistory workout in widget.workouts) {
      double date =
          Converter.toDayScale(DateTime.parse(workout.date), starting: 180);
      if (chartData.containsKey(date)) {
        chartData[date]?.add(Util.calculateOneRepMax(workout).toDouble());
      } else {
        chartData[date] = [Util.calculateOneRepMax(workout).toDouble()];
      }
    }

    List<double> sortedWeights = chartData.values.expand((w) => w).toList();
    sortedWeights.sort();
    minWeight = sortedWeights.first;
    maxWeight = sortedWeights.last;
  }

  ///                         Chart Elements                                 ///
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
                Color color = CommonStyles.primaryDark;

                return LineTooltipItem(
                    date + " \n " + item.y.toStringAsFixed(0),
                    TextStyle(color: color));
              }).toList();
            }),
      );

  static FlGridData get gridData =>
      FlGridData(drawHorizontalLine: true, drawVerticalLine: false);

  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: getBottomTitles(),
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        leftTitles: leftTitles(
          getTitles: (value) {
            return (value.toInt().toString());
          },
        ),
      );

  SideTitles getBottomTitles() {
    double interval = (chartData.keys.first / 10).roundToDouble();
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

  static FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 2),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  ///                        Data Builder                                    ///
  List<LineChartBarData> buildSeries() => [
        LineChartBarData(
          isCurved: true,
          colors: [CommonStyles.primaryColour],
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: false),
          belowBarData: gradient,
          spots: widget.workouts
              .map<FlSpot>((workout) => FlSpot(
                  Converter.toDayScale(DateTime.parse(workout.date),
                          starting: 180)
                      .truncateToDouble(),
                  Util.calculateOneRepMax(workout).toDouble()))
              .toList(),
        ),
      ];

  static BarAreaData get gradient => BarAreaData(
        show: true,
        colors: [
          CommonStyles.primaryColour.withOpacity(0.4),
          CommonStyles.tertiaryColour.withOpacity(0.4),
        ],
      );

  ///                           Build                                        ///
  @override
  Widget build(BuildContext context) {
    init();
    return (chartData.keys.length > 1)
        ? Column(children: <Widget>[
            SizedBox(
                key: _workoutHistoryChartKey,
                height: MediaQuery.of(context).size.height * .45,
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 14, top: 12, bottom: 14),
                    child: LineChart(
                      LineChartData(
                        lineTouchData: lineTouchData,
                        gridData: gridData,
                        titlesData: titlesData,
                        borderData: borderData,
                        lineBarsData: buildSeries(),
                        maxY: maxWeight + 2,
                        minY: minWeight - 2,
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 150),
                      swapAnimationCurve: Curves.linear,
                    ))),
          ])
        : SizedBox(
            key: _workoutHistoryChartKey,
            height: 128,
            child: const Center(
                child: Text('Complete more workouts to see a visualization!')));
  }
}
