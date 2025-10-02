import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

typedef ApiResponse<T> = (String? error, T? data);

class ApiService {
  static const String _baseUrl = 'https://insighted.onrender.com';

  Future<ApiResponse<String>> uploadPdf(dynamic file, String? filename) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload/'),
      );

      if (kIsWeb && file is Uint8List) {
        request.files.add(http.MultipartFile.fromBytes('file', file,
            filename: filename ?? 'upload.pdf',
            contentType: MediaType('application', 'pdf')));
      } else if (!kIsWeb && file is File) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path,
            contentType: MediaType('application', 'pdf')));
      } else {
        return ('Unsupported file type', null);
      }

      var response = await request.send(); 
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decodedData = json.decode(responseBody)['filename'] as String;
        return (null, decodedData);
      } else {
        return ('Server Error ${response.statusCode}: $responseBody', null);
      }
    } on SocketException {
      return ('Network Error: Could not connect to the server. Is it running?', null);
    } catch (e) {
      return ('An unexpected error occurred: $e', null);
    }
  }

  Future<ApiResponse<String>> generateSummary(String filename) async {
    try {
      final response = await http.post( 
        Uri.parse('$_baseUrl/generate/summary/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'filename': filename}),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body)['summary'] as String;
        return (null, decodedData);
      } else {
        return ('Server Error ${response.statusCode}: ${response.body}', null);
      }
    } on SocketException {
       return ('Network Error: Could not connect to the server.', null);
    } catch (e) {
      return ('An unexpected error occurred: $e', null);
    }
  }

  Future<ApiResponse<List<dynamic>>> generateQuiz(String filename, int num) async {
    try {
      final response = await http.post( // Removed .timeout()
        Uri.parse('$_baseUrl/generate/quiz/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'filename': filename, 'num': num}),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body)['questions'] as List<dynamic>;
        return (null, decodedData);
      } else {
        return ('Server Error ${response.statusCode}: ${response.body}', null);
      }
    } on SocketException {
      return ('Network Error: Could not connect to the server.', null);
    } catch (e) {
      return ('An unexpected error occurred: $e', null);
    }
  }
}