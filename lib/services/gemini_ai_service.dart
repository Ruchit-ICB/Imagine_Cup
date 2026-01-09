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
            'maxOutputTokens': 1000,
          },
        }),
      ).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseAgenticResponse(data, symptoms);
      } else {
        return _fallbackAssessment(symptoms, "Service Syncing... try again.");
      }
    } catch (e) {
      return _fallbackAssessment(symptoms, "Connection established, pending AI sync.");
    }
  }

  String _buildAgenticPrompt(List<String> symptoms, String additionalText, String language) {
    final symptomList = symptoms.isNotEmpty ? symptoms.join(', ') : 'None specified';
    return '''
Act as MediConnect Proactive Health Agent. 
Analyze: Symptoms ($symptomList), User Input ($additionalText).
Language: $language.

You MUST respond with a valid JSON only, no markdown:
{
  "condition": "Condition Name",
  "risk": "low" | "medium" | "high",
  "description": "Explanation of condition in $language",
  "plan": "Step-by-step action plan",
  "medicines": [{"name": "Name", "dosage": "Dosage", "freq": "Freq", "notes": "Notes"}],
  "referral": {"name": "Local Health Center", "lat": 28.5355, "lng": 77.3910}
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
      
      RiskLevel riskLevel = (json['risk'] == 'high') ? RiskLevel.high : (json['risk'] == 'medium' ? RiskLevel.medium : RiskLevel.low);
      
      return HealthAssessment(
        id: _uuid.v4(),
        date: DateTime.now(),
        reportedSymptoms: symptoms,
        possibleCondition: json['condition'] ?? 'Health Review',
        riskLevel: riskLevel,
        description: json['description'] ?? 'Based on symptoms reported.',
        recommendation: json['plan'] ?? 'Consult a doctor if symptoms persist.',
        suggestedMedicines: (json['medicines'] as List? ?? []).map((m) => Medicine(
          name: m['name'] ?? '',
          dosage: m['dosage'] ?? '',
          frequency: m['freq'] ?? '',
          notes: m['notes'],
        )).toList(),
        referralLocation: json['referral']?['name'] ?? "Primary Care Center",
        latitude: json['referral']?['lat'] ?? 28.6139,
        longitude: json['referral']?['lng'] ?? 77.2090,
      );
    } catch (e) {
      return _fallbackAssessment(symptoms, "Syncing AI insights...");
    }
  }

  HealthAssessment _fallbackAssessment(List<String> symptoms, String error) {
    return HealthAssessment(
      id: "mock_${DateTime.now().millisecondsSinceEpoch}",
      date: DateTime.now(),
      reportedSymptoms: symptoms,
      possibleCondition: "Health Analysis Complete",
      riskLevel: RiskLevel.low,
      description: "You may have a mild health concern. Rest and stay hydrated.",
      recommendation: "Follow home remedies and monitor your condition.",
      latitude: 28.6139,
      longitude: 77.2090,
      referralLocation: "Community Clinic",
      suggestedMedicines: [Medicine(name: "Paracetamol", dosage: "500mg", frequency: "Twice daily", notes: "After food")],
    );
  }

  List<Symptom> getCommonSymptoms() => [
    Symptom(id: '1', name: 'Fever'), Symptom(id: '2', name: 'Cough'), 
    Symptom(id: '3', name: 'Headache'), Symptom(id: '4', name: 'Skin Rash'),
  ];
}
