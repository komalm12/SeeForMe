// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class CurrencyRecognitionPage extends StatefulWidget {
//   const CurrencyRecognitionPage({super.key});

//   @override
//   State<CurrencyRecognitionPage> createState() => _CurrencyRecognitionPageState();
// }

// class _CurrencyRecognitionPageState extends State<CurrencyRecognitionPage> {
//   File? _image;
//   String result = "";
//   double confidence = 0.0;
//   final FlutterTts flutterTts = FlutterTts();

//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         result = "";
//         confidence = 0.0;
//       });
//       await recognizeCurrency(_image!);
//     }
//   }

//   Future<void> recognizeCurrency(File imageFile) async {
//     final apiKey = "AZkWitHZ7tFt8yHbaPks"; // 🔁 Replace with your Roboflow API Key
//     final projectName = "currency-detection-cgpjn"; // 🔁 Replace with your Roboflow Project Name
//     final modelVersion = "2"; // 🔁 Replace with model version, e.g., "1"

//     final url = Uri.parse("https://detect.roboflow.com/currency-detection-cgpjn/2?api_key=AZkWitHZ7tFt8yHbaPks");

//     final request = http.MultipartRequest("POST", url);
//     request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
//     request.fields['confidence'] = '40'; // Optional confidence filter
//     request.fields['overlap'] = '30';    // Optional overlap setting

//     final response = await request.send();

//     if (response.statusCode == 200) {
//       final responseData = await response.stream.bytesToString();
//       final data = json.decode(responseData);

//       if (data['predictions'] != null && data['predictions'].isNotEmpty) {
//         final topPrediction = data['predictions'][0];

//         setState(() {
//           result = topPrediction['class'];
//           confidence = (topPrediction['confidence'] as num) * 100;
//         });

//         await flutterTts.speak(
//             "Detected currency is $result with ${confidence.toStringAsFixed(0)} percent confidence.");
//       } else {
//         setState(() {
//           result = "No currency detected";
//           confidence = 0.0;
//         });
//         await flutterTts.speak("No currency detected.");
//       }
//     } else {
//       print("Currency recognition failed");
//       await flutterTts.speak("Failed to recognize currency");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Currency Recognition")),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             if (_image != null) Image.file(_image!),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: pickImage,
//               child: const Text("Capture Currency"),
//             ),
//             const SizedBox(height: 20),
//             if (result.isNotEmpty)
//               Text(
//                 "Result: $result\nConfidence: ${confidence.toStringAsFixed(2)}%",
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class CurrencyRecognitionPage extends StatefulWidget {
//   const CurrencyRecognitionPage({super.key});

//   @override
//   State<CurrencyRecognitionPage> createState() => _CurrencyRecognitionPageState();
// }

// class _CurrencyRecognitionPageState extends State<CurrencyRecognitionPage> {
//   File? _image;
//   String result = "";
//   double confidence = 0.0;
//   final FlutterTts flutterTts = FlutterTts();
//   bool _isLoading = false;

//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         result = "";
//         confidence = 0.0;
//         _isLoading = true;
//       });
//       await recognizeCurrency(_image!);
//     }
//   }

//   Future<void> recognizeCurrency(File imageFile) async {
//     final apiKey = "AZkWitHZ7tFt8yHbaPks";
//     final url = Uri.parse("https://detect.roboflow.com/currency-detection-cgpjn/2?api_key=$apiKey");

//     final request = http.MultipartRequest("POST", url);
//     request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
//     request.fields['confidence'] = '40';
//     request.fields['overlap'] = '30';

//     final response = await request.send();
//     setState(() => _isLoading = false);

//     if (response.statusCode == 200) {
//       final responseData = await response.stream.bytesToString();
//       final data = json.decode(responseData);

//       if (data['predictions'] != null && data['predictions'].isNotEmpty) {
//         final topPrediction = data['predictions'][0];

//         setState(() {
//           result = topPrediction['class'].replaceAll(RegExp(r"^\d+-"), ""); // removes "2-" or similar
//           confidence = (topPrediction['confidence'] as num) * 100;
//         });

//         await flutterTts.speak(
//           "Detected currency is $result with ${confidence.toStringAsFixed(0)} percent confidence.",
//         );
//       } else {
//         setState(() {
//           result = "No currency detected";
//           confidence = 0.0;
//         });
//         await flutterTts.speak("No currency detected.");
//       }
//     } else {
//       setState(() {
//         result = "Detection failed. Try again.";
//         confidence = 0.0;
//       });
//       await flutterTts.speak("Failed to recognize currency.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text("Currency Recognition"),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
//         child: Column(
//           children: [
//             if (_image != null)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.file(
//                   _image!,
//                   height: 250,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               )
//             else
//               Container(
//                 height: 250,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[800],
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     "No image selected",
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: pickImage,
//               icon: const Icon(Icons.camera_alt),
//               label: const Text("Capture Currency"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber,
//                 foregroundColor: Colors.black,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             if (_isLoading)
//               const CircularProgressIndicator(color: Colors.amber)
//             else if (result.isNotEmpty)
//               Column(
//                 children: [
//                   Text(
//                     "Result: $result",
//                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "Confidence: ${confidence.toStringAsFixed(2)}%",
//                     style: const TextStyle(fontSize: 18, color: Colors.white70),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class CurrencyRecognitionPage extends StatefulWidget {
  const CurrencyRecognitionPage({Key? key}) : super(key: key);

  @override
  State<CurrencyRecognitionPage> createState() => _CurrencyRecognitionPageState();
}

class _CurrencyRecognitionPageState extends State<CurrencyRecognitionPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  Timer? _detectionTimer;
  bool _isDetecting = false;

  final FlutterTts flutterTts = FlutterTts();
  String result = "";
  double confidence = 0.0;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);

    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
      startRealTimeDetection();
    }
  }

  void startRealTimeDetection() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (_cameraController!.value.isInitialized && !_isDetecting) {
        _isDetecting = true;
        try {
          final image = await _cameraController!.takePicture();
          await recognizeCurrency(File(image.path));
        } catch (e) {
          print("Error taking picture: $e");
        } finally {
          _isDetecting = false;
        }
      }
    });
  }

  Future<void> recognizeCurrency(File imageFile) async {
    final url = Uri.parse(
        "https://detect.roboflow.com/currency-detection-cgpjn/2?api_key=AZkWitHZ7tFt8yHbaPks");

    final request = http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    request.fields['confidence'] = '40';
    request.fields['overlap'] = '30';

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (data['predictions'] != null && data['predictions'].isNotEmpty) {
        final topPrediction = data['predictions'][0];
        final label = topPrediction['class'].replaceAll(RegExp(r"^\d+-"), "");

        if (label != result) {
          setState(() {
            result = label;
            confidence = (topPrediction['confidence'] as num) * 100;
          });

          await flutterTts.speak(
              "Detected currency is $result with ${confidence.toStringAsFixed(0)} percent confidence.");
        }
      }
    } else {
      print("Failed to recognize currency");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _detectionTimer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Real-Time Currency Detection",
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
  child: AnimatedOpacity(
    opacity: 1.0,
    duration: Duration(milliseconds: 500),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              result.isNotEmpty
                  ? "💸 $result"
                  : "📷 Point the camera at a currency note",
              key: ValueKey(result),
              style: TextStyle(
                fontSize: result.isNotEmpty ? 28 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          if (result.isNotEmpty)
            Text(
              "Confidence: ${confidence.toStringAsFixed(1)}%",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    ),
  ),
),

 ],
            ),
    );
  }
}
