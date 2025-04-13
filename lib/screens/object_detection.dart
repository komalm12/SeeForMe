import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class LiveObjectDetectionPage extends StatefulWidget {
  @override
  _LiveObjectDetectionPageState createState() => _LiveObjectDetectionPageState();
}

class _LiveObjectDetectionPageState extends State<LiveObjectDetectionPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isDetecting = false;
  List detections = [];
  Timer? _timer;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});

    _timer = Timer.periodic(Duration(seconds: 3), (_) => captureAndDetect());
  }

  Future<void> captureAndDetect() async {
    if (_cameraController == null || _isDetecting) return;

    _isDetecting = true;
    try {
      final file = await _cameraController!.takePicture();
      File imageFile = File(file.path);
      final detected = await detectObjects(imageFile);

      if (detected.isNotEmpty) {
        setState(() {
          detections = detected;
        });

        // Process detections and speak them with distance
        for (var detection in detections) {
          String label = detection['label'];
          var distance = detection['distance'] ?? 'unknown';  // Handle unknown distances

          String distanceText = distance == 'unknown' 
            ? "$label detected" 
            : "$label detected at $distance centimeters";

          await flutterTts.speak(distanceText);
        }
      }
    } catch (e) {
      print("Error in detection: $e");
    } finally {
      _isDetecting = false;
    }
  }

  Future<List> detectObjects(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://192.168.1.7:5000/detect"), // Replace with your IP
      );
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        return data['detections'];  // Ensure your backend sends `distance` with detections
      }
    } catch (e) {
      print("Failed to send image: $e");
    }
    return [];
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text("Live Object Detection")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Live Object Detection")),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
          if (detections.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Detected: ${detections.map((d) => d['label']).join(', ')}",
                style: TextStyle(fontSize: 18),
              ),
            )
        ],
      ),
    );
  }
}
