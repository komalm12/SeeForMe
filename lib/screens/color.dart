import 'dart:io'; // For file and directory operations
import 'dart:math'; // For mathematical functions
import 'package:camera/camera.dart'; // For accessing device camera
import 'package:flutter/material.dart'; // For building Flutter UI
import 'package:flutter_tts/flutter_tts.dart'; // For text-to-speech functionality
import 'package:image/image.dart' as img; // For image processing
import 'package:path/path.dart' show join; // For joining file paths
import 'package:path_provider/path_provider.dart'; // For getting app-specific directories

// Main widget for color detection screen
class ColorDetectionPage extends StatefulWidget {
  @override
  _ColorDetectionPageState createState() => _ColorDetectionPageState();
}

// State class for ColorDetectionPage
class _ColorDetectionPageState extends State<ColorDetectionPage> {
  late CameraController _cameraController; // Controls the camera
  late List<CameraDescription> _cameras; // List of available cameras
  bool _isCameraInitialized = false; // Flag to track if camera is ready
  bool _isFlashOn = false; // Flag for flashlight status

  String _detectedColor = ""; // Detected color name
  Color _detectedColorPreview = Colors.transparent; // Color preview for UI
  final FlutterTts _flutterTts = FlutterTts(); // Text-to-speech instance

  // Initialization function
  @override
  void initState() {
    super.initState();
    _initCamera(); // Start camera setup
  }

  // Initialize camera
  Future<void> _initCamera() async {
    _cameras = await availableCameras(); // Get list of available cameras
    _cameraController = CameraController(
      _cameras[0], // Use the first available camera
      ResolutionPreset.medium, // Set resolution
      imageFormatGroup: ImageFormatGroup.jpeg, // Image format
    );
    await _cameraController.initialize(); // Initialize camera
    try {
      await _cameraController.lockCaptureOrientation(); // Lock orientation if possible
    } catch (_) {}

    setState(() => _isCameraInitialized = true); // Mark camera as initialized
    await _autoEnableFlashlight(); // Auto toggle flashlight if environment is dark
  }

  // Automatically enable flashlight in dark conditions
  Future<void> _autoEnableFlashlight() async {
    try {
      final image = await _cameraController.takePicture(); // Capture image
      final imageBytes = await image.readAsBytes(); // Get image bytes
      final decodedImage = img.decodeImage(imageBytes); // Decode image for processing

      if (decodedImage == null) return;

      // Get center pixel color
      final pixel = decodedImage.getPixel(decodedImage.width ~/ 2, decodedImage.height ~/ 2);
      final r = (pixel >> 16) & 0xFF;
      final g = (pixel >> 8) & 0xFF;
      final b = pixel & 0xFF;

      // Calculate brightness using luminosity formula
      final brightness = 0.299 * r + 0.587 * g + 0.114 * b;

      // If dark and flash is off, turn it on
      if (brightness < 60 && !_isFlashOn) {
        _isFlashOn = true;
        await _cameraController.setFlashMode(FlashMode.torch);
      }
    } catch (e) {
      print("Flashlight error: $e");
    }
  }

  // Capture image and detect average color in center region
  Future<void> _captureAndDetectColor() async {
    try {
      final image = await _cameraController.takePicture(); // Capture image
      final bytes = await image.readAsBytes(); // Read bytes
      final decodedImage = img.decodeImage(bytes); // Decode for processing

      if (decodedImage == null) return;

      final centerX = decodedImage.width ~/ 2; // Center X
      final centerY = decodedImage.height ~/ 2; // Center Y
      const sampleSize = 20; // Region size to average

      int sumR = 0, sumG = 0, sumB = 0, count = 0;

      // Loop over square region around center
      for (int dx = -sampleSize ~/ 2; dx < sampleSize ~/ 2; dx++) {
        for (int dy = -sampleSize ~/ 2; dy < sampleSize ~/ 2; dy++) {
          final x = centerX + dx;
          final y = centerY + dy;
          if (x >= 0 && y >= 0 && x < decodedImage.width && y < decodedImage.height) {
            final pixel = decodedImage.getPixel(x, y);
            sumR += (pixel >> 16) & 0xFF;
            sumG += (pixel >> 8) & 0xFF;
            sumB += pixel & 0xFF;
            count++;
          }
        }
      }

      // Calculate average RGB values
      final avgR = (sumR / count).round();
      final avgG = (sumG / count).round();
      final avgB = (sumB / count).round();

      // Find closest color name
      final detectedName = _getClosestColorName(avgR, avgG, avgB);

      // If color changed, update UI and speak
      if (detectedName != _detectedColor) {
        setState(() {
          _detectedColor = detectedName;
          _detectedColorPreview = Color.fromARGB(255, avgR, avgG, avgB);
        });

        if (detectedName != "Unknown") {
          await _flutterTts.speak("Detected color is $detectedName");
        }
      }
    } catch (e) {
      print("Detection error: $e");
    }
  }

