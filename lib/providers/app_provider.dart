import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import '../api/api_service.dart'; 
import 'package:file_picker/file_picker.dart';
import '../models/quiz_question.dart';

class AppProvider extends ChangeNotifier {
  final ApiService apiService;
  dynamic uploadedFile;
  String? uploadedFilename;
  bool isLoading = false;
  String? summary;
  List<QuizQuestion>? quizQuestions;
  List<String?> userAnswers = [];
  int score = 0;
  String? errorMessage;
  List<int> timePerQuestion = [];

  AppProvider(this.apiService);

  void _clearError() {
    if (errorMessage != null) {
      errorMessage = null;
    }
  }

  Future<void> pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      isLoading = true;
      _clearError();
      notifyListeners();

      PlatformFile file = result.files.first;
      dynamic fileData = kIsWeb ? file.bytes : File(file.path!);
      final (error, filename) = await apiService.uploadPdf(fileData, file.name);

      if (error != null) {
        errorMessage = error;
        uploadedFilename = null;
        uploadedFile = null;
      } else {
        uploadedFilename = filename;
        uploadedFile = fileData;
      }

      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSummary(Function(String) onSummaryReady) async {
    if (uploadedFilename == null) return;
    isLoading = true;
    _clearError();
    notifyListeners();
    
    final (error, summaryData) = await apiService.generateSummary(uploadedFilename!);
    
    if (error != null) {
      errorMessage = error;
      summary = null;
    } else {
      summary = summaryData;
      onSummaryReady(summary!);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchQuiz(int numQuestions, Function(List<QuizQuestion>) onQuizReady) async {
    if (uploadedFilename == null) return;
    isLoading = true;
    _clearError();
    notifyListeners();

    final (error, questionsData) = await apiService.generateQuiz(uploadedFilename!, numQuestions);
    
    if (error != null) {
      errorMessage = error;
      quizQuestions = null;
    } else {
      quizQuestions = questionsData?.map((q) => QuizQuestion.fromJson(q)).toList();
      if (quizQuestions != null && quizQuestions!.isNotEmpty) {
        userAnswers = List.filled(quizQuestions!.length, null);
        timePerQuestion = List.filled(quizQuestions!.length, 0);
        score = 0;
        onQuizReady(quizQuestions!);
      }
    }

    isLoading = false;
    notifyListeners();
  }
  
  void submitAnswer(int questionIndex, String answer) {
    if (questionIndex < userAnswers.length) {
      userAnswers[questionIndex] = answer;
      notifyListeners();
    }
  }

  void calculateScore() {
    score = 0;
    for (int i = 0; i < quizQuestions!.length; i++) {
      if (quizQuestions![i].answer == userAnswers[i]) {
        score++;
      }
    }
    notifyListeners();
  }
  
  void resetQuiz() {
    quizQuestions = null;
    userAnswers = [];
    score = 0;
    timePerQuestion = [];
  }
}