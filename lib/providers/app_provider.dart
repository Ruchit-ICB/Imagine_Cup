import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/gemini_ai_service.dart';
import '../services/blockchain_service.dart';

class AppProvider with ChangeNotifier {
  final GeminiAIService _aiService = GeminiAIService();
  final BlockchainService _blockchain = BlockchainService();

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  List<HealthAssessment> _history = [];
  List<HealthAssessment> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastTransactionHash;
  String? get lastTransactionHash => _lastTransactionHash;

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

  Future<HealthAssessment?> submitAssessment({
    required List<Symptom> selectedSymptoms, 
    required String otherSymptoms,
    Uint8List? imageBytes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> symptomNames = selectedSymptoms.map((s) => s.name).toList();
      
      HealthAssessment result = await _aiService.analyzeSymptoms(
        symptoms: symptomNames,
        additionalText: otherSymptoms,
        imageBytes: imageBytes,
        language: _currentUser?.language ?? 'English',
      );

      // Secure the record on the blockchain
      _lastTransactionHash = await _blockchain.recordAssessment(result);
      
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
