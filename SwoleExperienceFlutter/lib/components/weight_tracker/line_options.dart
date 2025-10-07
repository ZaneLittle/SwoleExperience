import 'package:flutter/material.dart';

import 'package:swole_experience/constants/weight_chart_line_colors.dart';
import 'package:swole_experience/util/util.dart';

class LineOptions extends StatefulWidget {
  const LineOptions(
      {Key? key,
      required this.getShowMinMax,
      required this.setShowMinMax,
      required this.getShowAverage,
      required this.setShowAverage,
      required this.getShowSevenDayAverage,
      required this.setShowSevenDayAverage,
      required this.getShowThreeDayAverage,
      required this.setShowThreeDayAverage,
      required this.optionsInitiallyExpanded})
      : super(key: key);

  final Function getShowMinMax;
  final Function setShowMinMax;
  final Function getShowAverage;
  final Function setShowAverage;
  final Function getShowThreeDayAverage;
  final Function setShowThreeDayAverage;
  final Function getShowSevenDayAverage;
  final Function setShowSevenDayAverage;
  final bool optionsInitiallyExpanded;

  @override
  State<StatefulWidget> createState() => _LineOptionsState();
}

class _LineOptionsState extends State<LineOptions> {
  final GlobalKey<_LineOptionsState> _lineOptionsKey =
      GlobalKey<_LineOptionsState>();
  final ScrollController _scrollController = ScrollController();

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
    return getFillColor(states, WeightChartLineColors.minMaxColor);
  }

  Color getAverageFillColor(Set<MaterialState> states) {
    return getFillColor(states, WeightChartLineColors.averageColor);
  }

  Color getThreeDayAverageFillColor(Set<MaterialState> states) {
    return getFillColor(states, WeightChartLineColors.threeDayAverageColor);
  }

  Color getSevenDayAverageFillColor(Set<MaterialState> states) {
    return getFillColor(states, WeightChartLineColors.sevenDayAverageColor);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        key: _lineOptionsKey,
        title: const Text('Line Options'),
        initiallyExpanded: widget.optionsInitiallyExpanded,
        onExpansionChanged: (bool expanded) {
          if (expanded) {
            Util().scrollToSelectedContext(_lineOptionsKey);
          }
        },
        children: <Widget>[
          SizedBox(
              height: 100,
              child: ListView(controller: _scrollController, children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                          child: Column(children: <Widget>[
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: widget.getShowMinMax(),
                              fillColor: MaterialStateProperty.resolveWith(
                                  getMinMaxFillColor),
                              onChanged: (value) {
                                setState(() {
                                  widget.setShowMinMax(value);
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
                              value: widget.getShowAverage(),
                              fillColor: MaterialStateProperty.resolveWith(
                                  getAverageFillColor),
                              onChanged: (value) {
                                setState(() {
                                  widget.setShowAverage(value);
                                  build(context);
                                });
                              },
                            ),
                            const Text('Average'),
                          ],
                        )
                      ])),
                      Expanded(
                          child: Column(children: <Widget>[
                        Row(
                          children: [
                            Checkbox(
                              value: widget.getShowThreeDayAverage(),
                              fillColor: MaterialStateProperty.resolveWith(
                                  getThreeDayAverageFillColor),
                              onChanged: (value) {
                                setState(() {
                                  widget.setShowThreeDayAverage(value);
                                  build(context);
                                });
                              },
                            ),
                            const Text('Three Day Average'),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: widget.getShowSevenDayAverage(),
                              fillColor: MaterialStateProperty.resolveWith(
                                  getSevenDayAverageFillColor),
                              onChanged: (value) {
                                setState(() {
                                  widget.setShowSevenDayAverage(value);
                                  build(context);
                                });
                              },
                            ),
                            const Text('Seven Day Average'),
                          ],
                        ),
                      ]))
                    ])
              ]))
        ]);
  }
}
