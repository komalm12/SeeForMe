// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'screens/landing_page.dart';
// import 'screens/home_screen.dart';
// import 'screens/document_scanner.dart';
// import "screens/color.dart"; 
// // import "screens/currency_recognition.dart 

// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: const LandingPage(),
//     routes: {
//       '/scan': (context) => const DocumentScanner(),
//       '/color': (context) => ColorDetectionPage(),

//       // '/object': (context) => const ObjectDetectionScreen(),
//       // '/currency': (context) => const CurrencyRecognitionPage(),
//     },
//   ));
// }
import 'package:flutter/material.dart';
// Removed go_router import as it's not used here.
import 'screens/landing_page.dart';
import 'screens/home_screen.dart';
import 'screens/document_scanner.dart';
import 'screens/color.dart';
// import 'screens/currency_recognition.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LandingPage(), // Don't use `const` unless LandingPage constructor is const
    routes: {
      '/home': (context) => const HomeScreen(),
      '/scan': (context) => const DocumentScanner(),
      '/color': (context) => ColorDetectionPage(),
      // '/currency': (context) => const CurrencyRecognitionPage(),
    },
  ));
}
