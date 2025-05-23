import 'dart:async'; // For timers and async control
import 'dart:io'; // For working with files
import 'package:camera/camera.dart'; // Camera plugin
import 'package:flutter/material.dart'; // Flutter UI components
import 'package:flutter_tts/flutter_tts.dart'; // Text-to-speech plugin
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON decoding
import 'package:path_provider/path_provider.dart'; // (Not used here, can be removed)

// Stateful widget for live object detection screen
class LiveObjectDetectionPage extends StatefulWidget {
  @override
  _LiveObjectDetectionPageState createState() => _LiveObjectDetectionPageState();
}

class _LiveObjectDetectionPageState extends State<LiveObjectDetectionPage> {
  CameraController? _cameraController; // Controller to handle camera
  List<CameraDescription>? cameras; // List of available cameras
  bool _isDetecting = false; // Flag to prevent multiple detections at once
  List detections = []; // List to hold detected objects
  Timer? _timer; // Timer to schedule repeated detections
  final FlutterTts flutterTts = FlutterTts(); // Text-to-speech instance

  @override
  void initState() {
    super.initState();
    initCamera(); // Initialize camera when widget is created
  }

  // Function to initialize the camera and start periodic detection
  Future<void> initCamera() async {
    cameras = await availableCameras(); // Get list of available cameras
    _cameraController = CameraController(cameras![0], ResolutionPreset.medium); // Use the first camera with medium quality
    await _cameraController!.initialize(); // Initialize the camera
    setState(() {}); // Rebuild UI after camera is ready

    // Start capturing images every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (_) => captureAndDetect());
  }

  // Function to capture image and detect objects using backend API
  Future<void> captureAndDetect() async {
    // If already detecting or camera not ready, skip this call
    if (_cameraController == null || _isDetecting) return;

    _isDetecting = true; // Set detecting flag

    try {
      final file = await _cameraController!.takePicture(); // Capture image
      File imageFile = File(file.path); // Convert to File

      final detected = await detectObjects(imageFile); // Send to backend for detection

      if (detected.isNotEmpty) {
        setState(() {
          detections = detected; // Update UI with detected objects
        });

        // Speak out detected objects
        await flutterTts.speak("Detected: ${detections.join(', ')}");
      }
    } catch (e) {
      print("Error in detection: $e"); // Log error
    } finally {
      _isDetecting = false; // Reset flag
    }
  }

  // Function to send image to Flask backend and receive detected objects
  Future<List> detectObjects(File imageFile) async {
    try {
      // Create HTTP multipart POST request to Flask endpoint
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://100.67.175.40:5000/detect"), // Replace with your server IP
      );

      // Attach image file to the request
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        // If successful, decode response body
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        return data['detections']; // Return list of detected object names
      }
    } catch (e) {
      print("Failed to send image: $e"); // Log error
    }

    return []; // Return empty list if detection fails
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // Dispose camera controller
    _timer?.cancel(); // Cancel periodic timer
    super.dispose();
  }

  // UI rendering function
  @override
  Widget build(BuildContext context) {
    // Show loading spinner while camera is initializing
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text("Live Object Detection")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Main UI with live camera preview and detected object list overlay
    return Scaffold(
      body: Stack(
        children: [
          // Display camera preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // Show detected objects at bottom of screen if available
          if (detections.isNotEmpty)
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(12),
                color: Colors.black54, // Semi-transparent background
                child: Text(
                  "Detected: ${detections.join(', ')}", // Display detections
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            )
        ],
      ),
    );
  }
}
