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
