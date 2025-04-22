// import 'dart:io';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:image/image.dart' as img;
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';

// class ColorDetectionPage extends StatefulWidget {
//   @override
//   _ColorDetectionPageState createState() => _ColorDetectionPageState();
// }

// class _ColorDetectionPageState extends State<ColorDetectionPage> {
//   late CameraController _cameraController;
//   late List<CameraDescription> _cameras;
//   bool _isCameraInitialized = false;
//   String _detectedColor = "";
//   final FlutterTts _flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   Future<void> _initCamera() async {
//     _cameras = await availableCameras();
//     _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
//     await _cameraController.initialize();
//     setState(() {
//       _isCameraInitialized = true;
//     });
//   }

//   Future<void> _captureAndDetectColor() async {
//     final directory = await getTemporaryDirectory();
//     final imagePath = join(directory.path, '${DateTime.now()}.png');
//     await _cameraController.takePicture().then((XFile file) async {
//       final imageBytes = await file.readAsBytes();
//       final decodedImage = img.decodeImage(imageBytes);

//       if (decodedImage == null) return;

//       // Get center pixel
//       final centerX = decodedImage.width ~/ 2;
//       final centerY = decodedImage.height ~/ 2;
//       final pixel = decodedImage.getPixel(centerX, centerY);

//       final red = (pixel >> 16) & 0xFF;
//       final green = (pixel >> 8) & 0xFF;
//       final blue = pixel & 0xFF;

//      final colorName = _getColorName(red.toInt(), green.toInt(), blue.toInt());


//       setState(() {
//         _detectedColor = colorName;
//       });

//       await _flutterTts.speak("Detected color is $colorName");
//     });
//   }

//   String _getColorName(int r, int g, int b) {
//     final Map<String, Color> predefinedColors = {
//       "Red": Colors.red,
//       "Green": Colors.green,
//       "Blue": Colors.blue,
//       "Yellow": Colors.yellow,
//       "Orange": Colors.orange,
//       "Purple": Colors.purple,
//       "Pink": Colors.pink,
//       "Brown": Color(0xFFA52A2A),
//       "Black": Colors.black,
//       "White": Colors.white,
//       "Gray": Colors.grey,
//     };

//     String closestColor = "Unknown";
//     double minDistance = double.infinity;

//     predefinedColors.forEach((name, color) {
//       double distance = ((r - color.red) * (r - color.red) +
//               (g - color.green) * (g - color.green) +
//               (b - color.blue) * (b - color.blue))
//           .toDouble();
//       if (distance < minDistance) {
//         minDistance = distance;
//         closestColor = name;
//       }
//     });

//     return closestColor;
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Color Detection"),
//       ),
//       body: _isCameraInitialized
//           ? Stack(
//               children: [
//                 CameraPreview(_cameraController),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         ElevatedButton(
//                           onPressed: _captureAndDetectColor,
//                           child: Text("Detect Color"),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           _detectedColor.isNotEmpty
//                               ? "Color: $_detectedColor"
//                               : "Tap button to detect",
//                           style: TextStyle(fontSize: 20, color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }

// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:image/image.dart' as img;
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'dart:math';

// class ColorDetectionPage extends StatefulWidget {
//   @override
//   _ColorDetectionPageState createState() => _ColorDetectionPageState();
// }

// class _ColorDetectionPageState extends State<ColorDetectionPage> {
//   late CameraController _cameraController;
//   late List<CameraDescription> _cameras;
//   bool _isCameraInitialized = false;
//   String _detectedColor = "";
//   final FlutterTts _flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   Future<void> _initCamera() async {
//     _cameras = await availableCameras();
//     _cameraController = CameraController(
//       _cameras[0],
//       ResolutionPreset.medium,
//       imageFormatGroup: ImageFormatGroup.jpeg,
//     );
//     await _cameraController.initialize();

//     // Optionally lock white balance (if supported)
//     try {
//       await _cameraController.lockCaptureOrientation();
//     } catch (_) {}

//     setState(() {
//       _isCameraInitialized = true;
//     });
//   }

