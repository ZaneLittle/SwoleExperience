import 'dart:async';

import 'package:flutter/material.dart';

import 'package:swole_experience/components/workouts/workouts_configure.dart';
import 'package:swole_experience/model/preference.dart';
import 'package:swole_experience/service/preference_service.dart';
import 'package:swole_experience/constants/weight_units.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final ScrollController _scrollController = ScrollController();
  String? _weightUnitValue;

  FutureOr rebuild(dynamic value) {
    setState(() {});
  }

  Preference? findPreference(List<Preference> preferences, String pref) {
    for (var it in preferences) {
      if (it.preference == pref) {
        return it;
      }
    }
    return null;
  }

  DropdownButton buildWeightUnitPreferenceSelect(List<Preference> preferences) {
    Preference? pref =
        findPreference(preferences, WeightConstant.weightUnitKey);
    _weightUnitValue = pref == null ? WeightConstant.pounds : pref.value;

    return DropdownButton(
        // Default is pounds
        value: _weightUnitValue,
        items: WeightConstant.weightUnits.keys
            .map((unit) => DropdownMenuItem(
                child: Text(WeightConstant.weightUnits[unit]!), value: unit))
            .toList(),
        onChanged: (value) {
          PreferenceService.svc.addOrUpdatePreference(Preference(
              preference: WeightConstant.weightUnitKey,
              value: value,
              lastUpdated: DateTime.now()));
          setState(() {
            _weightUnitValue = value;
          });
        });
  }

  ///                           Lines                                        ///

  Widget buildWeightUnitLine(AsyncSnapshot<List<Preference>> snapshot) {
    return Card(
      child: SizedBox(height: 48, child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.only(left: 12), child: Text('Weight Unit')),
          Padding(
              padding: const EdgeInsets.only(right: 12),
              child: buildWeightUnitPreferenceSelect(snapshot.data!)),
        ],
      ),
    ));
  }

  Widget buildWorkoutConfigureLine() {
    return GestureDetector(
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WorkoutsConfigure()))
              .then(rebuild);
        },
        child: Card(
            child: SizedBox(height: 48, child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
              Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text('Configure Workouts')),
              Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.arrow_forward_ios)),
            ]))));
  }

  ///                           Build                                        ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
              future: PreferenceService.svc.getAllPreferences(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Preference>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null) {
                  return const Center(child: Text('Loading...'));
                } else {
                  return SizedBox(
                      height: MediaQuery.of(context).size.height * .9,
                      child: ListView(
                          controller: _scrollController,
                          children: <Widget>[
                            buildWeightUnitLine(snapshot),
                            buildWorkoutConfigureLine(),
                          ]));
                }
              })
        ]));
  }
}
