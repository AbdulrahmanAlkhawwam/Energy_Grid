import 'package:flutter/material.dart';
import 'screens/grid_setup_screen.dart';

void main() {
  runApp(EnergyGridApp());
}

class EnergyGridApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Grid Simulator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF071019),
        primaryColor: const Color(0xFF00FFC6),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
      ),
      home: GridSetupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
