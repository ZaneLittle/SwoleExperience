import 'package:flutter/material.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/constants/toggles.dart';
import 'package:swole_experience/model/preference.dart';
import 'package:swole_experience/service/preference_service.dart';

class FeatureList extends StatefulWidget {
  const FeatureList({
    Key? key,
    required this.preferences,
  }) : super(key: key);

  final List<Preference> preferences;

  @override
  State<FeatureList> createState() => _FeatureListState();
}

class _FeatureListState extends State<FeatureList> {
  final ScrollController _scrollController = ScrollController();
  bool shouldInit = true;

  Map<String, bool> toggles = Toggles.toggleMap;

  void init() {
    for (Preference preference in widget.preferences) {
      if (toggles[preference.preference] != null) {
        toggles[preference.preference] = preference.value == 'true';
      }
    }
  }

  Widget buildLine(String featureName) {
    return Card(
        child: SizedBox(
            height: 48,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(featureName)),
                  Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Switch(
                        value: toggles[featureName] ?? false,
                        activeColor: CommonStyles.secondaryColour,
                        onChanged: (bool value) {
                          PreferenceService.svc.setPreference(Preference(
                              preference: featureName,
                              value: value.toString()));
                          setState(() {
                            shouldInit = false;
                            toggles[featureName] = value;
                          });
                        },
                      ))
                ])));
  }

  @override
  Widget build(BuildContext context) {
    if (shouldInit) {
      init();
    }

    return Expanded(
        child: ListView(
          controller: _scrollController,
          children: toggles.keys.map((f) => buildLine(f)).toList(),
        ));
  }
}
