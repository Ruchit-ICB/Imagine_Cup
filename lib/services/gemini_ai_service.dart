import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/data_models.dart';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyB3BcqurFOtSHFKkvKCZ9EN7P3l1SLycUs';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  final Uuid _uuid = const Uuid();

  Future<HealthAssessment> analyzeSymptoms({
    required List<String> symptoms, 
    required String additionalText,
    Uint8List? imageBytes,
    String language = 'English',
  }) async {
    final prompt = _buildAgenticPrompt(symptoms, additionalText, language);
    
    final List<Map<String, dynamic>> parts = [{'text': prompt}];

    if (imageBytes != null) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(imageBytes)
        }
      });
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': parts}],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 2048,
          },
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseAgenticResponse(data, symptoms);
      } else {
        return _fallbackAssessment(symptoms, "Service busy. Providing generalized guidance.");
      }
    } catch (e) {
      return _fallbackAssessment(symptoms, "Connection error. Providing local guidance.");
    }
  }

  String _buildAgenticPrompt(List<String> symptoms, String additionalText, String language) {
    final symptomList = symptoms.isNotEmpty ? symptoms.join(', ') : 'None specified';
    return '''
Act as MediConnect Premium Health Agent. 
Input: Symptoms ($symptomList), Patient Description ($additionalText).
Language: $language.

CRITICAL TASK:
1. Analyze symptoms and any provided image (Computer Vision).
2. Provide a DETAILED medical assessment.
3. Be specific with medicines, home remedies, and warning signs.

OUTPUT ONLY VALID JSON (no markdown, no extra text):
{
  "condition": "Condition Name",
  "risk": "low" | "medium" | "high",
  "description": "DETAILED analysis including findings from the image if provided. Explain WHY this might be happening.",
  "actionPlan": "Clear, step-by-step guidance on what the patient should do right now.",
  "medicines": [
    {
      "name": "Medicine Name",
      "dosage": "e.g. 500mg",
      "freq": "e.g. Twice a day",
      "notes": "e.g. After meals"
    }
  ],
  "homeRemedies": [" Remedy 1 with details", "Remedy 2 with details"],
  "warningSigns": ["Specific sign 1 - Seek help immediately if this happens", "Specific sign 2"],
  "referral": {
    "name": "Name of Specific Hospital/Clinic in Delhi NCR area",
    "lat": 28.6139,
    "lng": 77.2090
  }
}
''';
  }

  HealthAssessment _parseAgenticResponse(Map<String, dynamic> apiResponse, List<String> symptoms) {
    try {
      String text = apiResponse['candidates'][0]['content']['parts'][0]['text'];
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart != -1) text = text.substring(jsonStart, jsonEnd + 1);
      final json = jsonDecode(text);
      
      String riskStr = json['risk']?.toString().toLowerCase() ?? 'low';
      RiskLevel riskLevel = riskStr.contains('high') ? RiskLevel.high : (riskStr.contains('medium') ? RiskLevel.medium : RiskLevel.low);
      
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: json['condition'] ?? 'Health Assessment',
        riskLevel: riskLevel,
        description: json['description'] ?? 'Analysis complete based on symptoms.',
        recommendation: json['actionPlan'] ?? 'Please follow care guidelines.',
        suggestedMedicines: (json['medicines'] as List? ?? []).map((m) => Medicine(
          name: m['name'] ?? '',
          dosage: m['dosage'] ?? '',
          frequency: m['freq'] ?? '',
          notes: m['notes'],
        )).toList(),
        homeRemedies: List<String>.from(json['homeRemedies'] ?? []),
        warningSignsToWatch: List<String>.from(json['warningSigns'] ?? []),
        referralLocation: json['referral']?['name'] ?? "Local Health Center",
        latitude: json['referral']?['lat'] ?? 28.6139,
        longitude: json['referral']?['lng'] ?? 77.2090,
      );
    } catch (e) {
      return _fallbackAssessment(symptoms, "Parsing error. Providing safety-first guidance.");
    }
  }

  HealthAssessment _fallbackAssessment(List<String> symptoms, String status) {
    return HealthAssessment(
      id: "err_${DateTime.now().millisecondsSinceEpoch}",
      date: DateTime.now(),
      reportedSymptoms: symptoms,
      possibleCondition: "Health Review",
      riskLevel: RiskLevel.low,
      description: "$status. Based on fever/cough symptoms, you might have a common viral infection.",
      recommendation: "Stay hydrated, take adequate rest, and monitor your temperature.",
      suggestedMedicines: [Medicine(name: "Paracetamol", dosage: "500mg", frequency: "As needed", notes: "Consult a doctor for dosage")],
      homeRemedies: ["Drink warm fluids", "Steam inhalation", "Honey and ginger for cough"],
      warningSignsToWatch: ["Difficulty breathing", "Persistent high fever > 103F", "Severe chest pain"],
      latitude: 28.6139,
      longitude: 77.2090,
      referralLocation: "Primary Health Center",
    );
  }

  List<Symptom> getCommonSymptoms() => [
    Symptom(id: '1', name: 'Fever'), Symptom(id: '2', name: 'Cough'), 
    Symptom(id: '3', name: 'Headache'), Symptom(id: '4', name: 'Skin Rash'),
    Symptom(id: '5', name: 'Stomach Pain'), Symptom(id: '6', name: 'Nausea'),
  ];
}
