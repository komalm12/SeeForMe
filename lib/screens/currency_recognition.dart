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
