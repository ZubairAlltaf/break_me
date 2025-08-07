import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const PatternRecallApp());
}

class PatternRecallApp extends StatelessWidget {
  const PatternRecallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pattern Recall',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'PressStart2P',
      ),
      navigatorKey: navigatorKey,
      home: const MainMenuScreen(),
    );
  }
}