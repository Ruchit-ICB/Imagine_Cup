import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/gemini_ai_service.dart';

class AppProvider with ChangeNotifier {
  final GeminiAIService _aiService = GeminiAIService();

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  List<HealthAssessment> _history = [];
  List<HealthAssessment> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Login
  void login(String name, String language) {
    _currentUser = UserProfile(
      id: "u123",
      name: name.isEmpty ? "Guest" : name,
      age: 0,
      gender: "",
      language: language,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _history.clear();
    notifyListeners();
  }

  List<Symptom> getSymptoms() {
    return _aiService.getCommonSymptoms();
  }

  Future<HealthAssessment?> submitAssessment(List<Symptom> selectedSymptoms, String otherSymptoms) async {
    if (selectedSymptoms.isEmpty && otherSymptoms.isEmpty) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<String> symptomNames = selectedSymptoms.map((s) => s.name).toList();
      
      // Add additional text as a symptom if provided
      if (otherSymptoms.isNotEmpty) {
        symptomNames.add(otherSymptoms);
      }
      
      HealthAssessment result = await _aiService.analyzeSymptoms(symptomNames, otherSymptoms);
      _history.insert(0, result);
      return result;
    } catch (e) {
      debugPrint("Error in assessment: $e");
      _errorMessage = "Failed to analyze symptoms. Please try again.";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
