import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';

class ApiService {
 static const String baseUrl = "http://192.168.144.138:8000"; // Ensure this is correct


  static Future<String> recognizeCurrency(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict_currency'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        filename: basename(image.path),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['currency'] ?? "No currency detected";
      } else {
        return "Error: Server returned ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
