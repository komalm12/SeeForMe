// 
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _focusedIndex = 0;

  final List<Map<String, dynamic>> _options = [
    {'label': 'Scan and Read', 'route': '/scan'},
    {'label': 'Color Detection', 'route': '/color'},
    {'label': 'Object Detection', 'route': '/object'},
    {'label': 'Currency Detection', 'route': '/currency'},
  ];

  @override
  void initState() {
    super.initState();
    _welcomeAndGuideUser();
  }

  Future<void> _welcomeAndGuideUser() async {
    await _flutterTts.speak("Welcome to SeeForMe App.");
    await Future.delayed(const Duration(seconds: 2));
    await _flutterTts.speak(
      "Swipe right or left to navigate between options. Double tap to select.",
    );
    await Future.delayed(const Duration(seconds: 3));
    _announceFocusedOption();
  }

  void _announceFocusedOption() async {
    await _flutterTts.speak(_options[_focusedIndex]['label']);
  }

  void _onSwipeLeft() {
    setState(() {
      _focusedIndex = (_focusedIndex - 1 + _options.length) % _options.length;
    });
    _announceFocusedOption();
  }

  void _onSwipeRight() {
    setState(() {
      _focusedIndex = (_focusedIndex + 1) % _options.length;
    });
    _announceFocusedOption();
  }

  void _onDoubleTap() {
    Navigator.pushNamed(context, _options[_focusedIndex]['route']);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            _onSwipeLeft(); // Right swipe
          } else {
            _onSwipeRight(); // Left swipe
          }
        }
      },
      onDoubleTap: _onDoubleTap,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0B836A), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Expanded(
                  child: Center(
                    child: Text(
                      _options[_focusedIndex]['label'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
