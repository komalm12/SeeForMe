

// Importing Flutter material design package for UI components
import 'package:flutter/material.dart';

// Importing image_picker to capture image from camera
import 'package:image_picker/image_picker.dart';

// Dart core library for working with files
import 'dart:io';

// Flutter package for text-to-speech functionality
import 'package:flutter_tts/flutter_tts.dart';

// ML Kit package for text recognition (OCR)
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// StatefulWidget to create a dynamic document scanner screen
class DocumentScanner extends StatefulWidget {
  const DocumentScanner({super.key});

  @override
  State<DocumentScanner> createState() => _DocumentScannerState();
}

// State class for DocumentScanner widget
class _DocumentScannerState extends State<DocumentScanner> {
  File? _image; // Holds the captured image file
  String _extractedText = ""; // Holds the extracted text from the image
  final FlutterTts _flutterTts = FlutterTts(); // TTS instance for speech

  @override
  void initState() {
    super.initState();
    // Speak instruction on screen load
    _flutterTts.speak("Ready to scan. Double tap anywhere to capture the document.");
  }

  // Function to capture image and extract text from it
  Future<void> _captureAndScan() async {
    // Speak instruction for using the camera
    await _flutterTts.speak(
      "Camera opened. Center the document. Tap the bottom of your screen to capture."
    );

    final picker = ImagePicker(); // Create an instance of ImagePicker

    // Pick an image from the camera
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // If user captured an image
      File imageFile = File(pickedFile.path); // Convert picked file to File

      // Create InputImage object required by ML Kit
      final inputImage = InputImage.fromFile(imageFile);

      // Initialize the text recognizer (for Latin script)
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      // Process the image to extract text
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // Update UI state with image and extracted text
      setState(() {
        _image = imageFile;
        _extractedText = recognizedText.text;
      });

      // Speak confirmation and read extracted text aloud
      await _flutterTts.speak("Text scanned. Reading now.");
      await _flutterTts.speak(_extractedText);
    } else {
      // If user didn't capture an image
      await _flutterTts.speak("No image captured. Please try again.");
    }
  }

  @override
  void dispose() {
    _flutterTts.stop(); // Stop TTS when screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTap: _captureAndScan, // Double tap anywhere triggers document scan
        child: Container(
          color: Colors.black, // Background color
          padding: const EdgeInsets.all(16), // Padding around content
          alignment: Alignment.center, // Center content
          child: _extractedText.isEmpty
              // If no text extracted yet, show instruction
              ? const Text(
                  "Double tap anywhere to capture the document.",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                )
              // If text is available, display it scrollably
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

