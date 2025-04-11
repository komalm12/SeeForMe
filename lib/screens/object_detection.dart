import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ObjectDetectionPage extends StatefulWidget {
  @override
  _ObjectDetectionPageState createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  File? _image;
  List detections = [];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        detections.clear();
      });
      await detectObjects(File(pickedFile.path));
    }
  }

  Future<void> detectObjects(File imageFile) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("http://192.168.1.7:5000/detect"), // Replace with your Flask server IP
    );
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      setState(() {
        detections = data['detections'];
      });
    } else {
      print("Detection failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Object Detection")),
      body: Column(
        children: [
          if (_image != null) Image.file(_image!),
          ElevatedButton(onPressed: pickImage, child: Text("Capture Image")),
          ...detections.map((d) => Text("${d['label']} - ${d['confidence'].toStringAsFixed(2)}"))
        ],
      ),
    );
  }
}