//   Future<void> _captureAndDetectColor() async {
//     final directory = await getTemporaryDirectory();
//     final imagePath = join(directory.path, '${DateTime.now()}.png');
//     await _cameraController.takePicture().then((XFile file) async {
//       final imageBytes = await file.readAsBytes();
//       final decodedImage = img.decodeImage(imageBytes);

//       if (decodedImage == null) return;

//       // Sample a 10x10 square around center
//       final centerX = decodedImage.width ~/ 2;
//       final centerY = decodedImage.height ~/ 2;
//       int sampleSize = 10;

//       int totalR = 0, totalG = 0, totalB = 0, count = 0;
//       for (int dx = -sampleSize ~/ 2; dx < sampleSize ~/ 2; dx++) {
//         for (int dy = -sampleSize ~/ 2; dy < sampleSize ~/ 2; dy++) {
//           int x = centerX + dx;
//           int y = centerY + dy;
//           if (x >= 0 && x < decodedImage.width && y >= 0 && y < decodedImage.height) {
//             int pixel = decodedImage.getPixel(x, y);
//             totalR += (pixel >> 16) & 0xFF;
//             totalG += (pixel >> 8) & 0xFF;
//             totalB += pixel & 0xFF;
//             count++;
//           }
//         }
//       }

//       int avgR = (totalR / count).round();
//       int avgG = (totalG / count).round();
//       int avgB = (totalB / count).round();

//       final colorName = _getClosestColorName(avgR, avgG, avgB);

//       setState(() {
//         _detectedColor = colorName;
//       });

//       await _flutterTts.speak("Detected color is $colorName");
//     });
//   }

//   String _getClosestColorName(int r, int g, int b) {
//     final Map<String, Color> namedColors = {
//       "Black": Color(0xFF000000),
//       "White": Color(0xFFFFFFFF),
//       "Red": Color(0xFFFF0000),
//       "Green": Color(0xFF008000),
//       "Blue": Color(0xFF0000FF),
//       "Yellow": Color(0xFFFFFF00),
//       "Cyan": Color(0xFF00FFFF),
//       "Magenta": Color(0xFFFF00FF),
//       "Gray": Color(0xFF808080),
//       "Orange": Color(0xFFFFA500),
//       "Pink": Color(0xFFFFC0CB),
//       "Brown": Color(0xFFA52A2A),
//       "Purple": Color(0xFF800080),
//       "Lime": Color(0xFF00FF00),
//       "Navy": Color(0xFF000080),
//       "Teal": Color(0xFF008080),
//       "Olive": Color(0xFF808000),
//       "Gold": Color(0xFFFFD700),
//       "Beige": Color(0xFFF5F5DC),
//       "Coral": Color(0xFFFF7F50),
//       "Sky Blue": Color(0xFF87CEEB),
//       "Lavender": Color(0xFFE6E6FA),
//       "Turquoise": Color(0xFF40E0D0),
//       "Crimson": Color(0xFFDC143C),
//       "Indigo": Color(0xFF4B0082),
//       "Plum": Color(0xFFDDA0DD),
//       "Forest Green": Color(0xFF228B22),
//       "Dark Gray": Color(0xFFA9A9A9),
//     };

//     double minDistance = double.infinity;
//     String closestColor = "Unknown";

//     namedColors.forEach((name, color) {
//       final dist = _colorDistanceLAB(r, g, b, color.red, color.green, color.blue);
//       if (dist < minDistance) {
//         minDistance = dist;
//         closestColor = name;
//       }
//     });

//     return closestColor;
//   }

//   // Convert RGB to LAB color space and compute distance
//   double _colorDistanceLAB(int r1, int g1, int b1, int r2, int g2, int b2) {
//     List<double> lab1 = _rgbToLab(r1, g1, b1);
//     List<double> lab2 = _rgbToLab(r2, g2, b2);
//     return sqrt(pow(lab1[0] - lab2[0], 2) +
//         pow(lab1[1] - lab2[1], 2) +
//         pow(lab1[2] - lab2[2], 2));
//   }

