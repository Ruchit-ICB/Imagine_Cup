import 'dart:math';
import '../models/data_models.dart';
import 'package:uuid/uuid.dart';

class MockAIService {
  final Uuid _uuid = const Uuid();

  Future<HealthAssessment> analyzeSymptoms(List<String> symptoms, String additionalText) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simple keyword matching for mock logic
    bool hasSevere = symptoms.any((s) => s.toLowerCase().contains('chest pain') || s.toLowerCase().contains('high fever') || s.toLowerCase().contains('breathing'));
    bool hasModerate = symptoms.any((s) => s.toLowerCase().contains('cough') || s.toLowerCase().contains('headache') || s.toLowerCase().contains('stomach'));

    String condition = "Viral Infection";
    RiskLevel risk = RiskLevel.low;
    String recommendation = "Rest and hydration. Monitor temperature.";
    String description = "Based on your symptoms, it appears to be a mild viral infection.";
    String? referral;

    if (hasSevere || additionalText.toLowerCase().contains('severe')) {
      condition = "Potential Respiratory Infection / Cardiac Issue";
      risk = RiskLevel.high;
      description = "Symptoms suggest a potentially serious condition requiring medical attention.";
      recommendation = "Visit the nearest clinic immediately.";
      referral = "Community Health Center, Block A (2km away)";
    } else if (hasModerate) {
      condition = "Flu / Common Cold";
      risk = RiskLevel.medium;
      description = "Symptoms are consistent with seasonal flu.";
      recommendation = "Take paracetamol if fever persists. Consult a health worker if symptoms worsen.";
      referral = "Village Health Worker: Mrs. Sharma (+91-9876543210)";
    } else {
      if (symptoms.contains('Skin Rash')) {
         condition = "Allergic Reaction";
         risk = RiskLevel.low;
         description = "Likely a mild allergy or insect bite.";
         recommendation = "Apply soothing cream. Avoid scratching.";
      }
    }

    return HealthAssessment(
      id: _uuid.v4(),
      date: DateTime.now(),
      reportedSymptoms: symptoms,
      possibleCondition: condition,
      riskLevel: risk,
      description: description,
      recommendation: recommendation,
      referralLocation: referral,
    );
  }

  // Common symptoms for selection
  List<Symptom> getCommonSymptoms() {
    return [
      Symptom(id: '1', name: 'Fever'),
      Symptom(id: '2', name: 'Cough'),
      Symptom(id: '3', name: 'Headache'),
      Symptom(id: '4', name: 'Breathing Difficulty'),
      Symptom(id: '5', name: 'Stomach Pain'),
      Symptom(id: '6', name: 'Skin Rash'),
      Symptom(id: '7', name: 'Fatigue'),
      Symptom(id: '8', name: 'Chest Pain'),
    ];
  }
}
