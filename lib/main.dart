import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/home_screen.dart';
import 'screens/document_scanner.dart';
import 'screens/color.dart';
import 'screens/currency_recognition.dart';
import 'screens/object_detection.dart'; // <-- Import currency recognition screen

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LandingPage(), // Main entry point
    routes: {
      '/home': (context) => const HomeScreen(),
      '/scan': (context) => const DocumentScanner(),
      '/color': (context) => ColorDetectionPage(),
     '/currency': (context) => const CurrencyRecognitionPage(),
      '/object': (context) => LiveObjectDetectionPage(), // <-- Route to currency recognition
    },
  ));
}