//   // RGB to LAB conversion (approximation)
//   List<double> _rgbToLab(int r, int g, int b) {
//     // Convert RGB to XYZ
//     double rf = r / 255, gf = g / 255, bf = b / 255;
//     rf = rf > 0.04045 ? pow((rf + 0.055) / 1.055, 2.4).toDouble() : rf / 12.92;
//     gf = gf > 0.04045 ? pow((gf + 0.055) / 1.055, 2.4).toDouble() : gf / 12.92;
//     bf = bf > 0.04045 ? pow((bf + 0.055) / 1.055, 2.4).toDouble() : bf / 12.92;

//     double x = (rf * 0.4124 + gf * 0.3576 + bf * 0.1805) / 0.95047;
//     double y = (rf * 0.2126 + gf * 0.7152 + bf * 0.0722) / 1.00000;
//     double z = (rf * 0.0193 + gf * 0.1192 + bf * 0.9505) / 1.08883;

//     x = x > 0.008856 ? pow(x, 1 / 3).toDouble() : (7.787 * x) + (16 / 116);
//     y = y > 0.008856 ? pow(y, 1 / 3).toDouble() : (7.787 * y) + (16 / 116);
//     z = z > 0.008856 ? pow(z, 1 / 3).toDouble() : (7.787 * z) + (16 / 116);

//     double l = (116 * y) - 16;
//     double a = 500 * (x - y);
//     double bVal = 200 * (y - z);
//     return [l, a, bVal];
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Color Detection"),
//         backgroundColor: Colors.teal[800],
//       ),
//       body: _isCameraInitialized
//           ? Stack(
//               children: [
//                 CameraPreview(_cameraController),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         ElevatedButton(
//                           onPressed: _captureAndDetectColor,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal,
//                             padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Text("Detect Color", style: TextStyle(fontSize: 18)),
//                         ),
//                         SizedBox(height: 12),
//                         Text(
//                           _detectedColor.isNotEmpty
//                               ? "Detected: $_detectedColor"
//                               : "Tap to detect color",
//                           style: TextStyle(fontSize: 20, color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }

import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class ColorDetectionPage extends StatefulWidget {
  @override
  _ColorDetectionPageState createState() => _ColorDetectionPageState();
}

