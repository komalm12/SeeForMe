// Import necessary Dart and Flutter packages
import 'dart:async'; // For using Timer
import 'dart:convert'; // For decoding JSON response
import 'dart:io'; // For File handling

import 'package:camera/camera.dart'; // To access device camera
import 'package:flutter/material.dart'; // UI toolkit for Flutter
import 'package:flutter_tts/flutter_tts.dart'; // For text-to-speech
import 'package:http/http.dart' as http; // For making HTTP requests

// Define the main CurrencyRecognitionPage widget
class CurrencyRecognitionPage extends StatefulWidget {
  const CurrencyRecognitionPage({Key? key}) : super(key: key);

  @override
  State<CurrencyRecognitionPage> createState() => _CurrencyRecognitionPageState();
}

// Define the state class for CurrencyRecognitionPage
class _CurrencyRecognitionPageState extends State<CurrencyRecognitionPage> {
  CameraController? _cameraController; // Controller for camera
  late List<CameraDescription> _cameras; // List of available cameras
  Timer? _detectionTimer; // Timer for periodic detection
  bool _isDetecting = false; // Flag to avoid overlapping detections

  final FlutterTts flutterTts = FlutterTts(); // Instance of text-to-speech
  String result = ""; // Detected currency label
  double confidence = 0.0; // Confidence of detection

  @override
  void initState() {
    super.initState();
    initializeCamera(); // Initialize camera when widget is created
  }

  // Function to initialize the device camera
  Future<void> initializeCamera() async {
    _cameras = await availableCameras(); // Get list of cameras
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium); // Use first camera

    await _cameraController!.initialize(); // Initialize the camera controller
    if (mounted) {
      setState(() {}); // Refresh UI
      startRealTimeDetection(); // Start detection loop
    }
  }

  // Start periodic real-time detection every 4 seconds
  void startRealTimeDetection() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      // If camera is initialized and not already detecting
      if (_cameraController!.value.isInitialized && !_isDetecting) {
        _isDetecting = true; // Mark detecting state
        try {
          final image = await _cameraController!.takePicture(); // Capture image from camera
          await recognizeCurrency(File(image.path)); // Send image for currency recognition
        } catch (e) {
          print("Error taking picture: $e"); // Handle any errors
        } finally {
          _isDetecting = false; // Reset detecting state
        }
      }
    });
  }

  // Send image to Roboflow API for currency recognition
  Future<void> recognizeCurrency(File imageFile) async {
   
    final url = Uri.parse(
        "https://detect.roboflow.com/currency-detection-cgpjn/2?api_key=AZkWitHZ7tFt8yHbaPks");

    final request = http.MultipartRequest("POST", url); 
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path)); 
    request.fields['confidence'] = '40'; // Minimum confidence level
    request.fields['overlap'] = '30'; // Overlap threshold

    final response = await request.send(); // Send the request

    // If API returns success
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString(); // Read response stream
      final data = json.decode(responseData); // Parse JSON

      // Check if any predictions were made
      if (data['predictions'] != null && data['predictions'].isNotEmpty) {
        final topPrediction = data['predictions'][0]; // Use first prediction
        final label = topPrediction['class'].replaceAll(RegExp(r"^\d+-"), ""); // Clean label

        // If label is different from the last result, speak it out
        if (label != result) {
          setState(() {
            result = label; // Update detected label
            confidence = (topPrediction['confidence'] as num) * 100; // Update confidence
          });

          // Speak out the detected currency
          await flutterTts.speak(
              "Detected currency is $result with ${confidence.toStringAsFixed(0)} percent confidence.");
        }
      }
    } else {
      print("Failed to recognize currency"); // Print error if response fails
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // Dispose camera controller
    _detectionTimer?.cancel(); // Cancel the timer
    flutterTts.stop(); // Stop any ongoing TTS
    super.dispose();
  }

  // Build the user interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for contrast
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white)) // Show loading while camera initializes
          : Stack(
              children: [
                CameraPreview(_cameraController!), // Show live camera feed
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87, // Dark background
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: const Text(
                      "Real-Time Currency Detection", // Header text
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95), // Light panel background
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26, // Shadow for elevation
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          result.isNotEmpty
                              ? "💵 $result" // Show detected label
                              : "👁 Point the camera at a currency note", // Instructional text
                          style: TextStyle(
                            fontSize: result.isNotEmpty ? 26 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (result.isNotEmpty) ...[ // Show confidence only if result exists
                          const SizedBox(height: 8),
                          Text(
                            "Confidence: ${confidence.toStringAsFixed(1)}%", // Display confidence
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
