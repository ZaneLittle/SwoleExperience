import 'package:flutter/material.dart';
import 'package:swole_experience/components/WeightTracker.dart';

void main() => runApp(SwoleExperienceApp());

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
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          // TODO: BUG: separation lines not showing
        ),
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: Center(
            child: _pages.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            // TODO: BUG: accent colour when selected is ugly
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
            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          ),
        ));
  }
}
