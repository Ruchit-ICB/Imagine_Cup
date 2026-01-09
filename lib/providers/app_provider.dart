import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/mock_ai_service.dart';

class AppProvider with ChangeNotifier {
  final MockAIService _aiService = MockAIService();

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  List<HealthAssessment> _history = [];
  List<HealthAssessment> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Login (Mock)
  void login(String name, String language) {
    _currentUser = UserProfile(
      id: "u123",
      name: name.isEmpty ? "Guest" : name,
      age: 45,
      gender: "Male",
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
    notifyListeners();

    try {
      List<String> symptomNames = selectedSymptoms.map((s) => s.name).toList();
      HealthAssessment result = await _aiService.analyzeSymptoms(symptomNames, otherSymptoms);
      _history.insert(0, result);
      return result;
    } catch (e) {
      debugPrint("Error in assessment: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
