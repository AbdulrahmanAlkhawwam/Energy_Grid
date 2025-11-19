import 'package:flutter/material.dart';
import 'screens/grid_setup_screen.dart';
import 'style/colors.dart';

void main() {
  runApp(EnergyGridApp());
}

class EnergyGridApp extends StatelessWidget {
  const EnergyGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Grid Simulator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GridColors.background,
        primaryColor: const Color(0xFF00FFC6),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
      ),
      home: GridSetupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
