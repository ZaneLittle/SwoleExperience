import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/preferences/feature_toggles.dart';

import 'package:swole_experience/components/preferences/navigation_line.dart';
import 'package:swole_experience/components/workouts/trends/trends.dart';
import 'package:swole_experience/components/workouts/workouts_configure.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/constants/toggles.dart';
import 'package:swole_experience/model/preference.dart';
import 'package:swole_experience/service/preference_service.dart';
import 'package:swole_experience/constants/weight_constant.dart';
import 'package:swole_experience/constants/preference_constants.dart';
import 'package:swole_experience/util/util.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final ScrollController _scrollController = ScrollController();
  final Uri _feedbackUri = Uri.parse(
      'https://github.com/ZaneLittle/SwoleExperience/issues/new/choose');
  String? _weightUnitValue;

  FutureOr rebuild(dynamic value) {
    setState(() {});
  }

  ///                          Helpers                                       ///

  Preference? findPreference(List<Preference> preferences, String pref) {
    for (var it in preferences) {
      if (it.preference == pref) {
        return it;
      }
    }
    return null;
  }

  ///                         Sub Components                                 ///

  DropdownButton buildWeightUnitPreferenceSelect(List<Preference> preferences) {
    Preference? pref =
        findPreference(preferences, PreferenceConstant.weightUnitKey);
    _weightUnitValue = pref == null ? WeightConstant.pounds : pref.value;

    return DropdownButton(
        // Default is pounds
        value: _weightUnitValue,
        items: WeightConstant.weightUnits.keys
            .map((unit) => DropdownMenuItem(
                child: Text(WeightConstant.weightUnits[unit]!), value: unit))
            .toList(),
        onChanged: (value) {
          PreferenceService.svc.setPreference(Preference(
              preference: PreferenceConstant.weightUnitKey,
              value: value,
              lastUpdated: DateTime.now()));
          setState(() {
            _weightUnitValue = value;
          });
        });
  }

  ///                           Lines                                        ///

  Widget buildWeightUnitLine(List<Preference> prefs) {
    return Card(
        child: SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.only(left: 12), child: Text('Weight Unit')),
          Padding(
              padding: const EdgeInsets.only(right: 12),
              child: buildWeightUnitPreferenceSelect(prefs)),
        ],
      ),
    ));
  }

  Widget buildWorkoutConfigureLine() {
    return NavigationLine(
        navType: NavigationType.internal,
        lineText: 'Configure Workouts',
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const WorkoutsConfigure(freshBuild: true))).then(rebuild);
        });
  }

  Widget buildTrendsLine(bool enabled) {
    return enabled
        ? NavigationLine(
            navType: NavigationType.internal,
            lineText: 'Workout Trends',
            onTap: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Trends()))
                  .then(rebuild);
            })
        : Container();
  }

  Widget buildFeedbackLine() {
    return NavigationLine(
        navType: NavigationType.external,
        lineText: 'Provide feedback on the app',
        onTap: () {
          Util.launchExternalUrl(_feedbackUri, context);
        });
  }

  Widget buildTogglesLine() {
    return NavigationLine(
        navType: NavigationType.internal,
        lineText: 'Turn features on or off',
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const FeatureToggles())).then(rebuild);
        });
  }

  ///                           Build                                        ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CommonStyles.primaryDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 32,
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),
          title: const Text('Settings'),
        ),
        body: Column(children: <Widget>[
          FutureBuilder(
              future: Future.wait([
                PreferenceService.svc.getAllPreferences(),
                PreferenceService.svc.isToggleEnabled(Toggles.workoutTrendsKey),
            ]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null || snapshot.data?.first == null) {
                  return const Center(child: Text('Loading...'));
                } else {
                  return Expanded(
                      child: ListView(
                          controller: _scrollController,
                          children: <Widget>[
                        buildWeightUnitLine(snapshot.requireData[0] as List<Preference>),
                        buildWorkoutConfigureLine(),
                        buildTrendsLine(snapshot.requireData[1]),
                        buildTogglesLine(),
                        buildFeedbackLine(),
                      ]));
                }
              })
        ]));
  }
}
