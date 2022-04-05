import 'package:flutter/material.dart';

import 'components/weight_tracker/weight_tracker.dart';

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
  int _selectedIndex = 1; // Default to weight tracker open
  static final List<Widget> _pages = <Widget>[
    const Text(
      'Macros Coming soon',
    ),
    const WeightTracker(),
    const Text(
      'Workouts Coming soon',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: Scaffold(
          body: Center(
            child: _pages.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant),
                label: 'Macros',
              ),
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
          )),
    );
  }
}
