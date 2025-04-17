// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite/tflite.dart';
// class CurrencyRecognitionPage extends StatefulWidget {
//   const CurrencyRecognitionPage({super.key});
//   @override
//   _CurrencyRecognitionPageState createState() => _CurrencyRecognitionPageState();
// }

// class _CurrencyRecognitionPageState extends State<CurrencyRecognitionPage> {
//   File? _image;
//   String _result = "";

//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//   }

//   Future loadModel() async {
//     String? res = await Tflite.loadModel(
//       model: "assets/best_float32.tflite",
//       labels: "assets/labels.txt",
//     );
//     print("Model loading result: $res");
//   }

//   Future predictCurrency(File image) async {
//     var recognitions = await Tflite.runModelOnImage(
//       path: image.path,
//       imageMean: 127.5,
//       imageStd: 127.5,
//       numResults: 1,
//       threshold: 0.5,
//     );
//     setState(() {
//       _result = recognitions != null && recognitions.isNotEmpty
//           ? recognitions[0]["label"]
//           : "Could not recognize currency";
//     });
//   }

//   Future pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);
//     if (pickedFile != null) {
//       File image = File(pickedFile.path);
//       setState(() => _image = image);
//       await predictCurrency(image);
//     }
//   }

//   @override
//   void dispose() {
//     Tflite.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Currency Recognition")),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _image != null
//               ? Image.file(_image!, height: 250)
//               : Icon(Icons.camera_alt, size: 100),
//           SizedBox(height: 20),
//           Text(_result, style: TextStyle(fontSize: 22)),
//           SizedBox(height: 20),
//           ElevatedButton(
//               onPressed: () => pickImage(ImageSource.camera),
//               child: Text("Capture Image")),
//           ElevatedButton(
//               onPressed: () => pickImage(ImageSource.gallery),
//               child: Text("Select from Gallery")),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite/tflite.dart';
// import 'dart:io';

// class CurrencyRecognitionPage extends StatefulWidget {
//   const CurrencyRecognitionPage({Key? key}) : super(key: key);

//   @override
//   State<CurrencyRecognitionPage> createState() => _CurrencyRecognitionPageState();
// }

// class _CurrencyRecognitionPageState extends State<CurrencyRecognitionPage> {
//   File? _image;
//   String _result = "No result";

//   @override
//   void initState() {
//     super.initState();
//     _loadModel();
//   }

//   Future<void> _loadModel() async {
//     String? res = await Tflite.loadModel(
//       model: "assets/currency_model.tflite",
//       labels: "assets/labels.txt",
//     );
//     print("Model loaded: $res");
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (pickedFile == null) return;

//     setState(() {
//       _image = File(pickedFile.path);
//     });

//     await _classifyImage(_image!);
//   }

//   Future<void> _classifyImage(File image) async {
//     var output = await Tflite.runModelOnImage(
//       path: image.path,
//       imageMean: 127.5,
//       imageStd: 127.5,
//       numResults: 1,
//       threshold: 0.5,
//     );

//     setState(() {
//       _result = output != null && output.isNotEmpty
//           ? "${output[0]["label"]} - ${(output[0]["confidence"] * 100).toStringAsFixed(2)}%"
//           : "Could not recognize currency";
//     });
//   }

//   @override
//   void dispose() {
//     Tflite.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Currency Recognition"),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _image != null
//                 ? Image.file(_image!, height: 200)
//                 : const Text("No image selected"),
//             const SizedBox(height: 20),
//             Text(
//               _result,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.camera_alt),
//               label: const Text("Capture Image"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//             ),
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
//     final request = http.MultipartRequest(
//       "POST",
//       Uri.parse("http://192.168.205.138:5000/recognize"), // <-- Replace with your Flask IP
//     );
//     request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//     final response = await request.send();

//     if (response.statusCode == 200) {
//       final responseData = await response.stream.bytesToString();
//       final data = json.decode(responseData);

//       setState(() {
//         result = data['currency'] ?? "Unknown";
//         confidence = data['confidence'] ?? 0.0;
//       });

//       await flutterTts.speak("Detected currency is $result with ${confidence.toStringAsFixed(0)} percent confidence.");
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


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CurrencyRecognitionPage extends StatefulWidget {
  const CurrencyRecognitionPage({super.key});

  @override
  State<CurrencyRecognitionPage> createState() => _CurrencyRecognitionPageState();
}

class _CurrencyRecognitionPageState extends State<CurrencyRecognitionPage> {
  File? _image;
  String result = "";
  double confidence = 0.0;
  final FlutterTts flutterTts = FlutterTts();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        result = "";
        confidence = 0.0;
      });
      await recognizeCurrency(_image!);
    }
  }

  Future<void> recognizeCurrency(File imageFile) async {
    final apiKey = "AZkWitHZ7tFt8yHbaPks"; // 🔁 Replace with your Roboflow API Key
    final projectName = "currency-detection-cgpjn"; // 🔁 Replace with your Roboflow Project Name
    final modelVersion = "2"; // 🔁 Replace with model version, e.g., "1"

    final url = Uri.parse("https://detect.roboflow.com/currency-detection-cgpjn/2?api_key=AZkWitHZ7tFt8yHbaPks");

    final request = http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    request.fields['confidence'] = '40'; // Optional confidence filter
    request.fields['overlap'] = '30';    // Optional overlap setting

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (data['predictions'] != null && data['predictions'].isNotEmpty) {
        final topPrediction = data['predictions'][0];

        setState(() {
          result = topPrediction['class'];
          confidence = (topPrediction['confidence'] as num) * 100;
        });

        await flutterTts.speak(
            "Detected currency is $result with ${confidence.toStringAsFixed(0)} percent confidence.");
      } else {
        setState(() {
          result = "No currency detected";
          confidence = 0.0;
        });
        await flutterTts.speak("No currency detected.");
      }
    } else {
      print("Currency recognition failed");
      await flutterTts.speak("Failed to recognize currency");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Currency Recognition")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (_image != null) Image.file(_image!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Capture Currency"),
            ),
            const SizedBox(height: 20),
            if (result.isNotEmpty)
              Text(
                "Result: $result\nConfidence: ${confidence.toStringAsFixed(2)}%",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
