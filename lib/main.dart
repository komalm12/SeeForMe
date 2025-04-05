import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/landing_page.dart';
import 'screens/home_screen.dart';
import 'screens/document_scanner.dart'; // <-- New screen import

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const HomeScreen(),
    routes: {
      '/scan': (context) => const DocumentScanner(),
      // '/color': (context) => const ColorDetectionScreen(),
      // '/object': (context) => const ObjectDetectionScreen(),
      // '/currency': (context) => const CurrencyDetectionScreen(),
    },
  ));
}