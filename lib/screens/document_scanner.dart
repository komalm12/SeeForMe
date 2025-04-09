import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class DocumentScanner extends StatefulWidget {
  const DocumentScanner({super.key});

  @override
  State<DocumentScanner> createState() => _DocumentScannerState();
}

class _DocumentScannerState extends State<DocumentScanner> {
  File? _image;
  String _extractedText = "";
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _flutterTts.speak("Ready to scan. Double tap anywhere to capture the document.");
  }

  Future<void> _captureAndScan() async {
    await _flutterTts.speak(
  "Camera opened. Center the document. Tap the bottom of your screen to capture."
);
    final picker = ImagePicker();
     
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _image = imageFile;
        _extractedText = recognizedText.text;
      });

      await _flutterTts.speak("Text scanned. Reading now.");
      await _flutterTts.speak(_extractedText);
    } else {
      await _flutterTts.speak("No image captured. Please try again.");
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTap: _captureAndScan,
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: _extractedText.isEmpty
              ? const Text(
                  "Double tap anywhere to capture the document.",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                )
              : SingleChildScrollView(
                  child: Text(
                    _extractedText,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
        ),
      ),
    );
  }
}
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_tts/flutter_tts.dart';

// class DocumentScanner extends StatefulWidget {
//   const DocumentScanner({super.key});

//   @override
//   State<DocumentScanner> createState() => _DocumentScannerState();
// }

// class _DocumentScannerState extends State<DocumentScanner> {
//   File? _image;
//   String _extractedText = "";
//   bool _isProcessing = false;

//   final FlutterTts _flutterTts = FlutterTts();

//   Future<void> _pickImageAndScan() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);

//     if (pickedFile == null) return;

//     setState(() {
//       _isProcessing = true;
//       _image = File(pickedFile.path);
//       _extractedText = "";
//     });

//     // ✅ Your server IP here (change if needed)
//     final String serverIP = "192.168.1.2";
//     final uri = Uri.parse("http://$serverIP:5000/ocr");

//     final request = http.MultipartRequest('POST', uri);
//     request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

//     try {
//       final streamedResponse = await request.send();
//       final responseStr = await streamedResponse.stream.bytesToString();

//       if (streamedResponse.statusCode == 200) {
//         final data = json.decode(responseStr);
//         setState(() {
//           _extractedText = data['text'] ?? "No text found in image.";
//         });

//         await _flutterTts.setLanguage("en-US");
//         await _flutterTts.speak(_extractedText);
//       } else {
//         setState(() {
//           _extractedText =
//               "Server responded with error: ${streamedResponse.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _extractedText =
//             "Connection error: $e\n\nMake sure Flask is running and phone is on same Wi-Fi.";
//       });
//     }

//     setState(() {
//       _isProcessing = false;
//     });
//   }

//   @override
//   void dispose() {
//     _flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Document Scanner"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             ElevatedButton.icon(
//               onPressed: _pickImageAndScan,
//               icon: const Icon(Icons.camera_alt),
//               label: const Text("Capture & Read Document"),
//             ),
//             const SizedBox(height: 20),
//             if (_isProcessing)
//               const CircularProgressIndicator()
//             else ...[
//               if (_image != null) Image.file(_image!, height: 200),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Text(
//                     _extractedText,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }