import 'package:flutter/material.dart';

import 'package:swole_experience/components/workouts/workouts.dart';
import 'package:swole_experience/components/weight_tracker/weight_tracker.dart';
import 'package:swole_experience/constants/pages.dart';
import 'package:swole_experience/constants/preference_constants.dart';
import 'package:swole_experience/constants/toggles.dart';
import 'package:swole_experience/model/preference.dart';
import 'package:swole_experience/service/preference_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SwoleExperienceApp());
}

class SwoleExperienceApp extends StatelessWidget {
  const SwoleExperienceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StatefulApp(),
    );
  }
}

class StatefulApp extends StatefulWidget {
  const StatefulApp({Key? key}) : super(key: key);

  @override
  State<StatefulApp> createState() => _AppState();
}

class _AppState extends State<StatefulApp> {
  int _selectedIndex = 0; // Default to weight tracker open
  static final List<Widget> _pages = <Widget>[
    Toggles.macros ? const Text('Macros Coming soon',) : Container(),
    const WeightTracker(),
    const Workouts(),
  ];

  void setPagePref(int index) {

    PreferenceService.svc.setPreference(Preference(
        preference: PreferenceConstant.defaultPageKey,
        value: Pages.getPage(index),
        lastUpdated: DateTime.now()));
  }

  void _onItemTapped(int index) {
    setPagePref(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  MaterialApp buildApp(Widget home) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: home,
    );
  }

  Scaffold buildAppHome() {
    return Scaffold(
        body: Center(
          child: _pages.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.restaurant),
            //   label: 'Macros',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: 'Weight',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Workout',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xffb24dff),
          onTap: _onItemTapped,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<dynamic>>>(
        future: Future.wait([
          PreferenceService.svc
              .getPreference(PreferenceConstant.defaultPageKey),
        ]),
        builder: (BuildContext context,
            AsyncSnapshot<List<List<dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildApp(
                const Scaffold(body: Center(child: Text('Loading...'))));
          } else if (snapshot.data != null &&
              snapshot.data!.first.isNotEmpty &&
              (snapshot.data!.first.first as Preference).value != null) {
            Preference? page = snapshot.data!.first.first as Preference;
            _selectedIndex = Pages.pageMap[page.value] ?? 0;
          }

          return buildApp(buildAppHome());
        });
  }
}
