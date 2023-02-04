import 'package:flutter/material.dart';
import 'package:swole_experience/components/preferences/features.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/service/preference_service.dart';

class FeatureToggles extends StatefulWidget {
  const FeatureToggles({
    Key? key,
  }) : super(key: key);

  @override
  State<FeatureToggles> createState() => _FeatureTogglesState();
}

class _FeatureTogglesState extends State<FeatureToggles> {
  final GlobalKey<_FeatureTogglesState> _togglesKey =
      GlobalKey<_FeatureTogglesState>();

  TextStyle disclaimerStyle =
      const TextStyle(fontSize: 12, fontStyle: FontStyle.italic);

  Widget buildDisclaimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline),
        Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  'Warning: Some of these features are in early access.',
                  style: disclaimerStyle,
                ),
                Text('Turning them on may result in bugs.',
                    style: disclaimerStyle)
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _togglesKey,
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
        title: const Text('Features'),
      ),
      body: FutureBuilder<List<dynamic>>(
          future: Future.wait([PreferenceService.svc.getAllPreferences()]),
          builder: (BuildContext context,
              AsyncSnapshot<List<dynamic>> initSnapshot) {
            if (initSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text('Loading...'));
            } else {
              return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(children: [
                    buildDisclaimer(),
                    FeatureList(preferences: initSnapshot.requireData.first),
                  ]));
            }
          }),
    );
  }
}