class _ColorDetectionPageState extends State<ColorDetectionPage> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  String _detectedColor = "";
  Color _detectedColorPreview = Colors.transparent;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }
  Future<void> _autoEnableFlashlight() async {
  try {
    final image = await _cameraController.takePicture();
    final imageBytes = await image.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) return;

    // Sample brightness at the center of the image
    int centerX = decodedImage.width ~/ 2;
    int centerY = decodedImage.height ~/ 2;
    int pixel = decodedImage.getPixel(centerX, centerY);

    int r = (pixel >> 16) & 0xFF;
    int g = (pixel >> 8) & 0xFF;
    int b = pixel & 0xFF;

    double brightness = (0.299 * r + 0.587 * g + 0.114 * b);

    if (brightness < 60 && !_isFlashOn) {
      _isFlashOn = true;
      await _cameraController.setFlashMode(FlashMode.torch);
      setState(() {});
    }
  } catch (e) {
    print("Error auto enabling flashlight: $e");
  }
}


 Future<void> _initCamera() async {
  _cameras = await availableCameras();
  _cameraController = CameraController(
    _cameras[0],
    ResolutionPreset.medium,
    imageFormatGroup: ImageFormatGroup.jpeg,
  );
  await _cameraController.initialize();

  try {
    await _cameraController.lockCaptureOrientation();
  } catch (_) {}

  setState(() {
    _isCameraInitialized = true;
  });

  // Auto-check brightness and turn on flashlight if needed
  await _autoEnableFlashlight();
}

  

  Future<void> _captureAndDetectColor() async {
    final directory = await getTemporaryDirectory();
    final imagePath = join(directory.path, '${DateTime.now()}.png');
    await _cameraController.takePicture().then((XFile file) async {
      final imageBytes = await file.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) return;

      final centerX = decodedImage.width ~/ 2;
      final centerY = decodedImage.height ~/ 2;
      int sampleSize = 20;

      List<int> reds = [], greens = [], blues = [];

      for (int dx = -sampleSize ~/ 2; dx < sampleSize ~/ 2; dx++) {
        for (int dy = -sampleSize ~/ 2; dy < sampleSize ~/ 2; dy++) {
          int x = centerX + dx;
          int y = centerY + dy;
          if (x >= 0 && x < decodedImage.width && y >= 0 && y < decodedImage.height) {
            int pixel = decodedImage.getPixel(x, y);
            reds.add((pixel >> 16) & 0xFF);
            greens.add((pixel >> 8) & 0xFF);
            blues.add(pixel & 0xFF);
          }
        }
      }

      reds.sort();
      greens.sort();
      blues.sort();
      int medianIndex = reds.length ~/ 2;

      int medianR = reds[medianIndex];
      int medianG = greens[medianIndex];
      int medianB = blues[medianIndex];

      final colorName = _getClosestColorName(medianR, medianG, medianB);

      setState(() {
        _detectedColor = colorName;
        _detectedColorPreview = Color.fromARGB(255, medianR, medianG, medianB);
      });

      await _flutterTts.speak("Detected color is $colorName");
    });
  }

  String _getClosestColorName(int r, int g, int b) {
    final Map<String, Color> namedColors = {
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
      "Brown": Color(0xFFA52A2A),
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
    };

    double minDistance = double.infinity;
    String closestColor = "Unknown";

    namedColors.forEach((name, color) {
      final dist = _colorDistanceLAB(r, g, b, color.red, color.green, color.blue);
      if (dist < minDistance) {
        minDistance = dist;
        closestColor = name;
      }
    });

    return closestColor;
  }

  double _colorDistanceLAB(int r1, int g1, int b1, int r2, int g2, int b2) {
    List<double> lab1 = _rgbToLab(r1, g1, b1);
    List<double> lab2 = _rgbToLab(r2, g2, b2);
    return sqrt(pow(lab1[0] - lab2[0], 2) +
        pow(lab1[1] - lab2[1], 2) +
        pow(lab1[2] - lab2[2], 2));
  }

  List<double> _rgbToLab(int r, int g, int b) {
    double rf = r / 255, gf = g / 255, bf = b / 255;
    rf = rf > 0.04045 ? pow((rf + 0.055) / 1.055, 2.4).toDouble() : rf / 12.92;
    gf = gf > 0.04045 ? pow((gf + 0.055) / 1.055, 2.4).toDouble() : gf / 12.92;
    bf = bf > 0.04045 ? pow((bf + 0.055) / 1.055, 2.4).toDouble() : bf / 12.92;

    double x = (rf * 0.4124 + gf * 0.3576 + bf * 0.1805) / 0.95047;
    double y = (rf * 0.2126 + gf * 0.7152 + bf * 0.0722) / 1.00000;
    double z = (rf * 0.0193 + gf * 0.1192 + bf * 0.9505) / 1.08883;

    x = x > 0.008856 ? pow(x, 1 / 3).toDouble() : (7.787 * x) + (16 / 116);
    y = y > 0.008856 ? pow(y, 1 / 3).toDouble() : (7.787 * y) + (16 / 116);
    z = z > 0.008856 ? pow(z, 1 / 3).toDouble() : (7.787 * z) + (16 / 116);

    double l = (116 * y) - 16;
    double a = 500 * (x - y);
    double bVal = 200 * (y - z);
    return [l, a, bVal];
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Color Detection"),
        backgroundColor: Colors.teal[800],
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: _captureAndDetectColor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Detect Color", style: TextStyle(fontSize: 18)),
                        ),
                        SizedBox(height: 12),
                        if (_detectedColor.isNotEmpty)
                          Column(
                            children: [
                              Text(
                                "Detected: $_detectedColor",
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _detectedColorPreview,
                                  border: Border.all(color: Colors.white),
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
          : Center(child: CircularProgressIndicator()),
    );
  }
}