  // Get closest named color using LAB color distance
  String _getClosestColorName(int r, int g, int b) {
    final namedColors = {
      "Black": Color(0xFF000000),
      "White": Color(0xFFFFFFFF),
      "Red": Color(0xFFFF0000),
      "Green": Color(0xFF008000),
      "Blue": Color(0xFF0000FF),
      "Yellow": Color(0xFFFFFF00),
      "Cyan": Color(0xFF00FFFF),
      "Magenta": Color(0xFFFF00FF),
      "Gray": Color(0xFF808080),
      "Orange": Color(0xFFFFA500),
      "Pink": Color(0xFFFFC0CB),
      "Brown": Color(0xFF6B4423),
      "Purple": Color(0xFF800080),
      "Lime": Color(0xFF00FF00),
      "Navy": Color(0xFF000080),
      "Teal": Color(0xFF008080),
      "Olive": Color(0xFF808000),
      "Gold": Color(0xFFFFD700),
      "Beige": Color(0xFFF5F5DC),
      "Coral": Color(0xFFFF7F50),
      "Sky Blue": Color(0xFF87CEEB),
      "Lavender": Color(0xFFE6E6FA),
      "Turquoise": Color(0xFF40E0D0),
      "Crimson": Color(0xFFDC143C),
      "Indigo": Color(0xFF4B0082),
      "Plum": Color(0xFFDDA0DD),
      "Forest Green": Color(0xFF228B22),
      "Dark Gray": Color(0xFFA9A9A9),
      "Dark Brown": Color(0xFF4B2E2B),
      "Light Brown": Color(0xFFB5651D),
    };

    double minDistance = double.infinity;
    String closest = "Unknown";

    // Find color with smallest LAB distance
    namedColors.forEach((name, color) {
      final dist = _colorDistanceLAB(r, g, b, color.red, color.green, color.blue);
      if (dist < minDistance) {
        minDistance = dist;
        closest = name;
      }
    });

    return closest;
  }

  // Calculate LAB color distance
  double _colorDistanceLAB(int r1, int g1, int b1, int r2, int g2, int b2) {
    final lab1 = _rgbToLab(r1, g1, b1);
    final lab2 = _rgbToLab(r2, g2, b2);
    return sqrt(pow(lab1[0] - lab2[0], 2) +
        pow(lab1[1] - lab2[1], 2) +
        pow(lab1[2] - lab2[2], 2));
  }

  // Convert RGB to LAB color space
  List<double> _rgbToLab(int r, int g, int b) {
    double rf = r / 255, gf = g / 255, bf = b / 255;

    // Convert to linear RGB
    rf = rf > 0.04045 ? pow((rf + 0.055) / 1.055, 2.4).toDouble() : rf / 12.92;
    gf = gf > 0.04045 ? pow((gf + 0.055) / 1.055, 2.4).toDouble() : gf / 12.92;
    bf = bf > 0.04045 ? pow((bf + 0.055) / 1.055, 2.4).toDouble() : bf / 12.92;

    // Convert to XYZ
    double x = (rf * 0.4124 + gf * 0.3576 + bf * 0.1805) / 0.95047;
    double y = (rf * 0.2126 + gf * 0.7152 + bf * 0.0722) / 1.00000;
    double z = (rf * 0.0193 + gf * 0.1192 + bf * 0.9505) / 1.08883;

    // Convert to LAB
    x = x > 0.008856 ? pow(x, 1 / 3).toDouble() : (7.787 * x) + (16 / 116);
    y = y > 0.008856 ? pow(y, 1 / 3).toDouble() : (7.787 * y) + (16 / 116);
    z = z > 0.008856 ? pow(z, 1 / 3).toDouble() : (7.787 * z) + (16 / 116);

    return [(116 * y) - 16, 500 * (x - y), 200 * (y - z)];
  }

  // Dispose camera and TTS when not needed
  @override
  void dispose() {
    _cameraController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Color Detection"),
        backgroundColor: Colors.teal[800],
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController), // Live camera preview
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.black.withOpacity(0.4), // Semi-transparent overlay
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: _captureAndDetectColor, // Trigger detection
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Detect Color", style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        if (_detectedColor.isNotEmpty)
                          Column(
                            children: [
                              Text(
                                "Detected: $_detectedColor", // Show detected color name
                                style: const TextStyle(fontSize: 22, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _detectedColorPreview, // Show detected color visually
                                  border: Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()), // Show loading until camera is ready
    );
  }
}
