import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- THE FIX IS HERE
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // --- NEW: For Bookmarks ---
  Map<String, List<QuizQuestion>> bookmarkedQuestions = {};

  AppProvider(this.apiService) {
    loadState();
  }

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
    notifyListeners(); // Important to notify listeners after resetting
  }

  // --- NEW: Bookmark Methods ---

  bool isBookmarked(String pdfName, QuizQuestion question) {
    if (!bookmarkedQuestions.containsKey(pdfName)) {
      return false;
    }
    return bookmarkedQuestions[pdfName]!
        .any((q) => q.question == question.question);
  }

  void toggleBookmark(String pdfName, QuizQuestion question) {
    if (isBookmarked(pdfName, question)) {
      // Remove it
      bookmarkedQuestions[pdfName]!
          .removeWhere((q) => q.question == question.question);
      if (bookmarkedQuestions[pdfName]!.isEmpty) {
        bookmarkedQuestions.remove(pdfName);
      }
    } else {
      // Add it
      if (!bookmarkedQuestions.containsKey(pdfName)) {
        bookmarkedQuestions[pdfName] = [];
      }
      bookmarkedQuestions[pdfName]!.add(question);
    }
    notifyListeners(); // This will trigger saveState
  }

  // --- END: Bookmark Methods ---

  // Method to save the entire app state
  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uploadedFilename', uploadedFilename ?? '');
    await prefs.setString('summary', summary ?? '');
    
    if (quizQuestions != null) {
      await prefs.setString('quizQuestions',
          json.encode(quizQuestions!.map((q) => q.toJson()).toList()));
    } else {
      await prefs.remove('quizQuestions');
    }

    // --- NEW: Save Bookmarks ---
    // Serialize the map into Map<String, List<Map<String, dynamic>>>
    final serializableBookmarks = bookmarkedQuestions.map(
      (pdfName, questions) => MapEntry(
        pdfName,
        questions.map((q) => q.toJson()).toList(),
      ),
    );
    await prefs.setString(
        'bookmarkedQuestionsMap', json.encode(serializableBookmarks));
  }

  // Method to load the app state
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    uploadedFilename = prefs.getString('uploadedFilename');
    summary = prefs.getString('summary');
    final quizQuestionsString = prefs.getString('quizQuestions');

    if (quizQuestionsString != null && quizQuestionsString.isNotEmpty) {
      final decodedQuestions =
          json.decode(quizQuestionsString) as List<dynamic>;
      quizQuestions =
          decodedQuestions.map((q) => QuizQuestion.fromJson(q)).toList();
    }

    // --- NEW: Load Bookmarks ---
    final bookmarksString = prefs.getString('bookmarkedQuestionsMap');
    if (bookmarksString != null && bookmarksString.isNotEmpty) {
      final decodedBookmarks =
          json.decode(bookmarksString) as Map<String, dynamic>;
      
      bookmarkedQuestions = decodedBookmarks.map(
        (pdfName, questionsList) => MapEntry(
          pdfName,
          (questionsList as List<dynamic>)
              .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList(),
        ),
      );
    }
    // --- END: Load Bookmarks ---

    notifyListeners();
  }

  // Override notifyListeners to save state on every change
  @override
  void notifyListeners() {
    super.notifyListeners();
    saveState();
  }
}